import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/features/medicine/domain/entities/medicine_risk_check.dart';
import 'package:luminous/features/medicine/presentation/widgets/shared/medicine_copy.dart';
import 'package:luminous/l10n/app_localizations.dart';

class MedicineRiskRedFlagBanner extends StatelessWidget {
  const MedicineRiskRedFlagBanner({
    super.key,
    required this.alerts,
    required this.l10n,
  });

  final List<RedFlagAlert> alerts;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacingTokens.level4),
      decoration: BoxDecoration(
        color: Color(0xFFDC2626).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadiusTokens.level3),
        border: Border.all(color: Color(0xFFDC2626).withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                FLucideIcons.triangleAlert,
                color: Color(0xFFDC2626),
                size: 20,
              ),
              const SizedBox(width: AppSpacingTokens.level3),
              Text(
                redFlagBannerTitle(l10n),
                style: textTheme.labelLarge?.copyWith(
                  color: Color(0xFFDC2626),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacingTokens.level3),
          for (var i = 0; i < alerts.length; i += 1) ...[
            if (i > 0) const SizedBox(height: AppSpacingTokens.level3),
            MedicineRiskRedFlagAlertRow(alert: alerts[i], l10n: l10n),
          ],
        ],
      ),
    );
  }
}

class MedicineRiskRedFlagAlertRow extends StatelessWidget {
  const MedicineRiskRedFlagAlertRow({
    super.key,
    required this.alert,
    required this.l10n,
  });

  final RedFlagAlert alert;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacingTokens.level3),
      decoration: BoxDecoration(
        color: colors.background.withValues(alpha: 0.84),
        borderRadius: BorderRadius.circular(AppRadiusTokens.level2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  redFlagAlertCopy(l10n, alert),
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.foreground,
                  ),
                ),
                const SizedBox(height: AppSpacingTokens.level3),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      FLucideIcons.siren,
                      color: Color(0xFFDC2626),
                      size: 16,
                    ),
                    const SizedBox(width: AppSpacingTokens.level2),
                    Expanded(
                      child: Text(
                        redFlagActionCopy(l10n, alert),
                        style: textTheme.bodySmall?.copyWith(
                          color: Color(0xFFDC2626),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
