import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/network/api_exception.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/features/auth/domain/entities/session.dart';
import 'package:luminous/features/health_context/data/providers/health_context.dart';
import 'package:luminous/features/health_context/domain/entities/snapshot.dart';
import 'package:luminous/features/medicine/data/datasources/dose_log_cached.dart';
import 'package:luminous/features/medicine/data/datasources/dose_log_remote.dart';
import 'package:luminous/features/medicine/data/providers/workspace.dart';
import 'package:luminous/features/medicine/domain/entities/dose_log.dart';
import 'package:luminous/features/medicine/domain/entities/reminder.dart';
import 'package:luminous/features/medicine/domain/repositories/dose_log.dart';
import 'package:luminous/features/medicine/domain/repositories/reminder.dart';
import 'package:luminous/features/record/data/providers/record_access.dart';
import 'package:luminous/features/record/data/repositories/lucent.dart';
import 'package:luminous/features/record/domain/entities/candidates.dart';
import 'package:luminous/features/record/domain/entities/dashboard.dart';
import 'package:luminous/features/record/domain/entities/inputs.dart';
import 'package:luminous/features/record/domain/entities/record.dart';
import 'package:luminous/features/record/domain/entities/type_mapping.dart';
import 'package:luminous/features/record/domain/repositories/daily.dart';
import 'package:luminous/features/record/domain/repositories/record.dart';
import 'package:luminous/features/record/presentation/pages/create.dart';
import 'package:luminous/features/record/presentation/pages/detail.dart';
import 'package:luminous/features/record/presentation/pages/edit.dart';
import 'package:luminous/features/record/presentation/pages/page.dart';
import 'package:luminous/features/record/presentation/providers/dashboard.dart';
import 'package:luminous/features/record/presentation/providers/time.dart';
import 'package:luminous/features/record/presentation/quick_entry/meal_flow.dart';
import 'package:luminous/features/record/presentation/widgets/shared/copy.dart';
import 'package:luminous/features/record/presentation/widgets/views/skeleton_view.dart';
import 'package:luminous/l10n/app_localizations.dart';

import '../helpers/feature_mocks.dart';
import '../helpers/test_forui_app.dart';

