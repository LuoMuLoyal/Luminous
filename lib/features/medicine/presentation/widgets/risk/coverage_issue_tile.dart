import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/divider.dart';
import 'package:luminous/features/medicine/domain/entities/risk_check.dart';
import 'package:luminous/features/medicine/presentation/widgets/shared/copy.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// A single coverage-gap item — icon + medicine name + reason label.
/// No [FCard] wrapper; items are separated by [AppDivider].
class RiskCoverageItem extends StatelessWidget {
  const RiskCoverageItem({
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
    final tile = Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.level3),
      child: Row(
        children: [
          Icon(
            SemanticIcons.statusError,
            color: SemanticColor.warning.solid(context),
            size: IconSizeTokens.level3,
          ),
          const SizedBox(width: Spacing.level3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  issue.medicineName,
                  style: context.theme.typography.body.md.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: Spacing.level1),
                Text(
                  medicineRiskCoverageReasonLabel(l10n, issue.reason),
                  style: context.theme.typography.body.xs.copyWith(
                    color: context.theme.colors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    if (isLast) return tile;
    return Column(children: [tile, const AppDivider()]);
  }
}
