import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:fpdart/fpdart.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/features/record/application/usecases/quick_entry_meal.dart';
import 'package:luminous/features/record/data/providers/record_access.dart';
import 'package:luminous/features/record/domain/entities/candidates.dart';
import 'package:luminous/features/record/domain/entities/inputs.dart';
import 'package:luminous/features/record/domain/entities/record.dart';
import 'package:luminous/features/record/domain/repositories/daily.dart';
import 'package:luminous/features/record/presentation/quick_entry/meal_flow.dart';
import 'package:luminous/l10n/app_localizations.dart';

import '../../../helpers/test_forui_app.dart';
import '../../../helpers/tiny_png.dart';

void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('zh'));
  });

  final image = MealQuickImage(
    bytes: tinyPngBytes(),
    fileName: 'lunch.jpg',
    contentType: 'image/jpeg',
  );

  /// Pumps a host with one button per [MealQuickEntrySource]; returns the
  /// sources the camera picker was asked for.
  Future<List<MealQuickImageSource>> pumpEntry(
    WidgetTester tester, {
    required MealQuickImage? picked,
    required List<DailyRecordCreateInput> created,
  }) async {
    // The camera draft previews a 4:3 photo; a taller surface keeps the
    // confirmation column from overflowing the default 800x600 test view.
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(480, 1200);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    final pickedSources = <MealQuickImageSource>[];
    final repository = _FakeDailyRecordRepository(created: created);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dailyRecordRepositoryProvider.overrideWithValue(repository),
          mealQuickImagePickerProvider.overrideWithValue((source) async {
            pickedSources.add(source);
            return picked;
          }),
        ],
        child: TestForuiApp(
          home: Consumer(
            builder: (context, ref, _) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final source in MealQuickEntrySource.values)
                    FButton(
                      key: Key('meal-entry-${source.name}'),
                      onPress: () => unawaited(
                        handleMealQuickAction(
                          context,
                          ref,
                          source: source,
                          now: DateTime(2026, 9, 15, 12, 30),
                          occurredAt: '2026-09-15',
                          occurredTime: '12:30',
                          canAccessProtectedData: true,
                          isAuthLoading: false,
                        ),
                      ),
                      child: Text(source.name),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return pickedSources;
  }

  testWidgets('single tap opens the camera and then the confirmation dialog', (
    tester,
  ) async {
    final created = <DailyRecordCreateInput>[];
    final pickedSources = await pumpEntry(
      tester,
      picked: image,
      created: created,
    );

    await tester.tap(find.byKey(const Key('meal-entry-camera')));
    await tester.pumpAndSettle();

    expect(pickedSources, [MealQuickImageSource.camera]);
    expect(find.text(l10n.recordQuickMealConfirmTitle), findsOneWidget);
    // 默认标题按当前时间给出（12:30 → 午餐）。
    expect(find.text('午餐'), findsOneWidget);
    expect(created, isEmpty, reason: '确认前不落库');
  });

  testWidgets('a cancelled camera writes nothing and shows no dialog', (
    tester,
  ) async {
    final created = <DailyRecordCreateInput>[];
    final pickedSources = await pumpEntry(
      tester,
      picked: null,
      created: created,
    );

    await tester.tap(find.byKey(const Key('meal-entry-camera')));
    await tester.pumpAndSettle();

    expect(pickedSources, [MealQuickImageSource.camera]);
    expect(find.text(l10n.recordQuickMealConfirmTitle), findsNothing);
    expect(created, isEmpty);
  });

  testWidgets('long press goes straight to the manual confirmation dialog', (
    tester,
  ) async {
    final created = <DailyRecordCreateInput>[];
    final pickedSources = await pumpEntry(
      tester,
      picked: image,
      created: created,
    );

    await tester.tap(find.byKey(const Key('meal-entry-manual')));
    await tester.pumpAndSettle();

    expect(pickedSources, isEmpty, reason: '手动录入不经过相机');
    expect(find.text(l10n.recordQuickMealConfirmTitle), findsOneWidget);
    expect(find.text('午餐'), findsOneWidget);
    expect(created, isEmpty);
  });
}

class _FakeDailyRecordRepository implements DailyRecordRepository {
  _FakeDailyRecordRepository({required this.created});

  final List<DailyRecordCreateInput> created;

  @override
  TaskEither<LucentFailure, DailyRecordItem> create(
    DailyRecordCreateInput input,
  ) {
    created.add(input);
    return TaskEither.right(
      DailyRecordItem(
        id: 'meal-1',
        kind: input.kind,
        occurredAt: input.occurredAt,
        occurredTime: input.occurredTime,
        title: input.title,
        value: input.value,
        unit: input.unit,
        note: input.note,
        createdAt: '2026-09-15T12:30:00Z',
        updatedAt: '2026-09-15T12:30:00Z',
      ),
    );
  }

  @override
  TaskEither<LucentFailure, void> delete(String id) => TaskEither.right(null);

  @override
  TaskEither<LucentFailure, DailyRecordListData> fetchRecords(
    String date, {
    String? kind,
    int page = 1,
    int pageSize = 50,
  }) => TaskEither.right(const DailyRecordListData(items: [], total: 0));

  @override
  TaskEither<LucentFailure, DailyRecordSummaryData> fetchSummary(String date) =>
      TaskEither.right(const DailyRecordSummaryData(summaries: []));

  @override
  TaskEither<LucentFailure, DailyRecordItem> get(String id) =>
      throw UnimplementedError();

  @override
  TaskEither<LucentFailure, DailyRecordAttachmentInput> uploadImage(
    DailyRecordImageUploadInput input,
  ) => TaskEither.right(
    DailyRecordAttachmentInput(
      objectKey: 'daily-records/u1/${input.fileName}',
      fileName: input.fileName,
      contentType: input.contentType,
      sizeBytes: input.sizeBytes,
      publicUrl: 'https://cdn.example.com/${input.fileName}',
    ),
  );

  @override
  TaskEither<LucentFailure, DailyRecordCandidateResult> generateCandidates({
    required String text,
    required String occurredAt,
  }) => throw UnimplementedError();

  @override
  TaskEither<LucentFailure, DailyRecordItem> update(
    String id,
    DailyRecordUpdateInput input,
  ) => throw UnimplementedError();
}