void main() {
  testWidgets('Record page renders mobile mock dashboard sections', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(480, 1200);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

    await _pumpRecordPage(tester);

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final keys = <String>[
      'record-quick-actions',
      'record-timeline',
      'record-filter-chips',
    ];

    for (final key in keys) {
      final finder = find.byKey(Key(key));
      await _scrollDashboardTo(tester, finder);
      expect(finder, findsOneWidget);
    }

    expect(find.text(l10n.recordQuickSectionTitle), findsOneWidget);
    for (final key in <String>['record-quick-actions', 'record-timeline']) {
      expect(
        find.descendant(of: find.byKey(Key(key)), matching: find.byType(FCard)),
        findsOneWidget,
      );
    }
    expect(
      find.descendant(
        of: find.byKey(const Key('record-filter-chips')),
        matching: find.byType(FCard),
      ),
      findsNothing,
    );
    expect(find.textContaining(l10n.recordTimelineMealName), findsOneWidget);
    expect(find.byKey(const Key('record-calendar-overview')), findsNothing);
    expect(find.byKey(const Key('record-summary')), findsNothing);
    expect(find.byKey(const Key('record-trends')), findsNothing);
    expect(find.byKey(const Key('record-health-bag')), findsNothing);
    expect(find.byKey(const Key('record-quick-operations')), findsNothing);
    expect(find.byKey(const Key('record-guide-row')), findsNothing);
    expect(find.byKey(const Key('record-nlp-fab')), findsNothing);
    expect(find.byKey(const Key('record-quick-sleep')), findsOneWidget);
    expect(find.byKey(const Key('record-quick-vitals')), findsNothing);
    expect(find.text(l10n.recordSummaryLatestVitalTitle), findsNothing);
    expect(find.text('情绪平均'), findsNothing);
    expect(find.text('查看今日报告'), findsNothing);
    expect(
      find.descendant(
        of: find.byKey(const Key('record-quick-sleep')),
        matching: find.text(l10n.recordTypeSleep),
      ),
      findsOneWidget,
    );
    expect(find.text('情绪趋势'), findsNothing);
  });

  testWidgets('Record mobile quick actions fit English labels', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(480, 1200);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));

    await _pumpRecordPage(tester, locale: const Locale('en'));

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('record-quick-medication')), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('record-quick-medication')),
        matching: find.text(l10n.recordTypeMedication),
      ),
      findsOneWidget,
    );
    expect(
      find.text(l10n.recordQuickActionLabel(l10n.recordTypeMedication)),
      findsNothing,
    );
  });

  testWidgets(
    'Record mobile quick actions default to symptom medication water first',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(480, 1200);
      addTearDown(() {
        tester.view.resetDevicePixelRatio();
        tester.view.resetPhysicalSize();
      });

      await _pumpRecordPage(tester);

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final symptom = tester.getTopLeft(
        find.byKey(const Key('record-quick-symptom')),
      );
      final medication = tester.getTopLeft(
        find.byKey(const Key('record-quick-medication')),
      );
      final water = tester.getTopLeft(
        find.byKey(const Key('record-quick-water')),
      );
      final meal = tester.getTopLeft(
        find.byKey(const Key('record-quick-meal')),
      );

      expect(medication.dy, symptom.dy);
      expect(water.dy, symptom.dy);
      expect(medication.dx, greaterThan(symptom.dx));
      expect(water.dx, greaterThan(medication.dx));
      expect(meal.dy, greaterThan(water.dy));
    },
  );

  testWidgets(
    'Record medication quick action prompts when no medicines exist',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(480, 1200);
      addTearDown(() {
        tester.view.resetDevicePixelRatio();
        tester.view.resetPhysicalSize();
      });
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

      await _pumpRecordRouter(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('record-quick-medication')));
      await tester.pumpAndSettle();

      expect(
        find.text(l10n.recordQuickMedicationNoMedicinesTitle),
        findsOneWidget,
      );
      expect(find.text(l10n.recordQuickMedicationAddAction), findsOneWidget);
    },
  );

  testWidgets('Record medication quick action marks one nearby slot taken', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(480, 1200);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });
    final doseLogs = _FakeCachedDoseLogDataSource();

    await _pumpRecordRouter(
      tester,
      healthContextSnapshot: _healthSnapshot(
        currentMedicines: [_currentMedicine(id: 'med-1')],
      ),
      doseLogRepository: doseLogs,
      medicineReminders: [
        _medicineReminder(id: 'rem-1', currentMedicineId: 'med-1', hour: 8),
      ],
      selectedDate: DateTime(2026, 7, 28),
      currentDateTime: DateTime(2026, 7, 28, 8),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('record-quick-medication')));
    await tester.pumpAndSettle();

    expect(doseLogs.markInputs, hasLength(1));
    expect(doseLogs.markInputs.single.currentMedicineId, 'med-1');
    expect(doseLogs.markInputs.single.reminderId, 'rem-1');
    expect(doseLogs.markInputs.single.scheduledTime, '08:00');
    expect(doseLogs.markInputs.single.status, 'taken');
  });

  testWidgets('Record meal quick action confirms camera image and saves', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(480, 1200);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });
    final dailyRepo = _FakeDailyRecordRepository();

    await _pumpRecordRouter(
      tester,
      dailyRecordRepository: dailyRepo,
      selectedDate: DateTime(2026, 7, 28),
      currentDateTime: DateTime(2026, 7, 28, 12, 30),
      mealQuickImagePicker: (_) async => MealQuickImage(
        bytes: _tinyPngBytes(),
        fileName: 'meal.jpg',
        contentType: 'image/jpeg',
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('record-quick-meal')));
    await tester.pumpAndSettle();

    expect(find.text('确认餐食记录'), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('record-quick-meal-value-field')),
      '番茄炒蛋',
    );
    await tester.tap(find.byKey(const Key('record-quick-meal-confirm-action')));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 2));

    expect(dailyRepo.uploadedImages, hasLength(1));
    expect(dailyRepo.createdInputs, hasLength(1));
    final input = dailyRepo.createdInputs.single;
    expect(input.kind, DailyRecordKind.meal);
    expect(input.occurredAt, '2026-07-28');
    expect(input.occurredTime, '12:30');
    expect(input.title, '午餐');
    expect(input.value, '番茄炒蛋');
    expect(input.attachments, hasLength(1));
  });

  testWidgets('Record meal quick action camera cancel writes nothing', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(480, 1200);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });
    final dailyRepo = _FakeDailyRecordRepository();

    await _pumpRecordRouter(
      tester,
      dailyRecordRepository: dailyRepo,
      mealQuickImagePicker: (_) async => null,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('record-quick-meal')));
    await tester.pumpAndSettle();

    expect(dailyRepo.createdInputs, isEmpty);
    expect(dailyRepo.uploadedImages, isEmpty);
    expect(find.text('确认餐食记录'), findsNothing);
  });

  testWidgets('Record page opens natural-language sheet on mobile', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(480, 1200);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    await _pumpRecordPage(
      tester,
      dailyRecordRepository: _FakeDailyRecordRepository(),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('record-nlp-action')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('record-nlp-input-field')), findsOneWidget);
    expect(find.byKey(const Key('record-nlp-generate-action')), findsOneWidget);
  });

  testWidgets('Record mobile timeline exposes explicit view-all continuation', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(480, 1200);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    await _pumpRecordPage(
      tester,
      recordRepository: _LongTimelineRecordRepository(),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final timeline = find.byKey(const Key('record-timeline'));
    await _scrollDashboardTo(tester, timeline);

    expect(find.text('查看全部记录'), findsOneWidget);
    expect(find.text('记录 9'), findsNothing);

    await tester.tap(find.text('查看全部记录'));
    await tester.pumpAndSettle();

    expect(find.text('记录 9'), findsOneWidget);
    expect(find.text('收起'), findsOneWidget);
  });

  testWidgets(
    'Record natural-language sheet edits candidates and saves selected only',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(480, 1200);
      addTearDown(() {
        tester.view.resetDevicePixelRatio();
        tester.view.resetPhysicalSize();
      });

      final repo = _FakeDailyRecordRepository(
        generatedCandidates: const DailyRecordCandidateResult(
          locale: 'zh-CN',
          generatedAt: '2026-06-14T00:00:00.000Z',
          confirmationHint: '确认后再保存。',
          items: [
            DailyRecordCandidateItem(
              kind: DailyRecordKind.meal,
              occurredAt: '2026-06-14',
              title: '午饭',
              value: '米饭',
              note: '食堂',
              rationale: '识别到饮食记录。',
            ),
            DailyRecordCandidateItem(
              kind: DailyRecordKind.note,
              occurredAt: '2026-06-14',
              title: '状态',
              note: '有点困',
              rationale: '识别到备注。',
            ),
          ],
        ),
      );

      await _pumpRecordPage(tester, dailyRecordRepository: repo);

      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('record-nlp-action')));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('record-nlp-input-field')),
        '午饭吃了米饭，下午有点困',
      );
      await tester.tap(find.byKey(const Key('record-nlp-generate-action')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('record-nlp-candidate-title-0')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('record-nlp-candidate-select-1')),
        findsOneWidget,
      );

      await tester.enterText(
        find.byKey(const Key('record-nlp-candidate-title-0')),
        '午饭修正',
      );
      await tester.enterText(
        find.byKey(const Key('record-nlp-candidate-note-0')),
        '自己改过',
      );
      await tester.tap(find.byKey(const Key('record-nlp-candidate-select-1')));
      await tester.pumpAndSettle();

      final saveSelectedAction = find.byKey(
        const Key('record-nlp-save-selected-action'),
      );
      await tester.ensureVisible(saveSelectedAction);
      await tester.pump();
      await tester.tap(saveSelectedAction);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 3));

      expect(repo.createdInputs, hasLength(1));
      expect(repo.createdInputs.single.kind, DailyRecordKind.meal);
      expect(repo.createdInputs.single.title, '午饭修正');
      expect(repo.createdInputs.single.note, '自己改过');
    },
  );

  testWidgets(
    'Record natural-language water candidate uses unit dropdown and saves selected unit',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(480, 1200);
      addTearDown(() {
        tester.view.resetDevicePixelRatio();
        tester.view.resetPhysicalSize();
      });

      final repo = _FakeDailyRecordRepository(
        generatedCandidates: const DailyRecordCandidateResult(
          locale: 'zh-CN',
          generatedAt: '2026-06-14T00:00:00.000Z',
          confirmationHint: '确认后再保存。',
          items: [
            DailyRecordCandidateItem(
              kind: DailyRecordKind.water,
              occurredAt: '2026-06-14',
              value: '2',
              unit: 'cup',
              rationale: '识别到饮水记录。',
            ),
          ],
        ),
      );

      await _pumpRecordPage(tester, dailyRecordRepository: repo);

      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('record-nlp-action')));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('record-nlp-input-field')),
        '今天喝了两杯水',
      );
      await tester.tap(find.byKey(const Key('record-nlp-generate-action')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('record-nlp-candidate-unit-0-cup')),
        findsOneWidget,
      );

      await tester.tap(
        find.byKey(const Key('record-nlp-candidate-unit-0-cup')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('次').last);
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('record-nlp-candidate-unit-0-times')),
        findsOneWidget,
      );

      final saveSelectedAction = find.byKey(
        const Key('record-nlp-save-selected-action'),
      );
      await tester.ensureVisible(saveSelectedAction);
      await tester.pump();
      await tester.tap(saveSelectedAction);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 3));

      expect(repo.createdInputs, hasLength(1));
      expect(repo.createdInputs.single.kind, DailyRecordKind.water);
      expect(repo.createdInputs.single.value, '2');
      expect(repo.createdInputs.single.unit, 'times');
    },
  );

  testWidgets(
    'Record natural-language sheet shows retry action and retries only failed candidates',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(480, 1200);
      addTearDown(() {
        tester.view.resetDevicePixelRatio();
        tester.view.resetPhysicalSize();
      });

      final repo = _FakeDailyRecordRepository(
        generatedCandidates: const DailyRecordCandidateResult(
          locale: 'zh-CN',
          generatedAt: '2026-06-14T00:00:00.000Z',
          confirmationHint: '确认后再保存。',
          items: [
            DailyRecordCandidateItem(
              kind: DailyRecordKind.water,
              occurredAt: '2026-06-14',
              value: '500',
              unit: 'ml',
              rationale: '识别到饮水记录。',
            ),
            DailyRecordCandidateItem(
              kind: DailyRecordKind.note,
              occurredAt: '2026-06-14',
              title: '午后状态',
              note: '有点累',
              rationale: '识别到备注。',
            ),
          ],
        ),
        failCreateAtIndexes: {1},
      );

      await _pumpRecordPage(tester, dailyRecordRepository: repo);

      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('record-nlp-action')));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('record-nlp-input-field')),
        '喝了水，下午有点累',
      );
      await tester.tap(find.byKey(const Key('record-nlp-generate-action')));
      await tester.pumpAndSettle();

      final saveSelectedAction = find.byKey(
        const Key('record-nlp-save-selected-action'),
      );
      await tester.ensureVisible(saveSelectedAction);
      await tester.pump();
      await tester.tap(saveSelectedAction);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 3));

      expect(
        find.byKey(const Key('record-nlp-retry-failed-action')),
        findsOneWidget,
      );
      expect(repo.createdInputs, hasLength(2));

      repo.failCreateAtIndexes.clear();

      await tester.tap(find.byKey(const Key('record-nlp-retry-failed-action')));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 3));

      expect(repo.createdInputs, hasLength(3));
      expect(repo.createdInputs.last.kind, DailyRecordKind.note);
      expect(find.byKey(const Key('record-nlp-input-field')), findsNothing);
    },
  );

  testWidgets(
    'Record page keeps period and vitals quick actions hidden in MVP',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(480, 1200);
      addTearDown(() {
        tester.view.resetDevicePixelRatio();
        tester.view.resetPhysicalSize();
      });
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

      await _pumpRecordPage(
        tester,
        healthContextSnapshot: _healthSnapshot(sexAtBirth: 'female'),
      );
      await tester.pumpAndSettle();

      expect(find.text('记经期'), findsNothing);
      expect(
        find.text(l10n.recordQuickActionLabel(l10n.recordTypeVitals)),
        findsNothing,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('record-quick-sleep')),
          matching: find.text(l10n.recordTypeSleep),
        ),
        findsOneWidget,
      );

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();

      await _pumpRecordPage(
        tester,
        healthContextSnapshot: _healthSnapshot(sexAtBirth: 'male'),
      );
      await tester.pumpAndSettle();

      expect(find.text('记经期'), findsNothing);
      expect(
        find.text(l10n.recordQuickActionLabel(l10n.recordTypeVitals)),
        findsNothing,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('record-quick-sleep')),
          matching: find.text(l10n.recordTypeSleep),
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets('Record loading shows dedicated skeleton placeholder', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(480, 1200);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
    final pending = Completer<RecordDashboard>();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWith(_SignedInAuthSessionNotifier.new),
          recordDashboardProvider.overrideWith((ref) => pending.future),
        ],
        child: const TestForuiApp(home: RecordPage()),
      ),
    );
    await tester.pump();

    expect(find.text(l10n.tabRecord), findsOneWidget);
    expect(find.byType(RecordSkeletonView), findsOneWidget);
    expect(find.byType(InlineSkeletonBlock), findsWidgets);
    expect(find.text(l10n.recordQuickSectionTitle), findsNothing);
  });

  testWidgets('Record edit page pre-fills fields from existing record', (
    tester,
  ) async {
    final repo = _FakeDailyRecordRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dailyRecordRepositoryProvider.overrideWithValue(repo),
          authSessionProvider.overrideWith(
            () => _SignedInAuthSessionNotifier(),
          ),
        ],
        child: TestForuiRouterApp(routerConfig: _buildEditTestRouter()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('编辑'), findsOneWidget);
    expect(find.text('备注'), findsWidgets);
  });

  testWidgets('Record edit page loads by id and clears nullable fields', (
    tester,
  ) async {
    final repo = _FakeDailyRecordRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dailyRecordRepositoryProvider.overrideWithValue(repo),
          authSessionProvider.overrideWith(
            () => _SignedInAuthSessionNotifier(),
          ),
        ],
        child: TestForuiRouterApp(
          routerConfig: _buildEditTestRouter(
            initialLocation: '/record/test-id-1/edit',
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(repo.getCalledWith, 'test-id-1');

    final fields = find.byType(TextField);
    expect(fields, findsNWidgets(6));
    // Clear the title/value/unit/note fields by key. Date/time and kind fields
    // are kept intact.
    for (final key in [
      'daily-record-title-field',
      'daily-record-value-field',
      'daily-record-unit-field',
      'daily-record-note-field',
    ]) {
      await tester.enterText(find.byKey(Key(key)), '');
    }

    final saveButton = find.byKey(const Key('record-edit-save-action'));
    await tester.ensureVisible(saveButton);
    await tester.pump();
    await tester.tap(saveButton);
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 3));

    expect(repo.updateCalledWith, 'test-id-1');
    final input = repo.lastUpdateInput;
    expect(input, isNotNull);
    expect(input!.title, isNull);
    expect(input.value, isNull);
    expect(input.unit, isNull);
    expect(input.note, isNull);
  });

  testWidgets(
    'Record edit page preserves duration-only sleep payload when saving note edits',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(480, 1200);
      addTearDown(() {
        tester.view.resetDevicePixelRatio();
        tester.view.resetPhysicalSize();
      });

      final repo = _FakeDailyRecordRepository(
        itemKind: DailyRecordKind.sleep,
        itemTitle: null,
        itemValue: null,
        itemUnit: null,
        itemNote: null,
        itemPayload: {'durationMinutes': 480},
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            dailyRecordRepositoryProvider.overrideWithValue(repo),
            authSessionProvider.overrideWith(
              () => _SignedInAuthSessionNotifier(),
            ),
          ],
          child: TestForuiRouterApp(routerConfig: _buildEditTestRouter()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byKey(const Key('sleep-bedtime-picker')), findsOneWidget);
      expect(find.byKey(const Key('sleep-waketime-picker')), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('daily-record-note-field')),
        'edit-preserve-time',
      );

      final saveButton = find.byKey(const Key('record-edit-save-action'));
      await tester.ensureVisible(saveButton);
      await tester.pumpAndSettle();
      await tester.tap(saveButton);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 3));

      expect(repo.updateCalledWith, 'test-id-1');
      final input = repo.lastUpdateInput;
      expect(input, isNotNull);
      expect(input!.note, 'edit-preserve-time');
      expect(input.payload, {'durationMinutes': 480});
    },
  );

  testWidgets('Record edit page shows delete confirmation and deletes', (
    tester,
  ) async {
    final repo = _FakeDailyRecordRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dailyRecordRepositoryProvider.overrideWithValue(repo),
          authSessionProvider.overrideWith(
            () => _SignedInAuthSessionNotifier(),
          ),
        ],
        child: TestForuiRouterApp(routerConfig: _buildEditTestRouter()),
      ),
    );

    await tester.pumpAndSettle();

    // Find and tap delete button
    final deleteButton = find.byKey(const Key('record-edit-delete-action'));
    expect(deleteButton, findsOneWidget);
    await tester.ensureVisible(deleteButton);
    await tester.pump();
    await tester.tap(deleteButton);
    await tester.pumpAndSettle();

    // Confirm delete in dialog
    final confirmButton = find.byKey(const Key('record-delete-confirm-action'));
    expect(confirmButton, findsOneWidget);
    await tester.tap(confirmButton);
    await tester.pumpAndSettle();
    // Let toast timer settle
    await tester.pump(const Duration(seconds: 3));

    expect(repo.deleteCalledWith, 'test-id-1');
  });

  testWidgets('Record edit page shows login prompt when signed out', (
    tester,
  ) async {
    final repo = _FakeDailyRecordRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dailyRecordRepositoryProvider.overrideWithValue(repo),
          authSessionProvider.overrideWith(
            () => _SignedOutAuthSessionNotifier(),
          ),
        ],
        child: TestForuiRouterApp(routerConfig: _buildEditTestRouter()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(RecordEditPage), findsOneWidget);
    expect(find.byKey(const Key('auth-required-dialog')), findsOneWidget);
    expect(find.text('尚未登录'), findsOneWidget);
    expect(find.text('是否去登录'), findsOneWidget);
    expect(find.byKey(const Key('auth-required-login-action')), findsOneWidget);

    await tester.tap(find.byKey(const Key('auth-required-login-action')));
    await tester.pumpAndSettle();

    expect(find.text('login-page:/record/test-id-1/edit'), findsOneWidget);
  });

  testWidgets('Record edit page signed-out does not call protected API', (
    tester,
  ) async {
    final repo = _FakeDailyRecordRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dailyRecordRepositoryProvider.overrideWithValue(repo),
          authSessionProvider.overrideWith(
            () => _SignedOutAuthSessionNotifier(),
          ),
        ],
        child: TestForuiRouterApp(routerConfig: _buildEditTestRouter()),
      ),
    );

    await tester.pumpAndSettle();

    // No fetchRecords call should have been made when signed out
    expect(repo.fetchRecordsCalled, isFalse);
  });

  testWidgets('Record detail page renders full saved fields', (tester) async {
    final repo = _FakeDailyRecordRepository(
      itemOccurredAt: '2026-06-06',
      itemOccurredTime: '09:45',
      withAttachment: true,
    );

    await _pumpRecordRouter(
      tester,
      dailyRecordRepository: repo,
      initialLocation: '/record/test-id-1',
    );
    await tester.pumpAndSettle();

    expect(repo.getCalledWith, 'test-id-1');
    expect(find.byType(RecordDetailPage), findsOneWidget);
    expect(find.text('记录详情'), findsOneWidget);
    expect(find.text('Blood pressure'), findsOneWidget);
    expect(find.text('2026-06-06 09:45'), findsOneWidget);
    expect(find.text('118/76 mmHg'), findsOneWidget);
    expect(find.text('This is a note'), findsOneWidget);
    expect(find.text('手动记录'), findsOneWidget);
    expect(find.text('test.jpg'), findsOneWidget);
  });

  testWidgets('Record timeline opens detail page for real record entries', (
    tester,
  ) async {
    final dailyRepo = _FakeDailyRecordRepository();
    final recordRepo = _FakeRecordRepository(withRecordEntry: true);

    await _pumpRecordRouter(
      tester,
      dailyRecordRepository: dailyRepo,
      recordRepository: recordRepo,
    );
    await tester.pumpAndSettle();

    final entry = find.text('Blood pressure');
    await _scrollDashboardTo(tester, entry);
    await tester.ensureVisible(entry);
    await tester.tap(entry);
    await tester.pumpAndSettle();

    expect(dailyRepo.getCalledWith, 'test-id-1');
    expect(find.byType(RecordDetailPage), findsOneWidget);
  });

  testWidgets('Record detail page confirms and deletes record', (tester) async {
    final repo = _FakeDailyRecordRepository();

    await _pumpRecordRouter(
      tester,
      dailyRecordRepository: repo,
      initialLocation: '/record/test-id-1',
    );
    await tester.pumpAndSettle();

    final deleteButton = find.byKey(const Key('record-detail-delete-action'));
    expect(deleteButton, findsOneWidget);
    await tester.ensureVisible(deleteButton);
    await tester.tap(deleteButton);
    await tester.pumpAndSettle();

    final confirmButton = find.byKey(const Key('record-delete-confirm-action'));
    expect(confirmButton, findsOneWidget);
    await tester.tap(confirmButton);
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 3));

    expect(repo.deleteCalledWith, 'test-id-1');
  });

  testWidgets('Record sleep quick action creates a start fact', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(480, 1200);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });
    final dailyRepo = _FakeDailyRecordRepository();
    final currentDateTime = DateTime(2026, 6, 6, 9, 45);
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

    await _pumpRecordRouter(
      tester,
      dailyRecordRepository: dailyRepo,
      selectedDate: DateTime(2026, 6, 6),
      currentDateTime: currentDateTime,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('record-quick-sleep')));
    await tester.pumpAndSettle();

    expect(find.text(l10n.recordQuickSleepTypeTitle), findsOneWidget);
    await tester.tap(find.text(l10n.recordQuickSleepNightAction));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.commonConfirm));
    await tester.pumpAndSettle();

    expect(find.byType(RecordCreatePage), findsNothing);
    final input = dailyRepo.createInput;
    expect(input, isNotNull);
    expect(input!.kind, DailyRecordKind.sleep);
    expect(input.occurredAt, '2026-06-06');
    expect(input.occurredTime, '09:45');
    expect(input.title, isNull);
    expect(input.value, isNull);
    expect(input.unit, isNull);
    expect(input.note, isNull);
    expect(input.payload, {
      'sleepEvent': 'start',
      'eventAt': currentDateTime.toUtc().toIso8601String(),
      'sleepType': 'nightSleep',
    });
  });

  testWidgets('Record sleep quick action records wake and merges confirmed', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(480, 1200);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    final dailyRepo = _FakeDailyRecordRepository(
      recordsByDate: {
        '2026-06-05': [
          _dailyRecord(
            id: 'sleep-start-1',
            kind: DailyRecordKind.sleep,
            occurredAt: '2026-06-05',
            occurredTime: '23:15',
            payload: {
              'sleepEvent': 'start',
              'eventAt': DateTime.utc(2026, 6, 5, 15, 15).toIso8601String(),
            },
          ),
        ],
        '2026-06-06': const <DailyRecordItem>[],
      },
    );

    await _pumpRecordRouter(
      tester,
      dailyRecordRepository: dailyRepo,
      selectedDate: DateTime(2026, 6, 6),
      currentDateTime: DateTime.utc(2026, 6, 5, 23, 10),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('record-quick-sleep')));
    await tester.pumpAndSettle();

    expect(find.text('合并为一条睡眠记录？'), findsOneWidget);
    expect(dailyRepo.createdInputs, hasLength(1));
    expect(dailyRepo.createdInputs.first.payload, {
      'sleepEvent': 'wake',
      'eventAt': DateTime.utc(2026, 6, 5, 23, 10).toIso8601String(),
      'startedRecordId': 'sleep-start-1',
    });

    await tester.tap(find.text('合并'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 2));

    expect(dailyRepo.createdInputs, hasLength(2));
    expect(dailyRepo.createdInputs.last.kind, DailyRecordKind.sleep);
    expect(dailyRepo.createdInputs.last.occurredAt, '2026-06-06');
    expect(dailyRepo.createdInputs.last.payload, {
      'durationMinutes': 475,
      'sleepType': 'nightSleep',
      'startedAt': DateTime.utc(2026, 6, 5, 15, 15).toIso8601String(),
      'endedAt': DateTime.utc(2026, 6, 5, 23, 10).toIso8601String(),
    });
    expect(dailyRepo.deletedIds, ['sleep-start-1', 'created-id-1']);
  });

  testWidgets('Record mobile note quick action opens fast entry first', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(480, 1200);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });
    final dailyRepo = _FakeDailyRecordRepository();

    await _pumpRecordRouter(
      tester,
      dailyRecordRepository: dailyRepo,
      selectedDate: DateTime(2026, 6, 6),
    );
    await tester.pumpAndSettle();

    // Verify the note quick action exists in the tree.
    final noteAction = find.byKey(const Key('record-quick-note'));
    expect(noteAction, findsOneWidget);

    // Ensure it's visible and tap it.
    await tester.ensureVisible(noteAction);
    await tester.pump();
    await tester.tap(noteAction);
    await tester.pumpAndSettle();

    expect(find.byType(RecordCreatePage), findsNothing);
    expect(find.byKey(const Key('record-fast-entry-note')), findsOneWidget);
  });

  testWidgets('Record page previous day action reloads selected date', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1440, 1000);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });
    final repo = _FakeRecordRepository();

    await _pumpRecordPage(
      tester,
      recordRepository: repo,
      authSessionNotifier: _SignedInAuthSessionNotifier.new,
      selectedDate: DateTime(2026, 6, 6),
    );
    await tester.pumpAndSettle();

    expect(repo.requestedDates, contains(DateTime(2026, 6, 6)));

    await tester.tap(find.byKey(const Key('record-date-previous-action')));
    await tester.pumpAndSettle();

    expect(repo.requestedDates, contains(DateTime(2026, 6, 5)));
  });

  testWidgets('Record water quick action records default amount immediately', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(480, 1200);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });
    final dailyRepo = _FakeDailyRecordRepository();
    final currentDateTime = DateTime(2026, 6, 6, 9, 45);

    await _pumpRecordRouter(
      tester,
      dailyRecordRepository: dailyRepo,
      selectedDate: DateTime(2026, 6, 6),
      currentDateTime: currentDateTime,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('record-quick-water')));
    await tester.pumpAndSettle();

    expect(find.byType(RecordCreatePage), findsNothing);
    expect(find.byKey(const Key('record-fast-entry-water')), findsNothing);
    expect(find.byKey(const Key('daily-record-kind-water')), findsNothing);

    expect(dailyRepo.createInput?.kind, DailyRecordKind.water);
    expect(dailyRepo.createInput?.occurredAt, '2026-06-06');
    expect(dailyRepo.createInput?.occurredTime, '09:45');
    expect(dailyRepo.createInput?.value, '250');
    expect(dailyRepo.createInput?.unit, 'ml');
  });

  testWidgets('Record symptom quick action opens fast entry and saves', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(480, 1200);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });
    final dailyRepo = _FakeDailyRecordRepository();
    final currentDateTime = DateTime(2026, 6, 6, 9, 45);

    await _pumpRecordRouter(
      tester,
      dailyRecordRepository: dailyRepo,
      selectedDate: DateTime(2026, 6, 6),
      currentDateTime: currentDateTime,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('record-quick-symptom')));
    await tester.pumpAndSettle();

    expect(find.byType(RecordCreatePage), findsNothing);
    expect(find.byKey(const Key('record-fast-entry-symptom')), findsOneWidget);
    expect(find.byKey(const Key('daily-record-kind-symptom')), findsNothing);

    await tester.tap(
      find.byKey(const Key('record-fast-entry-choice-symptom-0')),
    );
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 2));

    final input = dailyRepo.createInput;
    expect(input, isNotNull);
    expect(input!.kind, DailyRecordKind.symptom);
    expect(input.occurredAt, '2026-06-06');
    expect(input.occurredTime, '09:45');
    expect(input.title, '头痛');
    expect(input.value, '轻度');
    expect(input.unit, isNull);
    expect(input.note, isNull);
  });

  testWidgets(
    'Record symptom quick action supports multi-select confirmation',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(480, 1200);
      addTearDown(() {
        tester.view.resetDevicePixelRatio();
        tester.view.resetPhysicalSize();
      });
      final dailyRepo = _FakeDailyRecordRepository();

      await _pumpRecordRouter(
        tester,
        dailyRecordRepository: dailyRepo,
        selectedDate: DateTime(2026, 6, 6),
        currentDateTime: DateTime(2026, 6, 6, 9, 45),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('record-quick-symptom')));
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(const Key('record-fast-entry-multi-select-action')),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const Key('record-fast-entry-choice-symptom-0')),
      );
      await tester.tap(
        find.byKey(const Key('record-fast-entry-choice-symptom-2')),
      );
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(const Key('record-fast-entry-confirm-action')),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('record-fast-entry-symptom')), findsNothing);
      expect(dailyRepo.createdInputs, hasLength(2));
      expect(dailyRepo.createdInputs.map((input) => input.title), ['头痛', '头晕']);
      expect(dailyRepo.createdInputs.map((input) => input.value), ['轻度', '轻度']);
    },
  );

  testWidgets('Record symptom quick action more opens full create page', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(480, 1200);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    await _pumpRecordRouter(
      tester,
      selectedDate: DateTime(2026, 6, 6),
      currentDateTime: DateTime(2026, 6, 6, 9, 45),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('record-quick-symptom')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('record-fast-entry-more-action')));
    await tester.pumpAndSettle();

    expect(find.byType(RecordCreatePage), findsOneWidget);
    expect(find.byKey(const Key('daily-record-kind-symptom')), findsOneWidget);
    expect(find.text('日期'), findsOneWidget);
    expect(find.text('2026年6月6日'), findsOneWidget);
    expect(find.text('时间'), findsOneWidget);
    expect(find.text('09:45'), findsOneWidget);
  });

  testWidgets('Record note quick action opens fast entry and saves', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(480, 1200);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });
    final dailyRepo = _FakeDailyRecordRepository();
    final currentDateTime = DateTime(2026, 6, 6, 9, 45);

    await _pumpRecordRouter(
      tester,
      dailyRecordRepository: dailyRepo,
      selectedDate: DateTime(2026, 6, 6),
      currentDateTime: currentDateTime,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('record-quick-note')));
    await tester.pumpAndSettle();

    expect(find.byType(RecordCreatePage), findsNothing);
    expect(find.byKey(const Key('record-fast-entry-note')), findsOneWidget);
    expect(find.byKey(const Key('daily-record-kind-note')), findsNothing);

    await tester.tap(find.byKey(const Key('record-fast-entry-choice-note-1')));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 2));

    final input = dailyRepo.createInput;
    expect(input, isNotNull);
    expect(input!.kind, DailyRecordKind.note);
    expect(input.occurredAt, '2026-06-06');
    expect(input.occurredTime, '09:45');
    expect(input.title, '今天有点累');
    expect(input.value, isNull);
    expect(input.unit, isNull);
    expect(input.note, '今天有点累');
  });

  testWidgets('Record note quick action more opens full create page', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(480, 1200);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    await _pumpRecordRouter(
      tester,
      selectedDate: DateTime(2026, 6, 6),
      currentDateTime: DateTime(2026, 6, 6, 9, 45),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('record-quick-note')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('record-fast-entry-more-action')));
    await tester.pumpAndSettle();

    expect(find.byType(RecordCreatePage), findsOneWidget);
    expect(find.byKey(const Key('daily-record-kind-note')), findsOneWidget);
    expect(find.text('日期'), findsOneWidget);
    expect(find.text('2026年6月6日'), findsOneWidget);
    expect(find.text('时间'), findsOneWidget);
    expect(find.text('09:45'), findsOneWidget);
  });

  testWidgets('Record mood quick action opens fast entry and saves', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(480, 1200);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });
    final dailyRepo = _FakeDailyRecordRepository();
    final currentDateTime = DateTime(2026, 6, 6, 9, 45);

    await _pumpRecordRouter(
      tester,
      dailyRecordRepository: dailyRepo,
      selectedDate: DateTime(2026, 6, 6),
      currentDateTime: currentDateTime,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('record-quick-mood')));
    await tester.pumpAndSettle();

    expect(find.byType(RecordCreatePage), findsNothing);
    expect(find.byKey(const Key('record-fast-entry-mood')), findsOneWidget);
    expect(find.byKey(const Key('daily-record-kind-mood')), findsNothing);

    await tester.tap(find.byKey(const Key('record-fast-entry-choice-mood-1')));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 2));

    final input = dailyRepo.createInput;
    expect(input, isNotNull);
    expect(input!.kind, DailyRecordKind.mood);
    expect(input.occurredAt, '2026-06-06');
    expect(input.occurredTime, '09:45');
    expect(input.title, isNull);
    expect(input.value, isNull);
    expect(input.unit, isNull);
    expect(input.note, isNull);
    expect(input.payload, {'moodLevel': 4, 'moodLabel': 'good'});
  });

  testWidgets('Record mood quick action more opens full create page', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(480, 1200);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    await _pumpRecordRouter(
      tester,
      selectedDate: DateTime(2026, 6, 6),
      currentDateTime: DateTime(2026, 6, 6, 9, 45),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('record-quick-mood')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('record-fast-entry-more-action')));
    await tester.pumpAndSettle();

    expect(find.byType(RecordCreatePage), findsOneWidget);
    expect(find.byKey(const Key('daily-record-kind-mood')), findsOneWidget);
    expect(find.text('日期'), findsOneWidget);
    expect(find.text('2026年6月6日'), findsOneWidget);
    expect(find.text('时间'), findsOneWidget);
    expect(find.text('09:45'), findsOneWidget);
  });

  testWidgets('Record mobile quick action shows login dialog when signed out', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(480, 1200);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    await _pumpRecordRouter(
      tester,
      authSessionNotifier: _SignedOutAuthSessionNotifier.new,
      selectedDate: DateTime(2026, 6, 6),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('record-quick-water')));
    await tester.pumpAndSettle();

    expect(find.byType(RecordPage), findsOneWidget);
    expect(find.byType(RecordCreatePage), findsNothing);
    expect(find.byKey(const Key('auth-required-dialog')), findsOneWidget);
    expect(find.text('尚未登录'), findsOneWidget);
    expect(find.text('是否去登录'), findsOneWidget);
    expect(find.text('login-page:/'), findsNothing);

    await tester.tap(find.byKey(const Key('auth-required-cancel-action')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('auth-required-dialog')), findsNothing);
    expect(find.byType(RecordPage), findsOneWidget);
    expect(find.byType(RecordCreatePage), findsNothing);

    await tester.tap(find.byKey(const Key('record-quick-water')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('auth-required-login-action')));
    await tester.pumpAndSettle();

    expect(find.text('login-page:/'), findsOneWidget);
    expect(find.byType(RecordCreatePage), findsNothing);
  });

  testWidgets('Record create water defaults unit to ml', (tester) async {
    final dailyRepo = _FakeDailyRecordRepository();

    await _pumpRecordRouter(
      tester,
      dailyRecordRepository: dailyRepo,
      initialLocation: '/record/create?kind=water&date=2026-06-06',
    );
    await tester.pumpAndSettle();

    // Enter a value (required by front-end validation)
    await tester.enterText(
      find.byKey(const Key('daily-record-value-field')),
      '250',
    );
    await tester.pump();

    final saveButton = find.byKey(const Key('record-create-save-action'));
    await tester.ensureVisible(saveButton);
    await tester.pump();
    await tester.tap(saveButton);
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 2));

    final input = dailyRepo.createInput;
    expect(input, isNotNull);
    expect(input!.kind, DailyRecordKind.water);
    expect(input.occurredAt, '2026-06-06');
    expect(input.title, isNull);
    expect(input.value, '250');
    expect(input.unit, 'ml');
    expect(input.note, isNull);
  });

  testWidgets('Record create symptom sends title and value without unit', (
    tester,
  ) async {
    final dailyRepo = _FakeDailyRecordRepository();

    await _pumpRecordRouter(
      tester,
      dailyRecordRepository: dailyRepo,
      initialLocation: '/record/create?kind=symptom&date=2026-06-06',
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('daily-record-title-field')),
      'Headache',
    );
    await tester.enterText(
      find.byKey(const Key('daily-record-value-field')),
      'Mild',
    );
    await tester.enterText(
      find.byKey(const Key('daily-record-note-field')),
      'After lunch',
    );

    final saveButton = find.byKey(const Key('record-create-save-action'));
    await tester.ensureVisible(saveButton);
    await tester.pump();
    await tester.tap(saveButton);
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 2));

    final input = dailyRepo.createInput;
    expect(input, isNotNull);
    expect(input!.kind, DailyRecordKind.symptom);
    expect(input.title, 'Headache');
    expect(input.value, 'Mild');
    expect(input.unit, isNull);
    expect(input.note, 'After lunch');
  });

  testWidgets('Record create note sends title and note without value or unit', (
    tester,
  ) async {
    final dailyRepo = _FakeDailyRecordRepository();

    await _pumpRecordRouter(
      tester,
      dailyRecordRepository: dailyRepo,
      initialLocation: '/record/create?kind=note&date=2026-06-06',
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('daily-record-title-field')),
      'Quiet day',
    );
    await tester.enterText(
      find.byKey(const Key('daily-record-note-field')),
      'No special symptoms',
    );

    final saveButton = find.byKey(const Key('record-create-save-action'));
    await tester.ensureVisible(saveButton);
    await tester.pump();
    await tester.tap(saveButton);
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 2));

    final input = dailyRepo.createInput;
    expect(input, isNotNull);
    expect(input!.kind, DailyRecordKind.note);
    expect(input.title, 'Quiet day');
    expect(input.value, isNull);
    expect(input.unit, isNull);
    expect(input.note, 'No special symptoms');
  });

  testWidgets('Record edit water can clear value and note', (tester) async {
    final repo = _FakeDailyRecordRepository(
      itemKind: DailyRecordKind.water,
      itemTitle: null,
      itemValue: '500',
      itemUnit: 'ml',
      itemNote: 'Morning water',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dailyRecordRepositoryProvider.overrideWithValue(repo),
          authSessionProvider.overrideWith(
            () => _SignedInAuthSessionNotifier(),
          ),
        ],
        child: TestForuiRouterApp(
          routerConfig: _buildEditTestRouter(
            initialLocation: '/record/test-id-1/edit',
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byKey(const Key('daily-record-title-field')), findsNothing);
    await tester.enterText(
      find.byKey(const Key('daily-record-value-field')),
      '',
    );
    await tester.enterText(
      find.byKey(const Key('daily-record-note-field')),
      '',
    );

    final saveButton = find.byKey(const Key('record-edit-save-action'));
    await tester.ensureVisible(saveButton);
    await tester.pump();
    await tester.tap(saveButton);
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 3));

    final input = repo.lastUpdateInput;
    expect(input, isNotNull);
    expect(input!.kind, DailyRecordKind.water);
    expect(input.title, isNull);
    expect(input.value, isNull);
    expect(input.unit, 'ml');
    expect(input.note, isNull);
  });

  testWidgets('Record mobile filter chip reloads dashboard by type', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(480, 1200);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });
    final repo = _FakeRecordRepository();
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

    await _pumpRecordRouter(tester, recordRepository: repo);
    await tester.pumpAndSettle();

    final filter = find.byKey(const Key('record-filter-water'));
    await _scrollDashboardTo(tester, filter);
    await tester.ensureVisible(filter);
    await tester.tap(filter);
    await tester.pumpAndSettle();

    expect(repo.requestedFilters, contains(RecordEntryType.water));
    expect(find.textContaining(l10n.recordTimelineWaterAmount), findsOneWidget);
    expect(find.textContaining(l10n.recordTimelineMealName), findsNothing);
  });

  test(
    'Lucent record repository uses selected date and occurredAt time',
    () async {
      final dailyRepo = _FakeDailyRecordRepository(
        itemOccurredAt: '2026-06-06',
        itemOccurredTime: '09:45',
        itemKind: DailyRecordKind.symptom,
        itemTitle: 'Headache',
        itemValue: 'mild',
        itemUnit: null,
      );
      final repo = LucentRecordRepository(dailyRecordRepo: dailyRepo);

      final dashboard = await repo.fetchDashboard(DateTime(2026, 6, 6));

      expect(dailyRepo.fetchDate, '2026-06-06');
      expect(dashboard.selectedDay, 6);
      expect(dashboard.timeline.single.time, '09:45');
    },
  );

  test(
    'Lucent record repository shows sleep duration from payload when value is null',
    () async {
      final dailyRepo = _FakeDailyRecordRepository(
        itemKind: DailyRecordKind.sleep,
        itemTitle: null,
        itemValue: null,
        itemUnit: null,
        itemNote: null,
        itemPayload: {'durationMinutes': 480},
      );
      final repo = LucentRecordRepository(dailyRecordRepo: dailyRepo);

      final dashboard = await repo.fetchDashboard(DateTime(2026, 6, 6));

      expect(dashboard.timeline.single.value, '8h');
    },
  );

  test(
    'Lucent record repository shows sleep duration with minutes from payload',
    () async {
      final dailyRepo = _FakeDailyRecordRepository(
        itemKind: DailyRecordKind.sleep,
        itemTitle: null,
        itemValue: null,
        itemUnit: null,
        itemNote: null,
        itemPayload: {'durationMinutes': 450},
      );
      final repo = LucentRecordRepository(dailyRecordRepo: dailyRepo);

      final dashboard = await repo.fetchDashboard(DateTime(2026, 6, 6));

      expect(dashboard.timeline.single.value, '7h 30m');
    },
  );

  test(
    'Lucent record repository shows mood level from payload when value is null',
    () async {
      final dailyRepo = _FakeDailyRecordRepository(
        itemKind: DailyRecordKind.mood,
        itemTitle: null,
        itemValue: null,
        itemUnit: null,
        itemNote: null,
        itemPayload: {'moodLevel': 4, 'moodLabel': 'good'},
      );
      final repo = LucentRecordRepository(dailyRecordRepo: dailyRepo);

      final dashboard = await repo.fetchDashboard(DateTime(2026, 6, 6));

      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

      expect(dashboard.timeline.single.rawTitle, isNull);
      expect(dashboard.timeline.single.titleKey, RecordCopyKey.typeMood);
      expect(dashboard.timeline.single.value, isNull);
      expect(
        dashboard.timeline.single.valueKey,
        RecordCopyKey.timelineMoodGood,
      );
      expect(recordCopy(l10n, dashboard.timeline.single.valueKey!), '情绪 · 不错');
    },
  );

  test(
    'Lucent record repository surfaces meal analysis summary and badge',
    () async {
      final dailyRepo = _FakeDailyRecordRepository(
        itemKind: DailyRecordKind.meal,
        itemTitle: null,
        itemValue: null,
        itemUnit: null,
        itemNote: null,
        itemPayload: const {
          'mealAnalysis': {
            'analysisStatus': 'unconfirmed',
            'coverage': 'partial',
            'mealDescription': '一份米饭配鸡胸肉',
          },
        },
        itemMealAnalysisStatus: 'unconfirmed',
        itemMealAnalysisCoverage: 'partial',
        itemMealShortDescription: '一份米饭配鸡胸肉',
        itemMealTopFoods: const ['米饭', '鸡胸肉'],
      );
      final repo = LucentRecordRepository(dailyRecordRepo: dailyRepo);

      final dashboard = await repo.fetchDashboard(DateTime(2026, 6, 6));

      expect(dashboard.timeline.single.rawTitle, '一份米饭配鸡胸肉');
      expect(dashboard.timeline.single.rawDetail, '识别菜品：米饭、鸡胸肉');
      expect(
        dashboard.timeline.single.badgeKey,
        RecordCopyKey.timelineMealEstimateBadge,
      );
    },
  );

  test('recordEntryTypeForDailyRecordKind maps note to note type', () {
    expect(
      recordEntryTypeForDailyRecordKind(DailyRecordKind.note),
      RecordEntryType.note,
    );
  });

  test('dailyRecordKindForEntryType maps note type to note kind', () {
    expect(
      dailyRecordKindForEntryType(RecordEntryType.note),
      DailyRecordKind.note,
    );
  });

  test(
    'Lucent record repository does not fall back to mock timeline for empty filter results',
    () async {
      final dailyRepo = _FakeDailyRecordRepository(fetchThrows: true);
      final repo = LucentRecordRepository(dailyRecordRepo: dailyRepo);

      final dashboard = await repo.fetchDashboard(
        DateTime(2026, 6, 6),
        filterType: RecordEntryType.note,
      );

      // Fetch failed, so no real records; timeline must be empty, not mock.
      expect(dashboard.timeline, isEmpty);
    },
  );

  test(
    'Lucent timeline note without title leaves rawTitle null for localized fallback',
    () async {
      final dailyRepo = _FakeDailyRecordRepository(
        itemOccurredAt: '2026-06-06',
        itemOccurredTime: '14:00',
        itemKind: DailyRecordKind.note,
        itemTitle: null,
        itemValue: null,
        itemUnit: null,
        itemNote: 'Slept well tonight',
      );
      final repo = LucentRecordRepository(dailyRecordRepo: dailyRepo);

      final dashboard = await repo.fetchDashboard(DateTime(2026, 6, 6));

      expect(dashboard.timeline.single.rawTitle, isNull);
      expect(dashboard.timeline.single.titleKey, RecordCopyKey.typeNote);
    },
  );

  test('Lucent timeline note with title uses it as rawTitle', () async {
    final dailyRepo = _FakeDailyRecordRepository(
      itemOccurredAt: '2026-06-06',
      itemOccurredTime: '14:00',
      itemKind: DailyRecordKind.note,
      itemTitle: 'Evening reflection',
      itemValue: null,
      itemUnit: null,
      itemNote: 'Felt good today',
    );
    final repo = LucentRecordRepository(dailyRecordRepo: dailyRepo);

    final dashboard = await repo.fetchDashboard(DateTime(2026, 6, 6));

    expect(dashboard.timeline.single.rawTitle, 'Evening reflection');
    expect(dashboard.timeline.single.titleKey, RecordCopyKey.typeNote);
  });

  test(
    'Lucent timeline uses type-dependent titleKey instead of hardcoded typeMood',
    () async {
      final dailyRepo = _FakeDailyRecordRepository(
        itemOccurredAt: '2026-06-06',
        itemOccurredTime: '08:00',
        itemKind: DailyRecordKind.water,
        itemTitle: null,
        itemValue: '500',
        itemUnit: 'ml',
      );
      final repo = LucentRecordRepository(dailyRecordRepo: dailyRepo);

      final dashboard = await repo.fetchDashboard(DateTime(2026, 6, 6));

      expect(dashboard.timeline.single.titleKey, RecordCopyKey.typeWater);
    },
  );

  testWidgets('Record page uses desktop side rails', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1440, 1000);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    await _pumpRecordPage(tester);

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byKey(const Key('record-calendar-panel')), findsOneWidget);
    expect(find.byKey(const Key('record-filter-panel')), findsOneWidget);
    expect(find.byKey(const Key('record-new-entry-panel')), findsOneWidget);
    expect(find.byKey(const Key('record-timeline')), findsOneWidget);
  });
  testWidgets('Record error state shows StateErrorView with retry', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(480, 1200);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWith(_SignedInAuthSessionNotifier.new),
          recordDashboardProvider.overrideWith(
            (ref) => Future<RecordDashboard>.error(Exception('test error')),
          ),
        ],
        child: const TestForuiApp(home: RecordPage()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(StateErrorView), findsOneWidget);
    expect(find.text(l10n.recordErrorTitle), findsOneWidget);
    expect(find.text(l10n.recordErrorDescription), findsOneWidget);
    expect(find.text(l10n.todayRetryAction), findsOneWidget);
  });
}

