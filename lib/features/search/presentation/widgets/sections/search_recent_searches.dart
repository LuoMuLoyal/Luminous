import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/l10n/app_localizations.dart';

class RecentSearches extends StatelessWidget {
  const RecentSearches({
    super.key,
    required this.keywords,
    required this.l10n,
    this.onKeywordSelected,
  });

  final List<String> keywords;
  final AppLocalizations l10n;
  final ValueChanged<String>? onKeywordSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              l10n.medicineSearchRecentTitle,
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            Text(
              l10n.medicineSearchClearAction,
              style: textTheme.labelMedium?.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacingTokens.sm),
        Wrap(
          spacing: AppSpacingTokens.sm,
          runSpacing: AppSpacingTokens.sm,
          children: keywords
              .map(
                (keyword) => FButton(
                  variant: FButtonVariant.secondary,
                  size: FButtonSizeVariant.sm,
                  onPress: () => onKeywordSelected?.call(keyword),
                  child: Text(keyword),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
