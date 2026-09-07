import 'package:flow_ui/flow_ui.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Assistant-specific support rendered inside FlowChatScreen's empty state.
///
/// FlowChatScreen owns the greeting and composer layout. This host retains the
/// existing assistant description, starter prompts, memory hint, and
/// collapsible health disclaimer without introducing new localization.
class AssistantEmptySupport extends StatefulWidget {
  const AssistantEmptySupport({
    super.key,
    required this.onStarterPrompt,
    this.showMemoryHint = false,
    this.showDisclaimerExpanded = true,
  });

  final ValueChanged<String> onStarterPrompt;
  final bool showMemoryHint;
  final bool showDisclaimerExpanded;

  @override
  State<AssistantEmptySupport> createState() => _AssistantEmptySupportState();
}

class _AssistantEmptySupportState extends State<AssistantEmptySupport> {
  late bool _disclaimerExpanded;

  @override
  void initState() {
    super.initState();
    _disclaimerExpanded = widget.showDisclaimerExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final prompts = <String>[
      l10n.assistantStarterPromptTodaySummary,
      l10n.assistantStarterPromptSleep,
      l10n.assistantStarterPromptMedicines,
      l10n.assistantStarterPromptWhatToWatch,
    ];
    final typography = context.theme.typography;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.assistantWelcomeDescription,
          textAlign: TextAlign.center,
          style: typography.body.sm.copyWith(
            color: SemanticColor.neutral.solid(context),
          ),
        ),
        const SizedBox(height: Spacing.level6),
        Align(
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.assistantStarterPromptTitle,
                style: typography.body.xs.copyWith(
                  color: SemanticColor.neutral.solid(context),
                ),
              ),
              const SizedBox(height: Spacing.level2),
              FlowSuggestionGroup(
                layout: FlowSuggestionLayout.column,
                suggestions: [
                  for (final prompt in prompts)
                    FlowSuggestion(
                      label: prompt,
                      onTap: () => widget.onStarterPrompt(prompt),
                    ),
                ],
              ),
            ],
          ),
        ),
        if (widget.showMemoryHint) ...[
          const SizedBox(height: Spacing.level5),
          const AssistantMemoryHint(),
        ],
        const SizedBox(height: Spacing.level3),
        AssistantDisclaimer(
          expanded: _disclaimerExpanded,
          onToggle: () =>
              setState(() => _disclaimerExpanded = !_disclaimerExpanded),
        ),
      ],
    );
  }
}

/// Memory hint section for the assistant.
class AssistantMemoryHint extends StatelessWidget {
  const AssistantMemoryHint({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final typography = context.theme.typography;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.level2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            SemanticIcons.statusInfo,
            size: 14,
            color: SemanticColor.neutral.solid(context),
          ),
          const SizedBox(width: Spacing.level2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.assistantMemoryHintTitle,
                  style: typography.body.xs2.copyWith(
                    color: SemanticColor.neutral.solid(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: Spacing.level1),
                Text(
                  l10n.assistantMemoryHintDescription,
                  style: typography.body.xs2.copyWith(
                    color: SemanticColor.neutral.solid(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Collapsible disclaimer section for the assistant.
class AssistantDisclaimer extends StatelessWidget {
  const AssistantDisclaimer({
    super.key,
    required this.expanded,
    required this.onToggle,
  });

  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
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
                color: SemanticColor.neutral.solid(context),
              ),
              const SizedBox(width: Spacing.level2),
              Expanded(
                child: Text(
                  l10n.assistantDisclaimerText,
                  maxLines: expanded ? null : 1,
                  overflow: expanded ? null : TextOverflow.ellipsis,
                  style: context.theme.typography.body.xs2.copyWith(
                    color: SemanticColor.neutral.solid(context),
                  ),
                ),
              ),
              const SizedBox(width: Spacing.level2),
              Icon(
                expanded
                    ? SemanticIcons.actionCollapse
                    : SemanticIcons.actionExpand,
                size: 14,
                color: SemanticColor.neutral.solid(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
