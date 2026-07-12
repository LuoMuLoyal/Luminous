import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/settings/presentation/providers/data_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late ProviderContainer container;

  ProviderContainer buildContainer({Map<String, Object>? initialValues}) {
    SharedPreferences.setMockInitialValues(
      initialValues ?? const <String, Object>{},
    );
    final c = ProviderContainer();
    addTearDown(c.dispose);
    return c;
  }

  group('DataRetentionPeriod', () {
    test('fromStorage returns correct period for known values', () {
      expect(
        DataRetentionPeriod.fromStorage('30'),
        DataRetentionPeriod.thirtyDays,
      );
      expect(
        DataRetentionPeriod.fromStorage('90'),
        DataRetentionPeriod.ninetyDays,
      );
      expect(
        DataRetentionPeriod.fromStorage('forever'),
        DataRetentionPeriod.forever,
      );
    });

    test('fromStorage returns ninetyDays for null', () {
      expect(
        DataRetentionPeriod.fromStorage(null),
        DataRetentionPeriod.ninetyDays,
      );
    });

    test('fromStorage returns ninetyDays for unknown value', () {
      expect(
        DataRetentionPeriod.fromStorage('unknown'),
        DataRetentionPeriod.ninetyDays,
      );
    });

    test('days values are correct', () {
      expect(DataRetentionPeriod.thirtyDays.days, 30);
      expect(DataRetentionPeriod.ninetyDays.days, 90);
      expect(DataRetentionPeriod.forever.days, -1);
    });

    test('storageValue values are correct', () {
      expect(DataRetentionPeriod.thirtyDays.storageValue, '30');
      expect(DataRetentionPeriod.ninetyDays.storageValue, '90');
      expect(DataRetentionPeriod.forever.storageValue, 'forever');
    });
  });

  group('ImageQualityPreference', () {
    test('fromStorage returns correct preference for known values', () {
      expect(
        ImageQualityPreference.fromStorage('standard'),
        ImageQualityPreference.standard,
      );
      expect(
        ImageQualityPreference.fromStorage('dataSaver'),
        ImageQualityPreference.dataSaver,
      );
    });

    test('fromStorage returns standard for null', () {
      expect(
        ImageQualityPreference.fromStorage(null),
        ImageQualityPreference.standard,
      );
    });

    test('fromStorage returns standard for unknown value', () {
      expect(
        ImageQualityPreference.fromStorage('unknown'),
        ImageQualityPreference.standard,
      );
    });

    test('storageValue values are correct', () {
      expect(ImageQualityPreference.standard.storageValue, 'standard');
      expect(ImageQualityPreference.dataSaver.storageValue, 'dataSaver');
    });
  });

  group('SyncPreference', () {
    test('fromStorage returns correct preference for known values', () {
      expect(SyncPreference.fromStorage('wifiOnly'), SyncPreference.wifiOnly);
      expect(
        SyncPreference.fromStorage('wifiAndMobile'),
        SyncPreference.wifiAndMobile,
      );
    });

    test('fromStorage returns wifiAndMobile for null', () {
      expect(SyncPreference.fromStorage(null), SyncPreference.wifiAndMobile);
    });

    test('fromStorage returns wifiAndMobile for unknown value', () {
      expect(
        SyncPreference.fromStorage('unknown'),
        SyncPreference.wifiAndMobile,
      );
    });

    test('storageValue values are correct', () {
      expect(SyncPreference.wifiOnly.storageValue, 'wifiOnly');
      expect(SyncPreference.wifiAndMobile.storageValue, 'wifiAndMobile');
    });
  });

  group('DataStorageSettingsController.build', () {
    test('uses default values when no preferences are stored', () async {
      container = buildContainer();

      final state = await container.read(
        dataStorageSettingsControllerProvider.future,
      );

      expect(state.retentionPeriod, DataRetentionPeriod.ninetyDays);
      expect(state.imageQuality, ImageQualityPreference.standard);
      expect(state.syncPreference, SyncPreference.wifiAndMobile);
    });

    test('loads persisted retentionPeriod', () async {
      container = buildContainer(
        initialValues: const <String, Object>{
          'settings.dataStorage.retentionPeriod': '30',
        },
      );

      final state = await container.read(
        dataStorageSettingsControllerProvider.future,
      );

      expect(state.retentionPeriod, DataRetentionPeriod.thirtyDays);
    });

    test('loads persisted imageQuality', () async {
      container = buildContainer(
        initialValues: const <String, Object>{
          'settings.dataStorage.imageQuality': 'dataSaver',
        },
      );

      final state = await container.read(
        dataStorageSettingsControllerProvider.future,
      );

      expect(state.imageQuality, ImageQualityPreference.dataSaver);
    });

    test('loads persisted syncPreference', () async {
      container = buildContainer(
        initialValues: const <String, Object>{
          'settings.dataStorage.syncPreference': 'wifiOnly',
        },
      );

      final state = await container.read(
        dataStorageSettingsControllerProvider.future,
      );

      expect(state.syncPreference, SyncPreference.wifiOnly);
    });
  });

  group('setRetentionPeriod', () {
    test('updates state and persists the value', () async {
      container = buildContainer();

      await container.read(dataStorageSettingsControllerProvider.future);

      await container
          .read(dataStorageSettingsControllerProvider.notifier)
          .setRetentionPeriod(DataRetentionPeriod.forever);

      final state = container.read(dataStorageSettingsControllerProvider);
      expect(state.value?.retentionPeriod, DataRetentionPeriod.forever);

      final preferences = await SharedPreferences.getInstance();
      expect(
        preferences.getString('settings.dataStorage.retentionPeriod'),
        'forever',
      );
    });
  });

  group('setImageQuality', () {
    test('updates state and persists the value', () async {
      container = buildContainer();

      await container.read(dataStorageSettingsControllerProvider.future);

      await container
          .read(dataStorageSettingsControllerProvider.notifier)
          .setImageQuality(ImageQualityPreference.dataSaver);

      final state = container.read(dataStorageSettingsControllerProvider);
      expect(state.value?.imageQuality, ImageQualityPreference.dataSaver);

      final preferences = await SharedPreferences.getInstance();
      expect(
        preferences.getString('settings.dataStorage.imageQuality'),
        'dataSaver',
      );
    });
  });

  group('setSyncPreference', () {
    test('updates state and persists the value', () async {
      container = buildContainer();

      await container.read(dataStorageSettingsControllerProvider.future);

      await container
          .read(dataStorageSettingsControllerProvider.notifier)
          .setSyncPreference(SyncPreference.wifiOnly);

      final state = container.read(dataStorageSettingsControllerProvider);
      expect(state.value?.syncPreference, SyncPreference.wifiOnly);

      final preferences = await SharedPreferences.getInstance();
      expect(
        preferences.getString('settings.dataStorage.syncPreference'),
        'wifiOnly',
      );
    });
  });

  group('reset', () {
    test(
      'clears all data storage preference keys and restores defaults',
      () async {
        container = buildContainer(
          initialValues: const <String, Object>{
            'settings.dataStorage.retentionPeriod': 'forever',
            'settings.dataStorage.imageQuality': 'dataSaver',
            'settings.dataStorage.syncPreference': 'wifiOnly',
          },
        );

        await container.read(dataStorageSettingsControllerProvider.future);

        await container
            .read(dataStorageSettingsControllerProvider.notifier)
            .reset();

        final state = container.read(dataStorageSettingsControllerProvider);
        expect(state.value?.retentionPeriod, DataRetentionPeriod.ninetyDays);
        expect(state.value?.imageQuality, ImageQualityPreference.standard);
        expect(state.value?.syncPreference, SyncPreference.wifiAndMobile);

        final preferences = await SharedPreferences.getInstance();
        expect(
          preferences.containsKey('settings.dataStorage.retentionPeriod'),
          isFalse,
        );
        expect(
          preferences.containsKey('settings.dataStorage.imageQuality'),
          isFalse,
        );
        expect(
          preferences.containsKey('settings.dataStorage.syncPreference'),
          isFalse,
        );
      },
    );
  });
}
