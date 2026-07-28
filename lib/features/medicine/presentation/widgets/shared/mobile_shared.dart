part of '../views/mobile_dashboard_view.dart';

class _MedicationAvatar extends StatelessWidget {
  const _MedicationAvatar({required this.item, required this.size});

  final MedicinePlanItem item;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = item.color.solid(context);
    return FAvatar.raw(
      size: size,
      style: .delta(backgroundColor: item.color.muted(context)),
      child: Icon(
        SemanticIcons.medicineBottle,
        color: color,
        size: size * 0.52,
      ),
    );
  }
}

class _DoseActionButton extends StatelessWidget {
  const _DoseActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.color = SemanticColor.primary,
    this.filled = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final SemanticColor color;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final foregroundColor = filled
        ? colors.primaryForeground
        : color.solid(context);

    return FButton(
      onPress: onTap,
      variant: filled ? FButtonVariant.primary : FButtonVariant.outline,
      size: FButtonSizeVariant.sm,
      mainAxisSize: MainAxisSize.min,
      prefix: Icon(icon, size: Spacing.level4, color: foregroundColor),
      child: Text(
        label,
        style: TypographyToken.level4
            .body(context)
            .copyWith(fontWeight: FontWeight.w700, color: foregroundColor),
      ),
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
  final SemanticColor color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
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
  if (trimmed.isEmpty) return '—';
  return trimmed;
}
