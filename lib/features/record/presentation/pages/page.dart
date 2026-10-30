import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/composition/composition.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/logger/log_level.dart';
import 'package:luminous/core/utils/record_time_format.dart';
import 'package:luminous/core/widgets/auth/required_dialog.dart';
import 'package:luminous/core/widgets/common/control/date_picker.dart';
import 'package:luminous/core/widgets/common/control/surface_title_button.dart';
import 'package:luminous/core/widgets/common/feedback/refresh_indicator.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/core/widgets/layout/responsive_content_frame.dart';
import 'package:luminous/features/record/domain/entities/dashboard.dart';
import 'package:luminous/features/record/domain/entities/type_mapping.dart';
import 'package:luminous/features/record/presentation/providers/dashboard.dart';
import 'package:luminous/features/record/presentation/providers/data_access.dart';
import 'package:luminous/features/record/presentation/providers/surface.dart';
import 'package:luminous/features/record/presentation/quick_entry/core/dispatcher.dart';
import 'package:luminous/features/record/presentation/quick_entry/sheets/nlp_sheet.dart';
import 'package:luminous/features/record/presentation/quick_entry/sheets/record_date.dart';
import 'package:luminous/features/record/presentation/ui_defaults.dart';
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
    // 与 RecordDateBar 同一理由:共享的 FCalendar.grid 弹窗不会在 360dp 上溢出。
    final picked = await showForuiDatePicker(
      context,
      initial: selectedDate,
      first: kCalendarMinDate,
      last: today.add(const Duration(days: 365)),
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
    // 与区块同一个状态机：页面负责骨架/错误这层分流，区块只读 dataOrNull。
    final pageState = ref.watch(recordSurfaceStateProvider);
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
      onOpenNlpSheet: (ctx) =>
          openNlpSheet(ref: ref, context: ctx, selectedDate: selectedDate),
    );

    final pageStateContent = PageStateSwitch<RecordDashboard>(
      state: pageState,
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
              onSignIn: () => requestSignIn(context),
            ),
            const SizedBox(height: Spacing.lg),
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
            onNewEntry: () => _openRecordCreate(context),
          ),
        ],
      ),
    );

    if (!isMobileLayout) {
      return ShellDeferredContent(
        child: DesktopTabShell(
          title: l10n.tabRecord,
          titleSurface: SurfaceId.record,
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
        child: ForuiRefreshIndicator(
          onRefresh: () => _refreshAll(context),
          child: SingleChildScrollView(
            // PageStorageKey (not a plain Key) so the offset survives a
            // reload: recording an item re-fetches the timeline and shortens
            // it, and with a plain key the view silently reset to zero — which
            // reads as the content jumping down the screen.
            key: const PageStorageKey<String>('record-dashboard-scrollable'),
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
          title: SurfaceTitleEntry(
            surface: SurfaceId.record,
            title: l10n.tabRecord,
          ),
          suffixes: headerActions,
        ),
        child: scaffoldBody,
      ),
    );
  }
}
