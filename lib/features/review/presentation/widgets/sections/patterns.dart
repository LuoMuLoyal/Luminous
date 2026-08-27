import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/features/review/domain/entities/dashboard.dart';
import 'package:luminous/features/review/presentation/widgets/shared/components.dart';
import 'package:luminous/features/review/presentation/widgets/shared/section_models.dart';
import 'package:luminous/l10n/app_localizations.dart';

class ReviewPatternsSection extends StatelessWidget {
  const ReviewPatternsSection({
    super.key,
    required this.patterns,
    required this.l10n,
  });

  final List<ReviewPatternCard> patterns;
  final AppLocalizations l10n;

  double _patternCardHeight(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= Breakpoints.desktop) return 196;
    if (width >= Breakpoints.tablet) return 188;
    return 176;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.reviewPatternSectionTitle,
          style: TypographyToken.level5
              .body(context)
              .copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: Spacing.level3),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: patterns.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: Spacing.level3,
            mainAxisSpacing: Spacing.level3,
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

  final ReviewPatternCard pattern;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return FCard(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.level4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                FAvatar.raw(
                  size: ResponsiveSizing.scaleByWidth(
                    context,
                    fraction: 0.088,
                    minValue: 30,
                    maxValue: 38,
                  ),
                  child: Icon(
                    pattern.icon,
                    color: pattern.color.solid(context),
                    size: ResponsiveSizing.scaleByWidth(
                      context,
                      fraction: 0.048,
                      minValue: 16,
                      maxValue: 22,
                    ),
                  ),
                ),
                const SizedBox(width: Spacing.level2),
                Expanded(
                  child: Text(
                    pattern.title,
                    style: TypographyToken.level5
                        .body(context)
                        .copyWith(fontWeight: FontWeight.w800),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.level4),
            SkeletonText(
              text: reportStatusLabel(l10n, pattern.status),
              style: TypographyToken.level4
                  .body(context)
                  .copyWith(fontWeight: FontWeight.w800),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              widthFactor: 0.74,
            ),
            const SizedBox(height: Spacing.level1),
            SkeletonText(
              text: pattern.body,
              style: TypographyToken.level3
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
                  child: SkeletonSlot(
                    skeleton: const InlineSkeletonBlock(
                      height: 22,
                      radius: RadiusTokens.level2,
                    ),
                    child: ReviewMetricTrack(
                      values: pattern.sparkline,
                      color: pattern.color,
                      height: ResponsiveSizing.scaleByHeight(
                        context,
                        fraction: 0.034,
                        minValue: 22,
                        maxValue: 30,
                      ),
                    ),
                  ),
                ),
                // No decorative chevron — the card is informational, not
                // navigational.
              ],
            ),
          ],
        ),
      ),
    );
  }
}
