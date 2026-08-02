import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/assistant/presentation/widgets/sections/input_bar_starter_prompts.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Empty-state welcome content for a new assistant conversation.
class AssistantWelcomePanel extends StatelessWidget {
  const AssistantWelcomePanel({super.key, required this.onStarterPrompt});

  final ValueChanged<String> onStarterPrompt;

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
                  onSelected: onStarterPrompt,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
