enum MedicineReminderSoundPreference {
  defaultTone('default'),
  gentle('gentle'),
  silent('silent');

  const MedicineReminderSoundPreference(this.storageValue);

  final String storageValue;

  static MedicineReminderSoundPreference fromStorage(String? value) {
    return MedicineReminderSoundPreference.values.firstWhere(
      (item) => item.storageValue == value,
      orElse: () => MedicineReminderSoundPreference.defaultTone,
    );
  }
}
