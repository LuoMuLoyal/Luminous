import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:luminous/core/providers/instrumentation/data_change_bus.dart';
import 'package:luminous/features/record/application/usecases/change_record_date.dart';
import 'package:luminous/app/composition/record/record_access.dart';
import 'package:luminous/features/record/domain/entities/inputs.dart';
import 'package:luminous/features/record/domain/entities/record.dart';
import 'package:luminous/features/record/domain/repositories/daily.dart';
import 'package:luminous/features/record/domain/services/quick_entry.dart';
import 'package:luminous/features/record/domain/undo/quick_entry_undo.dart';
import 'package:luminous/features/record/presentation/providers/dashboard.dart';
import 'package:luminous/features/record/presentation/quick_entry/record_date.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/kv_test_store.dart';
import '../helpers/test_forui_app.dart';

class _FakeItem extends Fake implements DailyRecordItem {}

class _FakeUpdate extends Fake implements DailyRecordUpdateInput {}

class _MockRepo extends Mock implements DailyRecordRepository {}

class _RecordingWriter implements DailyRecordWriter {
  _RecordingWriter({this.updateError});

  final Object? updateError;
  final updates = <(String, DailyRecordUpdateInput)>[];

  @override
  Future<DailyRecordItem> update(
    String id,
    DailyRecordUpdateInput input,
  ) async {
    final error = updateError;
    if (error != null) throw error;
    updates.add((id, input));
    return _FakeItem();
  }

  @override
  Future<DailyRecordItem> create(DailyRecordCreateInput input) =>
      throw UnimplementedError();

  @override
  Future<void> delete(String id) => throw UnimplementedError();

  @override
  Future<DailyRecordAttachmentInput> uploadImage(
    DailyRecordImageUploadInput input,
  ) => throw UnimplementedError();
}

void main() {
  setUp(() {
    KvTestStore.install();
  });

  setUpAll(() {
    registerFallbackValue(_FakeUpdate());
  });

  group('ChangeRecordDateUseCase', () {
    test(
      'updates the repository with the zero-padded date and emits',
      () async {
        final writer = _RecordingWriter();
        final emitted = <String>[];

        final outcome = await ChangeRecordDateUseCase(
          repository: writer,
          emitDataChange: emitted.add,
        )(recordId: 'r1', newDate: DateTime(2026, 7, 15));

        expect(writer.updates.single.$1, 'r1');
        expect(
          writer.updates.single.$2.occurredAt,
          '2026-07-15',
          reason: 'yyyy-MM-dd with zero padding',
        );
        expect(emitted, [QuickEntryDataChange.dailyRecords]);
        expect(outcome, isA<ChangeRecordDateSucceeded>());
      },
    );

    test('zero-pads single-digit months and days', () async {
      final writer = _RecordingWriter();

      await ChangeRecordDateUseCase(repository: writer, emitDataChange: (_) {})(
        recordId: 'r1',
        newDate: DateTime(2026, 1, 5),
      );

      expect(writer.updates.single.$2.occurredAt, '2026-01-05');
    });

    test('a failed update reports failure and emits nothing', () async {
      final emitted = <String>[];

      final outcome = await ChangeRecordDateUseCase(
        repository: _RecordingWriter(updateError: Exception('boom')),
        emitDataChange: emitted.add,
      )(recordId: 'r1', newDate: DateTime(2026, 7, 15));

      expect(outcome, isA<ChangeRecordDateFailed>());
      expect(emitted, isEmpty);
    });
  });

  group('changeRecordDate (presentation)', () {
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

    testWidgets('updates repo, bus, and selected date', (tester) async {
      when(
        () => repo.update(any(), any()),
      ).thenAnswer((_) => TaskEither.right(_FakeItem()));

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
      ).thenAnswer((_) => TaskEither.right(_FakeItem()));

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
