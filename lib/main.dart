import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/app/bootstrap.dart';
import 'package:luminous/app/window_manager_setup.dart';
import 'package:luminous/core/config/env_keys.dart';
import 'package:luminous/core/config/env_reader.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> main() async {
  // Keep binding initialization in the root zone so that a synchronous
  // failure during init crashes visibly instead of being silently swallowed.
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize desktop window management (no-op on web/mobile).
  await initDesktopWindow();

  await _initSentry();

  // Catch framework errors (sync errors in widget build / layout / paint).
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    Sentry.captureException(details.exception, stackTrace: details.stack);
  };

  // Catch uncaught async errors without creating a new zone — avoids
  // "Zone mismatch" between binding init and runApp.
  PlatformDispatcher.instance.onError = (error, stack) {
    Sentry.captureException(error, stackTrace: stack);
    return true;
  };

  runApp(const ProviderScope(child: LuminousApp()));
}

/// Initializes Sentry if a DSN is configured.
///
/// When the DSN is empty (e.g. debug builds without Sentry configured),
/// the entire [SentryFlutter.init] call is skipped to avoid any SDK
/// overhead. All [Sentry.captureException] calls are safe no-ops when
/// the SDK has not been initialized.
///
/// If the DSN is non-empty but invalid (e.g. a placeholder URL was
/// accidentally injected), the error is caught and logged so the app
/// can still start — Sentry simply won't be active.
Future<void> _initSentry() async {
  final dsn = EnvReader.string(EnvKey.sentryDsn);
  if (dsn.isEmpty) return;

  try {
    await SentryFlutter.init((options) {
      options.dsn = dsn;
      options.tracesSampleRate = kReleaseMode ? 0.2 : 1.0;
      options.attachStacktrace = true;
      options.sendDefaultPii = false;
    });
  } catch (e, st) {
    debugPrint(
      '⚠️ Sentry initialization failed (DSN invalid?), '
      'Sentry disabled for this session.\n  Error: $e\n  Stack: $st',
    );
  }
}
