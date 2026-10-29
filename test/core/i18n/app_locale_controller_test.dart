import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/network/i18n/app_locale.dart';
import 'package:luminous/core/storage/kv_store.dart';

import '../../helpers/kv_test_store.dart';

void main() {
  group('LocaleController', () {
    test('build returns system locale when nothing is stored', () async {
      KvTestStore.install(seed: <String, Object>{});

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final locale = await container.read(localeControllerProvider.future);

      expect(locale, equals(AppLocale.system));
    });

    test('build returns stored locale when present', () async {
      KvTestStore.install(seed: <String, Object>{'app.locale': 'zh-CN'});

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final locale = await container.read(localeControllerProvider.future);

      expect(locale, equals(AppLocale.zhCn));
    });

    test('setLocale updates the provider value', () async {
      KvTestStore.install(seed: <String, Object>{});

      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(localeControllerProvider.future);

      await container
          .read(localeControllerProvider.notifier)
          .setLocale(AppLocale.en);

      final locale = container.read(localeControllerProvider).asData?.value;
      expect(locale, equals(AppLocale.en));
    });

    test('setLocale persists to SharedPreferences', () async {
      KvTestStore.install(seed: <String, Object>{});

      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(localeControllerProvider.future);

      await container
          .read(localeControllerProvider.notifier)
          .setLocale(AppLocale.zhCn);

      final prefs = KvStore.instance;
      expect(prefs.getOrNull<String>('app.locale'), equals('zh-CN'));
    });

    test('setLocale can change locale multiple times', () async {
      KvTestStore.install(seed: <String, Object>{});

      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(localeControllerProvider.future);

      await container
          .read(localeControllerProvider.notifier)
          .setLocale(AppLocale.en);
      expect(
        container.read(localeControllerProvider).asData?.value,
        equals(AppLocale.en),
      );

      await container
          .read(localeControllerProvider.notifier)
          .setLocale(AppLocale.zhCn);
      expect(
        container.read(localeControllerProvider).asData?.value,
        equals(AppLocale.zhCn),
      );

      await container
          .read(localeControllerProvider.notifier)
          .setLocale(AppLocale.system);
      expect(
        container.read(localeControllerProvider).asData?.value,
        equals(AppLocale.system),
      );
    });
  });
}
