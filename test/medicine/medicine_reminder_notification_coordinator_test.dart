import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucent_openapi/lucent_openapi.dart' show MedicineRemindersApi;
import 'package:luminous/core/i18n/app_locale.dart';
import 'package:luminous/core/i18n/app_locale_controller.dart';
import 'package:luminous/core/notifications/local_notification_gateway.dart';
import 'package:luminous/features/auth/domain/entities/auth_session.dart';
import 'package:luminous/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:luminous/features/medicine/data/datasources/medicine_reminder_remote_data_source.dart';
import 'package:luminous/features/medicine/data/repositories/mock_medicine_workspace_repository.dart';
import 'package:luminous/features/medicine/domain/services/medicine_reminder_notification_planner.dart';
import 'package:luminous/features/medicine/presentation/providers/medicine_reminder_notification_coordinator.dart';
import 'package:luminous/features/medicine/presentation/providers/medicine_reminder_providers.dart';
import 'package:luminous/features/settings/data/providers/notification_permission_providers.dart';
import 'package:luminous/features/settings/data/services/notification_permission_service.dart';
import 'package:luminous/features/settings/presentation/providers/notification_settings_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const texts = MedicineReminderNotificationTexts(
    defaultTitle: 'Medication reminder',
    defaultBody: 'It is time to take your medicine.',
    channelName: 'Medication reminders',
    channelDescription: 'On-device reminders for your medication schedule.',
  );
  final now = DateTime(2026, 6, 10, 9);

  test('coordinator cancels old ids schedules new ones and persists them', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      medicineReminderScheduledNotificationIdsStorageKey: <String>['7', '8'],
    });
    final gateway = _FakeLocalNotificationGateway();
    final coordinator = MedicineReminderNotificationCoordinator(
      gateway: gateway,
      planner: const MedicineReminderNotificationPlanner(),
    );

    await coordinator.resync(
      reminders: <MedicineReminderItem>[
        _reminder(id: 'reminder-1', hour: 10),
        _reminder(id: 'reminder-2', hour: 21),
      ],
      remindersEnabled: true,
      sound: MedicineReminderSoundPreference.defaultTone,
      texts: texts,
      now: now,
    );

    expect(gateway.cancelledIds, <int>[7, 8]);
    expect(gateway.scheduledCalls, hasLength(14));

    final preferences = await SharedPreferences.getInstance();
    expect(
      preferences.getStringList(
        medicineReminderScheduledNotificationIdsStorageKey,
      ),
      hasLength(14),
    );
  });

  test('coordinator leaves preferences untouched when gateway is unavailable', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      medicineReminderScheduledNotificationIdsStorageKey: <String>['7'],
    });
    final gateway = _FakeLocalNotificationGateway(available: false);
    final coordinator = MedicineReminderNotificationCoordinator(
      gateway: gateway,
      planner: const MedicineReminderNotificationPlanner(),
    );

    await coordinator.resync(
      reminders: <MedicineReminderItem>[_reminder(id: 'reminder-1', hour: 10)],
      remindersEnabled: true,
      sound: MedicineReminderSoundPreference.defaultTone,
      texts: texts,
      now: now,
    );

    expect(gateway.cancelledIds, isEmpty);
    expect(gateway.scheduledCalls, isEmpty);

    final preferences = await SharedPreferences.getInstance();
    expect(
      preferences.getStringList(
        medicineReminderScheduledNotificationIdsStorageKey,
      ),
      <String>['7'],
    );
  });

  test('coordinator clears stored ids when reminders are disabled', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      medicineReminderScheduledNotificationIdsStorageKey: <String>['5', '6'],
    });
    final gateway = _FakeLocalNotificationGateway();
    final coordinator = MedicineReminderNotificationCoordinator(
      gateway: gateway,
      planner: const MedicineReminderNotificationPlanner(),
    );

    await coordinator.resync(
      reminders: const <MedicineReminderItem>[],
      remindersEnabled: false,
      sound: MedicineReminderSoundPreference.defaultTone,
      texts: texts,
      now: now,
    );

    expect(gateway.cancelledIds, <int>[5, 6]);
    expect(gateway.scheduledCalls, isEmpty);

    final preferences = await SharedPreferences.getInstance();
    expect(
      preferences.getStringList(
        medicineReminderScheduledNotificationIdsStorageKey,
      ),
      isEmpty,
    );
  });

  test('sync provider schedules on first run and reschedules after list invalidation', () async {
    SharedPreferences.setMockInitialValues(const <String, Object>{});
    final gateway = _FakeLocalNotificationGateway();
    final reminderSource = _FakeReminderSource([
      _reminder(id: 'reminder-1', hour: 10),
    ]);
    final container = ProviderContainer(
      overrides: [
        authSessionProvider.overrideWith(_SignedInAuthSessionNotifier.new),
        appLocaleControllerProvider.overrideWith(() => _StaticLocaleController()),
        localNotificationGatewayProvider.overrideWithValue(gateway),
        medicineReminderNotificationNowProvider.overrideWithValue(() => now),
        medicineReminderRemoteDataSourceProvider.overrideWithValue(reminderSource),
        notificationPermissionServiceProvider.overrideWithValue(
          _FakeNotificationPermissionService(
            state: NotificationPermissionState.granted,
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(appLocaleControllerProvider.future);
    await container.read(notificationSettingsControllerProvider.future);
    await container.read(medicineReminderSoundProvider.future);
    final syncSub = _keepSyncProviderAlive(container);
    addTearDown(syncSub.close);
    await container.read(medicineReminderNotificationSyncProvider.future);

    expect(gateway.scheduledCalls, hasLength(7));
    final firstIds = gateway.scheduledCalls.map((item) => item.id).toList();

    reminderSource.items = <MedicineReminderItem>[
      _reminder(id: 'reminder-1', hour: 11),
    ];
    gateway.cancelledIds.clear();
    gateway.scheduledCalls.clear();
    container.invalidate(medicineReminderListProvider);

    await container.read(medicineReminderNotificationSyncProvider.future);

    expect(gateway.cancelledIds, firstIds);
    expect(gateway.scheduledCalls, hasLength(7));
    expect(
      gateway.scheduledCalls.first.scheduledAt,
      DateTime(2026, 6, 10, 11),
    );
  });

  test('sync provider keeps previous schedule when reminder fetch fails', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      medicineReminderScheduledNotificationIdsStorageKey: <String>['11', '12'],
    });
    final gateway = _FakeLocalNotificationGateway();
    final reminderSource = _FakeReminderSource(const <MedicineReminderItem>[])
      ..throwOnFetch = true;
    final container = ProviderContainer(
      overrides: [
        authSessionProvider.overrideWith(_SignedInAuthSessionNotifier.new),
        appLocaleControllerProvider.overrideWith(() => _StaticLocaleController()),
        localNotificationGatewayProvider.overrideWithValue(gateway),
        medicineReminderNotificationNowProvider.overrideWithValue(() => now),
        medicineReminderRemoteDataSourceProvider.overrideWithValue(reminderSource),
        notificationPermissionServiceProvider.overrideWithValue(
          _FakeNotificationPermissionService(
            state: NotificationPermissionState.granted,
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(appLocaleControllerProvider.future);
    await container.read(notificationSettingsControllerProvider.future);
    await container.read(medicineReminderSoundProvider.future);
    final syncSub = _keepSyncProviderAlive(container);
    addTearDown(syncSub.close);
    await container.read(medicineReminderNotificationSyncProvider.future);

    expect(gateway.cancelledIds, isEmpty);
    expect(gateway.scheduledCalls, isEmpty);

    final preferences = await SharedPreferences.getInstance();
    expect(
      preferences.getStringList(
        medicineReminderScheduledNotificationIdsStorageKey,
      ),
      <String>['11', '12'],
    );
  });

  test('sync provider clears notifications after medication reminders are turned off', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      medicineReminderScheduledNotificationIdsStorageKey: <String>['21', '22'],
    });
    final gateway = _FakeLocalNotificationGateway();
    final reminderSource = _FakeReminderSource([
      _reminder(id: 'reminder-1', hour: 10),
    ]);
    final container = ProviderContainer(
      overrides: [
        authSessionProvider.overrideWith(_SignedInAuthSessionNotifier.new),
        appLocaleControllerProvider.overrideWith(() => _StaticLocaleController()),
        localNotificationGatewayProvider.overrideWithValue(gateway),
        medicineReminderNotificationNowProvider.overrideWithValue(() => now),
        medicineReminderRemoteDataSourceProvider.overrideWithValue(reminderSource),
        notificationPermissionServiceProvider.overrideWithValue(
          _FakeNotificationPermissionService(
            state: NotificationPermissionState.granted,
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(appLocaleControllerProvider.future);
    await container.read(notificationSettingsControllerProvider.future);
    await container.read(medicineReminderSoundProvider.future);
    final syncSub = _keepSyncProviderAlive(container);
    addTearDown(syncSub.close);
    await container.read(medicineReminderNotificationSyncProvider.future);

    gateway.cancelledIds.clear();
    gateway.scheduledCalls.clear();

    await container
        .read(notificationSettingsControllerProvider.notifier)
        .setMedicationReminders(false);

    await container.read(medicineReminderNotificationSyncProvider.future);

    expect(gateway.scheduledCalls, isEmpty);
    expect(gateway.cancelledIds, isNotEmpty);

    final preferences = await SharedPreferences.getInstance();
    expect(
      preferences.getStringList(
        medicineReminderScheduledNotificationIdsStorageKey,
      ),
      isEmpty,
    );
  });
}

ProviderSubscription<AsyncValue<void>> _keepSyncProviderAlive(
  ProviderContainer container,
) {
  return container.listen<AsyncValue<void>>(
    medicineReminderNotificationSyncProvider,
    (_, _) {},
    fireImmediately: true,
  );
}

class _FakeLocalNotificationGateway extends LocalNotificationGateway {
  _FakeLocalNotificationGateway({this.available = true});

  final bool available;
  final cancelledIds = <int>[];
  final scheduledCalls = <_ScheduledCall>[];

  @override
  Future<bool> ensureInitialized() async => available;

  @override
  Future<void> cancel(int id) async {
    cancelledIds.add(id);
  }

  @override
  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledAt,
    required bool playSound,
    required String channelName,
    required String channelDescription,
    String? payload,
  }) async {
    scheduledCalls.add(
      _ScheduledCall(
        id: id,
        title: title,
        body: body,
        scheduledAt: scheduledAt,
        playSound: playSound,
        channelName: channelName,
        channelDescription: channelDescription,
        payload: payload,
      ),
    );
  }
}

class _ScheduledCall {
  const _ScheduledCall({
    required this.id,
    required this.title,
    required this.body,
    required this.scheduledAt,
    required this.playSound,
    required this.channelName,
    required this.channelDescription,
    required this.payload,
  });

  final int id;
  final String title;
  final String body;
  final DateTime scheduledAt;
  final bool playSound;
  final String channelName;
  final String channelDescription;
  final String? payload;
}

class _FakeReminderSource extends MedicineReminderRemoteDataSource {
  _FakeReminderSource(this.items)
    :
      super(
        api: MedicineRemindersApi(_fakeDio),
        dio: _fakeDio,
      );

  static final Dio _fakeDio = Dio(BaseOptions());

  List<MedicineReminderItem> items;
  bool throwOnFetch = false;

  @override
  Future<List<MedicineReminderItem>> fetchAll() async {
    if (throwOnFetch) {
      throw StateError('fetch failed');
    }
    return items;
  }
}

class _FakeNotificationPermissionService extends NotificationPermissionService {
  _FakeNotificationPermissionService({required this.state});

  final NotificationPermissionState state;

  @override
  Future<void> ensureInitialized() async {}

  @override
  Future<NotificationPermissionState> getPermissionState() async => state;

  @override
  Future<NotificationPermissionState> requestPermission() async => state;
}

class _SignedInAuthSessionNotifier extends AuthSessionNotifier {
  @override
  AuthSessionState build() {
    return AuthSessionState(
      isAuthenticated: true,
      isLoading: false,
      user: AuthUser(
        id: 'user-1',
        email: 'user@example.com',
        nickname: 'Lumi',
        avatar: null,
        emailVerifiedAt: DateTime.parse('2026-01-01T00:00:00Z'),
        createdAt: DateTime.parse('2026-01-01T00:00:00Z'),
        updatedAt: DateTime.parse('2026-01-02T00:00:00Z'),
      ),
    );
  }

  @override
  Future<void> restore() async {}
}

class _StaticLocaleController extends AppLocaleController {
  @override
  Future<AppLocale> build() async => AppLocale.zhCn;
}

MedicineReminderItem _reminder({
  required String id,
  required int hour,
  int minute = 0,
}) {
  return MedicineReminderItem(
    id: id,
    currentMedicineId: 'med-1',
    label: '阿托伐他汀',
    scheduledHour: hour,
    scheduledMinute: minute,
    daysOfWeek: null,
    startDate: null,
    endDate: null,
    isActive: true,
    note: '饭后服用',
    createdAt: '2026-06-01T00:00:00.000Z',
    updatedAt: '2026-06-01T00:00:00.000Z',
  );
}
