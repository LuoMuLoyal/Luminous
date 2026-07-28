import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/medicine/domain/entities/risk_check.dart';
import 'package:luminous/features/medicine/presentation/widgets/shared/copy.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// A red-flag alert item with a left destructive colour bar and a subtle
/// destructive background. Replaces the old nested banner + inner containers.
class RiskRedFlagItem extends StatelessWidget {
  const RiskRedFlagItem({super.key, required this.alert, required this.l10n});

  final RedFlagAlert alert;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: SemanticColor.destructive.subtle(context),
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.level4),
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left destructive colour bar.
            Container(
              width: 4,
              decoration: ShapeDecoration(
                color: SemanticColor.destructive.solid(context),
                shape: RoundedSuperellipseBorder(
                  borderRadius: BorderRadius.circular(RadiusTokens.levelFull),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(Spacing.level4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          SemanticIcons.statusWarning,
                          color: SemanticColor.destructive.solid(context),
                          size: IconSizeTokens.level3,
                        ),
                        const SizedBox(width: Spacing.level2),
                        Expanded(
                          child: Text(
                            redFlagAlertCopy(l10n, alert),
                            style: TypographyToken.level4
                                .body(context)
                                .copyWith(
                                  color: context.theme.colors.foreground,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Spacing.level2),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          SemanticIcons.safetyDanger,
                          color: SemanticColor.destructive.solid(context),
                          size: IconSizeTokens.level2,
                        ),
                        const SizedBox(width: Spacing.level2),
                        Expanded(
                          child: Text(
                            redFlagActionCopy(l10n, alert),
                            style: TypographyToken.level3
                                .body(context)
                                .copyWith(
                                  color: SemanticColor.destructive.solid(
                                    context,
                                  ),
                                ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A section that displays multiple [RiskRedFlagItem]s.
class RiskRedFlagSection extends StatelessWidget {
  const RiskRedFlagSection({
    super.key,
    required this.alerts,
    required this.l10n,
  });

  final List<RedFlagAlert> alerts;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.medicineRiskCheckRedFlagBannerTitle,
          style: TypographyToken.level6
              .body(context)
              .copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: Spacing.level3),
        for (var i = 0; i < alerts.length; i += 1) ...[
          RiskRedFlagItem(alert: alerts[i], l10n: l10n),
          if (i < alerts.length - 1) const SizedBox(height: Spacing.level3),
        ],
      ],
    );
  }
}
