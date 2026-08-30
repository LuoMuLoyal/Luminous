import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/utils/local_date.dart';
import 'package:luminous/core/widgets/common/dialog_shell.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/features/health_context/data/providers/health_context.dart';
import 'package:luminous/features/health_event/domain/entities/health_event.dart';
import 'package:luminous/features/health_event/presentation/providers/active_event.dart';
import 'package:luminous/features/health_event/presentation/widgets/sheets/check_in.dart';
import 'package:luminous/features/health_event/presentation/widgets/sheets/end_event.dart';
import 'package:luminous/features/health_event/presentation/widgets/sheets/start_event.dart';
import 'package:luminous/features/record/data/providers/record_access.dart';
import 'package:luminous/features/record/domain/entities/record.dart';
import 'package:luminous/features/today/domain/entities/dashboard.dart';
import 'package:luminous/features/today/presentation/widgets/sections/observation.dart';
import 'package:luminous/features/today/presentation/widgets/sections/quick_actions.dart';
import 'package:luminous/features/today/presentation/widgets/sections/suggestion.dart';
import 'package:luminous/features/today/presentation/widgets/sections/summary.dart';
import 'package:luminous/features/today/presentation/widgets/shared/section.dart';
import 'package:luminous/features/today/presentation/widgets/shared/top_bar.dart';
import 'package:luminous/features/today/presentation/widgets/shared/view_models.dart';
import 'package:luminous/l10n/app_localizations.dart';

class TodayDashboardView extends ConsumerWidget {
  const TodayDashboardView({
    super.key,
    required this.dashboard,
    this.isLoading = false,
    this.isPreview = false,
    this.onSignIn,
    required this.onRefresh,
  });

  final TodayDashboard dashboard;
  final bool isLoading;
  final bool isPreview;
  final VoidCallback? onSignIn;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= Breakpoints.desktop;

    final content = isDesktop
        ? _DesktopTodayDashboard(
            dashboard: dashboard,
            isPreview: isPreview,
            onSignIn: onSignIn,
            onRefresh: onRefresh,
          )
        : _MobileTodayDashboard(
            dashboard: dashboard,
            isPreview: isPreview,
            onSignIn: onSignIn,
            onRefresh: onRefresh,
          );

    return SkeletonScope(isLoading: isLoading, child: content);
  }
}

class TodayErrorView extends StatelessWidget {
  const TodayErrorView({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return StateErrorView(
      title: l10n.todayErrorTitle,
      description: l10n.todayErrorDescription,
      icon: SemanticIcons.actionHelp,
      actionLabel: l10n.todayRetryAction,
      onAction: onRetry,
      tone: StateTone.danger,
    );
  }
}

class _MobileTodayDashboard extends StatelessWidget {
  const _MobileTodayDashboard({
    required this.dashboard,
    required this.isPreview,
    required this.onSignIn,
    required this.onRefresh,
  });

  final TodayDashboard dashboard;
  final bool isPreview;
  final VoidCallback? onSignIn;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Each section carries its own bottom spacing so that the
    // conditional banner slot (SignInHintBanner or SizedBox.shrink)
    // doesn't leave an unwanted gap when hidden.
    final sections = <Widget>[
      // Preview banner slot — always present to keep list indices stable.
      // SizedBox.shrink has zero height, so no gap when hidden.
      if (isPreview)
        Padding(
          padding: const EdgeInsets.only(bottom: Spacing.level5),
          child: SignInHintBanner(
            onSignIn: onSignIn,
            message: l10n.todayPreviewBannerMessage,
          ),
        )
      else
        const SizedBox.shrink(),
      // 问候语从 Header 拆分，放到内容区
      Padding(
        padding: const EdgeInsets.only(bottom: Spacing.level5),
        child: Text(
          greetingSubtitle(l10n, dashboard),
          style: context.theme.typography.body.sm.copyWith(
            color: SemanticColor.neutral.solid(context),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: Spacing.level5),
        child: TodayPrimarySuggestionSection(dashboard: dashboard),
      ),
      const Padding(
        padding: EdgeInsets.only(bottom: Spacing.level5),
        child: TodaySecondarySuggestionsSection(
          key: Key('today-secondary-suggestions-card'),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: Spacing.level5),
        child: TodaySummarySection(dashboard: dashboard),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: Spacing.level5),
        child: _HealthEventSection(isPreview: isPreview, onRefresh: onRefresh),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: Spacing.level5),
        child: TodayObservationSection(dashboard: dashboard),
      ),
      TodayQuickActionsSection(dashboard: dashboard),
    ];

