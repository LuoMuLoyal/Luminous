import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/assistant/presentation/widgets/sections/input_bar_starter_prompts.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Empty-state welcome content for a new assistant conversation.
class AssistantWelcomePanel extends StatefulWidget {
  const AssistantWelcomePanel({
    super.key,
    required this.onStarterPrompt,
    this.showDisclaimerExpanded = true,
    this.showMemoryHint = false,
  });

  final ValueChanged<String> onStarterPrompt;

  /// Initial expansion state of the health disclaimer at the panel bottom.
  final bool showDisclaimerExpanded;

  /// Whether the "cross-conversation memory is on" hint is shown above the
  /// disclaimer (driven by the user's memory setting).
  final bool showMemoryHint;

  @override
  State<AssistantWelcomePanel> createState() => _AssistantWelcomePanelState();
}

class _AssistantWelcomePanelState extends State<AssistantWelcomePanel> {
  late bool _disclaimerExpanded;

  @override
  void initState() {
    super.initState();
    _disclaimerExpanded = widget.showDisclaimerExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.theme.colors;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.level4,
        vertical: Spacing.level5,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: SemanticColor.primary.subtle(context),
                  borderRadius: BorderRadius.circular(RadiusTokens.levelFull),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(Spacing.level4),
                  child: Icon(
                    SemanticIcons.aiGenerated,
                    size: IconSizeTokens.level5,
                    color: SemanticColor.primary.solid(context),
                  ),
                ),
              ),
              const SizedBox(height: Spacing.level5),
              Text(
                l10n.assistantWelcomeTitle,
                textAlign: TextAlign.center,
                style: TypographyToken.level8
                    .display(context)
                    .copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: Spacing.level3),
              Text(
                l10n.assistantWelcomeDescription,
                textAlign: TextAlign.center,
                style: TypographyToken.level4
                    .body(context)
                    .copyWith(color: colors.mutedForeground),
              ),
              const SizedBox(height: Spacing.level6),
              Align(
                alignment: Alignment.centerLeft,
                child: AssistantInputStarterPrompts(
                  onSelected: widget.onStarterPrompt,
                ),
              ),
              if (widget.showMemoryHint) ...[
                const SizedBox(height: Spacing.level5),
                const _WelcomeMemoryHintSection(),
              ],
              const SizedBox(height: Spacing.level3),
              _WelcomeDisclaimerSection(
                expanded: _disclaimerExpanded,
                onToggle: () =>
                    setState(() => _disclaimerExpanded = !_disclaimerExpanded),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Static "cross-conversation memory is on" hint shown above the disclaimer
/// when the user enabled persisted memory. Styled like the disclaimer row:
/// a small info icon plus two muted text lines.
class _WelcomeMemoryHintSection extends StatelessWidget {
  const _WelcomeMemoryHintSection();

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.level2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            SemanticIcons.statusInfo,
            size: 14,
            color: colors.mutedForeground,
          ),
          const SizedBox(width: Spacing.level2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.assistantMemoryHintTitle,
                  style: TypographyToken.level2
                      .body(context)
                      .copyWith(
                        color: colors.mutedForeground,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: Spacing.level1),
                Text(
                  l10n.assistantMemoryHintDescription,
                  style: TypographyToken.level2
                      .body(context)
                      .copyWith(color: colors.mutedForeground),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Collapsible health disclaimer row at the bottom of the welcome panel.
///
/// Collapsed it shows a single muted line plus a chevron; expanded it shows
/// the full disclaimer text over multiple lines.
class _WelcomeDisclaimerSection extends StatelessWidget {
  const _WelcomeDisclaimerSection({
    required this.expanded,
    required this.onToggle,
  });

  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final l10n = AppLocalizations.of(context)!;

    return Semantics(
      button: true,
      label: expanded
          ? l10n.assistantDisclaimerCollapseAction
          : l10n.assistantDisclaimerShowAction,
      child: GestureDetector(
        key: const Key('assistant-welcome-disclaimer'),
        behavior: HitTestBehavior.opaque,
        onTap: onToggle,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: Spacing.level2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                SemanticIcons.statusInfo,
                size: 14,
                color: colors.mutedForeground,
              ),
              const SizedBox(width: Spacing.level2),
              Expanded(
                child: Text(
                  l10n.assistantDisclaimerText,
                  maxLines: expanded ? null : 1,
                  overflow: expanded ? null : TextOverflow.ellipsis,
                  style: TypographyToken.level2
                      .body(context)
                      .copyWith(color: colors.mutedForeground),
                ),
              ),
              const SizedBox(width: Spacing.level2),
              Icon(
                expanded
                    ? SemanticIcons.actionCollapse
                    : SemanticIcons.actionExpand,
                size: 14,
                color: colors.mutedForeground,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
