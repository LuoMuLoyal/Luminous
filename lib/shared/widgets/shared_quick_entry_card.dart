import 'package:flutter/material.dart';
import 'package:luminous/shared/widgets/quick_entry_style.dart';
import 'package:luminous/shared/widgets/responsive_quick_grid.dart';

/// Shared quick-entry card used by Home, Mine and Drug sections.
class SharedQuickEntryCard extends StatelessWidget {
  const SharedQuickEntryCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
    this.metrics,
    this.repaintBoundary = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  final ResponsiveQuickGridMetrics? metrics;
  final bool repaintBoundary;

  @override
  Widget build(BuildContext context) {
    final content = LayoutBuilder(
      builder: (context, constraints) {
        final resolvedMetrics =
            metrics ??
            ResponsiveQuickGridMetrics.fromWidth(
              constraints.maxWidth,
              textScaleFactor: MediaQuery.textScalerOf(context).scale(1),
            );
        final compact = resolvedMetrics.isCompact;
        final iconBoxSize = resolvedMetrics.iconBoxSize + (compact ? 4 : 2);
        final iconSize = resolvedMetrics.iconSize + (compact ? 1 : 0);
        final style = resolveQuickEntryVisualStyle(context, color);

        return Semantics(
          button: true,
          label: title,
          hint: subtitle,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: 48,
              minHeight: compact ? 124 : 136,
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(kQuickEntryCardRadius),
              onTap: onTap,
              child: Ink(
                decoration: BoxDecoration(
                  color: style.background,
                  borderRadius: BorderRadius.circular(kQuickEntryCardRadius),
                  border: Border.all(color: style.border),
                ),
                child: Padding(
                  padding: resolvedMetrics.itemPadding,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        child: SizedBox(
                          width: iconBoxSize,
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: style.iconBackground,
                                borderRadius: BorderRadius.circular(
                                  resolvedMetrics.iconBorderRadius,
                                ),
                                border: Border.all(color: style.iconBorder),
                              ),
                              child: Icon(
                                icon,
                                size: iconSize,
                                color: style.iconColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: resolvedMetrics.titleSpacing),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: compact ? 14 : 14.5,
                          fontWeight: FontWeight.w800,
                          color: style.titleColor,
                          height: 1.2,
                          leadingDistribution: TextLeadingDistribution.even,
                        ),
                      ),
                      SizedBox(height: resolvedMetrics.subtitleSpacing),
                      Text(
                        subtitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: compact ? 11.5 : 12,
                          color: style.subtitleColor,
                          fontWeight: FontWeight.w700,
                          height: compact ? 1.28 : 1.32,
                          leadingDistribution: TextLeadingDistribution.even,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    if (repaintBoundary) {
      return RepaintBoundary(child: content);
    }
    return content;
  }
}
