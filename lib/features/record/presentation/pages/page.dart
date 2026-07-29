import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/providers/data_change_bus.dart';
import 'package:luminous/core/widgets/common/dialog_shell.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/core/widgets/layout/responsive_content_frame.dart';
import 'package:luminous/features/auth/presentation/providers/session.dart';
import 'package:luminous/features/auth/presentation/widgets/shared/required_dialog.dart';
import 'package:luminous/features/health_context/data/providers/health_context.dart';
import 'package:luminous/features/medicine/data/datasources/dose_log_cached.dart';
import 'package:luminous/features/medicine/presentation/providers/reminders.dart';
import 'package:luminous/features/record/data/providers/record_access.dart';
import 'package:luminous/features/record/data/quick_entry_preferences.dart';
import 'package:luminous/features/record/domain/entities/dashboard.dart';
import 'package:luminous/features/record/domain/entities/inputs.dart';
import 'package:luminous/features/record/domain/entities/record.dart';
import 'package:luminous/features/record/domain/entities/type_mapping.dart';
import 'package:luminous/features/record/presentation/controllers/nlp.dart';
import 'package:luminous/features/record/presentation/providers/dashboard.dart';
import 'package:luminous/features/record/presentation/providers/time.dart';
import 'package:luminous/features/record/presentation/quick_entry/meal_flow.dart';
import 'package:luminous/features/record/presentation/quick_entry/medication_flow.dart';
import 'package:luminous/features/record/presentation/quick_entry/sleep_flow.dart';
import 'package:luminous/features/record/presentation/services/quick_entry_context.dart';
import 'package:luminous/features/record/presentation/services/quick_entry_executor.dart';
import 'package:luminous/features/record/presentation/services/quick_entry_undo.dart';
import 'package:luminous/features/record/presentation/utils/date_time_formatters.dart';
import 'package:luminous/features/record/presentation/widgets/dialogs/nlp_sheet.dart';
import 'package:luminous/features/record/presentation/widgets/shared/components.dart';
import 'package:luminous/features/record/presentation/widgets/views/dashboard_view.dart';
import 'package:luminous/features/record/presentation/widgets/views/skeleton_view.dart';
import 'package:luminous/features/shell/presentation/deferred_content.dart';
import 'package:luminous/features/shell/presentation/desktop_tab_shell.dart';
import 'package:luminous/l10n/app_localizations.dart';

class RecordPage extends ConsumerStatefulWidget {
  const RecordPage({super.key});

