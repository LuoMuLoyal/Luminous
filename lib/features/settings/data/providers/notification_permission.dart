import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/features/settings/domain/services/notification_permission.dart';

final notificationPermissionServiceProvider =
    Provider<NotificationPermissionService>((ref) {
      return NotificationPermissionService();
    });
