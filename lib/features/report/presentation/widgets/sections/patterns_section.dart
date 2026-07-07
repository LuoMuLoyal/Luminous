import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/colors.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/design/responsive_sizing.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/features/report/domain/entities/dashboard.dart';
import 'package:luminous/features/report/presentation/widgets/shared/components.dart';
import 'package:luminous/features/report/presentation/widgets/shared/section_models.dart';
import 'package:luminous/l10n/app_localizations.dart';

class ReportPatternsSection extends StatelessWidget {
  const ReportPatternsSection({
    super.key,
    required this.patterns,
    required this.l10n,
  });

  final List<ReportPatternCard> patterns;
  final AppLocalizations l10n;

  double _patternCardHeight(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= AppBreakpoints.desktop) return 196;
    if (width >= AppBreakpoints.tablet) return 188;
    return 176;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.reportPatternSectionTitle,
          style: AppTypographyToken.level5
              .body(context)
              .copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: AppSpacingTokens.level3),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: patterns.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: AppSpacingTokens.level3,
            mainAxisSpacing: AppSpacingTokens.level3,
            mainAxisExtent: _patternCardHeight(context),
          ),
          itemBuilder: (context, index) {
            return _PatternCard(pattern: patterns[index], l10n: l10n);
          },
        ),
      ],
    );
  }
}

class _PatternCard extends StatelessWidget {
  const _PatternCard({required this.pattern, required this.l10n});

  final ReportPatternCard pattern;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return FCard.raw(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacingTokens.level4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                FAvatar.raw(
                  size: AppResponsiveSizing.scaleByWidth(
                    context,
                    fraction: 0.088,
                    minValue: 30,
                    maxValue: 38,
                  ),
                  child: Icon(
                    pattern.icon,
                    color: pattern.color.resolve(colors),
                    size: AppResponsiveSizing.scaleByWidth(
                      context,
                      fraction: 0.048,
                      minValue: 16,
                      maxValue: 22,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacingTokens.level2),
                Expanded(
                  child: Text(
                    pattern.title,
                    style: AppTypographyToken.level5
                        .body(context)
                        .copyWith(fontWeight: FontWeight.w800),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacingTokens.level4),
            AppSkeletonText(
              text: reportStatusLabel(l10n, pattern.status),
              style: AppTypographyToken.level4
                  .body(context)
                  .copyWith(fontWeight: FontWeight.w800),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              widthFactor: 0.74,
            ),
            const SizedBox(height: AppSpacingTokens.level1),
            AppSkeletonText(
              text: pattern.body,
              style: AppTypographyToken.level3
                  .body(context)
                  .copyWith(color: colors.mutedForeground),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              widthFactor: 0.88,
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: AppSkeletonSlot(
                    skeleton: const AppInlineSkeletonBlock(
                      height: 22,
                      radius: AppRadiusTokens.level2,
                    ),
                    child: ReportMetricTrack(
                      values: pattern.sparkline,
                      color: pattern.color,
                      height: AppResponsiveSizing.scaleByHeight(
                        context,
                        fraction: 0.034,
                        minValue: 22,
                        maxValue: 30,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacingTokens.level3),
                Icon(
                  FLucideIcons.chevronRight,
                  color: colors.mutedForeground,
                  size: 18,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
