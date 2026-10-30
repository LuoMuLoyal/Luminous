import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/medicine/domain/entities/workspace.dart';
import 'package:luminous/features/medicine/presentation/widgets/shared/copy.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// 药箱与今日计划两个区块共用的展示单元。
///
/// 原先是 `mobile_dashboard_view.dart` 的 `part` 私有成员；两个区块拆成独立
/// 组件文件后，这些共享件需要一个公共落点，否则任一区块都要重新实现一遍。
class MedicationAvatar extends StatelessWidget {
  const MedicationAvatar({super.key, required this.item, required this.size});

  final MedicinePlanItem item;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = item.color.solid(context);
    return Icon(SemanticIcons.medicineBottle, color: color, size: size * 0.52);
  }
}

/// Take / Skip 打卡按钮。
class DoseActionButton extends StatelessWidget {
  const DoseActionButton({
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
    final foregroundColor = filled
        ? SemanticColor.primary.foreground(context)
        : color.solid(context);

    return FButton(
      onPress: onTap,
      variant: filled ? FButtonVariant.primary : FButtonVariant.outline,
      size: FButtonSizeVariant.sm,
      mainAxisSize: MainAxisSize.min,
      prefix: Icon(icon, size: IconSizeTokens.sm, color: foregroundColor),
      child: Text(
        label,
        style: context.theme.typography.body.sm.copyWith(
          fontWeight: FontWeight.w700,
          color: foregroundColor,
        ),
      ),
    );
  }
}

/// 「还有 N 项」折叠页脚。
class TruncatedFooter extends StatelessWidget {
  const TruncatedFooter({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FTappable(
      onPress: onTap,
      builder: (context, data, _) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
          child: Text(
            label,
            style: context.theme.typography.body.xs.copyWith(
              color: SemanticColor.neutral.solid(context),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

/// 下一次待服用剂次：药 + 可选槽位。
class NextDose {
  const NextDose({required this.item, this.slot});

  final MedicinePlanItem item;
  final MedicineDoseSlot? slot;
}

/// 从工作区推导"下一剂"。
NextDose? nextDoseFor(MedicineWorkspace workspace) {
  for (final item in workspace.plan.items) {
    for (final slot in item.slots) {
      if (slot.status == MedicineDoseStatus.pending && !slot.isOverdue) {
        return NextDose(item: item, slot: slot);
      }
    }
  }
  for (final item in workspace.plan.items) {
    // 回退仅针对无提醒槽位的药（slots 为空时 todayStatus 由 dose log 派生）；
    // 槽位全 overdue 的药（status 仍 pending、isOverdue true）不再误判为「下一剂」，
    // 避免药箱条显示「未设置时间」而非「无待服用剂次」空态。
    if (item.slots.isEmpty && item.todayStatus == MedicineDoseStatus.pending) {
      return NextDose(item: item);
    }
  }
  return null;
}

String slotTimeLabel(AppLocalizations l10n, MedicineDoseSlot slot) {
  final raw = slot.rawTime?.trim();
  if (raw != null && raw.isNotEmpty) return raw;
  final key = slot.timeKey;
  if (key != null) return medicineCopy(l10n, key);
  return l10n.medicineScheduleNotSet;
}

String itemName(AppLocalizations l10n, MedicinePlanItem item) {
  final raw = item.rawName?.trim();
  if (raw != null && raw.isNotEmpty) return raw;
  return medicineCopy(l10n, item.nameKey);
}

String itemDosage(AppLocalizations l10n, MedicinePlanItem item) {
  final raw = item.rawDosage;
  if (raw != null) {
    final trimmed = raw.trim();
    return trimmed.isEmpty ? l10n.medicineDoseNotSet : trimmed;
  }
  return medicineCopy(l10n, item.dosageKey);
}

String itemSchedule(AppLocalizations l10n, MedicinePlanItem item) {
  final raw = item.rawSchedule;
  if (raw != null) {
    final trimmed = raw.trim();
    return trimmed.isEmpty ? l10n.medicineScheduleNotSet : trimmed;
  }
  return medicineCopy(l10n, item.scheduleKey);
}

String itemState(AppLocalizations l10n, MedicinePlanItem item) {
  final raw = item.rawState?.trim();
  if (raw != null && raw.isNotEmpty) return raw;
  return medicineCopy(l10n, item.stateKey);
}

String doseSummary(AppLocalizations l10n, MedicinePlanItem item) {
  return [
    itemName(l10n, item),
    itemDosage(l10n, item),
    compactRouteOrSchedule(itemSchedule(l10n, item)),
  ].where((value) => value.trim().isNotEmpty).join('  ');
}

String compactRouteOrSchedule(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return '—';
  return trimmed;
}