Future<void> _pumpRecordRouter(
  WidgetTester tester, {
  DailyRecordRepository? dailyRecordRepository,
  RecordRepository? recordRepository,
  HealthContextSnapshot? healthContextSnapshot,
  DoseLogRepository? doseLogRepository,
  List<MedicineReminderItem> medicineReminders = const [],
  String initialLocation = '/',
  DateTime? selectedDate,
  DateTime? currentDateTime,
  AuthSessionNotifier Function()? authSessionNotifier,
  PickMealQuickImage? mealQuickImagePicker,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        dailyRecordRepositoryProvider.overrideWithValue(
          dailyRecordRepository ?? _FakeDailyRecordRepository(),
        ),
        recordRepositoryProvider.overrideWithValue(
          recordRepository ?? const MockRecordRepository(),
        ),
        authSessionProvider.overrideWith(
          authSessionNotifier ?? _SignedInAuthSessionNotifier.new,
        ),
        healthContextSnapshotProvider.overrideWith(
          (ref) async => healthContextSnapshot ?? _healthSnapshot(),
        ),
        doseLogRepositoryProvider.overrideWith(
          (ref) => doseLogRepository ?? _FakeCachedDoseLogDataSource(),
        ),
        reminderRepositoryProvider.overrideWith(
          (ref) => _FakeReminderRepository(medicineReminders),
        ),
        if (mealQuickImagePicker != null)
          mealQuickImagePickerProvider.overrideWithValue(mealQuickImagePicker),
        if (selectedDate != null)
          selectedRecordDateProvider.overrideWith(
            () => _FixedSelectedRecordDateNotifier(selectedDate),
          ),
        if (currentDateTime != null)
          currentRecordDateTimeProvider.overrideWithValue(currentDateTime),
      ],
      child: TestForuiRouterApp(
        routerConfig: _buildRecordTestRouter(initialLocation),
      ),
    ),
  );
}

