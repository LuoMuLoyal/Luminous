import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/shell/presentation/tab.dart';
import 'package:luminous/l10n/app_localizations.dart';

void main() {
  group('ShellTab', () {
    test('has 5 tabs in correct order', () {
      expect(ShellTab.values, hasLength(5));
      expect(ShellTab.values[0], ShellTab.today);
      expect(ShellTab.values[1], ShellTab.record);
      expect(ShellTab.values[2], ShellTab.medicine);
      expect(ShellTab.values[3], ShellTab.report);
      expect(ShellTab.values[4], ShellTab.mine);
    });

    test('each tab has an icon', () {
      for (final tab in ShellTab.values) {
        expect(tab.icon, isNotNull, reason: '$tab should have an icon');
      }
    });

    test('each tab has an activeIcon', () {
      for (final tab in ShellTab.values) {
        expect(
          tab.activeIcon,
          isNotNull,
          reason: '$tab should have an activeIcon',
        );
      }
    });

    test('testKey returns ValueKey with shell-tab prefix', () {
      final key = ShellTab.today.testKey();
      expect(key, isA<ValueKey<String>>());
      expect(key.value, 'shell-tab-today');

      expect(ShellTab.record.testKey().value, 'shell-tab-record');
      expect(ShellTab.medicine.testKey().value, 'shell-tab-medicine');
      expect(ShellTab.report.testKey().value, 'shell-tab-report');
      expect(ShellTab.mine.testKey().value, 'shell-tab-mine');
    });

    test('testKey returns unique keys', () {
      final keys = ShellTab.values.map((t) => t.testKey().value).toSet();
      expect(keys.length, ShellTab.values.length);
    });
  });

  group('ShellTab.label', () {
    testWidgets('returns localized string from AppLocalizations', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: SizedBox.shrink(),
        ),
      );
      await tester.pumpAndSettle();
      final l10n = AppLocalizations.of(tester.element(find.byType(SizedBox)))!;

      expect(ShellTab.today.label(l10n), l10n.tabToday);
      expect(ShellTab.record.label(l10n), l10n.tabRecord);
      expect(ShellTab.medicine.label(l10n), l10n.tabMedicine);
      expect(ShellTab.report.label(l10n), l10n.tabReport);
      expect(ShellTab.mine.label(l10n), l10n.tabMine);
    });
  });

  group('ShellTab.label – fifth tab uses the Review task name', () {
    test('zh label is 回顾', () {
      final zh = lookupAppLocalizations(const Locale('zh'));
      expect(ShellTab.report.label(zh), '回顾');
    });

    test('en label is Review', () {
      final en = lookupAppLocalizations(const Locale('en'));
      expect(ShellTab.report.label(en), 'Review');
    });

    test('legacy tab key stays shell-tab-report', () {
      expect(ShellTab.report.testKey().value, 'shell-tab-report');
    });
  });
}
