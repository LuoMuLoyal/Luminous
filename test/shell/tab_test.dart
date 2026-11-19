import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/router/app_routes.dart';
import 'package:luminous/features/shell/domain/entities/nav_config.dart';
import 'package:luminous/features/shell/presentation/tab.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/kv_test_store.dart';

void main() {
  setUp(() {
    KvTestStore.install();
  });

  group('shellTabRegistry', () {
    test('has the five tabs in branch order', () {
      expect(shellTabRegistry, hasLength(5));
      expect(shellTabRegistry.map((t) => t.id), [
        TabId.today,
        TabId.record,
        TabId.medicine,
        TabId.review,
        TabId.mine,
      ]);
    });

    test('branchIndex matches the position in the registry', () {
      for (var i = 0; i < shellTabRegistry.length; i++) {
        expect(
          shellTabRegistry[i].branchIndex,
          i,
          reason: '${shellTabRegistry[i].id.value} must own branch $i',
        );
      }
    });

    test('each tab points at its Routes constant', () {
      expect(shellTabRegistry[0].path, Routes.home);
      expect(shellTabRegistry[1].path, Routes.record);
      expect(shellTabRegistry[2].path, Routes.medicine);
      expect(shellTabRegistry[3].path, Routes.review);
      expect(shellTabRegistry[4].path, Routes.mine);
    });

    test('tab ids are unique', () {
      final ids = shellTabRegistry.map((t) => t.id).toSet();
      expect(ids, hasLength(shellTabRegistry.length));
    });
  });

  group('ShellTabStyle', () {
    test('every registered tab has a style', () {
      for (final definition in shellTabRegistry) {
        expect(
          ShellTabStyle.of(definition.id),
          isNotNull,
          reason: '${definition.id.value} should have a default style',
        );
      }
    });

    test('testKey is prefixed with shell-tab', () {
      expect(ShellTabStyle.of(TabId.today)!.testKey, 'shell-tab-today');
      expect(ShellTabStyle.of(TabId.record)!.testKey, 'shell-tab-record');
      expect(ShellTabStyle.of(TabId.medicine)!.testKey, 'shell-tab-medicine');
      expect(ShellTabStyle.of(TabId.mine)!.testKey, 'shell-tab-mine');
    });

    test('review keeps the legacy shell-tab-report key', () {
      // 从 "report" 改名而来，既有测试与集成脚本仍引用旧 key。
      expect(ShellTabStyle.of(TabId.review)!.testKey, 'shell-tab-report');
    });

    test('test keys are unique', () {
      final keys = {
        for (final definition in shellTabRegistry)
          ShellTabStyle.of(definition.id)!.testKey,
      };
      expect(keys, hasLength(shellTabRegistry.length));
    });

    test('unknown id has no style', () {
      expect(ShellTabStyle.of(const TabId('nonexistent')), isNull);
    });

    test('every tab has a distinct default icon', () {
      final icons = {
        for (final definition in shellTabRegistry)
          ShellTabStyle.of(definition.id)!.icon,
      };
      expect(icons, hasLength(shellTabRegistry.length));
    });
  });

  group('ShellTabStyle.defaultLabel', () {
    testWidgets('reads the ARB strings', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: SizedBox.shrink(),
        ),
      );
      await tester.pumpAndSettle();
      final l10n = AppLocalizations.of(tester.element(find.byType(SizedBox)))!;

      expect(ShellTabStyle.of(TabId.today)!.defaultLabel(l10n), l10n.tabToday);
      expect(
        ShellTabStyle.of(TabId.record)!.defaultLabel(l10n),
        l10n.tabRecord,
      );
      expect(
        ShellTabStyle.of(TabId.medicine)!.defaultLabel(l10n),
        l10n.tabMedicine,
      );
      expect(
        ShellTabStyle.of(TabId.review)!.defaultLabel(l10n),
        l10n.tabReview,
      );
      expect(ShellTabStyle.of(TabId.mine)!.defaultLabel(l10n), l10n.tabMine);
    });

    test('fifth tab uses the Review task name', () {
      final zh = lookupAppLocalizations(const Locale('zh'));
      expect(ShellTabStyle.of(TabId.review)!.defaultLabel(zh), '回顾');

      final en = lookupAppLocalizations(const Locale('en'));
      expect(ShellTabStyle.of(TabId.review)!.defaultLabel(en), 'Review');
    });
  });

  group('shellTabKey', () {
    test('matches the style test key', () {
      expect(
        (shellTabKey(TabId.today) as ValueKey<String>).value,
        'shell-tab-today',
      );
      expect(
        (shellTabKey(TabId.review) as ValueKey<String>).value,
        'shell-tab-report',
      );
    });
  });
}