Future<void> _pumpRecordPage(
  WidgetTester tester, {
  RecordRepository recordRepository = const MockRecordRepository(),
  DailyRecordRepository? dailyRecordRepository,
  AuthSessionNotifier Function()? authSessionNotifier,
  HealthContextSnapshot? healthContextSnapshot,
  DateTime? selectedDate,
  DateTime? currentDateTime,
  Locale locale = const Locale('zh'),
}) async {
  final overrides = [
    recordRepositoryProvider.overrideWithValue(recordRepository),
    dailyRecordRepositoryProvider.overrideWithValue(
      dailyRecordRepository ?? _FakeDailyRecordRepository(),
    ),
    authSessionProvider.overrideWith(
      authSessionNotifier ?? _SignedInAuthSessionNotifier.new,
    ),
    healthContextSnapshotProvider.overrideWith(
      (ref) async => healthContextSnapshot ?? _healthSnapshot(),
    ),
    if (selectedDate != null)
      selectedRecordDateProvider.overrideWith(
        () => _FixedSelectedRecordDateNotifier(selectedDate),
      ),
    if (currentDateTime != null)
      currentRecordDateTimeProvider.overrideWithValue(currentDateTime),
  ];

  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: TestForuiApp(locale: locale, home: const RecordPage()),
    ),
  );
}

