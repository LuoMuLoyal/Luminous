import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/medicine/domain/entities/risk_check.dart';
import 'package:luminous/features/medicine/presentation/widgets/risk/coverage_issue_tile.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Coverage section of the risk check tab — shows a foldable list of
/// coverage issues with a "show all / collapse" toggle.
class CoverageTabSection extends StatelessWidget {
  const CoverageTabSection({
    super.key,
    required this.l10n,
    required this.result,
    required this.coverageKey,
    required this.expanded,
    required this.onToggle,
    required this.foldThreshold,
  });

  final AppLocalizations l10n;
  final MedicineRiskCheckResult result;
  final GlobalKey coverageKey;
  final bool expanded;
  final VoidCallback onToggle;
  final int foldThreshold;

  @override
  Widget build(BuildContext context) {
    final visibleCount = expanded
        ? result.coverageIssues.length
        : result.coverageIssues.length.clamp(0, foldThreshold);

    return Column(
      key: coverageKey,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.medicineRiskCheckCoverageTitle,
          style: TypographyToken.level6
              .body(context)
              .copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: Spacing.level3),
        for (var i = 0; i < visibleCount; i += 1)
          RiskCoverageItem(
            issue: result.coverageIssues[i],
            isLast: i == visibleCount - 1,
            l10n: l10n,
          ),
        if (result.coverageIssues.length > foldThreshold) ...[
          const SizedBox(height: Spacing.level3),
          Center(
            child: FButton(
              variant: FButtonVariant.ghost,
              size: .sm,
              onPress: onToggle,
              child: Text(
                expanded
                    ? l10n.medicineRiskCheckCollapse
                    : l10n.medicineRiskCheckShowAll(
                        result.coverageIssues.length,
                      ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
