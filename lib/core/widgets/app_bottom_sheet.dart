import 'package:flutter/material.dart';
import "package:luminous/core/design/app_design.dart";
import "package:luminous/core/theme/app_theme_extensions.dart";

/// Wraps content in a themed bottom sheet with handle bar and safe area.
class AppBottomSheet extends StatelessWidget {
  const AppBottomSheet({
    super.key,
    required this.title,
    required this.children,
    this.showHandle = true,
  });

  final String title;
  final List<Widget> children;
  final bool showHandle;

  /// Show this bottom sheet from any context.
  static Future<void> show(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return showModalBottomSheet(
      context: context,
      builder: (_) => AppBottomSheet(title: title, children: children),
    );
  }

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).extension<AppThemeSurface>()!;
    final typography = AppTypographyTokens.mobile(
      Theme.of(context).colorScheme.onSurface,
    );

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacingTokens.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showHandle)
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: surface.mute,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              if (showHandle)
                const SizedBox(height: AppSpacingTokens.lg),
              Text(title, style: typography.displaySm),
              const SizedBox(height: AppSpacingTokens.md),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

/// A selectable row inside a bottom sheet.
class AppBottomSheetOption extends StatelessWidget {
  const AppBottomSheetOption({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).extension<AppThemeSurface>()!;
    final typography = AppTypographyTokens.mobile(
      Theme.of(context).colorScheme.onSurface,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacingTokens.sm),
      child: Material(
        color: isSelected ? surface.canvasSoft2 : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacingTokens.md),
            child: Row(
              children: [
                Icon(icon, size: 22, color: surface.body),
                const SizedBox(width: AppSpacingTokens.md),
                Expanded(
                  child: Text(label, style: typography.bodyMd.copyWith(fontWeight: FontWeight.w500)),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle_rounded,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
