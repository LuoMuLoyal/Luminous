import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/medicine/data/datasources/dose_log_remote_data_source.dart';
import 'package:luminous/features/medicine/data/datasources/reminder_remote_data_source.dart';
import 'package:luminous/features/medicine/presentation/utils/reminder_formatters.dart';
import 'package:luminous/features/medicine/presentation/widgets/shared/workspace_parts.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/core/widgets/common/divider.dart';

class ReminderTodayLogPanel extends StatelessWidget {
  const ReminderTodayLogPanel({super.key, required this.logs});

  final List<DoseLogItem> logs;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.theme.colors;

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
            style: TypographyToken.level4
                .body(context)
                .copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(height: Spacing.level3),
        FCard.raw(
          child: visibleLogs.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(Spacing.level4),
                  child: Row(
                    children: [
                      Icon(
                        FLucideIcons.clipboardList,
                        color: colors.mutedForeground,
                        size: Spacing.level5,
                      ),
                      const SizedBox(width: Spacing.level3),
                      Expanded(
                        child: Text(
                          l10n.medicineReminderNoTodayLogs,
                          style: TypographyToken.level3
                              .body(context)
                              .copyWith(color: colors.mutedForeground),
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
      ],
    );
  }
}

class ReminderDeliveryLogPanel extends StatelessWidget {
  const ReminderDeliveryLogPanel({super.key, required this.logs});

  final List<ReminderDeliveryItem> logs;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.theme.colors;

    final visibleLogs = logs.take(5).toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: Spacing.level2),
          child: Text(
            l10n.medicineReminderDeliveryLogsTitle,
            style: TypographyToken.level4
                .body(context)
                .copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(height: Spacing.level3),
        FCard.raw(
          child: visibleLogs.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(Spacing.level4),
                  child: Row(
                    children: [
                      Icon(
                        FLucideIcons.receiptText,
                        color: colors.mutedForeground,
                        size: Spacing.level5,
                      ),
                      const SizedBox(width: Spacing.level3),
                      Expanded(
                        child: Text(
                          l10n.medicineReminderNoDeliveryLogs,
                          style: TypographyToken.level3
                              .body(context)
                              .copyWith(color: colors.mutedForeground),
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
                        isLast: index == visibleLogs.length - 1,
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
    final colors = context.theme.colors;

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
            color: color.resolve(colors),
            size: 18,
          ),
          const SizedBox(width: Spacing.level3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateTimeShortLabel(l10n, log.scheduledFor),
                  style: TypographyToken.level5
                      .body(context)
                      .copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: Spacing.level1),
                Text(
                  deliveryChannelLabel(l10n, log.channel),
                  style: TypographyToken.level3
                      .body(context)
                      .copyWith(color: colors.mutedForeground),
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
    final colors = context.theme.colors;

    final color = switch (log.status) {
      DoseLogStatus.taken => SemanticColor.primary,
      DoseLogStatus.skipped => SemanticColor.primary,
      DoseLogStatus.missed => SemanticColor.destructive,
      DoseLogStatus.planned => SemanticColor.primary,
    };
    final label = switch (log.status) {
      DoseLogStatus.taken => l10n.medicineDoseStatusTaken,
      DoseLogStatus.skipped => l10n.medicineDoseStatusSkipped,
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
          Icon(FLucideIcons.badgeCheck, color: color.resolve(colors), size: 18),
          const SizedBox(width: Spacing.level3),
          Expanded(
            child: Text(
              dateTimeTimeLabel(log.scheduledFor),
              style: TypographyToken.level3
                  .body(context)
                  .copyWith(color: colors.mutedForeground),
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
