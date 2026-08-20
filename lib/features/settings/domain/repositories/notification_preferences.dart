import 'package:luminous/features/settings/domain/entities/notification_preferences.dart';

abstract interface class NotificationPreferencesRepository {
  Future<NotificationPreferences> getPreferences();

  Future<NotificationPreferences> patchPreferences(
    NotificationPreferencesPatch patch,
  );
}
