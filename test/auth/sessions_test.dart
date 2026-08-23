import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/network/api_paths.dart';
import 'package:luminous/features/auth/data/providers/sessions.dart';
import 'package:luminous/features/auth/data/repositories/sessions.dart';
import 'package:luminous/features/auth/domain/entities/device_session.dart';
import 'package:luminous/features/auth/domain/repositories/sessions.dart';
import 'package:luminous/features/auth/presentation/pages/sessions.dart';
import 'package:luminous/features/auth/presentation/providers/sessions.dart';

import '../helpers/test_forui_app.dart';
import '../helpers/test_helpers.dart';

/// Resolves a repository task, returning the Right value and failing the
/// test when the repository reports a Left.
Future<T> _right<T>(TaskEither<LucentFailure, T> task) async {
  final result = await task.run();
  return result.fold(
    (failure) => fail('expected Right, got $failure'),
    (value) => value,
  );
}

void main() {
  final session = AuthDeviceSession(
    id: 'session-1',
    deviceType: 'desktop',
    deviceName: null,
    platform: 'web',
    lastUsedAt: DateTime.parse('2026-08-20T10:00:00Z'),
    createdAt: DateTime.parse('2026-08-19T10:00:00Z'),
    expiresAt: DateTime.parse('2026-09-18T10:00:00Z'),
    isCurrent: false,
  );

  test(
    'maps the direct session resource and sends revoke to the session path',
    () async {
      final adapter = CaptureAdapter(
        responseData: [
          {
            'id': 'session-1',
            'deviceType': 'desktop',
            'deviceName': null,
            'platform': 'web',
            'lastUsedAt': '2026-08-20T10:00:00Z',
            'createdAt': '2026-08-19T10:00:00Z',
            'expiresAt': '2026-09-18T10:00:00Z',
            'isCurrent': false,
          },
        ],
      );
      final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test'))
        ..httpClientAdapter = adapter;
      final repository = LucentAuthSessionsRepository(dio: dio);

      final mapped = await _right(repository.listSessions());
      expect(mapped, hasLength(1));
      expect(mapped.single.id, 'session-1');
      expect(mapped.single.platform, 'web');
      expect(adapter.capturedRequest?.path, LucentApiPaths.authSessions);
      expect(adapter.capturedRequest?.method, 'GET');

      adapter.responseData = null;
      await _right(repository.revokeSession('session-1'));
      expect(
        adapter.capturedRequest?.path,
        LucentApiPaths.authSession('session-1'),
      );
      expect(adapter.capturedRequest?.method, 'DELETE');
    },
  );

  test('refreshes the list after revoking a non-current session', () async {
    final repository = _FakeAuthSessionsRepository([session]);
    final container = ProviderContainer(
      overrides: [authSessionsRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    final loaded = await container.read(authSessionsControllerProvider.future);
    expect(loaded, [session]);

    await expectLater(
      container
          .read(authSessionsControllerProvider.notifier)
          .revokeSession(session),
      completion(isTrue),
    );
    expect(repository.revokedIds, ['session-1']);
    expect(repository.listCalls, 2);
  });

  test('logs out locally when the current session is revoked', () async {
    final currentSession = AuthDeviceSession(
      id: 'current-session',
      deviceType: session.deviceType,
      deviceName: session.deviceName,
      platform: session.platform,
      lastUsedAt: session.lastUsedAt,
      createdAt: session.createdAt,
      expiresAt: session.expiresAt,
      isCurrent: true,
    );
    final repository = _FakeAuthSessionsRepository([currentSession]);
    final auth = _FakeAuthSessionNotifier();
    final container = ProviderContainer(
      overrides: [
        authSessionsRepositoryProvider.overrideWithValue(repository),
        authSessionProvider.overrideWith(() => auth),
      ],
    );
    addTearDown(container.dispose);

    final loaded = await container.read(authSessionsControllerProvider.future);
    await expectLater(
      container
          .read(authSessionsControllerProvider.notifier)
          .revokeSession(loaded.single),
      completion(isTrue),
    );
    expect(auth.loggedOut, isTrue);
  });

  testWidgets('renders active sessions and revoke actions', (tester) async {
    final repository = _FakeAuthSessionsRepository([session]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionsRepositoryProvider.overrideWithValue(repository),
        ],
        child: const TestForuiApp(home: AccountSessionsPage()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('网页浏览器'), findsOneWidget);
    expect(find.text('撤销'), findsOneWidget);
  });
}

class _FakeAuthSessionsRepository implements AuthSessionsRepository {
  _FakeAuthSessionsRepository(this._sessions);

  List<AuthDeviceSession> _sessions;
  final revokedIds = <String>[];
  int listCalls = 0;

  @override
  TaskEither<LucentFailure, List<AuthDeviceSession>> listSessions() {
    listCalls += 1;
    return TaskEither.right(List<AuthDeviceSession>.of(_sessions));
  }

  @override
  TaskEither<LucentFailure, void> revokeSession(String sessionId) {
    revokedIds.add(sessionId);
    _sessions = _sessions.where((item) => item.id != sessionId).toList();
    return TaskEither.right(null);
  }
}

class _FakeAuthSessionNotifier extends AuthSessionNotifier {
  bool loggedOut = false;

  @override
  AuthSessionState build() =>
      const AuthSessionState(isAuthenticated: true, isLoading: false);

  @override
  Future<void> logout() async {
    loggedOut = true;
    state = const AuthSessionState();
  }
}
