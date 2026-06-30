import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/network/lucent_session_store.dart';
import 'package:luminous/features/auth/domain/entities/auth_session.dart';
import 'package:luminous/features/auth/presentation/providers/session/auth_session_provider.dart';

// ── Session Fakes ─────────────────────────────────────────────

/// In-memory implementation of [LucentSessionStore] for unit tests.
/// Use this instead of the SharedPreferences-backed store to avoid
/// platform channel dependencies.
///
/// Set [delay] to a non-zero duration to simulate network latency
/// and allow loading states to be tested.
class MemorySessionStore implements LucentSessionStore {
  MemorySessionStore({this.delay = Duration.zero});

  /// Simulated network delay. Defaults to [Duration.zero].
  final Duration delay;

  LucentSessionTokens? tokens;

  Future<void> _wait() async {
    if (delay != Duration.zero) await Future.delayed(delay);
  }

  @override
  Future<LucentSessionTokens?> read() async {
    await _wait();
    return tokens;
  }

  @override
  Future<String?> readAccessToken() async {
    await _wait();
    return tokens?.accessToken;
  }

  @override
  Future<String?> readRefreshToken() async {
    await _wait();
    return tokens?.refreshToken;
  }

  @override
  Future<void> write(LucentSessionTokens tokens) async {
    await _wait();
    this.tokens = LucentSessionTokens(
      accessToken: tokens.accessToken.trim(),
      refreshToken: tokens.refreshToken.trim(),
    );
  }

  @override
  Future<void> clear() async {
    await _wait();
    tokens = null;
  }
}

// ── Auth Session Fakes ────────────────────────────────────────

/// A pre-authenticated [AuthSessionNotifier] for tests that require
/// a signed-in user.
class SignedInAuthSessionNotifier extends AuthSessionNotifier {
  SignedInAuthSessionNotifier({
    this.id = 'user-1',
    this.email = 'test@example.com',
    this.nickname = 'Lumi',
  });

  final String id;
  final String email;
  final String nickname;

  @override
  AuthSessionState build() {
    return AuthSessionState(
      isAuthenticated: true,
      isLoading: false,
      user: AuthUser(
        id: id,
        email: email,
        nickname: nickname,
        avatar: null,
        emailVerifiedAt: DateTime(2026, 1, 1),
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      ),
    );
  }
}

/// A signed-out [AuthSessionNotifier] for tests that require
/// an unauthenticated state.
class SignedOutAuthSessionNotifier extends AuthSessionNotifier {
  @override
  AuthSessionState build() {
    return const AuthSessionState(isAuthenticated: false, isLoading: false);
  }
}

// ── HttpClientAdapter Fake ────────────────────────────────────

/// A configurable [HttpClientAdapter] that captures the latest request
/// and returns canned responses. Useful for testing Dio interceptor
/// behavior without a real server.
class CaptureAdapter implements HttpClientAdapter {
  CaptureAdapter({
    this.statusCode = 200,
    this.responseData,
    this.responseHeaders,
  });

  int statusCode;
  Object? responseData;
  Map<String, List<String>>? responseHeaders;

  RequestOptions? capturedRequest;
  int callCount = 0;

  /// Optional second-call override: when set, the second fetch() call
  /// uses these values instead. Useful for testing retry flows.
  int? secondCallStatusCode;
  Object? secondCallResponseData;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    capturedRequest = options;
    callCount += 1;

    final isSecondCall = callCount >= 2 && secondCallStatusCode != null;

    final int resolvedStatusCode = isSecondCall
        ? secondCallStatusCode!
        : statusCode;
    final Object? resolvedData = isSecondCall
        ? (secondCallResponseData ?? responseData)
        : responseData;

    final body = resolvedData != null
        ? utf8.encode(
            resolvedData is String ? resolvedData : jsonEncode(resolvedData),
          )
        : utf8.encode('');

    return ResponseBody(
      body.isNotEmpty ? Stream.fromIterable([body]) : const Stream.empty(),
      resolvedStatusCode,
      headers:
          responseHeaders ??
          {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
      statusMessage: isSecondCall
          ? 'OK (retry)'
          : (statusCode == 401 ? 'Unauthorized' : 'OK'),
    );
  }

  @override
  void close({bool force = false}) {}
}

// ── Screen Size Helpers ─────────────────────────────────────────

/// Sets the test device to a mobile screen size (iPhone 14-like: 390×844).
/// Resets automatically via [addTearDown].
void setMobileScreenSize(WidgetTester tester) {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = const Size(390, 844);
  addTearDown(() {
    tester.view.resetDevicePixelRatio();
    tester.view.resetPhysicalSize();
  });
}

/// Sets the test device to a desktop screen size (1440×1000).
/// Resets automatically via [addTearDown].
void setDesktopScreenSize(WidgetTester tester) {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = const Size(1440, 1000);
  addTearDown(() {
    tester.view.resetDevicePixelRatio();
    tester.view.resetPhysicalSize();
  });
}

/// Sets the test device to a tablet screen size (768×1024, iPad-like).
/// Resets automatically via [addTearDown].
void setTabletScreenSize(WidgetTester tester) {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = const Size(768, 1024);
  addTearDown(() {
    tester.view.resetDevicePixelRatio();
    tester.view.resetPhysicalSize();
  });
}
