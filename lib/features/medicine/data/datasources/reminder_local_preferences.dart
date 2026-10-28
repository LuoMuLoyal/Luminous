import 'package:luminous/core/config/pref_keys.dart';
import 'package:luminous/core/storage/kv_store.dart';
import 'package:luminous/features/medicine/domain/entities/reminder_sound_preference.dart';

/// Data-layer service for medicine reminder KvStore access.
///
/// Moves persistence out of presentation providers so that
/// `MedicineReminderSoundController` and
/// `MedicineReminderNotificationCoordinator` no longer call
/// `KvStore.instance` directly.
class MedicineReminderLocalPreferences {
  const MedicineReminderLocalPreferences();

  // ── Sound preference ───────────────────────────────────────────────────

  Future<MedicineReminderSoundPreference> readSound() async {
    final prefs = KvStore.instance;
    return MedicineReminderSoundPreference.fromStorage(
      prefs.getOrNull<String>(PrefKeys.medicineReminderSound),
    );
  }

  Future<void> writeSound(MedicineReminderSoundPreference preference) async {
    final prefs = KvStore.instance;
    await prefs.set(PrefKeys.medicineReminderSound, preference.storageValue);
  }

  // ── Scheduled notification IDs ─────────────────────────────────────────

  Future<List<String>> readScheduledNotificationIds() async {
    final prefs = KvStore.instance;
    return prefs.getOrNull<List<String>>(
          PrefKeys.medicineReminderScheduledNotificationIds,
        ) ??
        const <String>[];
  }

  Future<void> writeScheduledNotificationIds(List<String> ids) async {
    final prefs = KvStore.instance;
    await prefs.set(PrefKeys.medicineReminderScheduledNotificationIds, ids);
  }
}
