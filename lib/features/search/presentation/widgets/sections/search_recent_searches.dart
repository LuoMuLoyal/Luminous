import 'package:flutter/material.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/l10n/app_localizations.dart';

class RecentSearches extends StatelessWidget {
  const RecentSearches({
    super.key,
    required this.keywords,
    required this.l10n,
    required this.typography,
    required this.surface,
    this.onKeywordSelected,
  });
  final List<String> keywords;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final ValueChanged<String>? onKeywordSelected;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Text(l10n.medicineSearchRecentTitle, style: typography.bodyMdStrong),
          const Spacer(),
          Text(
            l10n.medicineSearchClearAction,
            style: typography.bodySmStrong.copyWith(color: surface.link),
          ),
        ],
      ),
      const SizedBox(height: AppSpacingTokens.sm),
      Wrap(
        spacing: AppSpacingTokens.sm,
        runSpacing: AppSpacingTokens.sm,
        children: keywords
            .map(
              (keyword) => ActionChip(
                label: Text(keyword),
                onPressed: () => onKeywordSelected?.call(keyword),
              ),
            )
            .toList(),
      ),
    ],
  );
}
