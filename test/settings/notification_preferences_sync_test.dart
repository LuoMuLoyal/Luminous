import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/config/pref_keys.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/features/auth/domain/entities/session.dart';
import 'package:luminous/features/settings/data/providers/notification_permission.dart';
import 'package:luminous/features/settings/data/providers/notification_preferences.dart';
import 'package:luminous/features/settings/domain/entities/notification_preferences.dart';
import 'package:luminous/features/settings/domain/repositories/notification_preferences.dart';
import 'package:luminous/features/settings/domain/services/notification_permission.dart';
import 'package:luminous/features/settings/presentation/providers/notification.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test(
    'migrates legacy SharedPreferences once when the remote row is unconfigured',
    () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        PrefKeys.settingsNotificationsHealthAlerts: false,
        PrefKeys.settingsNotificationsWeeklySummary: true,
        PrefKeys.settingsNotificationsWaterReminders: false,
        PrefKeys.settingsNotificationsSleepReminderEnabled: true,
        PrefKeys.settingsNotificationsSleepBedtime: '22:30',
        PrefKeys.settingsNotificationsSleepWakeTime: '06:45',
      });
      final repository = _FakeNotificationPreferencesRepository(
        const NotificationPreferences.defaults(configured: false),
      );
      final container = _buildContainer(repository);
      addTearDown(container.dispose);

      final first = await container.read(
        notificationSettingsControllerProvider.future,
      );
      expect(first.healthAlerts, isFalse);
      expect(first.weeklySummary, isTrue);
      expect(first.waterReminders, isFalse);
      expect(first.sleepReminderEnabled, isTrue);
      expect(first.sleepBedtimeMinutes, 1350);
      expect(first.sleepWakeTimeMinutes, 405);
      expect(repository.patches, hasLength(1));

      container.invalidate(notificationSettingsControllerProvider);
      await container.read(notificationSettingsControllerProvider.future);
      expect(repository.patches, hasLength(1));
      expect(
        (await SharedPreferences.getInstance()).getBool(
          PrefKeys.settingsNotificationsScoped(
            PrefKeys.settingsNotificationsRemoteMigrationCompleted,
            'user-a',
          ),
        ),
        isTrue,
      );
    },
  );

  test('configured remote preferences win over legacy local values', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      PrefKeys.settingsNotificationsHealthAlerts: false,
      PrefKeys.settingsNotificationsWeeklySummary: true,
    });
    final repository = _FakeNotificationPreferencesRepository(
      const NotificationPreferences(
        healthAlertsEnabled: true,
        weeklyInsightEnabled: false,
        waterRemindersEnabled: true,
        sleepReminderEnabled: true,
        sleepBedtimeMinutes: 1380,
        sleepWakeTimeMinutes: 420,
        configured: true,
        updatedAt: '2026-08-20T00:00:00.000Z',
      ),
    );
    final container = _buildContainer(repository);
    addTearDown(container.dispose);

    final state = await container.read(
      notificationSettingsControllerProvider.future,
    );
    expect(state.healthAlerts, isTrue);
    expect(state.weeklySummary, isFalse);
    expect(state.sleepBedtimeMinutes, 1380);
    expect(repository.patches, isEmpty);
  });

  test(
    'isolates notification cache and migration by user across A to B to A',
    () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        PrefKeys.settingsNotificationsHealthAlerts: false,
        PrefKeys.settingsNotificationsWeeklySummary: true,
      });
      var currentUserId = 'user-a';
      final repository = _MultiUserNotificationPreferencesRepository(
        currentUserId: () => currentUserId,
      );
      final container = _buildContainer(repository);
      addTearDown(container.dispose);

      final userA = await container.read(
        notificationSettingsControllerProvider.future,
      );
      expect(userA.healthAlerts, isFalse);
      expect(userA.weeklySummary, isTrue);

      currentUserId = 'user-b';
      container.read(authSessionProvider.notifier).applyUser(_user('user-b'));
      final userB = await container.read(
        notificationSettingsControllerProvider.future,
      );
      expect(userB.healthAlerts, isTrue);
      expect(userB.weeklySummary, isFalse);

      currentUserId = 'user-a';
      container.read(authSessionProvider.notifier).applyUser(_user('user-a'));
      final userAAgain = await container.read(
        notificationSettingsControllerProvider.future,
      );
      expect(userAAgain.healthAlerts, isFalse);
      expect(userAAgain.weeklySummary, isTrue);
      expect(repository.patchesByUser['user-a'], hasLength(1));
      expect(repository.patchesByUser['user-b'], hasLength(1));
      expect(
        repository.patchesByUser['user-b']!.single.healthAlertsEnabled,
        isTrue,
      );
      expect(
        repository.patchesByUser['user-b']!.single.weeklyInsightEnabled,
        isFalse,
      );
    },
  );

  test('keeps local values and leaves the migration marker unset when '
      'getPreferences fails', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      PrefKeys.settingsNotificationsHealthAlerts: false,
      PrefKeys.settingsNotificationsWeeklySummary: true,
      PrefKeys.settingsNotificationsWaterReminders: false,
    });
    final repository = _FakeNotificationPreferencesRepository(
      const NotificationPreferences.defaults(configured: false),
    )..throwOnGet = true;
    final container = _buildContainer(repository);
    addTearDown(container.dispose);

    final state = await container.read(
      notificationSettingsControllerProvider.future,
    );

    // The remote read failed, so the local values win.
    expect(state.healthAlerts, isFalse);
    expect(state.weeklySummary, isTrue);
    expect(state.waterReminders, isFalse);
    // No migration patch was attempted.
    expect(repository.patches, isEmpty);
    // The migration marker stays unset so the next build retries the sync.
    expect(
      (await SharedPreferences.getInstance()).getBool(
        PrefKeys.settingsNotificationsScoped(
          PrefKeys.settingsNotificationsRemoteMigrationCompleted,
          'user-a',
        ),
      ),
      isNull,
    );
  });

  test(
    'rolls back local and in-memory state when a remote patch fails',
    () async {
      SharedPreferences.setMockInitialValues(const <String, Object>{});
      final repository = _FakeNotificationPreferencesRepository(
        const NotificationPreferences.defaults(configured: true),
      )..throwOnPatch = true;
      final container = _buildContainer(repository);
      addTearDown(container.dispose);
      await container.read(notificationSettingsControllerProvider.future);

      await expectLater(
        container
            .read(notificationSettingsControllerProvider.notifier)
            .setHealthAlerts(false),
        throwsA(isA<LucentFailure>()),
      );
      expect(
        container
            .read(notificationSettingsControllerProvider)
            .value
            ?.healthAlerts,
        isTrue,
      );
      expect(
        (await SharedPreferences.getInstance()).getBool(
          PrefKeys.settingsNotificationsScoped(
            PrefKeys.settingsNotificationsHealthAlerts,
            'user-a',
          ),
        ),
        isTrue,
      );
    },
  );
}

