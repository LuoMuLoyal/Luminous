import 'package:flutter/material.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/features/assistant/presentation/utils/assistant_ui_formatters.dart';

class AssistantToolChip extends StatelessWidget {
  const AssistantToolChip({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadiusTokens.pill),
        border: Border.all(color: surface.hairline),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacingTokens.sm,
          vertical: 2,
        ),
        child: Text(
          label,
          style:
              assistantTypography(context).bodySm.copyWith(color: surface.body),
        ),
      ),
    );
  }
}
