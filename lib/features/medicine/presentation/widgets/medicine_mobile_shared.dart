part of 'medicine_mobile_dashboard_view.dart';

class _MedicationAvatar extends StatelessWidget {
  const _MedicationAvatar({required this.item, required this.size});

  final MedicinePlanItem item;
  final double size;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: item.color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
        border: Border.all(color: item.color.withValues(alpha: 0.16)),
      ),
      child: SizedBox.square(
        dimension: size,
        child: Icon(
          Icons.medication_rounded,
          color: item.color,
          size: size * 0.52,
        ),
      ),
    );
  }
}

class _DoseActionButton extends StatelessWidget {
  const _DoseActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.filled = false,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final typography = AppTypographyTokens.mobile(
      Theme.of(context).colorScheme.onSurface,
    );
    final foreground = filled ? AppColorTokens.onPrimary : color;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadiusTokens.md),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: filled ? color : color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppRadiusTokens.md),
            border: Border.all(color: color.withValues(alpha: 0.32)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacingTokens.sm,
              vertical: AppSpacingTokens.xs,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: foreground, size: AppSpacingTokens.md),
                const SizedBox(width: AppSpacingTokens.xxs),
                Text(
                  label,
                  style: typography.bodySmStrong.copyWith(
                    color: foreground,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterText extends StatelessWidget {
  const _FilterText({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final typography = AppTypographyTokens.mobile(theme.colorScheme.onSurface);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: typography.bodySm.copyWith(
            color: surface.body,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(width: AppSpacingTokens.xxs),
        Icon(
          Icons.keyboard_arrow_down_rounded,
          color: surface.body,
          size: AppSpacingTokens.md,
        ),
      ],
    );
  }
}

class _NextDose {
  const _NextDose({required this.item, this.slot});

  final MedicinePlanItem item;
  final MedicineDoseSlot? slot;
}

class _QuickOperation {
  const _QuickOperation({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
}

class _RecordRow {
  const _RecordRow({
    required this.item,
    required this.name,
    required this.detail,
    required this.date,
    required this.time,
    required this.statusLabel,
    required this.statusColor,
    required this.statusIcon,
  });

  final MedicinePlanItem item;
  final String name;
  final String detail;
  final String date;
  final String time;
  final String statusLabel;
  final Color statusColor;
  final IconData statusIcon;
}

class _SafetyTip {
  const _SafetyTip({
    required this.icon,
    required this.color,
    required this.text,
  });

  final IconData icon;
  final Color color;
  final String text;
}

_NextDose? _nextDoseFor(MedicineWorkspace workspace) {
  for (final item in workspace.plan.items) {
    for (final slot in item.slots) {
      if (slot.status == MedicineDoseStatus.pending) {
        return _NextDose(item: item, slot: slot);
      }
    }
  }
  for (final item in workspace.plan.items) {
    if (item.todayStatus == MedicineDoseStatus.pending) {
      return _NextDose(item: item);
    }
  }
  return null;
}

List<_RecordRow> _recordRowsFor(
  AppLocalizations l10n,
  List<MedicinePlanItem> items,
) {
  final rows = <_RecordRow>[];
  for (final item in items) {
    if (item.slots.isEmpty) {
      rows.add(
        _rowFromItem(
          l10n,
          item,
          null,
          rows.length,
          l10n.medicineRecordScheduledStatus,
        ),
      );
      continue;
    }

    for (final slot in item.slots) {
      rows.add(_rowFromItem(l10n, item, slot, rows.length, null));
    }
  }
  return rows;
}

_RecordRow _rowFromItem(
  AppLocalizations l10n,
  MedicinePlanItem item,
  MedicineDoseSlot? slot,
  int index,
  String? fallbackStatus,
) {
  final status = slot?.status ?? MedicineDoseStatus.pending;
  final statusColor = switch (status) {
    MedicineDoseStatus.taken => MedicinePalette.teal,
    MedicineDoseStatus.skipped => MedicinePalette.orangeDeep,
    MedicineDoseStatus.pending => MedicinePalette.blue,
  };
  final statusIcon = switch (status) {
    MedicineDoseStatus.taken => Icons.check_rounded,
    MedicineDoseStatus.skipped => Icons.remove_done_rounded,
    MedicineDoseStatus.pending => Icons.hourglass_top_rounded,
  };
  final statusLabel =
      fallbackStatus ??
      switch (status) {
        MedicineDoseStatus.taken => l10n.medicineRecordOnTimeStatus,
        MedicineDoseStatus.skipped => l10n.medicineDoseStatusSkipped,
        MedicineDoseStatus.pending => l10n.medicineRecordScheduledStatus,
      };
  final detail = [
    _itemDosage(l10n, item),
    _compactRouteOrSchedule(_itemSchedule(l10n, item)),
  ].where((value) => value.trim().isNotEmpty).join(' · ');

  return _RecordRow(
    item: item,
    name: _itemName(l10n, item),
    detail: detail,
    date: _recordDateLabel(l10n, index),
    time: slot == null
        ? l10n.medicineScheduleNotSet
        : _slotTimeLabel(l10n, slot),
    statusLabel: statusLabel,
    statusColor: statusColor,
    statusIcon: statusIcon,
  );
}

String _recordDateLabel(AppLocalizations l10n, int index) {
  if (index < 2) return l10n.medicineRecordTodayLabel;
  if (index == 2) return l10n.medicineRecordPreviousDate;
  return l10n.medicineRecordOlderDate;
}

String _slotTimeLabel(AppLocalizations l10n, MedicineDoseSlot slot) {
  final raw = slot.rawTime?.trim();
  if (raw != null && raw.isNotEmpty) return raw;
  final key = slot.timeKey;
  if (key != null) return medicineCopy(l10n, key);
  return l10n.medicineScheduleNotSet;
}

String _itemName(AppLocalizations l10n, MedicinePlanItem item) {
  final raw = item.rawName?.trim();
  if (raw != null && raw.isNotEmpty) return raw;
  return medicineCopy(l10n, item.nameKey);
}

String _itemDosage(AppLocalizations l10n, MedicinePlanItem item) {
  final raw = item.rawDosage;
  if (raw != null) {
    final trimmed = raw.trim();
    return trimmed.isEmpty ? l10n.medicineDoseNotSet : trimmed;
  }
  return medicineCopy(l10n, item.dosageKey);
}

String _itemSchedule(AppLocalizations l10n, MedicinePlanItem item) {
  final raw = item.rawSchedule;
  if (raw != null) {
    final trimmed = raw.trim();
    return trimmed.isEmpty ? l10n.medicineScheduleNotSet : trimmed;
  }
  return medicineCopy(l10n, item.scheduleKey);
}

String _itemState(AppLocalizations l10n, MedicinePlanItem item) {
  final raw = item.rawState?.trim();
  if (raw != null && raw.isNotEmpty) return raw;
  return medicineCopy(l10n, item.stateKey);
}

String _doseSummary(AppLocalizations l10n, MedicinePlanItem item) {
  return [
    _itemName(l10n, item),
    _itemDosage(l10n, item),
    _compactRouteOrSchedule(_itemSchedule(l10n, item)),
  ].where((value) => value.trim().isNotEmpty).join('  ');
}

String _compactRouteOrSchedule(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return '--';
  return trimmed;
}

String _alertActionResult(MedicineCopyKey key, AppLocalizations l10n) {
  return switch (key) {
    MedicineCopyKey.alertInteractionAction =>
      l10n.medicineAlertInteractionToast,
    MedicineCopyKey.alertOtherAction => l10n.medicineAlertOtherToast,
    MedicineCopyKey.alertAlcoholRiskStatus =>
      l10n.medicineAlertAlcoholRiskToast,
    MedicineCopyKey.alertCoffeeReminderStatus =>
      l10n.medicineAlertCoffeeReminderToast,
    MedicineCopyKey.alertDuplicateCheckStatus =>
      l10n.medicineAlertDuplicateCheckToast,
    MedicineCopyKey.alertSpecialGroupSafetyStatus =>
      l10n.medicineAlertSpecialGroupSafetyToast,
    _ => l10n.medicineAlertOtherToast,
  };
}
