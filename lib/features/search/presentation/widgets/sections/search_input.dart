import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/l10n/app_localizations.dart';

class SearchInput extends HookWidget {
  const SearchInput({
    super.key,
    required this.l10n,
    required this.typography,
    required this.surface,
    required this.query,
    required this.onChanged,
  });
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final String query;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController(text: query);

    useEffect(() {
      if (query != controller.text) {
        controller.text = query;
      }
      return null;
    }, [query]);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: surface.canvas,
        borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
        border: Border.all(
          color: surface.hairlineStrong.withValues(alpha: 0.28),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacingTokens.md,
          vertical: AppSpacingTokens.sm,
        ),
        child: Row(
          children: [
            Icon(Icons.search_rounded, color: surface.mute),
            const SizedBox(width: AppSpacingTokens.sm),
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: l10n.medicineSearchFieldHint,
                  hintStyle: typography.bodySm.copyWith(color: surface.mute),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                style: typography.bodySm,
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
                  Icons.cancel_rounded,
                  color: surface.mute,
                  size: 18,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
