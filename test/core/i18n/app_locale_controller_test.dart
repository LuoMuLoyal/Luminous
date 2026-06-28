import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/i18n/app_locale.dart';
import 'package:luminous/core/i18n/app_locale_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AppLocaleController', () {
    test('build returns system locale when nothing is stored', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final locale = await container.read(appLocaleControllerProvider.future);

      expect(locale, equals(AppLocale.system));
    });

    test('build returns stored locale when present', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'app.locale': 'zh-CN',
      });

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final locale = await container.read(appLocaleControllerProvider.future);

      expect(locale, equals(AppLocale.zhCn));
    });

    test('setLocale updates the provider value', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});

      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(appLocaleControllerProvider.future);

      await container
          .read(appLocaleControllerProvider.notifier)
          .setLocale(AppLocale.en);

      final locale = container.read(appLocaleControllerProvider).asData?.value;
      expect(locale, equals(AppLocale.en));
    });

    test('setLocale persists to SharedPreferences', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});

      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(appLocaleControllerProvider.future);

      await container
          .read(appLocaleControllerProvider.notifier)
          .setLocale(AppLocale.zhCn);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('app.locale'), equals('zh-CN'));
    });

    test('setLocale can change locale multiple times', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});

      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(appLocaleControllerProvider.future);

      await container
          .read(appLocaleControllerProvider.notifier)
          .setLocale(AppLocale.en);
      expect(
        container.read(appLocaleControllerProvider).asData?.value,
        equals(AppLocale.en),
      );

      await container
          .read(appLocaleControllerProvider.notifier)
          .setLocale(AppLocale.zhCn);
      expect(
        container.read(appLocaleControllerProvider).asData?.value,
        equals(AppLocale.zhCn),
      );

      await container
          .read(appLocaleControllerProvider.notifier)
          .setLocale(AppLocale.system);
      expect(
        container.read(appLocaleControllerProvider).asData?.value,
        equals(AppLocale.system),
      );
    });
  });
}
