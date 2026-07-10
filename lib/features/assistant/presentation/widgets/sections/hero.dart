import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/assistant/domain/entities/models.dart';
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
    final colors = context.theme.colors;

    final l10n = AppLocalizations.of(context)!;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [SemanticColor.primary.border(context), colors.background],
        ),
        borderRadius: BorderRadius.circular(RadiusTokens.level5),
        border: Border.all(color: colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.level5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: SemanticColor.primary.muted(context),
                    borderRadius: BorderRadius.circular(RadiusTokens.level3),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(Spacing.level3),
                    child: Icon(FLucideIcons.bot, size: 20),
                  ),
                ),
                const SizedBox(width: Spacing.level3),
                Expanded(
                  child: Text(
                    l10n.assistantPageTitle,
                    style: TypographyToken.level7
                        .display(context)
                        .copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.level3),
            Text(
              statusSummary,
              style: TypographyToken.level4
                  .body(context)
                  .copyWith(color: colors.mutedForeground),
            ),
            const SizedBox(height: Spacing.level4),
            Wrap(
              spacing: Spacing.level3,
              runSpacing: Spacing.level3,
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

    return DecoratedBox(
      decoration: BoxDecoration(
        color: enabled
            ? SemanticColor.primary.muted(context)
            : colors.secondary,
        borderRadius: BorderRadius.circular(RadiusTokens.levelFull),
        border: Border.all(
          color: enabled
              ? SemanticColor.primary.solid(context).withValues(alpha: 0.24)
              : colors.border,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.level4,
          vertical: Spacing.level2,
        ),
        child: Text(
          label,
          style: TypographyToken.level4
              .body(context)
              .copyWith(
                color: enabled ? colors.primary : colors.mutedForeground,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );
  }
}
