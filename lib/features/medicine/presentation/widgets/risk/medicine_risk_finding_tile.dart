import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/app_colors.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/features/medicine/domain/entities/medicine_risk_check.dart';
import 'package:luminous/features/medicine/presentation/widgets/shared/medicine_copy.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/core/widgets/common/app_divider.dart';

class MedicineRiskFindingTile extends StatelessWidget {
  const MedicineRiskFindingTile({
    super.key,
    required this.finding,
    required this.isLast,
    required this.l10n,
  });

  final MedicineRiskFinding finding;
  final bool isLast;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    final color = medicineRiskSeverityColor(finding.severity);
    final contextLabel = medicineRiskContextLabel(l10n, finding.context);

    final tile = Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacingTokens.level3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: medicineRiskSeveritySoftColor(
                finding.severity,
              ).resolve(colors).withValues(alpha: 0.56),
              shape: BoxShape.circle,
            ),
            child: SizedBox.square(
              dimension: AppSpacingTokens.level9,
              child: Icon(
                medicineRiskFindingIcon(finding),
                color: color.resolve(colors),
                size: AppSpacingTokens.level5,
              ),
            ),
          ),
          const SizedBox(width: AppSpacingTokens.level3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medicineRiskFindingTitle(l10n, finding),
                  style: AppTypographyToken.level5
                      .body(context)
                      .copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: AppSpacingTokens.level1),
                Text(
                  medicineRiskFindingBody(l10n, finding),
                  style: AppTypographyToken.level3
                      .body(context)
                      .copyWith(color: colors.mutedForeground),
                ),
                const SizedBox(height: AppSpacingTokens.level1),
                Text(
                  medicineRiskFindingEvidence(l10n, finding),
                  style: AppTypographyToken.level3
                      .body(context)
                      .copyWith(color: colors.mutedForeground),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacingTokens.level3),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              FBadge.raw(
                builder: (context, style) {
                  final resolvedColor = color.resolve(colors);
                  final foreground = 0.08 > 0.5
                      ? colors.primaryForeground
                      : resolvedColor;
                  return DecoratedBox(
                    decoration: ShapeDecoration(
                      color: resolvedColor.withValues(alpha: 0.08),
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
                            medicineRiskSeverityLabel(l10n, finding.severity),
                            style: AppTypographyToken.level3
                                .body(context)
                                .copyWith(
                                  color: foreground,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0,
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
              if (contextLabel.isNotEmpty) ...[
                const SizedBox(height: AppSpacingTokens.level1),
                FBadge.raw(
                  builder: (context, style) {
                    final resolvedColor = AppColors.muted.resolve(colors);
                    final foreground = 0.08 > 0.5
                        ? colors.primaryForeground
                        : resolvedColor;
                    return DecoratedBox(
                      decoration: ShapeDecoration(
                        color: resolvedColor.withValues(alpha: 0.08),
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
                              contextLabel,
                              style: AppTypographyToken.level3
                                  .body(context)
                                  .copyWith(
                                    color: foreground,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0,
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
            ],
          ),
        ],
      ),
    );

    if (isLast) return tile;
    return Column(
      children: [
        tile,
        AppDivider(color: colors.border),
      ],
    );
  }
}
