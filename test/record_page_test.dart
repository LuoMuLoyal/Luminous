import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/theme/app_theme.dart';
import 'package:luminous/core/widgets/app_state_views.dart';
import 'package:luminous/features/auth/domain/entities/auth_session.dart';
import 'package:luminous/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:luminous/features/health_context/data/providers/health_context_data_providers.dart';
import 'package:luminous/features/health_context/domain/entities/health_context_snapshot.dart';
import 'package:luminous/features/record/data/providers/daily_record_providers.dart';
import 'package:luminous/features/record/data/repositories/mock_record_repository.dart';
import 'package:luminous/features/record/data/repositories/lucent_record_repository.dart';
import 'package:luminous/features/record/domain/entities/daily_record.dart';
import 'package:luminous/features/record/domain/entities/daily_record_inputs.dart';
import 'package:luminous/features/record/domain/entities/record_dashboard.dart';
import 'package:luminous/features/record/domain/entities/record_type_mapping.dart';
import 'package:luminous/features/record/domain/repositories/daily_record_repository.dart';
import 'package:luminous/features/record/domain/repositories/record_repository.dart';
import 'package:luminous/features/record/presentation/pages/record_create.dart';
import 'package:luminous/features/record/presentation/pages/record_detail.dart';
import 'package:luminous/features/record/presentation/pages/record_edit.dart';
import 'package:luminous/features/record/presentation/providers/record_dashboard_provider.dart';
import 'package:luminous/features/record/presentation/record_page.dart';
import 'package:luminous/l10n/app_localizations.dart';