  @override
  ConsumerState<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends ConsumerState<RecordPage> {
  Future<void> _refreshAll(BuildContext context) async {
    ref.invalidate(recordDashboardProvider);
    try {
      await ref.read(recordDashboardProvider.future);
    } catch (_) {
      if (!context.mounted) return;
      final l10n = AppLocalizations.of(context)!;
      await Toast.show(context, l10n.recordRefreshErrorToast);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final goRouter = GoRouter.maybeOf(context);
    final filterParam = goRouter != null
        ? GoRouterState.of(context).uri.queryParameters['filter']
        : null;
    final filter = recordEntryTypeFromName(filterParam);
    final currentFilter = ref.read(selectedRecordFilterProvider);
    if (filter != currentFilter) {
      ref.read(selectedRecordFilterProvider.notifier).setFilter(filter);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(authSessionProvider);
    final canAccessProtectedData = session.canAccessProtectedData;
    final isAuthLoading = session.isLoading;
    // Always watch the provider — when signed out it returns preview data.
    final dashboardAsync = ref.watch(recordDashboardProvider);
    final selectedDate = ref.watch(selectedRecordDateProvider);
    final l10n = AppLocalizations.of(context)!;
    final size = MediaQuery.sizeOf(context);
    final width = size.width;
    final height = size.height;
    final isCompact = width < Breakpoints.mobile;
    final isMobileLayout = width < Breakpoints.desktop;
    final contentVerticalPadding = EdgeInsets.only(
      top: (height * 0.012).clamp(10.0, 16.0),
      bottom: (height * 0.025).clamp(16.0, 28.0),
    );

    final headerActions = isMobileLayout
        ? [
            RecordHeaderActionChip(
              key: const Key('record-quick-settings-action'),
              label: l10n.recordQuickSettingsTitle,
              icon: SemanticIcons.actionSettings,
              onTap: () => context.push(Routes.recordQuickEntrySettings),
              iconOnly: true,
            ),
            RecordHeaderActionChip(
              key: const Key('record-nlp-action'),
              label: l10n.recordNlpHeaderAction,
              icon: SemanticIcons.aiEntry,
              emphasized: true,
              onTap: () => _openNlpSheet(
                context,
                canAccessProtectedData: canAccessProtectedData,
                isAuthLoading: isAuthLoading,
                selectedDate: selectedDate,
              ),
              iconOnly: true,
            ),
          ]
        : [
            RecordHeaderActionChip(
              key: const Key('record-date-today-action'),
              label: l10n.recordTodayAction,
              icon: SemanticIcons.actionCalendar,
              onTap: () => _setSelectedDate(clock.now()),
              iconOnly: isCompact,
            ),
            RecordHeaderActionChip(
              key: const Key('record-date-previous-action'),
              label: l10n.recordPreviousDayAction,
              icon: SemanticIcons.actionPrev,
              onTap: () => _setSelectedDate(
                selectedDate.subtract(const Duration(days: 1)),
              ),
              iconOnly: true,
            ),
            RecordHeaderActionChip(
              key: const Key('record-date-next-action'),
              label: l10n.recordNextDayAction,
              icon: SemanticIcons.actionNext,
              onTap: () =>
                  _setSelectedDate(selectedDate.add(const Duration(days: 1))),
              iconOnly: true,
            ),
            RecordHeaderActionChip(
              label: l10n.recordPickDateAction,
              icon: SemanticIcons.actionCalendar,
              onTap: () => _pickSelectedDate(context, selectedDate),
              iconOnly: true,
            ),
            RecordHeaderActionChip(
              key: const Key('record-quick-settings-action'),
              label: l10n.recordQuickSettingsTitle,
              icon: SemanticIcons.actionSettings,
              onTap: () => context.push(Routes.recordQuickEntrySettings),
              iconOnly: true,
            ),
            RecordHeaderActionChip(
              key: const Key('record-nlp-action'),
              label: l10n.recordNlpHeaderAction,
              icon: SemanticIcons.aiEntry,
              emphasized: true,
              onTap: () => _openNlpSheet(
                context,
                canAccessProtectedData: canAccessProtectedData,
                isAuthLoading: isAuthLoading,
                selectedDate: selectedDate,
              ),
              iconOnly: true,
            ),
          ];

    final pageStateContent = PageStateSwitch<RecordDashboard>(
      state: resolvePageViewState(session: session, data: dashboardAsync),
      loadingBuilder: () => const RecordSkeletonView(),
      fatalErrorBuilder: (error) => StateErrorView(
        title: l10n.recordErrorTitle,
        description: l10n.recordErrorDescription,
        icon: SemanticIcons.tabRecord,
        actionLabel: l10n.todayRetryAction,
        onAction: () => ref.invalidate(recordDashboardProvider),
        tone: StateTone.warning,
      ),
      readyBuilder: (dashboard, isPreview) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isPreview) ...[
            SignInHintBanner(
              onSignIn: () =>
                  context.push(loginRouteForCurrentLocation(context)),
            ),
            const SizedBox(height: Spacing.level4),
          ],
          RecordDashboardView(
            dashboard: dashboard,
            isPreview: isPreview,
            onFilterSelected: (type) {
              // Defer provider modification to avoid "modified while
              // widget tree was building" errors when filter chips
              unawaited(
                // rebuild during tap handling.
                Future(
                  () => ref
                      .read(selectedRecordFilterProvider.notifier)
                      .setFilter(type),
                ),
              );
            },
            onDateSelected: (date) => _setSelectedDate(date),
            onRecordDateChange: (recordId, newDate) =>
                _changeRecordDate(context, recordId, newDate),
            onQuickAction: (action) {
              // Defer provider modification to avoid "modified while
              // widget tree was building" errors when the quick entry
              unawaited(
                // panel rebuilds during tap handling.
                Future(
                  () => ref
                      .read(quickEntryPreferencesProvider.notifier)
                      .recordTap(action.type),
                ),
              );
              unawaited(_handleQuickAction(context, action));
            },
            onNewEntry: () => _openRecordCreate(context),
          ),
        ],
      ),
    );

    if (!isMobileLayout) {
      return ShellDeferredContent(
        child: DesktopTabShell(
          title: l10n.tabRecord,
          suffixes: headerActions,
          scrollStorageKey: 'record-desktop-scroll',
          onRefresh: () => _refreshAll(context),
          child: pageStateContent,
        ),
      );
    }

    final scaffoldBody = SafeArea(
      top: false,
      child: ResponsiveContentFrame(
        child: RefreshIndicator(
          onRefresh: () => _refreshAll(context),
          child: SingleChildScrollView(
            key: const Key('record-dashboard-scrollable'),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: contentVerticalPadding,
              child: pageStateContent,
            ),
          ),
        ),
      ),
    );

