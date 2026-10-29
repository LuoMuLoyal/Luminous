import 'package:luminous/core/network/client/client_providers.dart';
import 'package:luminous/features/settings/data/repositories/notification_preferences.dart';
import 'package:luminous/features/settings/domain/repositories/notification_preferences.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notification_preferences.g.dart';

@riverpod
NotificationPreferencesRepository notificationPreferencesRepository(Ref ref) {
  return LucentNotificationPreferencesRepository(
    api: ref.watch(lucentClientProvider).notificationPreferences,
    dio: ref.watch(lucentDioClientProvider).dio,
  );
}
