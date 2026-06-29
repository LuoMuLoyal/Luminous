import 'package:flutter/material.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/features/assistant/domain/entities/assistant_models.dart';
import 'package:luminous/features/assistant/presentation/utils/assistant_ui_formatters.dart';
import 'package:luminous/l10n/app_localizations.dart';

class AssistantHero extends StatelessWidget {
  const AssistantHero({
    super.key,
    required this.capabilities,
    required this.statusSummary,
  });

  final AssistantCapabilities capabilities;
  final String statusSummary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final l10n = AppLocalizations.of(context)!;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.12),
            surface.canvas,
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadiusTokens.xl),
        border: Border.all(color: surface.hairline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacingTokens.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.assistantPageTitle,
              style: assistantTypography(context).displayMd,
            ),
            const SizedBox(height: AppSpacingTokens.xs),
            Text(
              statusSummary,
              style: assistantTypography(
                context,
              ).bodyMd.copyWith(color: surface.body),
            ),
            const SizedBox(height: AppSpacingTokens.md),
            Wrap(
              spacing: AppSpacingTokens.sm,
              runSpacing: AppSpacingTokens.sm,
              children: [
                _StatusChip(
                  label:
                      '${l10n.assistantStatusToolsLabel} ${capabilities.enabledToolCount}/${capabilities.tools.length}',
                  enabled: capabilities.enabledToolCount > 0,
                ),
                _StatusChip(
                  label:
                      '${l10n.assistantStatusContextLabel} ${capabilities.assistantContext.enabledCount}/4',
                  enabled: capabilities.assistantContext.enabledCount > 0,
                ),
                _StatusChip(
                  label: l10n.assistantStatusStreamingLabel,
                  enabled: capabilities.streamingSupported,
                ),
                _StatusChip(
                  label: l10n.assistantStatusRagLabel,
                  enabled: capabilities.ragEnabled,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.enabled});

  final String label;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: enabled
            ? theme.colorScheme.primary.withValues(alpha: 0.12)
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadiusTokens.pill),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacingTokens.md,
          vertical: AppSpacingTokens.xs,
        ),
        child: Text(label, style: assistantTypography(context).bodySm),
      ),
    );
  }
}
