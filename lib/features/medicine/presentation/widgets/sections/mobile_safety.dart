import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/medicine/domain/entities/risk_check.dart';
import 'package:luminous/features/medicine/domain/entities/workspace.dart';
import 'package:luminous/features/medicine/presentation/widgets/sections/safety_cards.dart';
import 'package:luminous/features/medicine/presentation/widgets/shared/copy.dart';
import 'package:luminous/l10n/app_localizations.dart';

class SafetyEngineSection extends StatelessWidget {
  const SafetyEngineSection({
    super.key,
    required this.records,
    required this.alerts,
    required this.l10n,
  });

  final MedicineRiskCheckRecords? records;
  final List<MedicineAlert> alerts;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final bestRecord = records?.bestRecord;
    final result = bestRecord?.result ?? const MedicineRiskCheckResult();
    final hasData = bestRecord != null;
    final visibleAlerts = alerts.take(2).toList(growable: false);

    return Column(
      key: const Key('medicine-safety-summary'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SafetyHeader(
          l10n: l10n,
          riskLevel: result.overallRiskLevel,
          hasData: hasData,
          isStale: records?.isStale ?? false,
          lastChecked: bestRecord?.updatedAt,
        ),
        const SizedBox(height: Spacing.level3),
        SafetyCard(
          l10n: l10n,
          result: result,
          riskLevel: result.overallRiskLevel,
          hasData: hasData,
          isStale: records?.isStale ?? false,
          visibleAlerts: visibleAlerts,
          alertCount: alerts.length,
        ),
      ],
    );
  }
}

class SafetyHeader extends StatelessWidget {
  const SafetyHeader({
    super.key,
    required this.l10n,
    required this.riskLevel,
    required this.hasData,
    required this.isStale,
    required this.lastChecked,
  });

  final AppLocalizations l10n;
  final MedicineRiskLevel riskLevel;
  final bool hasData;
  final bool isStale;
  final DateTime? lastChecked;

  @override
  Widget build(BuildContext context) {
    final typography = context.theme.typography;
    return Row(
      children: [
        Expanded(
          child: Text(
            l10n.medicineSafetyPanelTitle,
            style: typography.display.xl.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 0,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: Spacing.level2),
        if (hasData)
          LastCheckedLabel(
            l10n: l10n,
            isStale: isStale,
            lastChecked: lastChecked,
          )
        else
          Flexible(
            child: Text(
              l10n.medicineSafetyPanelEmptyBody,
              style: typography.body.xs.copyWith(
                color: SemanticColor.neutral.solid(context),
              ),
              textAlign: TextAlign.end,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }
}

class LastCheckedLabel extends StatelessWidget {
  const LastCheckedLabel({
    super.key,
    required this.l10n,
    required this.isStale,
    required this.lastChecked,
  });

  final AppLocalizations l10n;
  final bool isStale;
  final DateTime? lastChecked;

  @override
  Widget build(BuildContext context) {
    final typography = context.theme.typography;
    if (isStale) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            SemanticIcons.doseSlot,
            size: IconSizeTokens.level2,
            color: SemanticColor.warning.solid(context),
          ),
          const SizedBox(width: Spacing.level1),
          Text(
            l10n.medicineRiskCheckStale,
            style: typography.body.xs.copyWith(
              color: SemanticColor.warning.solid(context),
            ),
          ),
        ],
      );
    }

    final time = medicineRiskCheckFormatTime(lastChecked);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          SemanticIcons.doseSlot,
          size: IconSizeTokens.level2,
          color: SemanticColor.neutral.solid(context),
        ),
        const SizedBox(width: Spacing.level1),
        Text(
          l10n.medicineRiskCheckLastUpdated(time),
          style: typography.body.xs.copyWith(
            color: SemanticColor.neutral.solid(context),
          ),
        ),
      ],
    );
  }
}
