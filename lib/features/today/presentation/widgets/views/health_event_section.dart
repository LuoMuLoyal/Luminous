import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/utils/local_date.dart';
import 'package:luminous/core/widgets/common/dialog/dialog_shell.dart';
import 'package:luminous/features/health_context/data/providers/health_context.dart';
import 'package:luminous/features/health_event/domain/entities/health_event.dart';
import 'package:luminous/features/health_event/presentation/providers/active_event.dart';
import 'package:luminous/features/health_event/presentation/widgets/sheets/check_in.dart';
import 'package:luminous/features/health_event/presentation/widgets/sheets/end_event.dart';
import 'package:luminous/features/health_event/presentation/widgets/sheets/start_event.dart';
import 'package:luminous/features/record/data/providers/record_access.dart';
import 'package:luminous/features/record/domain/entities/record.dart';
import 'package:luminous/features/today/presentation/widgets/shared/section.dart';
import 'package:luminous/l10n/app_localizations.dart';

class HealthEventSection extends ConsumerWidget {
  const HealthEventSection({
    super.key,
    required this.isPreview,
    required this.onRefresh,
  });

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
        loading: () => const HealthEventCard(child: Center(child: FProgress())),
        error: (_, __) => HealthEventCard(
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
            ? HealthEventCard(
                child: HealthEventActionRow(
                  title: l10n.todayHealthEventStartTitle,
                  subtitle: l10n.todayHealthEventStartSubtitle,
                  actionLabel: l10n.todayHealthEventStartAction,
                  actionKey: const Key('health-event-start-action'),
                  onPress: () => _openStart(context, ref, l10n),
                ),
              )
            : HealthEventCard(
                child: ActiveHealthEventContent(
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

class HealthEventCard extends StatelessWidget {
  const HealthEventCard({super.key, required this.child});

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

class HealthEventActionRow extends StatelessWidget {
  const HealthEventActionRow({
    super.key,
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

class ActiveHealthEventContent extends StatelessWidget {
  const ActiveHealthEventContent({
    super.key,
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