    return Column(
      children: [
        const TodayTopBar(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: onRefresh,
            child: CustomScrollView(
              key: const PageStorageKey<String>('today-dashboard-scroll'),
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    Spacing.level4,
                    Spacing.level4,
                    Spacing.level4,
                    Spacing.level10 + MediaQuery.paddingOf(context).bottom,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate.fixed(sections),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _HealthEventSection extends ConsumerWidget {
  const _HealthEventSection({required this.isPreview, required this.onRefresh});

  final bool isPreview;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isPreview) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    final event = ref.watch(activeHealthEventProvider);

    return TodaySection(
      title: l10n.todayHealthEventSectionTitle,
      child: event.when(
        loading: () =>
            const _HealthEventCard(child: Center(child: FProgress())),
        error: (_, __) => _HealthEventCard(
          child: Row(
            children: [
              Expanded(
                child: Text(
                  l10n.todayHealthEventReadFailed,
                  style: context.theme.typography.body.xs.copyWith(
                    color: SemanticColor.destructive.solid(context),
                  ),
                ),
              ),
              FButton(
                key: const Key('health-event-retry'),
                variant: FButtonVariant.outline,
                size: FButtonSizeVariant.sm,
                onPress: () =>
                    ref.read(activeHealthEventProvider.notifier).refresh(),
                child: Text(l10n.todaySuggestionRetryAction),
              ),
            ],
          ),
        ),
        data: (activeEvent) => activeEvent == null
            ? _HealthEventCard(
                child: _HealthEventActionRow(
                  title: l10n.todayHealthEventStartTitle,
                  subtitle: l10n.todayHealthEventStartSubtitle,
                  actionLabel: l10n.todayHealthEventStartAction,
                  actionKey: const Key('health-event-start-action'),
                  onPress: () => _openStart(context, ref, l10n),
                ),
              )
            : _HealthEventCard(
                child: _ActiveHealthEventContent(
                  event: activeEvent,
                  onCheckIn: activeEvent.checkIn == null
                      ? () => _openCheckIn(context, ref, activeEvent, l10n)
                      : null,
                  onEnd: () => _openEnd(context, ref, activeEvent, l10n),
                  l10n: l10n,
                ),
              ),
      ),
    );
  }

  Future<void> _openStart(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    var currentMedicineResult = await _readCurrentMedicineOptions(ref);
    var reasonRecordResult = await _readReasonRecordOptions(ref);
    if (!context.mounted) return;
    await showAppDialog<void>(
      context: context,
      maxWidth: LayoutScaleResolver.dialogStandardMaxWidth,
      scrollable: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setSheetState) => StartEventSheet(
          heading: l10n.todayHealthEventStartTitle,
          shortTitleLabel: l10n.todayHealthEventTitleLabel,
          hint: l10n.todayHealthEventTitleHint,
          currentMedicineLabel: l10n.todayHealthEventCurrentMedicineLabel,
          currentMedicineOptions: currentMedicineResult.options,
          reasonRecordLabel: l10n.todayHealthEventReasonRecordLabel,
          reasonRecordOptions: reasonRecordResult.options,
          currentMedicineOptionsLoadFailed: currentMedicineResult.hasError,
          reasonRecordOptionsLoadFailed: reasonRecordResult.hasError,
          onRetryLoadOptions: () async {
            final newMedicineResult = await _readCurrentMedicineOptions(ref);
            final newReasonRecordResult = await _readReasonRecordOptions(ref);
            if (!context.mounted) return;
            setSheetState(() {
              currentMedicineResult = newMedicineResult;
              reasonRecordResult = newReasonRecordResult;
            });
          },
          cancelLabel: l10n.todayHealthEventCancelAction,
          submitLabel: l10n.todayHealthEventStartAction,
          submittingLabel: l10n.todayHealthEventSaveAction,
          requiredMessage: l10n.todayHealthEventTitleRequired,
          submitErrorLabel: l10n.todayHealthEventSaveFailed,
          onSubmit:
              ({
                required shortTitle,
                reasonRecordId,
                required currentMedicineIds,
              }) async {
                await ref
                    .read(activeHealthEventProvider.notifier)
                    .create(
                      title: shortTitle,
                      reasonRecordId: reasonRecordId,
                      currentMedicineIds: currentMedicineIds,
                    );
                if (dialogContext.mounted) Navigator.of(dialogContext).pop();
              },
        ),
      ),
    );
    // 事件创建成功后由 activeHealthEventProvider 直接更新 state，同时
    // DataChangeTopic.healthEvents 驱动 todayDashboardProvider /
    // todaySuggestionProvider 自动刷新，不再依赖手动 onRefresh。
  }

  Future<({List<HealthEventAssociationOption> options, bool hasError})>
  _readCurrentMedicineOptions(WidgetRef ref) async {
    try {
      final snapshot = await ref
          .read(healthContextSnapshotProvider.future)
          .timeout(const Duration(seconds: 2));
      return (
        options: snapshot.currentMedicines
            .where((medicine) => medicine.isCurrent)
            .map(
              (medicine) => HealthEventAssociationOption(
                id: medicine.id,
                label: medicine.displayName,
              ),
            )
            .toList(growable: false),
        hasError: false,
      );
    } catch (_) {
      return (options: const <HealthEventAssociationOption>[], hasError: true);
    }
  }

  Future<({List<HealthEventAssociationOption> options, bool hasError})>
  _readReasonRecordOptions(WidgetRef ref) async {
    try {
      final userTimezone = await readUserTimezone(ref);
      final today = DateTime.parse(
        localDateKey(DateTime.now(), timeZoneName: userTimezone),
      );
      final records = await ref
          .read(dailyRecordListForDateProvider(today).future)
          .timeout(const Duration(seconds: 2));
      return (
        options: records.items
            .where((record) => record.kind == DailyRecordKind.symptom)
            .map((record) {
              final label = [record.title, record.value, record.note]
                  .map((value) => value?.trim())
                  .whereType<String>()
                  .firstWhere((value) => value.isNotEmpty, orElse: () => '');
              return (record: record, label: label);
            })
            .where((item) => item.label.isNotEmpty)
            .map(
              (item) => HealthEventAssociationOption(
                id: item.record.id,
                label: item.label,
              ),
            )
            .toList(growable: false),
        hasError: false,
      );
    } catch (_) {
      return (options: const <HealthEventAssociationOption>[], hasError: true);
    }
  }

  Future<void> _openCheckIn(
    BuildContext context,
    WidgetRef ref,
    HealthEvent event,
    AppLocalizations l10n,
  ) async {
    await showAppDialog<void>(
      context: context,
      maxWidth: LayoutScaleResolver.dialogStandardMaxWidth,
      scrollable: false,
      builder: (dialogContext) => CheckInSheet(
        heading: l10n.todayHealthEventCheckInTitle,
        subtitle: l10n.todayHealthEventCheckInSubtitle,
        improvedLabel: l10n.todayHealthEventImproved,
        unchangedLabel: l10n.todayHealthEventUnchanged,
        worsenedLabel: l10n.todayHealthEventWorsened,
        cancelLabel: l10n.todayHealthEventCancelAction,
        submitLabel: l10n.todayHealthEventCheckInAction,
        submittingLabel: l10n.todayHealthEventSaveAction,
        requiredMessage: l10n.todayHealthEventOutcomeRequired,
        submitErrorLabel: l10n.todayHealthEventSaveFailed,
        onSubmit: (outcome) async {
          final userTimezone = await readUserTimezone(ref);
          await ref
              .read(activeHealthEventProvider.notifier)
              .checkIn(
                eventId: event.id,
                date: localDateKey(DateTime.now(), timeZoneName: userTimezone),
                outcome: outcome,
              );
          if (dialogContext.mounted) Navigator.of(dialogContext).pop();
        },
      ),
    );
    // 事件 check-in 成功后由 activeHealthEventProvider 直接更新 state，同时
    // DataChangeTopic.healthEvents 驱动 todayDashboardProvider /
    // todaySuggestionProvider 自动刷新，不再依赖手动 onRefresh。
  }

  Future<void> _openEnd(
    BuildContext context,
    WidgetRef ref,
    HealthEvent event,
    AppLocalizations l10n,
  ) async {
    await showAppDialog<void>(
      context: context,
      maxWidth: LayoutScaleResolver.dialogStandardMaxWidth,
      scrollable: false,
      builder: (dialogContext) => EndEventSheet(
        heading: l10n.todayHealthEventEndTitle,
        subtitle: l10n.todayHealthEventEndSubtitle,
        improvedLabel: l10n.todayHealthEventImproved,
        unchangedLabel: l10n.todayHealthEventUnchanged,
        worsenedLabel: l10n.todayHealthEventWorsened,
        cancelLabel: l10n.todayHealthEventCancelAction,
        submitLabel: l10n.todayHealthEventEndAction,
        submittingLabel: l10n.todayHealthEventSaveAction,
        requiredMessage: l10n.todayHealthEventOutcomeRequired,
        submitErrorLabel: l10n.todayHealthEventSaveFailed,
        onSubmit: (outcome) async {
          await ref
              .read(activeHealthEventProvider.notifier)
              .end(eventId: event.id, outcome: outcome);
          if (dialogContext.mounted) Navigator.of(dialogContext).pop();
        },
      ),
    );
    // 事件结束后由 activeHealthEventProvider 直接更新 state，同时
    // DataChangeTopic.healthEvents 驱动 todayDashboardProvider /
    // todaySuggestionProvider 自动刷新，不再依赖手动 onRefresh。
  }
}

class _HealthEventCard extends StatelessWidget {
  const _HealthEventCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.card,
        border: Border.all(color: SurfaceTokens.containerBorder(colors)),
        borderRadius: context.theme.style.borderRadius.sm,
      ),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.level4),
        child: child,
      ),
    );
  }
}