class _FixedSelectedRecordDateNotifier extends SelectedRecordDateNotifier {
  _FixedSelectedRecordDateNotifier(this.initialDate);

  final DateTime initialDate;

  @override
  DateTime build() =>
      DateTime(initialDate.year, initialDate.month, initialDate.day);
}

GoRouter _buildRecordTestRouter(String initialLocation) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(path: '/', builder: (context, state) => const RecordPage()),
      GoRoute(
        path: '/record/create',
        builder: (context, state) => RecordCreatePage(
          initialKind: dailyRecordKindFromName(
            state.uri.queryParameters['kind'],
          ),
          initialDate: _parseRecordDate(state.uri.queryParameters['date']),
          initialTime: state.uri.queryParameters['time'],
        ),
      ),
      GoRoute(
        path: '/record/:id',
        builder: (context, state) =>
            RecordDetailPage(recordId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/record/:id/edit',
        builder: (context, state) =>
            RecordEditPage(recordId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => Scaffold(
          body: Text("login-page:${state.uri.queryParameters['return-to']}"),
        ),
      ),
    ],
  );
}

DateTime? _parseRecordDate(String? value) {
  if (value == null) return null;
  final parsed = DateTime.tryParse(value);
  if (parsed == null) return null;
  return DateTime(parsed.year, parsed.month, parsed.day);
}

