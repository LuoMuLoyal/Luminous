import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/divider.dart';
import 'package:luminous/features/medicine/data/datasources/dose_log_remote.dart';
import 'package:luminous/features/medicine/data/datasources/reminder_remote.dart';
import 'package:luminous/features/medicine/presentation/utils/reminder_formatters.dart';
import 'package:luminous/features/medicine/presentation/widgets/shared/workspace_parts.dart';
import 'package:luminous/l10n/app_localizations.dart';

class ReminderTodayLogPanel extends StatelessWidget {
  const ReminderTodayLogPanel({super.key, required this.logs});

  final List<DoseLogItem> logs;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final visibleLogs = logs.isEmpty
        ? <DoseLogItem>[]
        : logs.take(3).toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: Spacing.level2),
          child: Text(
            l10n.medicineReminderTodayLogsTitle,
            style: context.theme.typography.body.sm.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: Spacing.level3),
        FCard(
          child: visibleLogs.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(Spacing.level4),
                  child: Row(
                    children: [
                      Icon(
                        SemanticIcons.recordClipboard,
                        color: SemanticColor.neutral.solid(context),
                        size: Spacing.level5,
                      ),
                      const SizedBox(width: Spacing.level3),
                      Expanded(
                        child: Text(
                          l10n.medicineReminderNoTodayLogs,
                          style: context.theme.typography.body.xs.copyWith(
                            color: SemanticColor.neutral.solid(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    for (var index = 0; index < visibleLogs.length; index += 1)
                      _TodayLogRow(
                        log: visibleLogs[index],
                        isLast: index == visibleLogs.length - 1,
                      ),
                  ],
                ),
        ),
        if (logs.length > visibleLogs.length)
          Padding(
            padding: const EdgeInsets.only(top: Spacing.level2),
            child: Text(
              l10n.medicineReminderLogCountTotal(logs.length),
              style: context.theme.typography.body.xs2.copyWith(
                color: SemanticColor.neutral.solid(context),
              ),
            ),
          ),
      ],
    );
  }
}

class ReminderDeliveryLogPanel extends StatefulWidget {
  const ReminderDeliveryLogPanel({super.key, required this.logs});

  final List<ReminderDeliveryItem> logs;

  @override
  State<ReminderDeliveryLogPanel> createState() =>
      _ReminderDeliveryLogPanelState();
}

class _ReminderDeliveryLogPanelState extends State<ReminderDeliveryLogPanel> {
  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final visibleLogs = (_showAll ? widget.logs : widget.logs.take(5)).toList(
      growable: false,
    );
    final hasMore = widget.logs.length > 5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: Spacing.level2),
          child: Text(
            l10n.medicineReminderDeliveryLogsTitle,
            style: context.theme.typography.body.sm.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: Spacing.level3),
        FCard(
          child: visibleLogs.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(Spacing.level4),
                  child: Row(
                    children: [
                      Icon(
                        SemanticIcons.doseLog,
                        color: SemanticColor.neutral.solid(context),
                        size: Spacing.level5,
                      ),
                      const SizedBox(width: Spacing.level3),
                      Expanded(
                        child: Text(
                          l10n.medicineReminderNoDeliveryLogs,
                          style: context.theme.typography.body.xs.copyWith(
                            color: SemanticColor.neutral.solid(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    for (var index = 0; index < visibleLogs.length; index += 1)
                      _DeliveryLogRow(
                        log: visibleLogs[index],
                        isLast: index == visibleLogs.length - 1 && !hasMore,
                      ),
                    if (hasMore)
                      Padding(
                        padding: const EdgeInsets.all(Spacing.level3),
                        child: FButton(
                          onPress: () => setState(() => _showAll = !_showAll),
                          variant: FButtonVariant.ghost,
                          size: FButtonSizeVariant.xs,
                          child: Text(
                            _showAll
                                ? l10n.medicineReminderLogCollapse
                                : l10n.medicineTodayPlanInspectAction,
                          ),
                        ),
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}

class _DeliveryLogRow extends StatelessWidget {
  const _DeliveryLogRow({required this.log, required this.isLast});

  final ReminderDeliveryItem log;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final color = _deliveryStatusColor(log.status);
    final row = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.level4,
        vertical: Spacing.level3,
      ),
      child: Row(
        children: [
          Icon(
            deliveryStatusIcon(log.status),
            color: color.solid(context),
            size: Spacing.level5,
          ),
          const SizedBox(width: Spacing.level3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateTimeShortLabel(
                    l10n,
                    log.scheduledFor,
                    Localizations.localeOf(context),
                  ),
                  style: context.theme.typography.body.md.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: Spacing.level1),
                Text(
                  deliveryChannelLabel(l10n, log.channel),
                  style: context.theme.typography.body.xs.copyWith(
                    color: SemanticColor.neutral.solid(context),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: Spacing.level3),
          TintedStatusBadge(
            color: color,
            label: deliveryStatusLabel(l10n, log.status),
          ),
        ],
      ),
    );
    if (isLast) return row;
    return Column(children: [row, const AppDivider()]);
  }
}

class _TodayLogRow extends StatelessWidget {
  const _TodayLogRow({required this.log, required this.isLast});

  final DoseLogItem log;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final color = switch (log.status) {
      DoseLogStatus.taken => SemanticColor.success,
      DoseLogStatus.skipped => SemanticColor.neutral,
      // missed 为防御性分支，主路径不产生该状态。
      DoseLogStatus.missed => SemanticColor.destructive,
      DoseLogStatus.planned => SemanticColor.warning,
    };
    final icon = switch (log.status) {
      DoseLogStatus.taken => SemanticIcons.statusSuccess,
      DoseLogStatus.skipped => SemanticIcons.statusUnavailable,
      // missed 为防御性分支，主路径不产生该状态。
      DoseLogStatus.missed => SemanticIcons.notificationFailed,
      DoseLogStatus.planned => SemanticIcons.doseSlot,
    };
    final label = switch (log.status) {
      DoseLogStatus.taken => l10n.medicineDoseStatusTaken,
      DoseLogStatus.skipped => l10n.medicineDoseStatusSkipped,
      // missed 为防御性分支，主路径不产生该状态。
      DoseLogStatus.missed => l10n.medicineReminderMissedStatus,
      DoseLogStatus.planned => l10n.medicineRecordScheduledStatus,
    };

    final row = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.level4,
        vertical: Spacing.level3,
      ),
      child: Row(
        children: [
          Icon(icon, color: color.solid(context), size: Spacing.level5),
          const SizedBox(width: Spacing.level3),
          Expanded(
            child: Text(
              dateTimeTimeLabel(
                log.scheduledFor,
                Localizations.localeOf(context),
              ),
              style: context.theme.typography.body.xs.copyWith(
                color: SemanticColor.neutral.solid(context),
              ),
            ),
          ),
          TintedStatusBadge(color: color, label: label),
        ],
      ),
    );
    if (isLast) return row;
    return Column(children: [row, const AppDivider()]);
  }
}

SemanticColor _deliveryStatusColor(String value) {
  return switch (value) {
    'delivered' => SemanticColor.primary,
    'failed' => SemanticColor.destructive,
    'scheduled' => SemanticColor.primary,
    _ => SemanticColor.neutral,
  };
}
