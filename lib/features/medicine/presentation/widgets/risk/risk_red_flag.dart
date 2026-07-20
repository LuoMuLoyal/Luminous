import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/medicine/domain/entities/risk_check.dart';
import 'package:luminous/features/medicine/presentation/widgets/shared/copy.dart';
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
    return Container(
      padding: const EdgeInsets.all(Spacing.level4),
      decoration: BoxDecoration(
        color: SemanticColor.destructive.muted(context),
        borderRadius: BorderRadius.circular(RadiusTokens.level3),
        border: Border.all(color: SemanticColor.destructive.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                FLucideIcons.triangleAlert,
                color: SemanticColor.destructive.solid(context),
                size: 20,
              ),
              const SizedBox(width: Spacing.level3),
              Text(
                redFlagBannerTitle(l10n),
                style: TypographyToken.level5
                    .body(context)
                    .copyWith(
                      color: SemanticColor.destructive.solid(context),
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.level3),
          for (var i = 0; i < alerts.length; i += 1) ...[
            if (i > 0) const SizedBox(height: Spacing.level3),
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

    return Container(
      padding: const EdgeInsets.all(Spacing.level3),
      decoration: BoxDecoration(
        color: colors.background.withValues(alpha: 0.84),
        borderRadius: BorderRadius.circular(RadiusTokens.level2),
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
                  style: TypographyToken.level3
                      .body(context)
                      .copyWith(color: colors.foreground),
                ),
                const SizedBox(height: Spacing.level3),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      FLucideIcons.siren,
                      color: SemanticColor.destructive.solid(context),
                      size: Spacing.level5,
                    ),
                    const SizedBox(width: Spacing.level2),
                    Expanded(
                      child: Text(
                        redFlagActionCopy(l10n, alert),
                        style: TypographyToken.level3
                            .body(context)
                            .copyWith(
                              color: SemanticColor.destructive.solid(context),
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