GoRouter _buildEditTestRouter({
  String initialLocation = '/record/test-id-1/edit',
}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/record/:id/edit',
        builder: (context, state) =>
            RecordEditPage(recordId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => Scaffold(
          body: Text("login-page:${state.uri.queryParameters['return-to']}"),
        ),
      ),
    ],
  );
}

class _FakeDailyRecordRepository implements DailyRecordRepository {
  _FakeDailyRecordRepository({
    this.itemOccurredAt,
    this.itemOccurredTime,
    this.itemKind = DailyRecordKind.vital,
    this.itemTitle = 'Blood pressure',
    this.itemValue = '118/76',
    this.itemUnit = 'mmHg',
    this.itemNote = 'This is a note',
    this.itemPayload,
    this.itemMealAnalysisStatus,
    this.itemMealAnalysisCoverage,
    this.itemMealShortDescription,
    this.itemMealTopFoods = const <String>[],
    this.withAttachment = false,
    this.fetchThrows = false,
    this.generatedCandidates,
    this.failCreateAtIndexes = const <int>{},
    this.recordsByDate,
  });

  final String? itemOccurredAt;
  final String? itemOccurredTime;
  final DailyRecordKind itemKind;
  final String? itemTitle;
  final String? itemValue;
  final String? itemUnit;
  final String? itemNote;
  final Map<String, dynamic>? itemPayload;
  final String? itemMealAnalysisStatus;
  final String? itemMealAnalysisCoverage;
  final String? itemMealShortDescription;
  final List<String> itemMealTopFoods;
  final bool withAttachment;
  final bool fetchThrows;
  final DailyRecordCandidateResult? generatedCandidates;
  final Set<int> failCreateAtIndexes;
  final Map<String, List<DailyRecordItem>>? recordsByDate;
  String? deleteCalledWith;
  String? updateCalledWith;
  String? getCalledWith;
  String? fetchDate;
  DailyRecordUpdateInput? lastUpdateInput;
  DailyRecordCreateInput? createInput;
  final List<DailyRecordCreateInput> createdInputs = <DailyRecordCreateInput>[];
  final List<DailyRecordImageUploadInput> uploadedImages =
      <DailyRecordImageUploadInput>[];
  final List<String> deletedIds = <String>[];
  bool fetchRecordsCalled = false;

