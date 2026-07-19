import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/features/report/domain/entities/dashboard.dart';
import 'package:luminous/features/report/presentation/widgets/shared/section_models.dart';
import 'package:luminous/l10n/app_localizations.dart';

class ReportScoreHero extends StatelessWidget {
  const ReportScoreHero({
    super.key,
    required this.dashboard,
    required this.l10n,
    this.isPreview = false,
  });

  final ReportDashboard dashboard;
  final AppLocalizations l10n;
  final bool isPreview;

  @override
  Widget build(BuildContext context) {
    final score = dashboard.score;
    final colors = context.theme.colors;
    final titleText = isPreview
        ? l10n.reportScoreTitlePreview
        : l10n.reportScoreTitle;
    final outOfText = isPreview
        ? l10n.reportScoreOutOfPreview(score.maxValue)
        : l10n.reportScoreOutOf(score.maxValue);

    return FCard.raw(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.level5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          titleText,
                          style: TypographyToken.level7
                              .display(context)
                              .copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                      FTooltip(
                        tipBuilder: (context, controller) =>
                            Text(l10n.reportScoreHelpTooltip),
                        child: Icon(
                          FLucideIcons.circleHelp,
                          color: colors.mutedForeground,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Spacing.level4),
                  Wrap(
                    spacing: Spacing.level3,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      AppSkeletonSlot(
                        skeleton: const AppInlineSkeletonBlock(
                          height: 58,
                          width: 76,
                          radius: RadiusTokens.level3,
                        ),
                        child: Text(
                          score.value.toString(),
                          style: TypographyToken.level9
                              .display(context)
                              .copyWith(
                                color: context.theme.colors.primary,
                                fontSize: ResponsiveSizing.scaleByWidth(
                                  context,
                                  fraction: 0.128,
                                  minValue: 40,
                                  maxValue: 54,
                                ),
                                height: 1,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ),
                      Text(
                        outOfText,
                        style: TypographyToken.level5
                            .body(context)
                            .copyWith(color: colors.mutedForeground),
                      ),
                      AppSkeletonSlot(
                        skeleton: const AppInlineSkeletonBlock(
                          height: 22,
                          width: 64,
                          radius: RadiusTokens.level2,
                        ),
                        child: _StatusBadge(
                          label: reportStatusLabel(l10n, score.status),
                          color: reportStatusColor(score.status),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Spacing.level5),
                  AppSkeletonText(
                    text: score.summary,
                    style: TypographyToken.level4
                        .body(context)
                        .copyWith(fontWeight: FontWeight.w600),
                    widthFactor: 0.88,
                  ),
                ],
              ),
            ),
            const SizedBox(width: Spacing.level4),
            FAvatar.raw(
              size: ResponsiveSizing.scaleByWidth(
                context,
                fraction: 0.26,
                minValue: 80,
                maxValue: 112,
              ),
              style: .delta(backgroundColor: colors.primary),
              child: Icon(
                FLucideIcons.badgeCheck,
                color: colors.primaryForeground,
                size: ResponsiveSizing.scaleByWidth(
                  context,
                  fraction: 0.16,
                  minValue: 48,
                  maxValue: 68,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.color});

  final String label;
  final SemanticColor color;

  @override
  Widget build(BuildContext context) {
    final resolvedColor = color.solid(context);

    return FBadge.raw(
      style: .delta(
        decoration: .shapeDelta(
          color: color.muted(context),
          shape: RoundedSuperellipseBorder(
            borderRadius: context.theme.style.borderRadius.pill,
          ),
        ),
      ),
      builder: (context, style) => Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.level3,
          vertical: Spacing.level1,
        ),
        child: Text(
          label,
          style: TypographyToken.level3
              .body(context)
              .copyWith(color: resolvedColor, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}
