import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/medicine/domain/entities/workspace.dart';
import 'package:luminous/features/medicine/presentation/widgets/shared/copy.dart';
import 'package:luminous/features/medicine/presentation/widgets/shared/workspace_parts.dart';
import 'package:luminous/features/medicine/presentation/widgets/workspace/workspace_helpers.dart';
import 'package:luminous/l10n/app_localizations.dart';

class MedicineTodayPlanSection extends StatelessWidget {
  const MedicineTodayPlanSection({
    super.key,
    required this.workspace,
    required this.l10n,
    required this.onMarkDose,
  });

  final MedicineWorkspace workspace;
  final AppLocalizations l10n;
  final void Function(MedicineDoseMarkRequest request)? onMarkDose;

  @override
  Widget build(BuildContext context) {
    return FCard.raw(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacingTokens.level4),
        child: Column(
          children: [
            for (var index = 0; index < workspace.plan.items.length; index += 1)
              Padding(
                padding: EdgeInsets.only(
                  bottom: index == workspace.plan.items.length - 1
                      ? 0
                      : AppSpacingTokens.level4,
                ),
                child: _MedicationPlanTile(
                  item: workspace.plan.items[index],
                  l10n: l10n,
                  onMarkDose: onMarkDose,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MedicationPlanTile extends StatelessWidget {
  const _MedicationPlanTile({
    required this.item,
    required this.l10n,
    required this.onMarkDose,
  });

  final MedicinePlanItem item;
  final AppLocalizations l10n;
  final void Function(MedicineDoseMarkRequest request)? onMarkDose;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    final nameText = item.rawName ?? medicineCopy(l10n, item.nameKey);
    final dosageText = item.rawDosage ?? medicineCopy(l10n, item.dosageKey);
    final scheduleText =
        item.rawSchedule ?? medicineCopy(l10n, item.scheduleKey);
    final stateText = item.rawState ?? medicineCopy(l10n, item.stateKey);
    final takenRequest = buildMedicineDoseMarkRequest(
      item: item,
      action: MedicineDoseAction.taken,
    );
    final skippedRequest = buildMedicineDoseMarkRequest(
      item: item,
      action: MedicineDoseAction.skipped,
    );

    return FTappable(
      onPress: () =>
          showPlannedAction(context, nameText, l10n.medicineOpenPlanItemToast),
      child: FCard.raw(
        style: .delta(
          decoration: .shapeDelta(
            color: colors.background,
            shape: RoundedSuperellipseBorder(
              side: BorderSide(color: colors.border),
              borderRadius: context.theme.style.borderRadius.lg,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacingTokens.level4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nameText,
                          style: AppTypographyToken.level4
                              .body(context)
                              .copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: AppSpacingTokens.level2),
                        Text(
                          '$dosageText · $scheduleText',
                          style: AppTypographyToken.level3
                              .body(context)
                              .copyWith(color: colors.mutedForeground),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacingTokens.level3),
                  FBadge.raw(
                    builder: (context, style) {
                      final resolvedColor = item.stateColor.resolve(colors);
                      final foreground = 0.12 > 0.5
                          ? colors.primaryForeground
                          : resolvedColor;
                      return DecoratedBox(
                        decoration: ShapeDecoration(
                          color: resolvedColor.withValues(alpha: 0.12),
                          shape: RoundedSuperellipseBorder(
                            borderRadius: BorderRadius.circular(
                              AppRadiusTokens.levelFull,
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacingTokens.level2,
                            vertical: AppSpacingTokens.level1,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                stateText,
                                style: AppTypographyToken.level4
                                    .body(context)
                                    .copyWith(
                                      color: foreground,
                                      fontWeight: FontWeight.w600,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              if (takenRequest != null &&
                  skippedRequest != null &&
                  onMarkDose != null) ...[
                const SizedBox(height: AppSpacingTokens.level3),
                Row(
                  children: [
                    Expanded(
                      child: FButton(
                        variant: FButtonVariant.outline,
                        onPress: () => onMarkDose!(takenRequest),
                        prefix: const Icon(FLucideIcons.check, size: 16),
                        child: Text(l10n.medicineDoseActionTaken),
                      ),
                    ),
                    const SizedBox(width: AppSpacingTokens.level3),
                    Expanded(
                      child: FButton(
                        variant: FButtonVariant.outline,
                        onPress: () => onMarkDose!(skippedRequest),
                        prefix: const Icon(FLucideIcons.ban, size: 16),
                        child: Text(l10n.medicineDoseActionSkipped),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
