import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/settings/domain/entities/user_settings.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// One engine option rendered inline above the composer.
///
/// Not a tile and not a menu item: the options sit in the composer's own
/// surface, so they read as part of the input area rather than as a floating
/// menu. The selected one is tinted; tapping a different one applies it.
class AssistantEngineOption extends StatelessWidget {
  const AssistantEngineOption({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelect,
  });

  final String label;
  final bool selected;
  final VoidCallback? onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onSelect,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.md,
            vertical: Spacing.sm,
          ),
          decoration: BoxDecoration(
            color: selected
                ? colors.primary.withValues(alpha: 0.12)
                : colors.secondary,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? colors.primary : colors.border,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.theme.typography.body.xs.copyWith(
              color: selected
                  ? colors.primary
                  : SemanticColor.neutral.solid(context),
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

/// Maps a mode to its caption, so the pill and the inline options cannot
/// disagree about naming.
String assistantEngineLabel(AppLocalizations l10n, AssistantAgentMode mode) {
  return switch (mode) {
    AssistantAgentMode.followOperator =>
      l10n.settingsAssistantBackendEngineDefault,
    AssistantAgentMode.graph => l10n.settingsAssistantBackendEngineGraph,
    AssistantAgentMode.deepAgents =>
      l10n.settingsAssistantBackendEngineDeepAgents,
  };
}