void main() {
  testWidgets('Record page renders mobile mock dashboard sections', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

    await _pumpRecordPage(tester);

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final scrollable = find.byType(Scrollable);
    final keys = <String>[
      'record-quick-actions',
      'record-ai-input',
      'record-timeline',
      'record-filter-chips',
      'record-calendar-overview',
      'record-today-overview',
      'record-quick-operations',
      'record-guide-row',
    ];

    for (final key in keys) {
      final finder = find.byKey(Key(key));
      await tester.scrollUntilVisible(finder, 240, scrollable: scrollable);
      await tester.pump(const Duration(milliseconds: 200));
      expect(finder, findsOneWidget);
    }

    expect(find.text(l10n.recordQuickSectionTitle), findsOneWidget);
    expect(find.textContaining(l10n.recordTimelineMealName), findsOneWidget);
    expect(find.byKey(const Key('record-summary')), findsNothing);
    expect(find.byKey(const Key('record-trends')), findsNothing);
    expect(find.byKey(const Key('record-health-bag')), findsNothing);
    expect(find.text(l10n.recordMoodTrendSectionTitle), findsNothing);
  });

  testWidgets('Record page keeps period quick action hidden in MVP', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
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
      findsOneWidget,
    );
  });

  testWidgets(
    'Record loading keeps static sections visible with skeleton slots',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
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
          child: MaterialApp(
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            locale: const Locale('zh'),
            localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: const RecordPage(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text(l10n.tabRecord), findsOneWidget);
      expect(find.text(l10n.recordQuickSectionTitle), findsOneWidget);
      expect(find.byKey(const Key('record-ai-input')), findsOneWidget);
      expect(find.byKey(const Key('record-timeline')), findsOneWidget);
      expect(find.byType(AppInlineSkeletonBlock), findsWidgets);
    },
  );

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
        child: MaterialApp.router(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          locale: const Locale('zh'),
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: _buildEditTestRouter(),
        ),
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
        child: MaterialApp.router(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          locale: const Locale('zh'),
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: _buildEditTestRouter(
            initialLocation: '/record/test-id-1/edit',
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(repo.getCalledWith, 'test-id-1');

    final fields = find.byType(TextField);
    expect(fields, findsNWidgets(4));
    for (var index = 0; index < 4; index += 1) {
      await tester.enterText(fields.at(index), '');
    }

    final saveButton = find.widgetWithText(ElevatedButton, '保存');
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
        child: MaterialApp.router(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          locale: const Locale('zh'),
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: _buildEditTestRouter(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Find and tap delete button
    final deleteButton = find.widgetWithText(OutlinedButton, '删除');
    expect(deleteButton, findsOneWidget);
    await tester.ensureVisible(deleteButton);
    await tester.pump();
    await tester.tap(deleteButton);
    await tester.pumpAndSettle();

    // Confirm delete in dialog
    final confirmButton = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.widgetWithText(FilledButton, '删除'),
    );
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
        child: MaterialApp.router(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          locale: const Locale('zh'),
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: _buildEditTestRouter(),
        ),
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
        child: MaterialApp.router(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          locale: const Locale('zh'),
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: _buildEditTestRouter(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // No fetchRecords call should have been made when signed out
    expect(repo.fetchRecordsCalled, isFalse);
  });

  testWidgets('Record detail page renders full saved fields', (tester) async {
    final repo = _FakeDailyRecordRepository(
      itemOccurredAt: '2026-06-06T09:45:00',
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
    expect(find.text('manual'), findsOneWidget);
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
    await tester.scrollUntilVisible(entry, 240);
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

    final deleteButton = find.widgetWithText(OutlinedButton, '删除');
    expect(deleteButton, findsOneWidget);
    await tester.ensureVisible(deleteButton);
    await tester.tap(deleteButton);
    await tester.pumpAndSettle();

    final confirmButton = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.widgetWithText(FilledButton, '删除'),
    );
    expect(confirmButton, findsOneWidget);
    await tester.tap(confirmButton);
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 3));

    expect(repo.deleteCalledWith, 'test-id-1');
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
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
    final repo = _FakeRecordRepository();

    await _pumpRecordPage(
      tester,
      recordRepository: repo,
      authSessionNotifier: _SignedInAuthSessionNotifier.new,
      selectedDate: DateTime(2026, 6, 6),
    );
    await tester.pumpAndSettle();

    expect(repo.requestedDates, contains(DateTime(2026, 6, 6)));

    await tester.tap(find.byTooltip(l10n.recordPreviousDayAction).first);
    await tester.pumpAndSettle();

    expect(repo.requestedDates, contains(DateTime(2026, 6, 5)));
  });

  testWidgets(
    'Record mobile quick action opens create page with kind and date',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
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

      await tester.tap(find.byKey(const Key('record-quick-water')));
      await tester.pumpAndSettle();

      expect(find.byType(RecordCreatePage), findsOneWidget);
      final dropdown = tester.widget<DropdownButtonFormField<DailyRecordKind>>(
        find.byType(DropdownButtonFormField<DailyRecordKind>),
      );
      expect(dropdown.initialValue, DailyRecordKind.water);

      await tester.tap(find.widgetWithText(ElevatedButton, '保存'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));

      expect(dailyRepo.createInput?.kind, DailyRecordKind.water);
      expect(dailyRepo.createInput?.occurredAt, '2026-06-06');
    },
  );

  testWidgets('Record mobile quick action shows login dialog when signed out', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
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

    final saveButton = find.widgetWithText(ElevatedButton, '保存');
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
    expect(input.value, isNull);
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

    final saveButton = find.widgetWithText(ElevatedButton, '保存');
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

    final saveButton = find.widgetWithText(ElevatedButton, '保存');
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
        child: MaterialApp.router(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          locale: const Locale('zh'),
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
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

    final saveButton = find.widgetWithText(ElevatedButton, '保存');
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
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });
    final repo = _FakeRecordRepository();
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

    await _pumpRecordRouter(tester, recordRepository: repo);
    await tester.pumpAndSettle();

    final filter = find.byKey(const Key('record-filter-water'));
    await tester.scrollUntilVisible(filter, 240);
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
        itemOccurredAt: '2026-06-06T09:45:00',
      );
      final repo = LucentRecordRepository(dailyRecordRepo: dailyRepo);

      final dashboard = await repo.fetchDashboard(DateTime(2026, 6, 6));

      expect(dailyRepo.fetchDate, '2026-06-06');
      expect(dashboard.selectedDay, 6);
      expect(dashboard.timeline.single.time, '09:45');
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
}

