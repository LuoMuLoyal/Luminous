import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/medicine/domain/entities/risk_check.dart';
import 'package:luminous/features/medicine/presentation/widgets/risk/finding_tile.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Findings section of the risk check tab — shows a foldable list of
/// risk findings with a "show all / collapse" toggle.
class FindingsTabSection extends StatelessWidget {
  const FindingsTabSection({
    super.key,
    required this.l10n,
    required this.result,
    required this.findingsKey,
    required this.expanded,
    required this.onToggle,
    required this.foldThreshold,
  });

  final AppLocalizations l10n;
  final MedicineRiskCheckResult result;
  final GlobalKey findingsKey;
  final bool expanded;
  final VoidCallback onToggle;
  final int foldThreshold;

  @override
  Widget build(BuildContext context) {
    final visibleCount = expanded
        ? result.findings.length
        : result.findings.length.clamp(0, foldThreshold);

    return Column(
      key: findingsKey,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.medicineRiskCheckFindingsTitle,
          style: context.theme.typography.body.lg.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: Spacing.level3),
        for (var i = 0; i < visibleCount; i += 1)
          RiskFindingItem(
            finding: result.findings[i],
            isLast: i == visibleCount - 1,
            l10n: l10n,
          ),
        if (result.findings.length > foldThreshold) ...[
          const SizedBox(height: Spacing.level3),
          Center(
            child: FButton(
              variant: FButtonVariant.ghost,
              size: .sm,
              onPress: onToggle,
              child: Text(
                expanded
                    ? l10n.medicineRiskCheckCollapse
                    : l10n.medicineRiskCheckShowAll(result.findings.length),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