  @override
  Future<DailyRecordListData> fetchRecords(
    String date, {
    String? kind,
    int page = 1,
    int pageSize = 50,
  }) async {
    fetchRecordsCalled = true;
    fetchDate = date;
    if (fetchThrows) throw Exception('fetch error');
    final records = recordsByDate?[date];
    if (records != null) {
      return DailyRecordListData(items: records, total: records.length);
    }
    return DailyRecordListData(
      items: [
        DailyRecordItem(
          id: 'test-id-1',
          kind: itemKind,
          occurredAt: itemOccurredAt ?? date,
          occurredTime: itemOccurredTime,
          title: itemTitle,
          value: itemValue,
          unit: itemUnit,
          note: itemNote,
          payload: itemPayload,
          mealAnalysisStatus: itemMealAnalysisStatus,
          mealAnalysisCoverage: itemMealAnalysisCoverage,
          mealShortDescription: itemMealShortDescription,
          mealTopFoods: itemMealTopFoods,
          source: 'manual',
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
        ),
      ],
      total: 1,
    );
  }

  @override
  Future<DailyRecordCandidateResult> generateCandidates({
    required String text,
    required String occurredAt,
  }) async {
    return generatedCandidates ??
        const DailyRecordCandidateResult(
          locale: 'zh-CN',
          generatedAt: '2026-06-14T00:00:00.000Z',
          confirmationHint: '确认后再保存。',
          items: <DailyRecordCandidateItem>[],
        );
  }

  @override
  Future<DailyRecordItem> get(String id) async {
    getCalledWith = id;
    return DailyRecordItem(
      id: id,
      kind: itemKind,
      occurredAt: itemOccurredAt ?? '2026-05-20',
      occurredTime: itemOccurredTime,
      title: itemTitle,
      value: itemValue,
      unit: itemUnit,
      note: itemNote,
      payload: itemPayload,
      mealAnalysisStatus: itemMealAnalysisStatus,
      mealAnalysisCoverage: itemMealAnalysisCoverage,
      mealShortDescription: itemMealShortDescription,
      mealTopFoods: itemMealTopFoods,
      source: 'manual',
      attachments: withAttachment
          ? [
              DailyRecordAttachment(
                id: 'attachment-1',
                kind: DailyRecordAttachmentKind.image,
                objectKey: 'daily-records/user-1/test.jpg',
                fileName: 'test.jpg',
                contentType: 'image/jpeg',
                sizeBytes: 12,
                publicUrl: 'https://cdn.example.com/test.jpg',
                createdAt: DateTime.now().toIso8601String(),
              ),
            ]
          : const <DailyRecordAttachment>[],
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    );
  }

  @override
  Future<DailyRecordAttachmentInput> uploadImage(
    DailyRecordImageUploadInput input,
  ) async {
    uploadedImages.add(input);
    return DailyRecordAttachmentInput(
      objectKey: 'daily-records/user-1/test.jpg',
      bucket: 'bucket',
      provider: 'tencent-cos',
      fileName: input.fileName,
      contentType: input.contentType,
      sizeBytes: input.sizeBytes,
      publicUrl: 'https://cdn.example.com/test.jpg',
    );
  }

  @override
  Future<DailyRecordSummaryData> fetchSummary(String date) async {
    return const DailyRecordSummaryData(summaries: []);
  }

  @override
  Future<DailyRecordItem> create(DailyRecordCreateInput input) async {
    createInput = input;
    createdInputs.add(input);
    final createIndex = createdInputs.length - 1;
    if (failCreateAtIndexes.contains(createIndex)) {
      throw const LucentApiException(message: 'Create failed.');
    }
    return DailyRecordItem(
      id: 'created-id-${createIndex + 1}',
      kind: input.kind,
      occurredAt: input.occurredAt,
      occurredTime: input.occurredTime,
      title: input.title,
      value: input.value,
      unit: input.unit,
      note: input.note,
      payload: input.payload,
      mealAnalysisStatus: itemMealAnalysisStatus,
      mealAnalysisCoverage: itemMealAnalysisCoverage,
      mealShortDescription: itemMealShortDescription,
      mealTopFoods: itemMealTopFoods,
      source: 'manual',
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    );
  }

  @override
  Future<DailyRecordItem> update(
    String id,
    DailyRecordUpdateInput input,
  ) async {
    updateCalledWith = id;
    lastUpdateInput = input;
    return DailyRecordItem(
      id: id,
      kind: DailyRecordKind.vital,
      occurredAt:
          (input.occurredAt == dailyRecordNoChange
              ? fetchDate
              : input.occurredAt as String?) ??
          '2026-05-20',
      occurredTime: input.occurredTime == dailyRecordNoChange
          ? itemOccurredTime
          : input.occurredTime as String?,
      title: input.title as String?,
      value: input.value as String?,
      unit: input.unit as String?,
      note: input.note as String?,
      source: 'manual',
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    );
  }

  @override
  Future<void> delete(String id) async {
    deleteCalledWith = id;
    deletedIds.add(id);
  }
}

DailyRecordItem _dailyRecord({
  required String id,
  required DailyRecordKind kind,
  required String occurredAt,
  String? occurredTime,
  String? title,
  String? value,
  String? unit,
  String? note,
  Map<String, dynamic>? payload,
}) {
  return DailyRecordItem(
    id: id,
    kind: kind,
    occurredAt: occurredAt,
    occurredTime: occurredTime,
    title: title,
    value: value,
    unit: unit,
    note: note,
    payload: payload,
    source: 'manual',
    createdAt: DateTime.now().toIso8601String(),
    updatedAt: DateTime.now().toIso8601String(),
  );
}

Uint8List _tinyPngBytes() {
  return Uint8List.fromList(const [
    0x89,
    0x50,
    0x4e,
    0x47,
    0x0d,
    0x0a,
    0x1a,
    0x0a,
    0x00,
    0x00,
    0x00,
    0x0d,
    0x49,
    0x48,
    0x44,
    0x52,
    0x00,
    0x00,
    0x00,
    0x01,
    0x00,
    0x00,
    0x00,
    0x01,
    0x08,
    0x06,
    0x00,
    0x00,
    0x00,
    0x1f,
    0x15,
    0xc4,
    0x89,
    0x00,
    0x00,
    0x00,
    0x0a,
    0x49,
    0x44,
    0x41,
    0x54,
    0x78,
    0x9c,
    0x63,
    0x00,
    0x01,
    0x00,
    0x00,
    0x05,
    0x00,
    0x01,
    0x0d,
    0x0a,
    0x2d,
    0xb4,
    0x00,
    0x00,
    0x00,
    0x00,
    0x49,
    0x45,
    0x4e,
    0x44,
    0xae,
    0x42,
    0x60,
    0x82,
  ]);
}

