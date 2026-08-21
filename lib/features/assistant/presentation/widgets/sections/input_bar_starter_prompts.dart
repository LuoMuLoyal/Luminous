import 'package:flow_ui/flow_ui.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// A set of starter prompt chips shown above the assistant input field when the
/// conversation is empty. Prompts are localised via ARB fragments.
class AssistantInputStarterPrompts extends StatelessWidget {
  const AssistantInputStarterPrompts({super.key, this.onSelected});

  final void Function(String prompt)? onSelected;

  List<String> _prompts(AppLocalizations l10n) => <String>[
    l10n.assistantStarterPromptTodaySummary,
    l10n.assistantStarterPromptSleep,
    l10n.assistantStarterPromptMedicines,
    l10n.assistantStarterPromptWhatToWatch,
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final l10n = AppLocalizations.of(context)!;
    final callback = onSelected;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.assistantStarterPromptTitle,
          style: TypographyToken.level3
              .body(context)
              .copyWith(color: colors.mutedForeground),
        ),
        const SizedBox(height: Spacing.level2),
        FlowSuggestionGroup(
          layout: FlowSuggestionLayout.column,
          suggestions: [
            for (final prompt in _prompts(l10n))
              FlowSuggestion(
                label: prompt,
                onTap: callback == null ? null : () => callback(prompt),
              ),
          ],
        ),
      ],
    );
  }
}