Future<void> _pumpRecordRouter(
  WidgetTester tester, {
  DailyRecordRepository? dailyRecordRepository,
  RecordRepository? recordRepository,
  HealthContextSnapshot? healthContextSnapshot,
  String initialLocation = '/',
  DateTime? selectedDate,
  AuthSessionNotifier Function()? authSessionNotifier,
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
        if (selectedDate != null)
          selectedRecordDateProvider.overrideWith(
            () => _FixedSelectedRecordDateNotifier(selectedDate),
          ),
      ],
      child: MaterialApp.router(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        locale: const Locale('zh'),
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: _buildRecordTestRouter(initialLocation),
      ),
    ),
  );
}

Future<void> _pumpRecordPage(
  WidgetTester tester, {
  RecordRepository recordRepository = const MockRecordRepository(),
  AuthSessionNotifier Function()? authSessionNotifier,
  HealthContextSnapshot? healthContextSnapshot,
  DateTime? selectedDate,
}) async {
  final overrides = [
    recordRepositoryProvider.overrideWithValue(recordRepository),
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
  ];

  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        locale: const Locale('zh'),
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: const RecordPage(),
      ),
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
          body: Text("login-page:${state.uri.queryParameters['returnTo']}"),
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
          body: Text("login-page:${state.uri.queryParameters['returnTo']}"),
        ),
      ),
    ],
  );
}

class _FakeDailyRecordRepository implements DailyRecordRepository {
  _FakeDailyRecordRepository({
    this.itemOccurredAt,
    this.itemKind = DailyRecordKind.vital,
    this.itemTitle = 'Blood pressure',
    this.itemValue = '118/76',
    this.itemUnit = 'mmHg',
    this.itemNote = 'This is a note',
    this.withAttachment = false,
  });

  final String? itemOccurredAt;
  final DailyRecordKind itemKind;
  final String? itemTitle;
  final String? itemValue;
  final String? itemUnit;
  final String? itemNote;
  final bool withAttachment;
  String? deleteCalledWith;
  String? updateCalledWith;
  String? getCalledWith;
  String? fetchDate;
  DailyRecordUpdateInput? lastUpdateInput;
  DailyRecordCreateInput? createInput;
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
    return DailyRecordListData(
      items: [
        DailyRecordItem(
          id: 'test-id-1',
          kind: itemKind,
          occurredAt: itemOccurredAt ?? date,
          title: itemTitle,
          value: itemValue,
          unit: itemUnit,
          note: itemNote,
          source: 'manual',
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
        ),
      ],
      total: 1,
    );
  }

  @override
  Future<DailyRecordItem> get(String id) async {
    getCalledWith = id;
    return DailyRecordItem(
      id: id,
      kind: itemKind,
      occurredAt: itemOccurredAt ?? '2026-05-20',
      title: itemTitle,
      value: itemValue,
      unit: itemUnit,
      note: itemNote,
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
    return DailyRecordItem(
      id: 'created-id-1',
      kind: input.kind,
      occurredAt: input.occurredAt,
      title: input.title,
      value: input.value,
      unit: input.unit,
      note: input.note,
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
      occurredAt: fetchDate ?? '2026-05-20',
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
  }
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
              icon: Icons.favorite_rounded,
              accent: Color(0xFFFF4D57),
              softColor: Color(0xFFFFEEEE),
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
      weekDays: mock.weekDays,
      monthDays: mock.monthDays,
      quickActions: mock.quickActions,
      summary: mock.summary,
      filters: mock.filters,
      timeline: timeline,
      trends: mock.trends,
    );
  }
}

HealthContextSnapshot _healthSnapshot({String? sexAtBirth = 'male'}) {
  return HealthContextSnapshot(
    summary: const HealthSummary(
      age: 27,
      onboardingCompleted: true,
      activeAllergyCount: 0,
      conditionCount: 0,
      currentMedicineCount: 0,
      missingCoreProfileFields: <String>[],
    ),
    profile: HealthProfile(
      birthDate: '1999-01-15',
      sexAtBirth: sexAtBirth,
      heightCm: 165,
      pregnancyState: null,
      lactationState: null,
      bloodType: null,
      locale: null,
      timezone: null,
      unitSystem: null,
      onboardingCompletedAt: '2026-01-01T00:00:00Z',
      extras: const <String, dynamic>{},
    ),
    allergies: const <AllergyItem>[],
    conditions: const <ConditionItem>[],
    currentMedicines: const <CurrentMedicineItem>[],
  );
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
