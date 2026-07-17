import 'package:luminous/core/config/pref_keys.dart';
import 'package:luminous/features/medicine/domain/entities/reminder_sound_preference.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Data-layer service for medicine reminder SharedPreferences access.
///
/// Moves persistence out of presentation providers so that
/// `MedicineReminderSoundController` and
/// `MedicineReminderNotificationCoordinator` no longer call
/// `SharedPreferences.getInstance()` directly.
class MedicineReminderLocalPreferences {
  const MedicineReminderLocalPreferences();

  // ── Sound preference ───────────────────────────────────────────────────

  Future<MedicineReminderSoundPreference> readSound() async {
    final prefs = await SharedPreferences.getInstance();
    return MedicineReminderSoundPreference.fromStorage(
      prefs.getString(PrefKeys.medicineReminderSound),
    );
  }

  Future<void> writeSound(MedicineReminderSoundPreference preference) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      PrefKeys.medicineReminderSound,
      preference.storageValue,
    );
  }

  // ── Scheduled notification IDs ─────────────────────────────────────────

  Future<List<String>> readScheduledNotificationIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(
          PrefKeys.medicineReminderScheduledNotificationIds,
        ) ??
        const <String>[];
  }

  Future<void> writeScheduledNotificationIds(List<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      PrefKeys.medicineReminderScheduledNotificationIds,
      ids,
    );
  }
}