class _HealthEventActionRow extends StatelessWidget {
  const _HealthEventActionRow({
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.actionKey,
    required this.onPress,
  });

  final String title;
  final String subtitle;
  final String actionLabel;
  final Key actionKey;
  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) {
    final typography = context.theme.typography;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: typography.body.md),
        const SizedBox(height: Spacing.level2),
        Text(
          subtitle,
          style: typography.body.xs.copyWith(
            color: SemanticColor.neutral.solid(context),
          ),
        ),
        const SizedBox(height: Spacing.level4),
        FButton(key: actionKey, onPress: onPress, child: Text(actionLabel)),
      ],
    );
  }
}

class _ActiveHealthEventContent extends StatelessWidget {
  const _ActiveHealthEventContent({
    required this.event,
    required this.onCheckIn,
    required this.onEnd,
    required this.l10n,
  });

  final HealthEvent event;
  final VoidCallback? onCheckIn;
  final VoidCallback onEnd;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final typography = context.theme.typography;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(event.title, style: typography.body.md),
        const SizedBox(height: Spacing.level2),
        Text(
          onCheckIn == null
              ? l10n.todayHealthEventCheckInDone
              : l10n.todayHealthEventCheckInSubtitle,
          style: typography.body.xs.copyWith(
            color: SemanticColor.neutral.solid(context),
          ),
        ),
        const SizedBox(height: Spacing.level4),
        Wrap(
          spacing: Spacing.level2,
          runSpacing: Spacing.level2,
          children: [
            if (onCheckIn != null)
              FButton(
                key: const Key('health-event-check-in-action'),
                onPress: onCheckIn,
                child: Text(l10n.todayHealthEventCheckInAction),
              ),
            FButton(
              key: const Key('health-event-end-action'),
              variant: FButtonVariant.outline,
              onPress: onEnd,
              child: Text(l10n.todayHealthEventEndAction),
            ),
          ],
        ),
      ],
    );
  }
}

