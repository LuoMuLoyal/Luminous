import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/features/settings/data/services/notification_permission_service.dart';

final notificationPermissionServiceProvider =
    Provider<NotificationPermissionService>((ref) {
      return NotificationPermissionService();
    });
