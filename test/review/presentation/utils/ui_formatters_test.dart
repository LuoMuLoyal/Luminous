import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/review/presentation/utils/ui_formatters.dart';

void main() {
  testWidgets('reportDashboardDateRangeLabel formats start and end dates', (
    tester,
  ) async {
    late BuildContext capturedContext;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: const [
          DefaultMaterialLocalizations.delegate,
          DefaultWidgetsLocalizations.delegate,
        ],
        home: Builder(
          builder: (context) {
            capturedContext = context;
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    final label = reportDashboardDateRangeLabel(
      capturedContext,
      '2026-01-15',
      '2026-01-22',
    );
    expect(label, contains('Jan'));
    expect(label, contains('15'));
    expect(label, contains('22'));
    expect(label, contains(' - '));
  });

  testWidgets('reportDashboardDateRangeLabel works with zh locale', (
    tester,
  ) async {
    late BuildContext capturedContext;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('zh'),
        localizationsDelegates: const [
          DefaultMaterialLocalizations.delegate,
          DefaultWidgetsLocalizations.delegate,
        ],
        home: Builder(
          builder: (context) {
            capturedContext = context;
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    final label = reportDashboardDateRangeLabel(
      capturedContext,
      '2026-03-01',
      '2026-03-07',
    );
    // zh locale uses month-day format, should contain both day numbers
    expect(label, contains('1'));
    expect(label, contains('7'));
  });

  testWidgets(
    'reportDashboardGeneratedAtLabel returns empty string for invalid date',
    (tester) async {
      late BuildContext capturedContext;
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: const [
            DefaultMaterialLocalizations.delegate,
            DefaultWidgetsLocalizations.delegate,
          ],
          home: Builder(
            builder: (context) {
              capturedContext = context;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      final label = reportDashboardGeneratedAtLabel(
        capturedContext,
        'not-a-date',
      );
      expect(label, '');
    },
  );

  testWidgets('reportDashboardGeneratedAtLabel formats valid date with time', (
    tester,
  ) async {
    late BuildContext capturedContext;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: const [
          DefaultMaterialLocalizations.delegate,
          DefaultWidgetsLocalizations.delegate,
        ],
        home: Builder(
          builder: (context) {
            capturedContext = context;
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    final label = reportDashboardGeneratedAtLabel(
      capturedContext,
      '2026-01-15T14:30:00Z',
    );
    // Should contain a month abbreviation and time
    expect(label, isNotEmpty);
    expect(label, contains(':'));
  });
}
