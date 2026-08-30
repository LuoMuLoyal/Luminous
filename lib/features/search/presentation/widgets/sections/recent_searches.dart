import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/l10n/app_localizations.dart';

class RecentSearches extends StatelessWidget {
  const RecentSearches({
    super.key,
    required this.keywords,
    required this.l10n,
    this.onKeywordSelected,
    this.onClear,
  });

  final List<String> keywords;
  final AppLocalizations l10n;
  final ValueChanged<String>? onKeywordSelected;

  /// Clears all recent search keywords. The section collapses back to
  /// `SizedBox.shrink` once the keyword list is empty.
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    if (keywords.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              l10n.medicineSearchRecentTitle,
              style: context.theme.typography.body.sm.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            FTappable(
              onPress: onClear,
              child: Text(
                l10n.medicineSearchClearAction,
                style: context.theme.typography.body.sm.copyWith(
                  color: SemanticColor.primary.solid(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: Spacing.level3),
        Wrap(
          spacing: Spacing.level3,
          runSpacing: Spacing.level3,
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
