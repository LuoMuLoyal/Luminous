import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:luminous/core/logger/logger.dart';
import 'package:luminous/core/notifications/local_notification_gateway.dart';
import 'package:luminous/features/medicine/data/providers/workspace.dart';
import 'package:luminous/features/medicine/domain/repositories/reminder.dart';
import 'package:luminous/features/medicine/domain/services/reminder_notification_payload.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'reminder_delivery_reporter.g.dart';

/// Reports local notification delivery receipts to the server so the audit
/// trail records `channel='local'`, `status='delivered'` rows.
///
/// The server is idempotent per `reminderId|date|time`; this session also
/// deduplicates in memory so a tap event and the startup sweep for the same
/// notification only produce one request. Failures are logged, never thrown.
class MedicineReminderDeliveryReporter {
  MedicineReminderDeliveryReporter({
    required this.gateway,
    required this.repository,
  });

  final LocalNotificationGateway gateway;
  final ReminderRepository repository;

  final Set<String> _reportedKeys = <String>{};
  StreamSubscription<NotificationResponse>? _subscription;

  /// Subscribes to notification tap events and sweeps the OS notification
  /// tray for already-delivered reminders whose receipt was never sent
  /// (e.g. the app was not running when the notification fired).
  Future<void> start() async {
    _subscription ??= gateway.tapEvents.listen(_handleTapEvent);
    if (!await gateway.ensureInitialized()) {
      return;
    }

    final active = await gateway.getActiveNotifications();
    for (final notification in active) {
      final payload = ReminderNotificationPayload.tryParse(
        notification.payload,
      );
      if (payload == null) {
        continue;
      }
      await _report(payload);
    }
  }

  Future<void> _handleTapEvent(NotificationResponse response) async {
    final payload = ReminderNotificationPayload.tryParse(response.payload);
    if (payload == null) {
      return;
    }
    await _report(payload);
  }

  Future<void> _report(ReminderNotificationPayload payload) async {
    final key = '${payload.reminderId}|${payload.date}|${payload.time}';
    if (!_reportedKeys.add(key)) {
      return;
    }
    try {
      final result = await repository
          .reportLocalReceipt(
            reminderId: payload.reminderId,
            scheduledDate: payload.date,
            scheduledTime: payload.time,
          )
          .run();
      result.fold(
        (failure) => appTalker.error(
          'MedicineReminderDeliveryReporter: reportLocalReceipt failed: '
          '$failure',
        ),
        (_) {},
      );
    } catch (e) {
      // 协议异常（如非 problem+json 错误体）从 run() 直接传播，同样只记录。
      appTalker.error(
        'MedicineReminderDeliveryReporter: reportLocalReceipt failed: $e',
      );
    }
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
  }
}

@Riverpod(keepAlive: true)
MedicineReminderDeliveryReporter medicineReminderDeliveryReporter(Ref ref) {
  final reporter = MedicineReminderDeliveryReporter(
    gateway: ref.watch(localNotificationGatewayProvider),
    repository: ref.watch(reminderRepositoryProvider),
  );
  ref.onDispose(reporter.dispose);
  // Kick off the tap-event subscription and startup sweep when the provider
  // is first watched (bootstrap keeps it alive for the app lifetime).
  unawaited(reporter.start());
  return reporter;
}