ProviderContainer _buildContainer(
  NotificationPreferencesRepository repository,
) {
  return ProviderContainer(
    overrides: [
      authSessionProvider.overrideWith(_SignedInAuthSessionNotifier.new),
      notificationPreferencesRepositoryProvider.overrideWithValue(repository),
      notificationPermissionServiceProvider.overrideWithValue(
        _FakeNotificationPermissionService(),
      ),
    ],
  );
}

class _FakeNotificationPreferencesRepository
    implements NotificationPreferencesRepository {
  _FakeNotificationPreferencesRepository(this.remote);

  NotificationPreferences remote;
  final patches = <NotificationPreferencesPatch>[];
  bool throwOnGet = false;
  bool throwOnPatch = false;

  @override
  TaskEither<LucentFailure, NotificationPreferences> getPreferences() {
    if (throwOnGet) {
      return TaskEither.left(
        LucentFailure.unknown(message: 'remote get failed'),
      );
    }
    return TaskEither.right(remote);
  }

  @override
  TaskEither<LucentFailure, NotificationPreferences> patchPreferences(
    NotificationPreferencesPatch patch,
  ) {
    patches.add(patch);
    if (throwOnPatch) {
      return TaskEither.left(
        LucentFailure.unknown(message: 'remote patch failed'),
      );
    }
    remote = remote.apply(patch).copyWith(configured: true);
    return TaskEither.right(remote);
  }
}

class _MultiUserNotificationPreferencesRepository
    implements NotificationPreferencesRepository {
  _MultiUserNotificationPreferencesRepository({required this.currentUserId});

  final String Function() currentUserId;
  final remotes = <String, NotificationPreferences>{
    'user-a': const NotificationPreferences.defaults(configured: false),
    'user-b': const NotificationPreferences.defaults(configured: false),
  };
  final patchesByUser = <String, List<NotificationPreferencesPatch>>{};

  @override
  TaskEither<LucentFailure, NotificationPreferences> getPreferences() =>
      TaskEither.right(remotes[currentUserId()]!);

  @override
  TaskEither<LucentFailure, NotificationPreferences> patchPreferences(
    NotificationPreferencesPatch patch,
  ) {
    final userId = currentUserId();
    patchesByUser.putIfAbsent(userId, () => []).add(patch);
    final next = remotes[userId]!.apply(patch).copyWith(configured: true);
    remotes[userId] = next;
    return TaskEither.right(next);
  }
}

class _FakeNotificationPermissionService extends NotificationPermissionService {
  _FakeNotificationPermissionService() : super(plugin: null);

  @override
  Future<NotificationPermissionState> getPermissionState() async =>
      NotificationPermissionState.unsupported;
}

class _SignedInAuthSessionNotifier extends AuthSessionNotifier {
  @override
  AuthSessionState build() => AuthSessionState(
    user: _user('user-a'),
    isAuthenticated: true,
    isLoading: false,
  );
}

AuthUser _user(String id) => AuthUser(
  id: id,
  email: null,
  nickname: null,
  avatar: null,
  emailVerifiedAt: null,
  createdAt: DateTime.utc(2026, 1, 1),
  updatedAt: DateTime.utc(2026, 1, 1),
);
