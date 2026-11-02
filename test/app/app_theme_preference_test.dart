import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/storage/kv_store.dart';
import 'package:luminous/core/theme/family.dart';
import 'package:luminous/core/theme/preference.dart';

import '../helpers/kv_test_store.dart';

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

  test('theme family defaults to blue for empty or unknown values', () {
    expect(AppThemeFamily.fromStorage(null), AppThemeFamily.blue);
    expect(AppThemeFamily.fromStorage('unexpected'), AppThemeFamily.blue);
  });

  test(
    'theme controller restores and persists the selected mode and family',
    () async {
      KvTestStore.install(
        seed: <String, Object>{
          'theme.mode': AppThemeModePreference.dark.storageValue,
          'theme.family': AppThemeFamily.green.storageValue,
        },
      );

      final container = ProviderContainer.test();
      addTearDown(container.dispose);

      await expectLater(
        container.read(themeControllerProvider.future),
        completion(
          const ThemePreference(
            mode: AppThemeModePreference.dark,
            family: AppThemeFamily.green,
          ),
        ),
      );

      await container
          .read(themeControllerProvider.notifier)
          .setMode(AppThemeModePreference.light);
      await container
          .read(themeControllerProvider.notifier)
          .setFamily(AppThemeFamily.violet);

      expect(
        container.read(themeControllerProvider).requireValue,
        const ThemePreference(
          mode: AppThemeModePreference.light,
          family: AppThemeFamily.violet,
        ),
      );

      final preferences = KvStore.instance;
      expect(preferences.getOrNull<String>('theme.mode'), 'light');
      expect(preferences.getOrNull<String>('theme.family'), 'violet');
    },
  );
}
