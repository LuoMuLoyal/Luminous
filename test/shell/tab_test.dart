import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/shell/presentation/tab.dart';

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
        expect(tab.activeIcon, isNotNull,
            reason: '$tab should have an activeIcon');
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
    test('returns fallback string when l10n is null', () {
      expect(ShellTab.today.label(null), 'Today');
      expect(ShellTab.record.label(null), 'Record');
      expect(ShellTab.medicine.label(null), 'Medicine');
      expect(ShellTab.report.label(null), 'Report');
      expect(ShellTab.mine.label(null), 'Mine');
    });
  });
}
