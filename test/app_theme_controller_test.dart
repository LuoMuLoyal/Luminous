import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/theme/app_theme_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('theme preference defaults to system for empty or unknown values', () {
    expect(
      AppThemeModePreference.fromStorage(null),
      AppThemeModePreference.system,
    );
    expect(
      AppThemeModePreference.fromStorage('unexpected'),
      AppThemeModePreference.system,
    );
  });

  test('theme palette defaults to classic for empty or unknown values', () {
    expect(
      AppThemePalettePreference.fromStorage(null),
      AppThemePalettePreference.classic,
    );
    expect(
      AppThemePalettePreference.fromStorage('unexpected'),
      AppThemePalettePreference.classic,
    );
  });

  test('theme controller restores and persists the selected mode', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'theme.mode': AppThemeModePreference.dark.storageValue,
    });

    final container = ProviderContainer.test();
    addTearDown(container.dispose);

    await expectLater(
      container.read(appThemeControllerProvider.future),
      completion(AppThemeModePreference.dark),
    );

    await container
        .read(appThemeControllerProvider.notifier)
        .setMode(AppThemeModePreference.light);

    expect(
      container.read(appThemeControllerProvider).requireValue,
      AppThemeModePreference.light,
    );

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('theme.mode'), 'light');
  });

  test(
    'theme palette controller restores and persists the selected palette',
    () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'theme.palette': AppThemePalettePreference.bluePink.storageValue,
      });

      final container = ProviderContainer.test();
      addTearDown(container.dispose);

      await expectLater(
        container.read(appThemePaletteControllerProvider.future),
        completion(AppThemePalettePreference.bluePink),
      );

      await container
          .read(appThemePaletteControllerProvider.notifier)
          .setPalette(AppThemePalettePreference.yellowGreen);

      expect(
        container.read(appThemePaletteControllerProvider).requireValue,
        AppThemePalettePreference.yellowGreen,
      );

      final preferences = await SharedPreferences.getInstance();
      expect(preferences.getString('theme.palette'), 'yellow-green');
    },
  );
}
