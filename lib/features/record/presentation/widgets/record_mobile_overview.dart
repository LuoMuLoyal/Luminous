import 'package:flutter/material.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/core/widgets/app_state_views.dart';
import 'package:luminous/features/record/domain/entities/record_dashboard.dart';
import 'package:luminous/features/record/presentation/widgets/record_components.dart';
import 'package:luminous/features/record/presentation/widgets/record_dashboard_tokens.dart';
import 'package:luminous/features/record/presentation/widgets/record_shared_widgets.dart';
import 'package:luminous/l10n/app_localizations.dart';

class RecordMobileOverview extends StatelessWidget {
  const RecordMobileOverview({
    super.key,
    required this.dashboard,
    required this.l10n,
    required this.typography,
    required this.surface,
  });

  final RecordDashboard dashboard;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const Key('record-today-overview'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.recordTodayOverviewTitle, style: typography.displaySm),
        const SizedBox(height: AppSpacingTokens.sm),
        _OverviewGrid(
          dashboard: dashboard,
          l10n: l10n,
          typography: typography,
          surface: surface,
        ),
      ],
    );
  }
}

class _OverviewGrid extends StatelessWidget {
  const _OverviewGrid({
    required this.dashboard,
    required this.l10n,
    required this.typography,
    required this.surface,
  });

  final RecordDashboard dashboard;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    final items = buildMobileOverviewItems(l10n, dashboard);
    final rows = <List<RecordMobileOverviewItem>>[];
    for (var index = 0; index < items.length; index += 3) {
      rows.add(items.skip(index).take(3).toList(growable: false));
    }

    return RecordSectionSurface(
      typography: typography,
      surface: surface,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var rowIndex = 0; rowIndex < rows.length; rowIndex += 1) ...[
            SizedBox(
              height: 84,
              child: Row(
                children: [
                  for (
                    var index = 0;
                    index < rows[rowIndex].length;
                    index += 1
                  ) ...[
                    Expanded(
                      child: _OverviewItemTile(
                        item: rows[rowIndex][index],
                        typography: typography,
                        surface: surface,
                      ),
                    ),
                    if (index < rows[rowIndex].length - 1)
                      RecordShortVerticalDivider(
                        surface: surface,
                        height: AppSpacingTokens.x4l,
                      ),
                  ],
                  for (
                    var filler = rows[rowIndex].length;
                    filler < 3;
                    filler += 1
                  )
                    const Expanded(child: SizedBox.shrink()),
                ],
              ),
            ),
            if (rowIndex < rows.length - 1)
              RecordIndentedDivider(
                surface: surface,
                indent: AppSpacingTokens.md,
                endIndent: AppSpacingTokens.md,
              ),
          ],
        ],
      ),
    );
  }
}

class _OverviewItemTile extends StatelessWidget {
  const _OverviewItemTile({
    required this.item,
    required this.typography,
    required this.surface,
  });

  final RecordMobileOverviewItem item;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacingTokens.xxs,
        vertical: AppSpacingTokens.xxs,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(item.icon, color: item.color, size: AppSpacingTokens.lg),
          const SizedBox(height: AppSpacingTokens.xxs),
          AppSkeletonText(
            text: item.value,
            style: typography.bodyMdStrong.copyWith(
              fontWeight: FontWeight.w800,
            ),
            widthFactor: 0.64,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          AppSkeletonText(
            text: item.label,
            style: typography.caption.copyWith(
              color: surface.body,
              fontWeight: FontWeight.w600,
            ),
            widthFactor: 0.56,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