class _FakeRecordRepository implements RecordRepository {
  _FakeRecordRepository({this.withRecordEntry = false});

  final bool withRecordEntry;
  final requestedDates = <DateTime>[];
  final requestedFilters = <RecordEntryType?>[];

  @override
  Future<RecordDashboard> fetchDashboard(
    DateTime selectedDate, {
    RecordEntryType? filterType,
  }) async {
    requestedDates.add(selectedDate);
    requestedFilters.add(filterType);
    final mock = await const MockRecordRepository().fetchDashboard(
      selectedDate,
      filterType: filterType,
    );
    final timeline = withRecordEntry
        ? [
            const RecordTimelineEntry(
              time: '09:45',
              type: RecordEntryType.vitals,
              icon: SemanticIcons.profileCondition,
              accent: SemanticColor.primary,
              softColor: SemanticColor.neutral,
              titleKey: RecordCopyKey.typeVitals,
              rawTitle: 'Blood pressure',
              value: '118/76 mmHg',
              recordId: 'test-id-1',
            ),
          ]
        : mock.timeline;
    return RecordDashboard(
      selectedDate: selectedDate,
      selectedDay: selectedDate.day,
      monthDays: mock.monthDays,
      quickActions: mock.quickActions,
      summary: mock.summary,
      filters: mock.filters,
      timeline: timeline,
      trends: mock.trends,
    );
  }

  @override
  Future<RecordDashboard> signedOutDashboard(
    DateTime selectedDate, {
    RecordEntryType? filterType,
  }) => Future.value(RecordDashboard.signedOut(selectedDate));
}

class _LongTimelineRecordRepository implements RecordRepository {
  @override
  Future<RecordDashboard> fetchDashboard(
    DateTime selectedDate, {
    RecordEntryType? filterType,
  }) async {
    final mock = await const MockRecordRepository().fetchDashboard(
      selectedDate,
      filterType: filterType,
    );
    final timeline = List<RecordTimelineEntry>.generate(9, (index) {
      final hour = 8 + (index * 2) ~/ 3;
      final minute = (index % 3) * 15;
      final time =
          '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
      return RecordTimelineEntry(
        time: time,
        type: RecordEntryType.note,
        icon: SemanticIcons.tabRecord,
        accent: SemanticColor.primary,
        softColor: SemanticColor.neutral,
        titleKey: RecordCopyKey.typeNote,
        rawTitle: '记录 ${index + 1}',
        value: '第 ${index + 1} 条',
        recordId: 'record-${index + 1}',
      );
    });
    return RecordDashboard(
      selectedDate: selectedDate,
      selectedDay: selectedDate.day,
      monthDays: mock.monthDays,
      quickActions: mock.quickActions,
      summary: mock.summary,
      filters: mock.filters,
      timeline: timeline,
      trends: mock.trends,
    );
  }

  @override
  Future<RecordDashboard> signedOutDashboard(
    DateTime selectedDate, {
    RecordEntryType? filterType,
  }) {
    return Future.value(RecordDashboard.signedOut(selectedDate));
  }
}

class _SignedInAuthSessionNotifier extends AuthSessionNotifier {
  @override
  AuthSessionState build() {
    return AuthSessionState(
      isAuthenticated: true,
      isLoading: false,
      user: AuthUser(
        id: 'user-1',
        email: 'user@example.com',
        nickname: 'Lumi',
        avatar: null,
        emailVerifiedAt: DateTime.parse('2026-01-01T00:00:00Z'),
        createdAt: DateTime.parse('2026-01-01T00:00:00Z'),
        updatedAt: DateTime.parse('2026-01-02T00:00:00Z'),
      ),
    );
  }
}

class _SignedOutAuthSessionNotifier extends AuthSessionNotifier {
  @override
  AuthSessionState build() {
    return const AuthSessionState(isAuthenticated: false, isLoading: false);
  }
}

HealthContextSnapshot _healthSnapshot({
  String? sexAtBirth = 'male',
  List<CurrentMedicineItem> currentMedicines = const <CurrentMedicineItem>[],
}) {
  return HealthContextSnapshot(
    summary: const HealthSummary(
      age: 27,
      onboardingCompleted: true,
      activeAllergyCount: 2,
      conditionCount: 1,
      currentMedicineCount: 3,
      missingCoreProfileFields: ['bloodType'],
    ),
    profile: HealthProfile(
      birthDate: '1999-01-15',
      sexAtBirth: sexAtBirth,
      heightCm: null,
      weightKg: null,
      bloodType: null,
      locale: null,
      timezone: null,
      unitSystem: null,
      onboardingCompletedAt: '2026-01-01T00:00:00Z',
      emergencyContactName: null,
      emergencyContactPhone: null,
      extras: {},
    ),
    allergies: const <AllergyItem>[],
    conditions: const <ConditionItem>[],
    currentMedicines: currentMedicines,
  );
}

CurrentMedicineItem _currentMedicine({required String id}) {
  return CurrentMedicineItem(
    id: id,
    source: 'manual',
    sourceRefId: null,
    displayName: 'Medicine $id',
    strengthText: '10mg',
    doseText: '1 tablet',
    route: null,
    startedAt: null,
    endedAt: null,
    isCurrent: true,
    note: null,
    createdAt: '2026-07-28T08:00:00Z',
    updatedAt: '2026-07-28T08:00:00Z',
  );
}

MedicineReminderItem _medicineReminder({
  required String id,
  required String currentMedicineId,
  required int hour,
}) {
  return MedicineReminderItem(
    id: id,
    currentMedicineId: currentMedicineId,
    scheduledHour: hour,
    scheduledMinute: 0,
    isActive: true,
    createdAt: '2026-07-28T08:00:00Z',
    updatedAt: '2026-07-28T08:00:00Z',
  );
}

class _CapturedDoseMark {
  const _CapturedDoseMark({
    required this.currentMedicineId,
    required this.status,
    required this.date,
    this.reminderId,
    this.scheduledTime,
  });

  final String currentMedicineId;
  final String status;
  final String date;
  final String? reminderId;
  final String? scheduledTime;
}

class _FakeCachedDoseLogDataSource implements CachedDoseLogDataSource {
  final logs = <DoseLogItem>[];
  final markInputs = <_CapturedDoseMark>[];
  final deletedIds = <String>[];
  final updated = <String, String>{};

  @override
  TaskEither<LucentFailure, List<DoseLogItem>> fetchForDate(String date) =>
      TaskEither.right(logs);

  @override
  TaskEither<LucentFailure, DoseLogItem> mark({
    required String currentMedicineId,
    required String status,
    required String date,
    String? reminderId,
    String? scheduledTime,
  }) {
    markInputs.add(
      _CapturedDoseMark(
        currentMedicineId: currentMedicineId,
        status: status,
        date: date,
        reminderId: reminderId,
        scheduledTime: scheduledTime,
      ),
    );
    return TaskEither.right(
      DoseLogItem(
        id: 'dose-${markInputs.length}',
        currentMedicineId: currentMedicineId,
        reminderId: reminderId,
        status: DoseLogStatus.taken,
        scheduledFor: date,
        scheduledTime: scheduledTime,
        createdAt: '2026-07-28T08:00:00Z',
        updatedAt: '2026-07-28T08:00:00Z',
      ),
    );
  }

  @override
  TaskEither<LucentFailure, void> delete(
    String doseLogId, {
    required String date,
  }) {
    deletedIds.add(doseLogId);
    return TaskEither.right(null);
  }

  @override
  TaskEither<LucentFailure, DoseLogItem> update(
    String doseLogId,
    String status,
  ) {
    updated[doseLogId] = status;
    return TaskEither.right(
      DoseLogItem(
        id: doseLogId,
        status: DoseLogStatus.values.firstWhere(
          (value) => value.name == status,
        ),
        scheduledFor: '2026-07-28',
        createdAt: '2026-07-28T08:00:00Z',
        updatedAt: '2026-07-28T08:00:00Z',
      ),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeReminderRepository implements ReminderRepository {
  _FakeReminderRepository(this._reminders);

  final List<MedicineReminderItem> _reminders;

  @override
  TaskEither<LucentFailure, List<MedicineReminderItem>> fetchActive() =>
      TaskEither.right(_reminders.where((r) => r.isActive).toList());

  @override
  TaskEither<LucentFailure, List<MedicineReminderItem>> fetchAll() =>
      TaskEither.right(_reminders);

  @override
  TaskEither<LucentFailure, void> reportLocalReceipt({
    required String reminderId,
    required String scheduledDate,
    required String scheduledTime,
  }) => TaskEither.right(null);

  @override
  TaskEither<LucentFailure, void> reportLocalCapability(String state) =>
      TaskEither.right(null);

  @override
  TaskEither<LucentFailure, List<MedicineReminderItem>> upsertGroup(
    MedicineReminderGroupUpsertInput input,
  ) => TaskEither.right(_reminders);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _scrollDashboardTo(WidgetTester tester, Finder finder) async {
  const maxDrags = 10;
  for (var i = 0; i < maxDrags && finder.evaluate().isEmpty; i++) {
    await tester.drag(
      find.byKey(const Key('record-dashboard-scrollable')),
      const Offset(0, -300),
    );
    await tester.pump(const Duration(milliseconds: 200));
  }
}