    return ShellDeferredContent(
      child: FScaffold(
        header: FHeader.nested(
          title: Text(l10n.tabRecord),
          suffixes: headerActions,
        ),
        child: scaffoldBody,
      ),
    );
  }

  void _setSelectedDate(DateTime date) {
    ref.read(selectedRecordDateProvider.notifier).setDate(date);
  }

  Future<void> _changeRecordDate(
    BuildContext context,
    String recordId,
    DateTime newDate,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final dateStr = formatRecordDate(newDate);

    try {
      await ref
          .read(dailyRecordRepositoryProvider)
          .update(recordId, DailyRecordUpdateInput(occurredAt: dateStr));

      // Notify cross-feature data change bus so dashboards refresh.
      ref
          .read(dataChangeBusProvider.notifier)
          .emit(DataChangeTopic.dailyRecords);

      // Navigate to the new date so the user sees the moved record.
      _setSelectedDate(newDate);

      if (!context.mounted) return;
      await Toast.show(context, l10n.recordDragDateChanged);
    } catch (e) {
      if (!context.mounted) return;
      await Toast.show(context, l10n.recordDragDateError);
    }
  }

  void _openRecordCreate(BuildContext context) {
    final selectedDate = ref.read(selectedRecordDateProvider);
    unawaited(
      pushAuthRequiredRoute(
        context,
        '/record/create?date=${formatRecordDate(selectedDate)}',
      ),
    );
  }

  Future<void> _handleQuickAction(
    BuildContext context,
    RecordQuickAction action,
  ) async {
    assert(!action.locked, 'Locked quick actions should be disabled by UI');

    final selectedDate = ref.read(selectedRecordDateProvider);
    final now = ref.read(currentRecordDateTimeProvider);
    final date = formatRecordDate(selectedDate);
    final currentTime = formatRecordTimeValue(now);
    final session = ref.read(authSessionProvider);

    if (action.type == RecordEntryType.medication) {
      await _handleMedicationQuickAction(
        context,
        now: now,
        occurredAt: date,
        session: session,
      );
      return;
    }

    if (action.type == RecordEntryType.sleep) {
      await _handleSleepQuickAction(
        context,
        selectedDate: selectedDate,
        now: now,
        occurredAt: date,
        occurredTime: currentTime,
        session: session,
      );
      return;
    }

    if (action.type == RecordEntryType.meal) {
      await _handleMealQuickAction(
        context,
        now: now,
        occurredAt: date,
        occurredTime: currentTime,
        session: session,
      );
      return;
    }

    final prefs =
        ref.read(quickEntryPreferencesProvider).asData?.value ??
        const QuickEntryPreferences();

    await QuickEntryExecutor(
      createRecord: ref.read(dailyRecordRepositoryProvider).create,
      deleteDailyRecord: ref.read(dailyRecordRepositoryProvider).delete,
      emitDataChange: (topic) =>
          ref.read(dataChangeBusProvider.notifier).emit(topic),
      preferences: prefs,
    ).execute(
      QuickEntryExecutionContext(
        buildContext: context,
        action: action,
        selectedDate: selectedDate,
        now: now,
        occurredAt: date,
        occurredTime: currentTime,
        canAccessProtectedData: session.canAccessProtectedData,
        isAuthLoading: session.isLoading,
      ),
    );
  }

  Future<void> _handleMealQuickAction(
    BuildContext context, {
    required DateTime now,
    required String occurredAt,
    required String occurredTime,
    required AuthSessionState session,
  }) async {
    if (!session.canAccessProtectedData) {
      if (session.isLoading) return;
      await showAuthRequiredDialog(
        context,
        onLogin: () => context.push(loginRouteForCurrentLocation(context)),
      );
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    final repository = ref.read(dailyRecordRepositoryProvider);
    final flow = MealQuickEntryFlow(
      pickImage: ref.read(mealQuickImagePickerProvider),
      uploadImage: repository.uploadImage,
      createRecord: repository.create,
      emitDataChange: (topic) =>
          ref.read(dataChangeBusProvider.notifier).emit(topic),
    );

    late final MealQuickEntryOutcome outcome;
    try {
      outcome = await flow.startWithCamera(
        MealQuickEntryContext(
          occurredAt: occurredAt,
          occurredTime: occurredTime,
          defaultTitle: _defaultMealTitle(l10n, now),
        ),
      );
    } on MealQuickImageUnsupportedException {
      if (!context.mounted) return;
      await Toast.show(context, l10n.recordImageUnsupportedToast);
      return;
    } catch (_) {
      if (!context.mounted) return;
      await Toast.show(context, l10n.recordImagePickFailedToast);
      return;
    }

    if (!context.mounted ||
        outcome.type == MealQuickEntryOutcomeType.cancelled) {
      return;
    }
    final draft = outcome.draft;
    if (draft == null) return;
    await _showMealConfirmationDialog(context, flow: flow, draft: draft);
  }

  Future<void> _showMealConfirmationDialog(
    BuildContext context, {
    required MealQuickEntryFlow flow,
    required MealQuickEntryDraft draft,
  }) async {
    await showAppDialog<void>(
      context: context,
      maxWidth: 460,
      scrollable: false,
      builder: (dialogContext) =>
          _MealQuickConfirmationDialog(flow: flow, draft: draft),
    );
  }

  String _defaultMealTitle(AppLocalizations l10n, DateTime now) {
    final hour = now.hour;
    if (hour < 10) return l10n.recordFastChoiceMealBreakfast;
    if (hour < 15) return l10n.recordFastChoiceMealLunch;
    if (hour < 21) return l10n.recordFastChoiceMealDinner;
    return l10n.recordFastChoiceMealSnack;
  }

  Future<void> _handleSleepQuickAction(
    BuildContext context, {
    required DateTime selectedDate,
    required DateTime now,
    required String occurredAt,
    required String occurredTime,
    required AuthSessionState session,
  }) async {
    if (!session.canAccessProtectedData) {
      if (session.isLoading) return;
      await showAuthRequiredDialog(
        context,
        onLogin: () => context.push(loginRouteForCurrentLocation(context)),
      );
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    final repository = ref.read(dailyRecordRepositoryProvider);
    QuickEntryUndoAction? undoAction;
    final flow = SleepQuickEntryFlow(
      createRecord: repository.create,
      deleteRecord: repository.delete,
      emitDataChange: (topic) =>
          ref.read(dataChangeBusProvider.notifier).emit(topic),
      registerUndo: (action) => undoAction = action,
    );

    late final List<DailyRecordItem> records;
    try {
      records = await _fetchSleepQuickCandidates(selectedDate);
    } catch (_) {
      if (!context.mounted) return;
      await Toast.show(context, l10n.recordQuickSleepLoadFailedToast);
      return;
    }

    late final SleepQuickEntryOutcome outcome;
    try {
      outcome = await flow.handleTap(
        context: SleepQuickEntryContext(
          occurredAt: occurredAt,
          occurredTime: occurredTime,
          now: now,
        ),
        candidateRecords: records,
      );
    } catch (_) {
      if (!context.mounted) return;
      await Toast.show(context, l10n.recordCreateFailedToast);
      return;
    }

    if (!context.mounted) return;
    switch (outcome.type) {
      case SleepQuickEntryOutcomeType.started:
        final action = undoAction;
        if (action == null) {
          await Toast.show(context, l10n.recordQuickSleepStartedToast);
          return;
        }
        await Toast.showWithAction(
          context,
          l10n.recordQuickSleepStartedToast,
          l10n.recordQuickUndoAction,
          () {
            unawaited(_undoDailyRecordQuickAction(context, action));
          },
        );
      case SleepQuickEntryOutcomeType.wakeRecorded:
        final merge = outcome.merge;
        if (merge == null) return;
        await _showSleepMergeDialog(context, flow: flow, merge: merge);
      case SleepQuickEntryOutcomeType.needsStartSelection:
        await _showSleepStartSelectionDialog(
          context,
          flow: flow,
          contextData: SleepQuickEntryContext(
            occurredAt: occurredAt,
            occurredTime: occurredTime,
            now: now,
          ),
          openStarts: outcome.openStarts,
        );
      case SleepQuickEntryOutcomeType.invalidDuration:
        await Toast.show(context, l10n.recordQuickSleepInvalidDurationToast);
    }
  }

  Future<List<DailyRecordItem>> _fetchSleepQuickCandidates(
    DateTime selectedDate,
  ) async {
    final repository = ref.read(dailyRecordRepositoryProvider);
    final dates = [
      selectedDate.subtract(const Duration(days: 1)),
      selectedDate,
    ];
    final lists = await Future.wait(
      dates.map(
        (date) => repository.fetchRecords(
          formatRecordDate(date),
          kind: DailyRecordKind.sleep.name,
          pageSize: 100,
        ),
      ),
    );
    return [for (final list in lists) ...list.items];
  }

  Future<void> _showSleepStartSelectionDialog(
    BuildContext context, {
    required SleepQuickEntryFlow flow,
    required SleepQuickEntryContext contextData,
    required List<DailyRecordItem> openStarts,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    var saving = false;

    await showAppDialog<void>(
      context: context,
      maxWidth: 440,
      scrollable: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.recordQuickSleepSelectStartTitle,
                style: TypographyToken.level6.body(dialogContext),
              ),
              const SizedBox(height: Spacing.level4),
              for (final start in openStarts) ...[
                FButton(
                  key: Key('record-quick-sleep-start-${start.id}'),
                  variant: FButtonVariant.outline,
                  onPress: saving
                      ? null
                      : () async {
                          setDialogState(() => saving = true);
                          late final SleepQuickEntryOutcome outcome;
                          try {
                            outcome = await flow.recordWakeForStart(
                              context: contextData,
                              startRecord: start,
                            );
                          } catch (_) {
                            if (!dialogContext.mounted) return;
                            setDialogState(() => saving = false);
                            unawaited(
                              Toast.show(context, l10n.recordCreateFailedToast),
                            );
                            return;
                          }
                          if (!dialogContext.mounted) return;
                          if (outcome.type ==
                              SleepQuickEntryOutcomeType.invalidDuration) {
                            setDialogState(() => saving = false);
                            unawaited(
                              Toast.show(
                                context,
                                l10n.recordQuickSleepInvalidDurationToast,
                              ),
                            );
                            return;
                          }
                          final merge = outcome.merge;
                          Navigator.of(dialogContext).pop();
                          if (merge != null && context.mounted) {
                            await _showSleepMergeDialog(
                              context,
                              flow: flow,
                              merge: merge,
                            );
                          }
                        },
                  child: Text(_sleepEventLabel(start)),
                ),
                const SizedBox(height: Spacing.level3),
              ],
              if (saving) ...[
                const SizedBox(height: Spacing.level2),
                const Center(child: FProgress()),
              ],
              const SizedBox(height: Spacing.level2),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FButton(
                    variant: FButtonVariant.ghost,
                    onPress: saving
                        ? null
                        : () => Navigator.of(dialogContext).pop(),
                    child: Text(l10n.commonCancel),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showSleepMergeDialog(
    BuildContext context, {
    required SleepQuickEntryFlow flow,
    required SleepQuickEntryMerge merge,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    var saving = false;

    await showAppDialog<void>(
      context: context,
      maxWidth: 440,
      scrollable: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.recordQuickSleepMergeTitle,
                style: TypographyToken.level6.body(dialogContext),
              ),
              const SizedBox(height: Spacing.level3),
              Text(
                l10n.recordQuickSleepMergeBody,
                style: TypographyToken.level4.body(dialogContext),
              ),
              const SizedBox(height: Spacing.level4),
              _SleepMergeSummaryRow(
                label: l10n.recordQuickSleepStartLabel,
                value: _sleepEventLabel(merge.startRecord),
              ),
              const SizedBox(height: Spacing.level2),
              _SleepMergeSummaryRow(
                label: l10n.recordQuickSleepWakeLabel,
                value: _sleepEventLabel(merge.wakeRecord),
              ),
              const SizedBox(height: Spacing.level2),
              _SleepMergeSummaryRow(
                label: l10n.recordSleepDurationLabel,
                value: _formatSleepDuration(merge.durationMinutes, l10n),
              ),
              if (saving) ...[
                const SizedBox(height: Spacing.level4),
                const Center(child: FProgress()),
              ],
              const SizedBox(height: Spacing.level5),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FButton(
                    variant: FButtonVariant.ghost,
                    onPress: saving
                        ? null
                        : () => Navigator.of(dialogContext).pop(),
                    child: Text(l10n.recordQuickSleepKeepSeparateAction),
                  ),
                  const SizedBox(width: Spacing.level3),
                  FButton(
                    onPress: saving
                        ? null
                        : () async {
                            setDialogState(() => saving = true);
                            try {
                              await flow.confirmMerge(merge);
                            } catch (_) {
                              if (!dialogContext.mounted) return;
                              setDialogState(() => saving = false);
                              unawaited(
                                Toast.show(
                                  context,
                                  l10n.recordCreateFailedToast,
                                ),
                              );
                              return;
                            }
                            if (!dialogContext.mounted) return;
                            Navigator.of(dialogContext).pop();
                            unawaited(
                              Toast.show(context, l10n.recordCreateSavedToast),
                            );
                          },
                    child: Text(l10n.recordQuickSleepMergeAction),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  String _sleepEventLabel(DailyRecordItem record) {
    final eventAt = SleepQuickEntryFlow.eventAtForRecord(record);
    if (eventAt == null) {
      return formatRecordDateTimeLabel(
        record.occurredAt,
        occurredTime: record.occurredTime,
      );
    }
    return formatRecordDateTimeLabel(
      formatRecordDate(eventAt.toLocal()),
      occurredTime: formatRecordTimeValue(eventAt.toLocal()),
    );
  }

  String _formatSleepDuration(int minutes, AppLocalizations l10n) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (m == 0) return '$h${l10n.todayVitalSleepUnit}';
    return '$h${l10n.todayVitalSleepUnit} $m${l10n.recordSleepMinutesUnit}';
  }

  Future<void> _handleMedicationQuickAction(
    BuildContext context, {
    required DateTime now,
    required String occurredAt,
    required AuthSessionState session,
  }) async {
    if (!session.canAccessProtectedData) {
      if (session.isLoading) return;
      await showAuthRequiredDialog(
        context,
        onLogin: () => context.push(loginRouteForCurrentLocation(context)),
      );
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    QuickEntryUndoAction? undoAction;
    final flow = MedicationQuickEntryFlow(
      markDose: (input) => ref
          .read(cachedDoseLogDataSourceProvider)
          .mark(
            currentMedicineId: input.currentMedicineId,
            status: input.status,
            date: input.date,
            reminderId: input.reminderId,
            scheduledTime: input.scheduledTime,
          ),
      emitDataChange: (topic) =>
          ref.read(dataChangeBusProvider.notifier).emit(topic),
      registerUndo: (action) => undoAction = action,
    );

    late final MedicationQuickEntryOutcome outcome;
    try {
      final snapshot = await ref.read(healthContextSnapshotProvider.future);
      final reminders = await ref.read(medicineReminderListProvider.future);
      final todayLogs = await ref
          .read(cachedDoseLogDataSourceProvider)
          .fetchForDate(occurredAt);
      outcome = await flow.handleTap(
        context: MedicationQuickEntryContext(date: occurredAt, now: now),
        currentMedicines: snapshot.currentMedicines,
        reminders: reminders,
        todayLogs: todayLogs,
      );
    } catch (_) {
      if (!context.mounted) return;
      await Toast.show(context, l10n.recordQuickMedicationLoadFailedToast);
      return;
    }

    if (!context.mounted) return;
    switch (outcome.type) {
      case MedicationQuickEntryOutcomeType.noCurrentMedicines:
        await _showNoMedicationPrompt(context);
      case MedicationQuickEntryOutcomeType.alreadyRecorded:
        await Toast.show(
          context,
          l10n.recordQuickMedicationAlreadyRecordedToast,
        );
      case MedicationQuickEntryOutcomeType.recordedSingle:
        final action = undoAction;
        if (action == null) {
          await Toast.show(context, l10n.recordQuickSavedToast);
          return;
        }
        await Toast.showWithAction(
          context,
          l10n.recordQuickSavedToast,
          l10n.recordQuickUndoAction,
          () {
            unawaited(_undoMedicationQuickAction(context, action, occurredAt));
          },
        );
      case MedicationQuickEntryOutcomeType.needsSelection:
        final selection = outcome.selection;
        if (selection == null) return;
        await _showMedicationSelectionDialog(
          context,
          flow: flow,
          contextData: MedicationQuickEntryContext(date: occurredAt, now: now),
          selection: selection,
        );
    }
  }

  Future<void> _showNoMedicationPrompt(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final add = await showAppDialog<bool>(
      context: context,
      maxWidth: 440,
      scrollable: false,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.recordQuickMedicationNoMedicinesTitle,
            style: TypographyToken.level6.body(context),
          ),
          const SizedBox(height: Spacing.level3),
          Text(
            l10n.recordQuickMedicationNoMedicinesBody,
            style: TypographyToken.level4.body(context),
          ),
          const SizedBox(height: Spacing.level5),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FButton(
                variant: FButtonVariant.ghost,
                onPress: () => Navigator.of(context).pop(false),
                child: Text(l10n.commonCancel),
              ),
              const SizedBox(width: Spacing.level3),
              FButton(
                onPress: () => Navigator.of(context).pop(true),
                child: Text(l10n.recordQuickMedicationAddAction),
              ),
            ],
          ),
        ],
      ),
    );

    if (add == true && context.mounted) {
      unawaited(context.push(Routes.medicineSearch));
    }
  }

  Future<void> _showMedicationSelectionDialog(
    BuildContext context, {
    required MedicationQuickEntryFlow flow,
    required MedicationQuickEntryContext contextData,
    required MedicationQuickSelection selection,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final selected = {...selection.defaultSelectedIds};
    var saving = false;

    await showAppDialog<void>(
      context: context,
      maxWidth: 440,
      scrollable: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          final selectedChoices = selection.choices
              .where((choice) => selected.contains(choice.id))
              .toList(growable: false);
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.recordQuickMedicationSelectTitle,
                style: TypographyToken.level6.body(dialogContext),
              ),
              const SizedBox(height: Spacing.level4),
              Wrap(
                spacing: Spacing.level3,
                runSpacing: Spacing.level3,
                children: [
                  for (final choice in selection.choices)
                    FButton(
                      variant: selected.contains(choice.id)
                          ? FButtonVariant.primary
                          : FButtonVariant.outline,
                      onPress: saving
                          ? null
                          : () => setDialogState(() {
                              if (selected.contains(choice.id)) {
                                selected.remove(choice.id);
                              } else {
                                selected.add(choice.id);
                              }
                            }),
                      child: Text(choice.name),
                    ),
                ],
              ),
              if (saving) ...[
                const SizedBox(height: Spacing.level4),
                const Center(child: FProgress()),
              ],
              const SizedBox(height: Spacing.level5),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FButton(
                    variant: FButtonVariant.ghost,
                    onPress: saving
                        ? null
                        : () => Navigator.of(dialogContext).pop(),
                    child: Text(l10n.commonCancel),
                  ),
                  const SizedBox(width: Spacing.level3),
                  FButton(
                    onPress: saving || selectedChoices.isEmpty
                        ? null
                        : () async {
                            setDialogState(() => saving = true);
                            final result = await flow.recordConfirmedSelection(
                              context: contextData,
                              choices: selectedChoices,
                            );
                            if (!dialogContext.mounted) return;
                            if (result.failed.isEmpty) {
                              unawaited(
                                Toast.show(
                                  context,
                                  l10n.recordCreateSavedToast,
                                ),
                              );
                              Navigator.of(dialogContext).pop();
                              return;
                            }
                            final failedIds = result.failed
                                .map((choice) => choice.id)
                                .toSet();
                            setDialogState(() {
                              saving = false;
                              selected
                                ..clear()
                                ..addAll(failedIds);
                            });
                            unawaited(
                              Toast.show(
                                context,
                                l10n.recordQuickMedicationPartialFailedToast(
                                  result.succeeded.length,
                                  result.failed.length,
                                ),
                              ),
                            );
                          },
                    child: Text(l10n.commonConfirm),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _undoMedicationQuickAction(
    BuildContext context,
    QuickEntryUndoAction action,
    String date,
  ) async {
    try {
      await QuickEntryUndoService(
        deleteDailyRecord: ref.read(dailyRecordRepositoryProvider).delete,
        deleteDoseLog: (doseLogId) => ref
            .read(cachedDoseLogDataSourceProvider)
            .delete(doseLogId, date: date),
        updateDoseLogStatus: (doseLogId, status) async {
          await ref
              .read(cachedDoseLogDataSourceProvider)
              .update(doseLogId, status);
        },
        emitDataChange: (topic) =>
            ref.read(dataChangeBusProvider.notifier).emit(topic),
      ).undo(action);
    } catch (_) {
      if (!context.mounted) return;
      await Toast.show(
        context,
        AppLocalizations.of(context)!.recordQuickUndoFailedToast,
      );
    }
  }

  Future<void> _undoDailyRecordQuickAction(
    BuildContext context,
    QuickEntryUndoAction action,
  ) async {
    try {
      await QuickEntryUndoService(
        deleteDailyRecord: ref.read(dailyRecordRepositoryProvider).delete,
        emitDataChange: (topic) =>
            ref.read(dataChangeBusProvider.notifier).emit(topic),
      ).undo(action);
    } catch (_) {
      if (!context.mounted) return;
      await Toast.show(
        context,
        AppLocalizations.of(context)!.recordQuickUndoFailedToast,
      );
    }
  }

  Future<void> _pickSelectedDate(
    BuildContext context,
    DateTime selectedDate,
  ) async {
    final today = _dateOnly(clock.now());
    final picked = await showFDialog<DateTime?>(
      context: context,
      builder: (dialogContext, style, animation) => DialogShell(
        maxWidth: LayoutScaleResolver.dialogMaxWidthFor(
          MediaQuery.sizeOf(context).width,
        ),
        padding: const EdgeInsets.all(Spacing.level4),
        builder: (_) => SizedBox(
          height: 400,
          child: FCalendar.splitGrid(
            control: FGridSplitCalendarControl(
              start: DateTime(2000),
              end: today.add(const Duration(days: 365)),
            ),
            selectionControl: FDateSelectionControl.managedSingle(
              initial: selectedDate,
              onChange: (date) {
                if (date != null) {
                  _setSelectedDate(_dateOnly(date));
                }
                Navigator.of(dialogContext).pop(date);
              },
            ),
          ),
        ),
      ),
    );
    if (picked != null) {
      _setSelectedDate(_dateOnly(picked));
    }
  }

  DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  Future<void> _openNlpSheet(
    BuildContext context, {
    required bool canAccessProtectedData,
    required bool isAuthLoading,
    required DateTime selectedDate,
  }) async {
    if (!canAccessProtectedData) {
      if (isAuthLoading) {
        return;
      }
      await showAuthRequiredDialog(
        context,
        onLogin: () => context.push(loginRouteForCurrentLocation(context)),
      );
      return;
    }

    ref.read(recordNlpControllerProvider.notifier).reset();
    await showFSheet<void>(
      context: context,
      side: FLayout.btt,
      useSafeArea: true,
      resizeToAvoidBottomInset: true,
      mainAxisMaxRatio: 0.85,
      builder: (sheetContext) =>
          RecordNlpSheet(occurredAt: formatRecordDate(selectedDate)),
    );
  }
}

class _MealQuickConfirmationDialog extends StatefulWidget {
  const _MealQuickConfirmationDialog({required this.flow, required this.draft});

  final MealQuickEntryFlow flow;
  final MealQuickEntryDraft draft;

  @override
  State<_MealQuickConfirmationDialog> createState() =>
      _MealQuickConfirmationDialogState();
}

class _MealQuickConfirmationDialogState
    extends State<_MealQuickConfirmationDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _valueController;
  late final TextEditingController _noteController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.draft.title ?? '');
    _valueController = TextEditingController(text: widget.draft.value ?? '');
    _noteController = TextEditingController(text: widget.draft.note ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _valueController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final image = widget.draft.image;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.recordQuickMealConfirmTitle,
          style: TypographyToken.level6.body(context),
        ),
        if (image != null) ...[
          const SizedBox(height: Spacing.level4),
          ClipRRect(
            borderRadius: BorderRadius.circular(RadiusTokens.level3),
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child: Image.memory(image.bytes, fit: BoxFit.cover),
            ),
          ),
        ],
        const SizedBox(height: Spacing.level4),
        FTextField(
          key: const Key('record-quick-meal-title-field'),
          control: FTextFieldControl.managed(controller: _titleController),
          label: Text(l10n.recordCreateFieldTitle),
          enabled: !_saving,
        ),
        const SizedBox(height: Spacing.level3),
        FTextField(
          key: const Key('record-quick-meal-value-field'),
          control: FTextFieldControl.managed(controller: _valueController),
          label: Text(l10n.recordCreateValueMeal),
          enabled: !_saving,
        ),
        const SizedBox(height: Spacing.level3),
        FTextField(
          key: const Key('record-quick-meal-note-field'),
          control: FTextFieldControl.managed(controller: _noteController),
          label: Text(l10n.recordCreateFieldNote),
          maxLines: 2,
          enabled: !_saving,
        ),
        if (_saving) ...[
          const SizedBox(height: Spacing.level4),
          const Center(child: FProgress()),
        ],
        const SizedBox(height: Spacing.level5),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FButton(
              variant: FButtonVariant.ghost,
              onPress: _saving ? null : () => Navigator.of(context).pop(),
              child: Text(l10n.commonCancel),
            ),
            const SizedBox(width: Spacing.level3),
            FButton(
              key: const Key('record-quick-meal-confirm-action'),
              onPress: _saving ? null : _save,
              child: Text(l10n.commonConfirm),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _saving = true);
    try {
      await widget.flow.saveDraft(
        widget.draft.copyWith(
          title: _titleController.text,
          value: _valueController.text,
          note: _noteController.text,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      unawaited(Toast.show(context, l10n.recordCreateFailedToast));
      return;
    }
    if (!mounted) return;
    Navigator.of(context).pop();
    unawaited(Toast.show(context, l10n.recordCreateSavedToast));
  }
}

class _SleepMergeSummaryRow extends StatelessWidget {
  const _SleepMergeSummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 76,
          child: Text(
            label,
            style: TypographyToken.level3
                .body(context)
                .copyWith(color: context.theme.colors.mutedForeground),
          ),
        ),
        const SizedBox(width: Spacing.level3),
        Expanded(
          child: Text(value, style: TypographyToken.level4.body(context)),
        ),
      ],
    );
  }
}
