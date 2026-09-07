import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/record/presentation/utils/detail_labels.dart';
import 'package:luminous/features/record/presentation/widgets/detail/surface.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Same-day water progress card for the record detail page.
///
/// The water total/target are aggregated and resolved by the caller (only
/// water records with ml data pass non-zero values), keeping the conditional
/// provider watch semantics of the original inline build: non-water records
/// never trigger the water-target or health-context fetches.
class WaterProgressCard extends StatelessWidget {
  const WaterProgressCard({
    super.key,
    required this.waterTotalMl,
    required this.waterTargetMl,
    required this.isImperialWater,
  });

  final int waterTotalMl;
  final int waterTargetMl;
  final bool isImperialWater;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.theme.colors;
    final typography = context.theme.typography;

    return DetailSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(SemanticIcons.recordWater, size: 18),
              const SizedBox(width: Spacing.level3),
              Expanded(
                child: Text(
                  l10n.recordDetailDailyWaterTitle,
                  style: typography.body.sm.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                isImperialWater
                    ? l10n.recordDetailDailyWaterProgressOz(
                        formatFlOz(waterTotalMl),
                        formatFlOz(waterTargetMl),
                      )
                    : l10n.recordDetailDailyWaterProgress(
                        waterTotalMl,
                        waterTargetMl,
                      ),
                style: typography.body.xs.copyWith(
                  color: SemanticColor.neutral.solid(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.level4),
          ClipRRect(
            borderRadius: context.theme.style.borderRadius.xs2,
            child: LinearProgressIndicator(
              value: (waterTotalMl / waterTargetMl).clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: colors.muted,
              color: SemanticColor.primary.solid(context),
            ),
          ),
        ],
      ),
    );
  }
}
