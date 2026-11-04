import 'package:flutter/foundation.dart';
import 'package:luminous/core/network/config/env_keys.dart';
import 'package:luminous/core/network/config/env_reader.dart';

abstract final class LucentBaseUrl {
  static String get defineKey => EnvKey.lucentBaseUrl.wireName;

  /// Matches an already-qualified URL scheme (`http://`, `https://`, ...).
  static final RegExp _schemePattern = RegExp(r'^[a-zA-Z][a-zA-Z0-9+.\-]*://');

  /// Resolves a build- or user-supplied endpoint into a URL Dio can consume.
  ///
  /// `Dio`'s `BaseOptions` parses `baseUrl` with `Uri.parse`, which throws
  /// `FormatException: Scheme not starting with alphabetic character` for a
  /// scheme-less `host:port` value such as `122.9.102.50:3000` — and because
  /// that happens while the client provider is being built, the exception
  /// takes the whole provider graph down (red `ProviderException` screen)
  /// instead of surfacing as a normal request failure.
  ///
  /// So every endpoint that reaches Dio — compile-time define, stored
  /// developer setting, or typed input — goes through this normalization:
  ///
  /// - trims whitespace and one layer of matching quotes (copy/paste);
  /// - prepends `http://` when the scheme is omitted (`122.9.102.50:3000`);
  /// - only accepts `http` / `https` with a non-empty host;
  /// - drops trailing slashes so `get('/api/v1/...')` does not become
  ///   `//api/v1/...` (Dio concatenates the resolved paths).
  ///
  /// Returns `null` when [raw] is blank or cannot be turned into an http(s)
  /// URL; callers fall back to a known-good default instead of crashing.
  static String? normalize(String raw) {
    var value = raw.trim();
    if (value.length >= 2) {
      final quoted =
          (value.startsWith('"') && value.endsWith('"')) ||
          (value.startsWith("'") && value.endsWith("'"));
      if (quoted) {
        value = value.substring(1, value.length - 1).trim();
      }
    }
    if (value.isEmpty) return null;
    if (!_schemePattern.hasMatch(value)) value = 'http://$value';
    final uri = Uri.tryParse(value);
    if (uri == null) return null;
    if (uri.scheme != 'http' && uri.scheme != 'https') return null;
    if (uri.host.isEmpty) return null;

    var normalized = uri.toString();
    while (normalized.endsWith('/')) {
      normalized = normalized.substring(0, normalized.length - 1);
    }
    return normalized;
  }

  /// The base URL explicitly pinned by the build, normalized, or `null` when
  /// no `LUCENT_BASE_URL` was supplied (`--dart-define` /
  /// `--dart-define-from-file`) or the pinned value is not a usable http(s)
  /// URL.
  ///
  /// [value] always returns a non-empty string, so it cannot tell "the build
  /// pinned an endpoint" apart from "nobody configured anything, fall back to
  /// the platform default". Callers that need that distinction (the
  /// developer-settings default) must use this getter.
  static String? get configured {
    final raw = EnvReader.string(EnvKey.lucentBaseUrl);
    if (raw.trim().isEmpty) return null;
    final normalized = normalize(raw);
    if (normalized == null) {
      debugPrint(
        '[LucentBaseUrl] LUCENT_BASE_URL is not a usable http(s) URL: "$raw"',
      );
    }
    return normalized;
  }

  /// The `LUCENT_PROD_BASE_URL` pinned by the build, normalized, or `null`
  /// when unset/unusable.
  ///
  /// The deployed host address never lives in the repository (it would be
  /// published with the repo): it is injected at build time through `.env` /
  /// CI secrets and read back by the 「生产」developer preset. See
  /// `DeveloperSettingsState.resolvedBaseUrl`.
  static String? get productionConfigured =>
      _normalizedEnv(EnvKey.lucentProdBaseUrl, name: 'LUCENT_PROD_BASE_URL');

  /// Platform-local development server.
  ///
  /// On Android emulators `127.0.0.1` refers to the emulator itself, so the
  /// host loopback alias `10.0.2.2` is used instead.
  static String get fallback => defaultTargetPlatform == TargetPlatform.android
      ? 'http://10.0.2.2:3000'
      : 'http://127.0.0.1:3000';

  /// The base URL to use when no runtime override is stored: the pinned
  /// `LUCENT_BASE_URL` when it is usable, otherwise [fallback].
  ///
  /// This no longer throws in release builds. A release package that forgot to
  /// pin the endpoint stays usable (and the endpoint can be fixed at runtime
  /// through 设置 → 高级设置 → 开发者选项) instead of dying before the first
  /// frame with `StateError`.
  static String get value {
    final pinned = configured;
    if (pinned != null) return pinned;
    if (kReleaseMode) {
      debugPrint(
        '[LucentBaseUrl] release build without a usable LUCENT_BASE_URL; '
        'falling back to $fallback',
      );
    }
    return fallback;
  }

  static String? _normalizedEnv(EnvKey key, {required String name}) {
    final raw = EnvReader.string(key);
    if (raw.trim().isEmpty) return null;
    final normalized = normalize(raw);
    if (normalized == null) {
      debugPrint('[LucentBaseUrl] $name is not a usable http(s) URL: "$raw"');
    }
    return normalized;
  }
}
