import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/app/bootstrap.dart';
import 'package:luminous/core/config/env_keys.dart';
import 'package:luminous/core/config/env_reader.dart';
import 'package:luminous/core/network/api.dart';
import 'package:luminous/features/auth/presentation/providers/forms/login.dart';
import 'package:luminous/features/record/presentation/providers/dashboard.dart';
import 'package:luminous/features/shell/presentation/tab.dart';

import 'e2e_test_helpers.dart';

class FullstackE2eConfig {
  const FullstackE2eConfig({
    required this.baseUrl,
    required this.email,
    required this.password,
    required this.recordDate,
    this.nickname = 'E2E Record Lane',
  });

  static String get emailDefineKey => EnvKey.e2eTestEmail.wireName;
  static String get passwordDefineKey => EnvKey.e2eTestPassword.wireName;
  static String get recordDateDefineKey => EnvKey.e2eRecordDate.wireName;
  static String get nicknameDefineKey => EnvKey.e2eTestNickname.wireName;

  final String baseUrl;
  final String email;
  final String password;
  final String recordDate;
  final String nickname;

  static FullstackE2eConfig fromEnvironment() {
    final config = FullstackE2eConfig(
      baseUrl: EnvReader.string(
        EnvKey.e2eLucentBaseUrl,
        fallback: EnvReader.string(EnvKey.lucentBaseUrl),
      ),
      email: EnvReader.string(EnvKey.e2eTestEmail),
      password: EnvReader.string(EnvKey.e2eTestPassword),
      recordDate: EnvReader.string(
        EnvKey.e2eRecordDate,
        fallback: '2026-06-12',
      ),
      nickname: EnvReader.string(
        EnvKey.e2eTestNickname,
        fallback: 'E2E Record Lane',
      ),
    );
    config.assertUsable();
    return config;
  }

  void assertUsable() {
    final missing = <String>[
      if (baseUrl.trim().isEmpty) EnvKey.e2eLucentBaseUrl.wireName,
      if (email.trim().isEmpty) emailDefineKey,
      if (password.trim().isEmpty) passwordDefineKey,
    ];

    if (missing.isNotEmpty) {
      throw TestFailure(
        'Missing required dart-define(s): ${missing.join(', ')}',
      );
    }

    final normalizedBaseUrl = baseUrl.trim().toLowerCase();
    if (normalizedBaseUrl.contains('127.0.0.1') ||
        normalizedBaseUrl.contains('localhost')) {
      throw TestFailure(
        'Full-stack mobile E2E must use a host-reachable Lucent URL, not localhost/127.0.0.1. '
        'For Android emulator use --dart-define=${EnvKey.e2eLucentBaseUrl.wireName}=http://10.0.2.2:3000',
      );
    }
  }
}

class MemoryLucentSessionStore implements LucentSessionStore {
  LucentSessionTokens? _tokens;

  @override
  Future<void> clear() async {
    _tokens = null;
  }

  @override
  Future<LucentSessionTokens?> read() async => _tokens;

  @override
  Future<String?> readAccessToken() async => _tokens?.accessToken;

  @override
  Future<String?> readRefreshToken() async => _tokens?.refreshToken;

  @override
  Future<void> write(LucentSessionTokens tokens) async {
    _tokens = tokens;
  }
}

Future<void> prepareFullstackRecordLane(FullstackE2eConfig config) async {
  final dio = Dio(
    BaseOptions(
      baseUrl: config.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
    ),
  );

  try {
    DioException? lastError;

    for (var attempt = 1; attempt <= 3; attempt += 1) {
      try {
        final response = await dio.post<Map<String, dynamic>>(
          '/api/v1/testing/fullstack-e2e/record-lane/prepare',
          data: <String, String>{
            'email': config.email,
            'password': config.password,
            'date': config.recordDate,
            'nickname': config.nickname,
          },
        );

        final body = response.data;
        if (response.statusCode != 200 || body == null || body['code'] != 0) {
          throw TestFailure(
            'Lucent full-stack prepare failed with status ${response.statusCode}: ${body ?? '<empty>'}',
          );
        }
        return;
      } on DioException catch (error) {
        lastError = error;
        if (attempt == 3) {
          break;
        }
        await Future<void>.delayed(const Duration(seconds: 2));
      }
    }

    throw TestFailure(
      'Could not prepare Lucent full-stack record lane at ${config.baseUrl}: '
      '${lastError?.message ?? lastError?.error ?? lastError?.type.name ?? 'unknown dio error'}',
    );
  } finally {
    dio.close(force: true);
  }
}

Future<ProviderContainer> pumpFullstackApp(
  PatrolIntegrationTester $, {
  required FullstackE2eConfig config,
  MemoryLucentSessionStore? sessionStore,
}) async {
  SharedPreferences.setMockInitialValues(const <String, Object>{
    'app.locale': 'zh-CN',
  });
  router.go('/');

  final container = ProviderContainer(
    overrides: [
      lucentBaseUrlProvider.overrideWithValue(config.baseUrl),
      lucentSessionStoreProvider.overrideWithValue(
        sessionStore ?? MemoryLucentSessionStore(),
      ),
    ],
  );
  addTearDown(container.dispose);

  await $.pumpWidget(
    UncontrolledProviderScope(container: container, child: const LuminousApp()),
  );
  await settleE2e($, frames: 8);
  return container;
}

