import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/widgets/common/app_status_pill.dart';
import 'package:luminous/features/medicine/data/datasources/dose_log_remote_data_source.dart';
import 'package:luminous/features/medicine/data/datasources/medicine_reminder_remote_data_source.dart';
import 'package:luminous/features/medicine/presentation/utils/medicine_reminder_formatters.dart';
import 'package:luminous/l10n/app_localizations.dart';

class ReminderTodayLogPanel extends StatelessWidget {
  const ReminderTodayLogPanel({super.key, required this.logs});

  final List<DoseLogItem> logs;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.theme.colors;
    final textTheme = Theme.of(context).textTheme;
    final visibleLogs = logs.isEmpty
        ? <DoseLogItem>[]
        : logs.take(3).toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppSpacingTokens.xs),
          child: Text(
            l10n.medicineReminderTodayLogsTitle,
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(height: AppSpacingTokens.sm),
        FCard.raw(
          child: visibleLogs.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(AppSpacingTokens.md),
                  child: Row(
                    children: [
                      Icon(
                        FLucideIcons.clipboardList,
                        color: colors.mutedForeground,
                        size: AppSpacingTokens.lg,
                      ),
                      const SizedBox(width: AppSpacingTokens.sm),
                      Expanded(
                        child: Text(
                          l10n.medicineReminderNoTodayLogs,
                          style: textTheme.bodySmall?.copyWith(
                            color: colors.mutedForeground,
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
    final textTheme = Theme.of(context).textTheme;
    final visibleLogs = logs.take(5).toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppSpacingTokens.xs),
          child: Text(
            l10n.medicineReminderDeliveryLogsTitle,
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(height: AppSpacingTokens.sm),
        FCard.raw(
          child: visibleLogs.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(AppSpacingTokens.md),
                  child: Row(
                    children: [
                      Icon(
                        FLucideIcons.receiptText,
                        color: colors.mutedForeground,
                        size: AppSpacingTokens.lg,
                      ),
                      const SizedBox(width: AppSpacingTokens.sm),
                      Expanded(
                        child: Text(
                          l10n.medicineReminderNoDeliveryLogs,
                          style: textTheme.bodySmall?.copyWith(
                            color: colors.mutedForeground,
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
    final textTheme = Theme.of(context).textTheme;
    final color = _deliveryStatusColor(
      log.status,
      destructive: colors.destructive,
      mutedForeground: colors.mutedForeground,
    );
    final row = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacingTokens.md,
        vertical: AppSpacingTokens.sm,
      ),
      child: Row(
        children: [
          Icon(deliveryStatusIcon(log.status), color: color, size: 18),
          const SizedBox(width: AppSpacingTokens.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateTimeShortLabel(l10n, log.scheduledFor),
                  style: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacingTokens.xxs),
                Text(
                  deliveryChannelLabel(l10n, log.channel),
                  style: textTheme.labelSmall?.copyWith(
                    color: colors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacingTokens.sm),
          AppStatusPill(
            label: deliveryStatusLabel(l10n, log.status),
            color: color,
          ),
        ],
      ),
    );
    if (isLast) return row;
    return Column(
      children: [
        row,
        Divider(
          height: 1,
          thickness: 1,
          indent: AppSpacingTokens.md + AppSpacingTokens.lg,
          color: colors.border,
        ),
      ],
    );
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
    final textTheme = Theme.of(context).textTheme;
    final color = switch (log.status) {
      DoseLogStatus.taken => Color(0xFF0F766E),
      DoseLogStatus.skipped => Color(0xFFB45309),
      DoseLogStatus.missed => colors.destructive,
      DoseLogStatus.planned => colors.primary,
    };
    final label = switch (log.status) {
      DoseLogStatus.taken => l10n.medicineDoseStatusTaken,
      DoseLogStatus.skipped => l10n.medicineDoseStatusSkipped,
      DoseLogStatus.missed => l10n.medicineReminderMissedStatus,
      DoseLogStatus.planned => l10n.medicineRecordScheduledStatus,
    };

    final row = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacingTokens.md,
        vertical: AppSpacingTokens.sm,
      ),
      child: Row(
        children: [
          Icon(FLucideIcons.badgeCheck, color: color, size: 18),
          const SizedBox(width: AppSpacingTokens.sm),
          Expanded(
            child: Text(
              dateTimeTimeLabel(log.scheduledFor),
              style: textTheme.bodySmall?.copyWith(
                color: colors.mutedForeground,
              ),
            ),
          ),
          AppStatusPill(label: label, color: color),
        ],
      ),
    );
    if (isLast) return row;
    return Column(
      children: [
        row,
        Divider(
          height: 1,
          thickness: 1,
          indent: AppSpacingTokens.md + AppSpacingTokens.lg,
          color: colors.border,
        ),
      ],
    );
  }
}

Color _deliveryStatusColor(
  String value, {
  required Color destructive,
  required Color mutedForeground,
}) {
  return switch (value) {
    'delivered' => Color(0xFF0F766E),
    'failed' => destructive,
    'scheduled' => Color(0xFFB45309),
    _ => mutedForeground,
  };
}
