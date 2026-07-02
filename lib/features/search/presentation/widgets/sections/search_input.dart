import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/l10n/app_localizations.dart';

class SearchInput extends HookWidget {
  const SearchInput({
    super.key,
    required this.l10n,
    required this.query,
    required this.onChanged,
  });

  final AppLocalizations l10n;
  final String query;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController(text: query);
    final colors = context.theme.colors;
    final textTheme = Theme.of(context).textTheme;

    useEffect(() {
      if (query != controller.text) {
        controller.text = query;
      }
      return null;
    }, [query]);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
        border: Border.all(color: colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacingTokens.md,
          vertical: AppSpacingTokens.sm,
        ),
        child: Row(
          children: [
            Icon(FLucideIcons.search, color: colors.mutedForeground, size: 18),
            const SizedBox(width: AppSpacingTokens.sm),
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: l10n.medicineSearchFieldHint,
                  hintStyle: textTheme.bodyMedium?.copyWith(
                    color: colors.mutedForeground,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                style: textTheme.bodyMedium,
                onChanged: onChanged,
                textInputAction: TextInputAction.search,
                onSubmitted: onChanged,
              ),
            ),
            if (controller.text.isNotEmpty)
              GestureDetector(
                onTap: () {
                  controller.clear();
                  onChanged('');
                },
                child: Icon(
                  FLucideIcons.circleX,
                  color: colors.mutedForeground,
                  size: 18,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
