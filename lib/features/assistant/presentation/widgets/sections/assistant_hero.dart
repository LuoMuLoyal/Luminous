import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/features/assistant/domain/entities/assistant_models.dart';
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
    final colors = context.theme.colors;
    final textTheme = theme.textTheme;
    final l10n = AppLocalizations.of(context)!;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.primary.withValues(alpha: 0.16), colors.background],
        ),
        borderRadius: BorderRadius.circular(AppRadiusTokens.xl),
        border: Border.all(color: colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacingTokens.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadiusTokens.md),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(AppSpacingTokens.sm),
                    child: Icon(FLucideIcons.bot, size: 20),
                  ),
                ),
                const SizedBox(width: AppSpacingTokens.sm),
                Expanded(
                  child: Text(
                    l10n.assistantPageTitle,
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacingTokens.sm),
            Text(
              statusSummary,
              style: textTheme.bodyMedium?.copyWith(
                color: colors.mutedForeground,
              ),
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
    final colors = context.theme.colors;
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: enabled
            ? colors.primary.withValues(alpha: 0.12)
            : colors.secondary,
        borderRadius: BorderRadius.circular(AppRadiusTokens.pill),
        border: Border.all(
          color: enabled
              ? colors.primary.withValues(alpha: 0.24)
              : colors.border,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacingTokens.md,
          vertical: AppSpacingTokens.xs,
        ),
        child: Text(
          label,
          style: textTheme.labelMedium?.copyWith(
            color: enabled ? colors.primary : colors.mutedForeground,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