Future<void> signInThroughUi(
  PatrolIntegrationTester $, {
  required FullstackE2eConfig config,
}) async {
  await openLoginFromSignedOutMine($);
  await pumpUntilFound(
    $,
    find.byKey(const Key('auth-login-submit-action')),
    timeout: const Duration(seconds: 10),
  );

  await $.tester.enterText(
    _editableTextIn(const Key('auth-login-email-field')),
    config.email,
  );
  await settleE2e($, frames: 4);
  await $.tester.enterText(
    _editableTextIn(const ValueKey<String>('password-login-field')),
    config.password,
  );
  await settleE2e($, frames: 4);

  final submitButton = find.byKey(const Key('auth-login-submit-action'));
  await $.tester.ensureVisible(submitButton);
  await settleE2e($, frames: 4);
  await $.tester.tap(submitButton);
  await settleE2e($, frames: 12);
}

Future<void> waitForAuthenticatedSession(
  PatrolIntegrationTester $,
  ProviderContainer container, {
  Duration timeout = const Duration(seconds: 30),
  Duration step = const Duration(milliseconds: 100),
}) async {
  final endTime = $.tester.binding.clock.fromNowBy(timeout);

  do {
    await $.pump(step);
    if (container.read(authSessionProvider).isAuthenticated) {
      return;
    }
  } while ($.tester.binding.clock.now().isBefore(endTime));

  final state = container.read(authSessionProvider);
  final loginForm = container.read(loginFormProvider);
  throw TestFailure(
    'Timed out waiting for authenticated session. '
    'route=${router.routeInformationProvider.value.uri}, '
    'isLoading=${state.isLoading}, isAuthenticated=${state.isAuthenticated}, authError=${state.errorMessage}, '
    'loginSubmitting=${loginForm.isSubmitting}, loginError=${loginForm.errorMessage}',
  );
}

Future<void> waitForRoute(
  PatrolIntegrationTester $, {
  required bool Function(Uri uri) predicate,
  required String description,
  Duration timeout = const Duration(seconds: 15),
  Duration step = const Duration(milliseconds: 100),
}) async {
  final endTime = $.tester.binding.clock.fromNowBy(timeout);

  do {
    await $.pump(step);
    final currentRoute = router.routeInformationProvider.value.uri;
    if (predicate(currentRoute)) {
      return;
    }
  } while ($.tester.binding.clock.now().isBefore(endTime));

  throw TestFailure(
    'Timed out waiting for route: $description. '
    'currentRoute=${router.routeInformationProvider.value.uri}',
  );
}

DateTime parseRecordDate(String value) {
  final parsed = DateTime.tryParse(value);
  if (parsed == null) {
    throw TestFailure('Invalid E2E record date: $value');
  }
  return DateTime(parsed.year, parsed.month, parsed.day);
}

Future<void> openRecordTabForDate(
  PatrolIntegrationTester $,
  ProviderContainer container, {
  required DateTime targetDate,
}) async {
  await openShellTab($, ShellTab.record, timeout: const Duration(seconds: 15));
  await pumpUntilFound(
    $,
    find.byKey(const Key('record-timeline')),
    timeout: const Duration(seconds: 15),
  );

  while (!_isSameDate(container.read(selectedRecordDateProvider), targetDate)) {
    final current = container.read(selectedRecordDateProvider);
    final actionKey = current.isBefore(targetDate)
        ? const Key('record-date-next-action')
        : const Key('record-date-previous-action');
    await tapVisible($, find.byKey(actionKey));
    await _waitForRecordDate(
      $,
      container,
      targetDate: _stepDate(current, targetDate),
    );
  }
}

Future<void> _waitForRecordDate(
  PatrolIntegrationTester $,
  ProviderContainer container, {
  required DateTime targetDate,
  Duration timeout = const Duration(seconds: 10),
  Duration step = const Duration(milliseconds: 100),
}) async {
  final endTime = $.tester.binding.clock.fromNowBy(timeout);

  do {
    await $.pump(step);
    if (_isSameDate(container.read(selectedRecordDateProvider), targetDate)) {
      return;
    }
  } while ($.tester.binding.clock.now().isBefore(endTime));

  throw TestFailure(
    'Timed out waiting for record date ${targetDate.toIso8601String()}',
  );
}

Finder _editableTextIn(Key key) {
  return find.descendant(
    of: find.byKey(key),
    matching: find.byType(EditableText),
  );
}

bool _isSameDate(DateTime left, DateTime right) {
  return left.year == right.year &&
      left.month == right.month &&
      left.day == right.day;
}

DateTime _stepDate(DateTime current, DateTime target) {
  if (current.isBefore(target)) {
    return current.add(const Duration(days: 1));
  }
  return current.subtract(const Duration(days: 1));
}
