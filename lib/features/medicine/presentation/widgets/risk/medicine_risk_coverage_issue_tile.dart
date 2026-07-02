import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/features/medicine/domain/entities/medicine_risk_check.dart';
import 'package:luminous/features/medicine/presentation/widgets/shared/medicine_copy.dart';
import 'package:luminous/l10n/app_localizations.dart';

class MedicineRiskCoverageIssueTile extends StatelessWidget {
  const MedicineRiskCoverageIssueTile({
    super.key,
    required this.issue,
    required this.isLast,
    required this.l10n,
  });

  final MedicineRiskCoverageIssue issue;
  final bool isLast;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final textTheme = Theme.of(context).textTheme;

    final tile = Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacingTokens.level3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            FLucideIcons.circleAlert,
            color: Color(0xFFB45309),
            size: AppSpacingTokens.level5,
          ),
          const SizedBox(width: AppSpacingTokens.level3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  issue.medicineName,
                  style: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacingTokens.level1),
                Text(
                  medicineRiskCoverageReasonLabel(l10n, issue.reason),
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.mutedForeground,
                  ),
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
        Divider(height: 1, color: colors.border),
      ],
    );
  }
}