class _DesktopTodayDashboard extends StatelessWidget {
  const _DesktopTodayDashboard({
    required this.dashboard,
    required this.isPreview,
    required this.onSignIn,
    required this.onRefresh,
  });

  final TodayDashboard dashboard;
  final bool isPreview;
  final VoidCallback? onSignIn;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Fixed list — always same item count to keep indices stable.
    // The banner slot uses Padding so SizedBox.shrink is truly zero-height.
    final items = <Widget>[
      // 问候语从 Header 拆分，放到内容区
      Text(
        greetingSubtitle(l10n, dashboard),
        style: context.theme.typography.body.sm.copyWith(
          color: SemanticColor.neutral.solid(context),
        ),
      ),
      // Preview banner slot — SizedBox.shrink has zero height when hidden
      if (isPreview)
        Padding(
          padding: const EdgeInsets.only(
            top: Spacing.level3,
            bottom: Spacing.level6,
          ),
          child: SignInHintBanner(
            onSignIn: onSignIn,
            message: l10n.todayPreviewBannerMessage,
          ),
        )
      else
        const SizedBox.shrink(),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 7,
            child: Column(
              children: [
                TodayPrimarySuggestionSection(dashboard: dashboard),
                const SizedBox(height: Spacing.level6),
                TodaySummarySection(dashboard: dashboard),
              ],
            ),
          ),
          const SizedBox(width: Spacing.level6),
          Expanded(
            flex: 5,
            child: Column(
              children: [
                const TodaySecondarySuggestionsSection(
                  key: Key('today-secondary-suggestions-card'),
                ),
                const SizedBox(height: Spacing.level6),
                TodayObservationSection(dashboard: dashboard),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: Spacing.level6),
      TodayQuickActionsSection(dashboard: dashboard),
    ];

    return Column(
      children: [
        const TodayTopBar(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: onRefresh,
            child: CustomScrollView(
              key: const PageStorageKey<String>(
                'today-dashboard-desktop-scroll',
              ),
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  // Horizontal padding is provided by DesktopTabShell's
                  // content area. Only add bottom padding for nav bar.
                  padding: const EdgeInsets.only(bottom: Spacing.level10),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate.fixed(items),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
