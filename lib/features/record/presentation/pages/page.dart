import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/widgets/common/dialog_shell.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/core/widgets/layout/responsive_content_frame.dart';
import 'package:luminous/features/shell/presentation/deferred_content.dart';
import 'package:luminous/features/shell/presentation/desktop_tab_shell.dart';
import 'package:luminous/features/auth/presentation/providers/session.dart';
import 'package:luminous/features/auth/presentation/widgets/shared/required_dialog.dart';
import 'package:luminous/features/record/data/quick_entry_preferences.dart';
import 'package:luminous/features/record/domain/entities/record.dart';
import 'package:luminous/features/record/domain/entities/dashboard.dart';
import 'package:luminous/features/record/domain/entities/type_mapping.dart';
import 'package:luminous/features/record/presentation/controllers/nlp.dart';
import 'package:luminous/features/record/presentation/providers/dashboard.dart';
import 'package:luminous/features/record/presentation/providers/time.dart';
import 'package:luminous/features/record/presentation/utils/date_time_formatters.dart';
import 'package:luminous/features/record/presentation/widgets/shared/components.dart';
import 'package:luminous/features/record/presentation/widgets/views/dashboard_view.dart';
import 'package:luminous/features/record/presentation/widgets/dialogs/fast_entry_dialog.dart';
import 'package:luminous/features/record/presentation/widgets/dialogs/nlp_dialog.dart';
import 'package:luminous/features/record/presentation/widgets/dialogs/voice_entry_dialog.dart';
import 'package:luminous/features/record/presentation/widgets/dialogs/ocr_entry_dialog.dart';
import 'package:luminous/features/record/presentation/widgets/views/skeleton_view.dart';
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
              key: const Key('record-add-action'),
              label: isCompact
                  ? l10n.recordAddCompactAction
                  : l10n.recordAddAction,
              icon: FLucideIcons.plus,
              emphasized: true,
              onTap: () => pushAuthRequiredRoute(
                context,
                '/record/create?date=${formatRecordDate(selectedDate)}',
              ),
              iconOnly: true,
            ),
          ]
        : [
            RecordHeaderActionChip(
              key: const Key('record-date-today-action'),
              label: l10n.recordTodayAction,
              icon: FLucideIcons.calendarDays,
              onTap: () => _setSelectedDate(clock.now()),
              iconOnly: isCompact,
            ),
            RecordHeaderActionChip(
              key: const Key('record-date-previous-action'),
              label: l10n.recordPreviousDayAction,
              icon: FLucideIcons.chevronLeft,
              onTap: () => _setSelectedDate(
                selectedDate.subtract(const Duration(days: 1)),
              ),
              iconOnly: true,
            ),
            RecordHeaderActionChip(
              key: const Key('record-date-next-action'),
              label: l10n.recordNextDayAction,
              icon: FLucideIcons.chevronRight,
              onTap: () =>
                  _setSelectedDate(selectedDate.add(const Duration(days: 1))),
              iconOnly: true,
            ),
            RecordHeaderActionChip(
              label: l10n.recordPickDateAction,
              icon: FLucideIcons.calendarDays,
              onTap: () => _pickSelectedDate(context, selectedDate),
              iconOnly: true,
            ),
            RecordHeaderActionChip(
              key: const Key('record-add-action'),
              label: isCompact
                  ? l10n.recordAddCompactAction
                  : l10n.recordAddAction,
              icon: FLucideIcons.plus,
              emphasized: true,
              onTap: () => pushAuthRequiredRoute(
                context,
                '/record/create?date=${formatRecordDate(selectedDate)}',
              ),
            ),
          ];

    final pageStateContent = PageStateSwitch<RecordDashboard>(
      state: resolvePageViewState(session: session, data: dashboardAsync),
      loadingBuilder: () => const RecordSkeletonView(),
      fatalErrorBuilder: (error) => StateErrorView(
        title: l10n.recordErrorTitle,
        description: l10n.recordErrorDescription,
        icon: FLucideIcons.notebookPen,
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
              // rebuild during tap handling.
              Future(
                () => ref
                    .read(selectedRecordFilterProvider.notifier)
                    .setFilter(type),
              );
            },
            onDateSelected: (date) => _setSelectedDate(date),
            onQuickAction: (action) {
              // Defer provider modification to avoid "modified while
              // widget tree was building" errors when the quick entry
              // panel rebuilds during tap handling.
              Future(
                () => ref
                    .read(quickEntryPreferencesProvider.notifier)
                    .recordTap(action.type),
              );
              _handleQuickAction(context, action);
            },
            onAiInputTap: () => _openNlpDialog(
              context,
              canAccessProtectedData: canAccessProtectedData,
              isAuthLoading: isAuthLoading,
              selectedDate: selectedDate,
            ),
            onMicTap: () => _openVoiceEntry(
              context,
              canAccessProtectedData: canAccessProtectedData,
              isAuthLoading: isAuthLoading,
              selectedDate: selectedDate,
            ),
            onCameraTap: () => _openOcrEntry(
              context,
              canAccessProtectedData: canAccessProtectedData,
              isAuthLoading: isAuthLoading,
              selectedDate: selectedDate,
            ),
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

  void _openRecordCreate(BuildContext context) {
    final selectedDate = ref.read(selectedRecordDateProvider);
    pushAuthRequiredRoute(
      context,
      '/record/create?date=${formatRecordDate(selectedDate)}',
    );
  }

  void _handleQuickAction(
    BuildContext context,
    RecordQuickAction action,
  ) async {
    assert(!action.locked, 'Locked quick actions should be disabled by UI');

    final selectedDate = ref.read(selectedRecordDateProvider);
    final now = ref.read(currentRecordDateTimeProvider);
    final date = formatRecordDate(selectedDate);
    final currentTime = formatRecordTimeValue(now);
    final kind = dailyRecordKindForEntryType(action.type);
    final route = kind == null
        ? '/record/create?date=${Uri.encodeComponent(date)}'
        : '/record/create?kind=${Uri.encodeComponent(kind.name)}'
              '&date=${Uri.encodeComponent(date)}'
              '&time=${Uri.encodeComponent(currentTime)}';
    final session = ref.read(authSessionProvider);

    if (!session.canAccessProtectedData) {
      if (session.isLoading) {
        return;
      }
      await showAuthRequiredDialog(
        context,
        onLogin: () => context.push(loginRouteForCurrentLocation(context)),
      );
      return;
    }

    if (kind == null || !_usesFastEntry(kind)) {
      if (!context.mounted) {
        return;
      }
      unawaited(context.push(route));
      return;
    }

    await showFDialog<void>(
      context: context,
      builder: (dialogContext, style, animation) => RecordFastEntryDialog(
        kind: kind,
        occurredAt: date,
        currentDateTime: now,
        moreRoute: route,
        animation: animation,
      ),
    );
  }

  Future<void> _pickSelectedDate(
    BuildContext context,
    DateTime selectedDate,
  ) async {
    final today = _dateOnly(clock.now());
    final picked = await showFDialog<DateTime?>(
      context: context,
      builder: (dialogContext, style, animation) => DialogShell(
        maxWidth: LayoutScaleResolver.dialogMaxWidth,
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

  bool _usesFastEntry(DailyRecordKind kind) {
    return switch (kind) {
      DailyRecordKind.water ||
      DailyRecordKind.meal ||
      DailyRecordKind.symptom ||
      DailyRecordKind.mood ||
      DailyRecordKind.note ||
      DailyRecordKind.sleep => true,
      _ => false,
    };
  }

  Future<void> _openNlpDialog(
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
    await showAppDialog<void>(
      context: context,
      builder: (dialogContext) =>
          RecordNlpDialog(occurredAt: formatRecordDate(selectedDate)),
    );
  }

  Future<void> _openVoiceEntry(
    BuildContext context, {
    required bool canAccessProtectedData,
    required bool isAuthLoading,
    required DateTime selectedDate,
  }) async {
    if (!canAccessProtectedData) {
      if (isAuthLoading) return;
      await showAuthRequiredDialog(
        context,
        onLogin: () => context.push(loginRouteForCurrentLocation(context)),
      );
      return;
    }

    final text = await showRecordVoiceEntrySheet(context);
    if (text == null || text.trim().isEmpty || !context.mounted) return;

    // Feed recognized text into NLP pipeline
    ref.read(recordNlpControllerProvider.notifier).reset();
    ref.read(recordNlpControllerProvider.notifier).updateDraft(text.trim());
    await ref
        .read(recordNlpControllerProvider.notifier)
        .generate(occurredAt: formatRecordDate(selectedDate));

    if (!context.mounted) return;
    await showAppDialog<void>(
      context: context,
      builder: (dialogContext) =>
          RecordNlpDialog(occurredAt: formatRecordDate(selectedDate)),
    );
  }

  Future<void> _openOcrEntry(
    BuildContext context, {
    required bool canAccessProtectedData,
    required bool isAuthLoading,
    required DateTime selectedDate,
  }) async {
    if (!canAccessProtectedData) {
      if (isAuthLoading) return;
      await showAuthRequiredDialog(
        context,
        onLogin: () => context.push(loginRouteForCurrentLocation(context)),
      );
      return;
    }

    final text = await showRecordOcrEntrySheet(context);
    if (text == null || text.trim().isEmpty || !context.mounted) return;

    // Feed recognized text into NLP pipeline
    ref.read(recordNlpControllerProvider.notifier).reset();
    ref.read(recordNlpControllerProvider.notifier).updateDraft(text.trim());
    await ref
        .read(recordNlpControllerProvider.notifier)
        .generate(occurredAt: formatRecordDate(selectedDate));

    if (!context.mounted) return;
    await showAppDialog<void>(
      context: context,
      builder: (dialogContext) =>
          RecordNlpDialog(occurredAt: formatRecordDate(selectedDate)),
    );
  }
}
