import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:lucent_api/lucent_api.dart' show MedicineRemindersApi;
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/notifications/local_notification_gateway.dart';
import 'package:luminous/features/medicine/data/datasources/reminder_remote.dart';
import 'package:luminous/features/medicine/data/providers/workspace.dart';
import 'package:luminous/features/medicine/presentation/providers/reminder_delivery_reporter.dart';

void main() {
  const payload =
      '{"reminderId":"reminder-1","date":"2026-06-10","time":"21:30"}';

  group('MedicineReminderDeliveryReporter', () {
    late _FakeGateway gateway;
    late _FakeRepository repository;
    late MedicineReminderDeliveryReporter reporter;

    setUp(() {
      gateway = _FakeGateway();
      repository = _FakeRepository();
      reporter = MedicineReminderDeliveryReporter(
        gateway: gateway,
        repository: repository,
      );
    });

    tearDown(() async {
      await reporter.dispose();
    });

    test('tap event with a valid payload reports a local receipt', () async {
      await reporter.start();
      gateway.emitTap(
        const NotificationResponse(
          notificationResponseType:
              NotificationResponseType.selectedNotification,
          id: 1,
          payload: payload,
        ),
      );
      await pumpEventQueue();

      expect(repository.receipts, hasLength(1));
      expect(repository.receipts.single.reminderId, 'reminder-1');
      expect(repository.receipts.single.date, '2026-06-10');
      expect(repository.receipts.single.time, '21:30');
    });

    test('the same reminder moment is reported only once', () async {
      await reporter.start();
      gateway.emitTap(
        const NotificationResponse(
          notificationResponseType:
              NotificationResponseType.selectedNotification,
          id: 1,
          payload: payload,
        ),
      );
      gateway.emitTap(
        const NotificationResponse(
          notificationResponseType:
              NotificationResponseType.selectedNotification,
          id: 1,
          payload: payload,
        ),
      );
      await pumpEventQueue();

      expect(repository.receipts, hasLength(1));
    });

    test('invalid payloads are ignored without reporting', () async {
      await reporter.start();
      gateway.emitTap(
        const NotificationResponse(
          notificationResponseType:
              NotificationResponseType.selectedNotification,
          id: 2,
          payload: 'not-a-reminder-payload',
        ),
      );
      await pumpEventQueue();

      expect(repository.receipts, isEmpty);
    });

    test('a failing report is logged and does not throw', () async {
      repository.throwOnReport = true;
      await reporter.start();
      gateway.emitTap(
        const NotificationResponse(
          notificationResponseType:
              NotificationResponseType.selectedNotification,
          id: 3,
          payload: payload,
        ),
      );
      // Must not throw even though the repository fails.
      await pumpEventQueue();

      expect(repository.receiptAttempts, 1);
    });

    test(
      'startup sweep reports active notifications with valid payloads',
      () async {
        gateway.active = <ActiveNotification>[
          const ActiveNotification(id: 10, payload: payload),
          const ActiveNotification(id: 11, payload: 'ignored'),
          const ActiveNotification(
            id: 12,
            payload: '{"reminderId":"r2","date":"2026-06-11","time":"08:00"}',
          ),
        ];

        await reporter.start();
        await pumpEventQueue();

        expect(repository.receipts, hasLength(2));
        expect(repository.receipts[0].reminderId, 'reminder-1');
        expect(repository.receipts[1].reminderId, 'r2');
      },
    );

    test('sweep and tap event for the same moment deduplicate', () async {
      gateway.active = <ActiveNotification>[
        const ActiveNotification(id: 10, payload: payload),
      ];

      await reporter.start();
      await pumpEventQueue();
      gateway.emitTap(
        const NotificationResponse(
          notificationResponseType:
              NotificationResponseType.selectedNotification,
          id: 10,
          payload: payload,
        ),
      );
      await pumpEventQueue();

      expect(repository.receipts, hasLength(1));
    });

    test('no sweep when the gateway is not initialized', () async {
      gateway.available = false;
      gateway.active = <ActiveNotification>[
        const ActiveNotification(id: 10, payload: payload),
      ];

      await reporter.start();
      await pumpEventQueue();

      expect(repository.receipts, isEmpty);
    });
  });

  group('medicineReminderDeliveryReporterProvider', () {
    test('watching the provider starts the subscription and sweep', () async {
      final gateway = _FakeGateway();
      gateway.active = <ActiveNotification>[
        const ActiveNotification(id: 20, payload: payload),
      ];
      final repository = _FakeRepository();
      final container = ProviderContainer(
        overrides: [
          localNotificationGatewayProvider.overrideWithValue(gateway),
          reminderRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      container.read(medicineReminderDeliveryReporterProvider);
      await pumpEventQueue();

      expect(repository.receipts, hasLength(1));

      // The subscription stays alive and processes later tap events.
      gateway.emitTap(
        const NotificationResponse(
          notificationResponseType:
              NotificationResponseType.selectedNotification,
          id: 21,
          payload: '{"reminderId":"r3","date":"2026-06-12","time":"07:30"}',
        ),
      );
      await pumpEventQueue();

      expect(repository.receipts, hasLength(2));
    });
  });
}

class _FakeGateway extends LocalNotificationGateway {
  final _controller = StreamController<NotificationResponse>.broadcast();
  bool available = true;
  List<ActiveNotification> active = const <ActiveNotification>[];

  @override
  Stream<NotificationResponse> get tapEvents => _controller.stream;

  @override
  Future<bool> ensureInitialized() async => available;

  @override
  Future<List<ActiveNotification>> getActiveNotifications() async => active;

  void emitTap(NotificationResponse response) => _controller.add(response);
}

class _FakeRepository extends MedicineReminderRemoteDataSource {
  _FakeRepository() : super(api: MedicineRemindersApi(_fakeDio), dio: _fakeDio);

  static final Dio _fakeDio = Dio(BaseOptions());

  final receipts = <_Receipt>[];
  int receiptAttempts = 0;
  bool throwOnReport = false;

  @override
  TaskEither<LucentFailure, void> reportLocalReceipt({
    required String reminderId,
    required String scheduledDate,
    required String scheduledTime,
  }) {
    receiptAttempts += 1;
    if (throwOnReport) {
      return TaskEither.left(LucentFailure.unknown(message: 'report failed'));
    }
    receipts.add(
      _Receipt(
        reminderId: reminderId,
        date: scheduledDate,
        time: scheduledTime,
      ),
    );
    return TaskEither.right(null);
  }
}

class _Receipt {
  const _Receipt({
    required this.reminderId,
    required this.date,
    required this.time,
  });

  final String reminderId;
  final String date;
  final String time;
}
