import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/providers/data_change_bus.dart';
import 'package:luminous/features/record/application/usecases/change_record_date.dart';
import 'package:luminous/features/record/data/providers/record_access.dart';
import 'package:luminous/features/record/domain/entities/inputs.dart';
import 'package:luminous/features/record/domain/entities/record.dart';
import 'package:luminous/features/record/domain/repositories/daily.dart';
import 'package:luminous/features/record/presentation/providers/dashboard.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/test_forui_app.dart';

class _FakeItem extends Fake implements DailyRecordItem {}

class _FakeUpdate extends Fake implements DailyRecordUpdateInput {}

class _MockRepo extends Mock implements DailyRecordRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeUpdate());
  });

  late _MockRepo repo;
  late ProviderContainer container;
  late BuildContext ctx;
  late WidgetRef ref;

  setUp(() {
    repo = _MockRepo();
  });

  Future<void> pumpPage(WidgetTester tester) async {
    container = ProviderContainer(
      overrides: [dailyRecordRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestForuiApp(
          home: Consumer(
            builder: (context, r, _) {
              ctx = context;
              ref = r;
              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }

  group('changeRecordDate', () {
    testWidgets('updates repo, bus, and selected date', (tester) async {
      when(
        () => repo.update(any(), any()),
      ).thenAnswer((_) async => _FakeItem());

      await pumpPage(tester);
      final newDate = DateTime(2026, 7, 15);

      await changeRecordDate(
        ref: ref,
        context: ctx,
        recordId: 'r1',
        newDate: newDate,
      );

      verify(
        () => repo.update(
          'r1',
          const DailyRecordUpdateInput(occurredAt: '2026-07-15'),
        ),
      ).called(1);
      expect(container.read(dataChangeBusProvider)['dailyRecords'], 1);
      expect(container.read(selectedRecordDateProvider), newDate);
    });

    testWidgets('on failure: bus unchanged, date unchanged', (tester) async {
      when(() => repo.update('r1', any())).thenThrow(Exception('boom'));

      await pumpPage(tester);

      await changeRecordDate(
        ref: ref,
        context: ctx,
        recordId: 'r1',
        newDate: DateTime(2026, 7, 15),
      );

      expect(container.read(dataChangeBusProvider)['dailyRecords'], isNull);
      expect(
        container.read(selectedRecordDateProvider),
        isNot(DateTime(2026, 7, 15)),
      );
    });

    testWidgets('zero-padded yyyy-MM-dd format', (tester) async {
      when(
        () => repo.update(any(), any()),
      ).thenAnswer((_) async => _FakeItem());

      await pumpPage(tester);

      await changeRecordDate(
        ref: ref,
        context: ctx,
        recordId: 'r1',
        newDate: DateTime(2026, 1, 5),
      );

      verify(
        () => repo.update(
          'r1',
          const DailyRecordUpdateInput(occurredAt: '2026-01-05'),
        ),
      ).called(1);
    });
  });
}
