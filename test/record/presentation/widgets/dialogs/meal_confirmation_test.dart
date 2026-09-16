import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/widgets/common/dialog/dialog_shell.dart';
import 'package:luminous/features/record/domain/entities/inputs.dart';
import 'package:luminous/features/record/domain/entities/record.dart';
import 'package:luminous/features/record/presentation/quick_entry/meal_flow.dart';
import 'package:luminous/features/record/presentation/widgets/dialogs/meal_confirmation.dart';
import 'package:luminous/l10n/app_localizations.dart';

import '../../../../helpers/test_forui_app.dart';
import '../../../../helpers/tiny_png.dart';

void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('zh'));
  });

  /// Opens the confirmation dialog through the production entry point
  /// ([showAppDialog]) and returns the sink of created record inputs.
  Future<List<DailyRecordCreateInput>> openDialog(
    WidgetTester tester, {
    required MealQuickEntryDraft draft,
  }) async {
    // The photo draft renders a 4:3 preview; give the dialog a tall enough
    // surface so the column does not overflow in the default 800x600 test view.
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(480, 1200);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    final created = <DailyRecordCreateInput>[];
    final flow = MealQuickEntryFlow(
      pickImage: (_) async => null,
      uploadImage: (input) async => DailyRecordAttachmentInput(
        objectKey: 'daily-records/u1/${input.fileName}',
        fileName: input.fileName,
        contentType: input.contentType,
        sizeBytes: input.sizeBytes,
        publicUrl: 'https://cdn.example.com/${input.fileName}',
      ),
      createRecord: (input) async {
        created.add(input);
        return _record(input);
      },
      emitDataChange: (_) {},
    );

    await tester.pumpWidget(
      TestForuiApp(
        showToaster: true,
        home: Builder(
          builder: (context) => Center(
            child: FButton(
              key: const Key('open-meal-confirmation'),
              onPress: () => showAppDialog<void>(
                context: context,
                maxWidth: 460,
                scrollable: false,
                builder: (_) =>
                    MealQuickConfirmationDialog(flow: flow, draft: draft),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('open-meal-confirmation')));
    await tester.pumpAndSettle();
    return created;
  }

  FButton confirmButton(WidgetTester tester) => tester.widget<FButton>(
    find.byKey(const Key('record-quick-meal-confirm-action')),
  );

  testWidgets('an empty draft cannot be submitted', (tester) async {
    final created = await openDialog(
      tester,
      draft: const MealQuickEntryDraft(
        occurredAt: '2026-07-28',
        occurredTime: '12:30',
      ),
    );

    expect(confirmButton(tester).onPress, isNull);

    // Tapping the disabled action records nothing and keeps the dialog open.
    await tester.tap(
      find.byKey(const Key('record-quick-meal-confirm-action')),
      warnIfMissed: false,
    );
    await tester.pumpAndSettle();
    expect(created, isEmpty);
    expect(
      find.byKey(const Key('record-quick-meal-confirm-action')),
      findsOneWidget,
    );
  });

  testWidgets('clearing every prefilled field disables the confirm action', (
    tester,
  ) async {
    final created = await openDialog(
      tester,
      draft: const MealQuickEntryDraft(
        occurredAt: '2026-07-28',
        occurredTime: '12:30',
        title: '午餐',
      ),
    );

    // The quick-entry flow prefills the title, so the action starts enabled...
    expect(confirmButton(tester).onPress, isNotNull);

    // ...and goes back to disabled once the user empties it.
    await tester.enterText(
      find.byKey(const Key('record-quick-meal-title-field')),
      '',
    );
    await tester.pumpAndSettle();
    expect(confirmButton(tester).onPress, isNull);
    expect(created, isEmpty);
  });

  testWidgets('a filled draft is submitted and toasted', (tester) async {
    final created = await openDialog(
      tester,
      draft: const MealQuickEntryDraft(
        occurredAt: '2026-07-28',
        occurredTime: '12:30',
        title: '午餐',
      ),
    );

    await tester.enterText(
      find.byKey(const Key('record-quick-meal-value-field')),
      '番茄炒蛋',
    );
    await tester.pumpAndSettle();
    expect(confirmButton(tester).onPress, isNotNull);

    await tester.tap(find.byKey(const Key('record-quick-meal-confirm-action')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final input = created.single;
    expect(input.kind, DailyRecordKind.meal);
    expect(input.title, '午餐');
    expect(input.value, '番茄炒蛋');
    expect(input.attachments, isEmpty);
    expect(find.text(l10n.recordCreateSavedToast), findsOneWidget);

    // Drain the toast auto-dismiss timer.
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('a photo-only draft is submitted with no text fields filled', (
    tester,
  ) async {
    final image = MealQuickImage(
      bytes: tinyPngBytes(),
      fileName: 'lunch.jpg',
      contentType: 'image/jpeg',
    );
    final created = await openDialog(
      tester,
      draft: MealQuickEntryDraft(
        occurredAt: '2026-07-28',
        occurredTime: '12:30',
        image: image,
      ),
    );

    expect(confirmButton(tester).onPress, isNotNull);

    await tester.tap(find.byKey(const Key('record-quick-meal-confirm-action')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final input = created.single;
    expect(input.title, isNull);
    expect(input.value, isNull);
    expect(input.note, isNull);
    expect(input.attachments, hasLength(1));
    expect(find.text(l10n.recordCreateSavedToast), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('a rejected save keeps the dialog open and shows the failure '
      'toast', (tester) async {
    final rejected = <DailyRecordCreateInput>[];
    final flow = MealQuickEntryFlow(
      pickImage: (_) async => null,
      uploadImage: (_) async => throw StateError('unused'),
      createRecord: (input) async {
        rejected.add(input);
        throw StateError('backend down');
      },
      emitDataChange: (_) {},
    );

    await tester.pumpWidget(
      TestForuiApp(
        showToaster: true,
        home: Builder(
          builder: (context) => Center(
            child: FButton(
              key: const Key('open-meal-confirmation'),
              onPress: () => showAppDialog<void>(
                context: context,
                maxWidth: 460,
                scrollable: false,
                builder: (_) => MealQuickConfirmationDialog(
                  flow: flow,
                  draft: const MealQuickEntryDraft(
                    occurredAt: '2026-07-28',
                    occurredTime: '12:30',
                    title: '午餐',
                  ),
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('open-meal-confirmation')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('record-quick-meal-confirm-action')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(rejected, hasLength(1));
    expect(find.text(l10n.recordCreateFailedToast), findsOneWidget);
    // 失败后弹窗保留，用户可直接重试。
    expect(
      find.byKey(const Key('record-quick-meal-confirm-action')),
      findsOneWidget,
    );

    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('typing that does not change canSave still updates the button', (
    tester,
  ) async {
    // 输入监听现在只在「确认按钮可点状态」翻转时重建,`_saving` 也参与该状态。
    // 这条用例锁住:在已有内容的基础上继续输入(可点状态不变)之后,
    // 按钮仍然反映最新内容,并且提交拿到的是最新文本。
    final created = await openDialog(
      tester,
      draft: const MealQuickEntryDraft(
        occurredAt: '2026-07-28',
        occurredTime: '12:30',
        title: '午餐',
      ),
    );

    expect(confirmButton(tester).onPress, isNotNull);

    // 可点状态始终为 true,期间不应丢失对最新文本的读取。
    await tester.enterText(
      find.byKey(const Key('record-quick-meal-value-field')),
      '番茄',
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('record-quick-meal-value-field')),
      '番茄炒蛋',
    );
    await tester.pumpAndSettle();

    expect(confirmButton(tester).onPress, isNotNull);

    await tester.tap(find.byKey(const Key('record-quick-meal-confirm-action')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(created.single.value, '番茄炒蛋');
    await tester.pump(const Duration(seconds: 2));
  });
}

DailyRecordItem _record(DailyRecordCreateInput input) {
  return DailyRecordItem(
    id: 'meal-1',
    kind: input.kind,
    occurredAt: input.occurredAt,
    occurredTime: input.occurredTime,
    title: input.title,
    value: input.value,
    unit: input.unit,
    note: input.note,
    attachments: [
      for (final attachment in input.attachments)
        DailyRecordAttachment(
          id: 'attachment-${attachment.objectKey}',
          kind: DailyRecordAttachmentKind.image,
          objectKey: attachment.objectKey,
          fileName: attachment.fileName,
          contentType: attachment.contentType,
          sizeBytes: attachment.sizeBytes,
          publicUrl: attachment.publicUrl,
          createdAt: '2026-07-28T00:00:00.000Z',
        ),
    ],
    createdAt: '2026-07-28T00:00:00.000Z',
    updatedAt: '2026-07-28T00:00:00.000Z',
  );
}
