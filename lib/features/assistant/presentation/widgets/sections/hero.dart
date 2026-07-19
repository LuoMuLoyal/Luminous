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
    this.compact = false,
    this.onToggleCompact,
  });

  final AssistantCapabilities capabilities;
  final String statusSummary;

  /// When true, the hero collapses into a single-line status bar so the
  /// conversation surface below gets the vertical room. Users can still tap
  /// it (when [onToggleCompact] is provided) to expand it back to the full
  /// status summary.
  final bool compact;

  /// Optional callback invoked when the user taps the compact hero to expand
  /// it (or the full hero to collapse it). When null, the hero is not
  /// interactive — this matches the pre-compact behaviour for the very first
  /// render before any conversation has started.
  final VoidCallback? onToggleCompact;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return _CompactHero(
        capabilities: capabilities,
        statusSummary: statusSummary,
        onToggleCompact: onToggleCompact,
      );
    }
    return _FullHero(
      capabilities: capabilities,
      statusSummary: statusSummary,
      onToggleCompact: onToggleCompact,
    );
  }
}

class _FullHero extends StatelessWidget {
  const _FullHero({
    required this.capabilities,
    required this.statusSummary,
    required this.onToggleCompact,
  });

  final AssistantCapabilities capabilities;
  final String statusSummary;
  final VoidCallback? onToggleCompact;

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
                if (onToggleCompact != null)
                  Tooltip(
                    message: l10n.assistantHeroCollapseAction,
                    child: Semantics(
                      label: l10n.assistantHeroCollapseAction,
                      button: true,
                      child: FButton.icon(
                        variant: FButtonVariant.ghost,
                        onPress: onToggleCompact,
                        child: const Icon(FLucideIcons.chevronsUp, size: 16),
                      ),
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

class _CompactHero extends StatelessWidget {
  const _CompactHero({
    required this.capabilities,
    required this.statusSummary,
    required this.onToggleCompact,
  });

  final AssistantCapabilities capabilities;
  final String statusSummary;
  final VoidCallback? onToggleCompact;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final l10n = AppLocalizations.of(context)!;

    // The compact hero is a single line: bot badge + page title (small) +
    // status summary (muted, one line, ellipsized) + expand chevron.
    final card = DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [SemanticColor.primary.border(context), colors.background],
        ),
        borderRadius: BorderRadius.circular(RadiusTokens.level4),
        border: Border.all(color: colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.level4,
          vertical: Spacing.level3,
        ),
        child: Row(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: SemanticColor.primary.muted(context),
                borderRadius: BorderRadius.circular(RadiusTokens.level2),
              ),
              child: const Padding(
                padding: EdgeInsets.all(Spacing.level2),
                child: Icon(FLucideIcons.bot, size: 14),
              ),
            ),
            const SizedBox(width: Spacing.level3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.assistantPageTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TypographyToken.level5
                        .display(context)
                        .copyWith(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    statusSummary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TypographyToken.level3
                        .body(context)
                        .copyWith(color: colors.mutedForeground),
                  ),
                ],
              ),
            ),
            const SizedBox(width: Spacing.level3),
            // Inline status dots: green if ready, warning if not configured,
            // muted if disabled. Keeps the single-line affordance informative
            // without expanding back to the full chip layout.
            _CompactStatusDot(capabilities: capabilities),
            if (onToggleCompact != null) ...[
              const SizedBox(width: Spacing.level2),
              Tooltip(
                message: l10n.assistantHeroExpandAction,
                child: Semantics(
                  label: l10n.assistantHeroExpandAction,
                  button: true,
                  child: FButton.icon(
                    variant: FButtonVariant.ghost,
                    onPress: onToggleCompact,
                    child: const Icon(FLucideIcons.chevronsDown, size: 16),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );

    if (onToggleCompact == null) {
      return card;
    }
    // Wrap in a tappable surface so the whole bar is the hit target; the
    // explicit chevron button still receives its own press.
    return Semantics(
      label: l10n.assistantHeroExpandAction,
      button: true,
      child: FTappable(onPress: onToggleCompact, child: card),
    );
  }
}

class _CompactStatusDot extends StatelessWidget {
  const _CompactStatusDot({required this.capabilities});

  final AssistantCapabilities capabilities;

  @override
  Widget build(BuildContext context) {
    final Color color;
    if (!capabilities.assistantEnabled) {
      color = context.theme.colors.mutedForeground;
    } else if (!capabilities.chatModelConfigured ||
        !capabilities.interactiveChatReady) {
      color = SemanticColor.warning.solid(context);
    } else {
      color = SemanticColor.success.solid(context);
    }
    return Tooltip(
      message: _statusTooltip(AppLocalizations.of(context)!, capabilities),
      child: DecoratedBox(
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: const SizedBox(width: 8, height: 8),
      ),
    );
  }

  String _statusTooltip(
    AppLocalizations l10n,
    AssistantCapabilities capabilities,
  ) {
    if (!capabilities.assistantEnabled) return l10n.assistantStatusDisabled;
    if (!capabilities.chatModelConfigured)
      return l10n.assistantStatusModelMissing;
    if (!capabilities.interactiveChatReady) return l10n.assistantStatusNotReady;
    return l10n.assistantStatusReady;
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
