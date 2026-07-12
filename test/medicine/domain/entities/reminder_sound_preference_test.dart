import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/medicine/domain/entities/reminder_sound_preference.dart';

void main() {
  group('MedicineReminderSoundPreference', () {
    test('defaultTone has correct storageValue', () {
      expect(
        MedicineReminderSoundPreference.defaultTone.storageValue,
        'default',
      );
    });

    test('gentle has correct storageValue', () {
      expect(MedicineReminderSoundPreference.gentle.storageValue, 'gentle');
    });

    test('silent has correct storageValue', () {
      expect(MedicineReminderSoundPreference.silent.storageValue, 'silent');
    });

    test('has exactly 3 values', () {
      expect(MedicineReminderSoundPreference.values.length, 3);
    });
  });

  group('fromStorage', () {
    test('returns defaultTone for "default"', () {
      expect(
        MedicineReminderSoundPreference.fromStorage('default'),
        MedicineReminderSoundPreference.defaultTone,
      );
    });

    test('returns gentle for "gentle"', () {
      expect(
        MedicineReminderSoundPreference.fromStorage('gentle'),
        MedicineReminderSoundPreference.gentle,
      );
    });

    test('returns silent for "silent"', () {
      expect(
        MedicineReminderSoundPreference.fromStorage('silent'),
        MedicineReminderSoundPreference.silent,
      );
    });

    test('returns defaultTone for null', () {
      expect(
        MedicineReminderSoundPreference.fromStorage(null),
        MedicineReminderSoundPreference.defaultTone,
      );
    });

    test('returns defaultTone for unknown string', () {
      expect(
        MedicineReminderSoundPreference.fromStorage('unknown'),
        MedicineReminderSoundPreference.defaultTone,
      );
      expect(
        MedicineReminderSoundPreference.fromStorage(''),
        MedicineReminderSoundPreference.defaultTone,
      );
      expect(
        MedicineReminderSoundPreference.fromStorage('DEFAULT'),
        MedicineReminderSoundPreference.defaultTone,
      );
    });

    test('fromStorage/storageValue round-trip preserves identity', () {
      for (final value in MedicineReminderSoundPreference.values) {
        expect(
          MedicineReminderSoundPreference.fromStorage(value.storageValue),
          value,
        );
      }
    });
  });
}
