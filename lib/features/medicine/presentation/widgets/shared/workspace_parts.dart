import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/medicine/domain/entities/workspace.dart';

enum MedicineDoseAction { taken, skipped }

class MedicineDoseMarkRequest {
  const MedicineDoseMarkRequest({
    required this.currentMedicineId,
    required this.action,
    this.reminderId,
    this.scheduledTime,
  });

  final String currentMedicineId;
  final MedicineDoseAction action;
  final String? reminderId;
  final String? scheduledTime;
}

MedicineDoseMarkRequest? buildMedicineDoseMarkRequest({
  required MedicinePlanItem item,
  MedicineDoseSlot? slot,
  required MedicineDoseAction action,
}) {
  final currentMedicineId = item.currentMedicineId;
  if (currentMedicineId == null) {
    return null;
  }

  if (slot != null && slot.status != MedicineDoseStatus.pending) {
    return null;
  }
  if (slot == null && item.todayStatus != MedicineDoseStatus.pending) {
    return null;
  }

  final targetSlot = slot ?? _firstPendingSlot(item);
  return MedicineDoseMarkRequest(
    currentMedicineId: currentMedicineId,
    action: action,
    reminderId: targetSlot?.reminderId,
    scheduledTime: targetSlot?.scheduledTime ?? targetSlot?.rawTime,
  );
}

MedicineDoseSlot? _firstPendingSlot(MedicinePlanItem item) {
  for (final slot in item.slots) {
    if (slot.status == MedicineDoseStatus.pending) {
      return slot;
    }
  }
  return null;
}

/// 彩色文字 + 同色浅底的状态徽标，用于用药状态、配送状态等。
///
/// 文字颜色为 [color] 全不透明，背景为 [color] 的 12% 透明度。
class TintedStatusBadge extends StatelessWidget {
  const TintedStatusBadge({
    super.key,
    required this.color,
    required this.label,
  });

  final SemanticColor color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final resolvedColor = color.resolve(colors);
    final backgroundColor = Color.alphaBlend(
      resolvedColor.withValues(alpha: 0.14),
      colors.background,
    );

    return DecoratedBox(
      decoration: ShapeDecoration(
        color: backgroundColor,
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.level2),
          side: BorderSide(color: resolvedColor.withValues(alpha: 0.16)),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.level2,
          vertical: Spacing.level1,
        ),
        child: Text(
          label,
          style: TypographyToken.level3
              .body(context)
              .copyWith(
                color: resolvedColor,
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
              ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class MedicineHeaderActionChip extends StatelessWidget {
  const MedicineHeaderActionChip({
    super.key,
    required this.label,
    required this.icon,
    this.onTap,
    this.emphasized = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return FButton(
      onPress: onTap,
      variant: emphasized ? FButtonVariant.primary : FButtonVariant.outline,
      mainAxisSize: MainAxisSize.min,
      style: const .delta(
        contentStyle: .delta(
          padding: .value(
            EdgeInsets.symmetric(
              horizontal: Spacing.level4,
              vertical: Spacing.level3,
            ),
          ),
        ),
      ),
      prefix: Icon(icon, size: 18),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }
}
