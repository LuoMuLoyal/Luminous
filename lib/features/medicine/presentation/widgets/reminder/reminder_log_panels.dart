import 'package:flutter/material.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/features/medicine/data/datasources/dose_log_remote_data_source.dart';
import 'package:luminous/features/medicine/data/datasources/medicine_reminder_remote_data_source.dart';
import 'package:luminous/features/medicine/presentation/utils/medicine_reminder_formatters.dart';
import 'package:luminous/features/medicine/presentation/widgets/medicine_workspace_parts.dart';
import 'package:luminous/l10n/app_localizations.dart';

class ReminderTodayLogPanel extends StatelessWidget {
  const ReminderTodayLogPanel({
    super.key,
    required this.logs,
    required this.typography,
    required this.surface,
  });

  final List<DoseLogItem> logs;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

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
          padding: const EdgeInsets.only(left: AppSpacingTokens.xs),
          child: Text(
            l10n.medicineReminderTodayLogsTitle,
            style: typography.bodyMdStrong.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
        ),
        const SizedBox(height: AppSpacingTokens.sm),
        MedicinePanel(
          padding: EdgeInsets.zero,
          child: visibleLogs.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(AppSpacingTokens.md),
                  child: Row(
                    children: [
                      Icon(
                        Icons.pending_actions_rounded,
                        color: surface.mute,
                        size: AppSpacingTokens.lg,
                      ),
                      const SizedBox(width: AppSpacingTokens.sm),
                      Expanded(
                        child: Text(
                          l10n.medicineReminderNoTodayLogs,
                          style: typography.bodySm.copyWith(
                            color: surface.body,
                            letterSpacing: 0,
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
                        typography: typography,
                        surface: surface,
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}

class ReminderDeliveryLogPanel extends StatelessWidget {
  const ReminderDeliveryLogPanel({
    super.key,
    required this.logs,
    required this.typography,
    required this.surface,
  });

  final List<ReminderDeliveryItem> logs;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final visibleLogs = logs.take(5).toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppSpacingTokens.xs),
          child: Text(
            l10n.medicineReminderDeliveryLogsTitle,
            style: typography.bodyMdStrong.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
        ),
        const SizedBox(height: AppSpacingTokens.sm),
        MedicinePanel(
          padding: EdgeInsets.zero,
          child: visibleLogs.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(AppSpacingTokens.md),
                  child: Row(
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        color: surface.mute,
                        size: AppSpacingTokens.lg,
                      ),
                      const SizedBox(width: AppSpacingTokens.sm),
                      Expanded(
                        child: Text(
                          l10n.medicineReminderNoDeliveryLogs,
                          style: typography.bodySm.copyWith(
                            color: surface.body,
                            letterSpacing: 0,
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
                        typography: typography,
                        surface: surface,
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}

class _DeliveryLogRow extends StatelessWidget {
  const _DeliveryLogRow({
    required this.log,
    required this.isLast,
    required this.typography,
    required this.surface,
  });

  final ReminderDeliveryItem log;
  final bool isLast;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final color = deliveryStatusColor(log.status, surface);
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
                  style: typography.bodySmStrong.copyWith(letterSpacing: 0),
                ),
                const SizedBox(height: AppSpacingTokens.xxs),
                Text(
                  deliveryChannelLabel(l10n, log.channel),
                  style: typography.caption.copyWith(
                    color: surface.mute,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacingTokens.sm),
          MedicineStatusPill(
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
          color: surface.hairline,
        ),
      ],
    );
  }
}

class _TodayLogRow extends StatelessWidget {
  const _TodayLogRow({
    required this.log,
    required this.isLast,
    required this.typography,
    required this.surface,
  });

  final DoseLogItem log;
  final bool isLast;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final color = switch (log.status) {
      DoseLogStatus.taken => surface.teal,
      DoseLogStatus.skipped => surface.warningDeep,
      DoseLogStatus.missed => surface.error,
      DoseLogStatus.planned => surface.link,
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
          Icon(Icons.check_circle_outline_rounded, color: color, size: 18),
          const SizedBox(width: AppSpacingTokens.sm),
          Expanded(
            child: Text(
              dateTimeTimeLabel(log.scheduledFor),
              style: typography.bodySm.copyWith(
                color: surface.body,
                letterSpacing: 0,
              ),
            ),
          ),
          MedicineStatusPill(label: label, color: color),
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
          color: surface.hairline,
        ),
      ],
    );
  }
}
