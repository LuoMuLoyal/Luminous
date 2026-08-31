import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/logger/log_level.dart';
import 'package:luminous/core/widgets/auth/required_dialog.dart';
import 'package:luminous/core/widgets/common/dialog/dialog_shell.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/core/widgets/layout/responsive_content_frame.dart';
import 'package:luminous/features/record/application/orchestrators/nlp_flow.dart';
import 'package:luminous/features/record/application/usecases/change_record_date.dart';
import 'package:luminous/features/record/application/usecases/quick_entry.dart';
import 'package:luminous/features/record/data/datasources/quick_entry_preferences.dart';
import 'package:luminous/features/record/domain/entities/dashboard.dart';
import 'package:luminous/features/record/domain/entities/type_mapping.dart';
import 'package:luminous/features/record/presentation/providers/dashboard.dart';
import 'package:luminous/features/record/presentation/ui_defaults.dart';
import 'package:luminous/features/record/presentation/utils/date_time_formatters.dart';
import 'package:luminous/features/record/presentation/widgets/header_actions.dart';
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
    } catch (e, st) {
      ref.read(talkerProvider).error('RecordPage._refreshAll failed: $e', st);
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

  void _setSelectedDate(DateTime date) {
    ref.read(selectedRecordDateProvider.notifier).setDate(date);
  }

  void _openRecordCreate(BuildContext context) {
    final selectedDate = ref.read(selectedRecordDateProvider);
    unawaited(
      pushAuthRequiredRoute(
        context,
        Uri(
          path: '/record/create',
          queryParameters: {'date': formatRecordDate(selectedDate)},
        ).toString(),
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
        maxWidth: LayoutScaleResolver.dialogMaxWidthFor(
          MediaQuery.sizeOf(context).width,
        ),
        padding: const EdgeInsets.all(Spacing.level4),
        builder: (_) => SizedBox(
          height: 400,
          child: FCalendar.splitGrid(
            control: FGridSplitCalendarControl(
              start: kCalendarMinDate,
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

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(authSessionProvider);
    final canAccessProtectedData = session.canAccessProtectedData;
    final isAuthLoading = session.isLoading;
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

    final headerActions = buildRecordHeaderActions(
      context: context,
      l10n: l10n,
      isMobileLayout: isMobileLayout,
      isCompact: isCompact,
      selectedDate: selectedDate,
      onSetDate: _setSelectedDate,
      onPickDate: _pickSelectedDate,
      onOpenNlpSheet: (ctx) => openNlpSheet(
        ref: ref,
        context: ctx,
        canAccessProtectedData: canAccessProtectedData,
        isAuthLoading: isAuthLoading,
        selectedDate: selectedDate,
      ),
    );

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
              unawaited(
                Future(
                  () => ref
                      .read(selectedRecordFilterProvider.notifier)
                      .setFilter(type),
                ),
              );
            },
            onDateSelected: (date) => _setSelectedDate(date),
            onRecordDateChange: (recordId, newDate) => changeRecordDate(
              ref: ref,
              context: context,
              recordId: recordId,
              newDate: newDate,
            ),
            onQuickAction: (action) {
              unawaited(
                Future(
                  () => ref
                      .read(quickEntryPreferencesProvider.notifier)
                      .recordTap(action.type),
                ),
              );
              unawaited(handleQuickAction(context, ref, action));
            },
            onQuickActionLongPress: (action) {
              unawaited(handleQuickActionLongPress(context, ref, action));
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
}
