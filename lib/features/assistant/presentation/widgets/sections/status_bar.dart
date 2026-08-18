// Experimental/legacy — not part of the shipping assistant path.
// Kept for reference only; no entry points wire this component.
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/assistant/domain/entities/models.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Collapsible single-line status bar for the assistant page.
///
/// Replaces the previous full-width hero card that exposed technical tags
/// (tool count, context count, RAG, streaming). The collapsed bar only shows
/// a bot icon, the page title, a one-line status summary, and a colored dot
/// that indicates readiness. Tapping it expands a small panel with the full
/// status sentence and a link to context settings.
class AssistantStatusBar extends StatelessWidget {
  const AssistantStatusBar({
    super.key,
    required this.capabilities,
    this.onOpenSettings,
  });

  final AssistantCapabilities capabilities;
  final VoidCallback? onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return _CollapsedBar(
      capabilities: capabilities,
      onOpenSettings: onOpenSettings,
    );
  }
}

class _CollapsedBar extends StatelessWidget {
  const _CollapsedBar({required this.capabilities, this.onOpenSettings});

  final AssistantCapabilities capabilities;
  final VoidCallback? onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final l10n = AppLocalizations.of(context)!;
    final status = _statusSummary(l10n, capabilities);
    final statusColor = _statusColor(context, capabilities);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: SemanticColor.primary.subtle(context),
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
                child: Icon(
                  SemanticIcons.aiGenerated,
                  size: IconSizeTokens.level2,
                ),
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
                    status,
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
            if (onOpenSettings != null) ...[
              FTooltip(
                tipBuilder: (context, controller) =>
                    Text(l10n.assistantControlsDrawerTitle),
                child: FButton.icon(
                  key: const Key('assistant-status-settings-action'),
                  variant: FButtonVariant.ghost,
                  onPress: onOpenSettings,
                  child: const Icon(SemanticIcons.actionSettings, size: 18),
                ),
              ),
              const SizedBox(width: Spacing.level2),
            ],
            Tooltip(
              message: status,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
                child: const SizedBox(
                  width: Spacing.level2,
                  height: Spacing.level2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _statusSummary(AppLocalizations l10n, AssistantCapabilities caps) {
    if (!caps.assistantEnabled) return l10n.assistantStatusDisabled;
    if (!caps.chatModelConfigured) return l10n.assistantStatusModelMissing;
    if (!caps.interactiveChatReady) return l10n.assistantStatusNotReady;
    return l10n.assistantStatusReady;
  }

  Color _statusColor(BuildContext context, AssistantCapabilities caps) {
    if (!caps.assistantEnabled) {
      return context.theme.colors.mutedForeground;
    }
    if (!caps.chatModelConfigured || !caps.interactiveChatReady) {
      return SemanticColor.warning.solid(context);
    }
    return SemanticColor.success.solid(context);
  }
}
