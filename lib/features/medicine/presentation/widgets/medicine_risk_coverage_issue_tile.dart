import 'package:flutter/material.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/features/medicine/domain/entities/medicine_risk_check.dart';
import 'package:luminous/features/medicine/presentation/widgets/medicine_copy.dart';
import 'package:luminous/l10n/app_localizations.dart';

class MedicineRiskCoverageIssueTile extends StatelessWidget {
  const MedicineRiskCoverageIssueTile({
    super.key,
    required this.issue,
    required this.isLast,
    required this.typography,
    required this.surface,
    required this.l10n,
  });

  final MedicineRiskCoverageIssue issue;
  final bool isLast;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final tile = Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacingTokens.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AppColorTokens.warningDeep,
            size: AppSpacingTokens.lg,
          ),
          const SizedBox(width: AppSpacingTokens.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  issue.medicineName,
                  style: typography.bodyMdStrong.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacingTokens.xxs),
                Text(
                  medicineRiskCoverageReasonLabel(l10n, issue.reason),
                  style: typography.bodySm.copyWith(color: surface.body),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    if (isLast) return tile;
    return Column(
      children: [
        tile,
        Divider(height: 1, color: surface.hairline),
      ],
    );
  }
}
