import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/errors/user_message.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/features/assistant/presentation/widgets/shared/engine_option.dart';
import 'package:luminous/features/settings/domain/entities/user_settings.dart';
import 'package:luminous/features/settings/presentation/providers/user_settings.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// The engine capsule in the composer's bottom row.
///
/// ## Why a capsule here at all
///
/// Choosing the engine is a decision made *while* asking a question, not while
/// configuring the app. Two screens deep in settings, the user picks an engine
/// before knowing what they will ask. This is the shape the assistant apps
/// ship: a capsule in the composer that expands the options in place.
///
/// ## Expansion is inline, not a sheet
///
/// The options render **above** the input, inside the composer's own surface,
/// and the capsule sits below it. A modal sheet would cover the text the user
/// is writing and add a dismissal step for a one-tap decision.
///
/// ## What it reads
///
/// The server's stored value, verbatim. When that is
/// [AssistantAgentMode.followOperator] the capsule says "server default"
/// instead of guessing which engine the operator configured — the client never
/// knows, and showing a guess would make the setting look changed the moment
/// the operator flipped the server default.
class AssistantEnginePill extends ConsumerWidget {
  const AssistantEnginePill({
    super.key,
    required this.expanded,
    required this.onToggle,
  });

  /// Whether the options are showing above the composer.
  final bool expanded;

  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(userSettingsControllerProvider).value;
    final mode =
        settings?.assistantAgentMode ?? AssistantAgentMode.followOperator;
    final label = assistantEngineLabel(l10n, mode);

    return Semantics(
      button: true,
      expanded: expanded,
      label: l10n.assistantEnginePillSemantics(label),
      child: GestureDetector(
        key: const Key('assistant-engine-pill'),
        behavior: HitTestBehavior.opaque,
        onTap: settings == null ? null : onToggle,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.md,
            vertical: Spacing.xs,
          ),
          decoration: BoxDecoration(
            color: context.theme.colors.secondary,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: context.theme.colors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                // Deliberately not a chevron: the disclaimer bar already uses
                // `actionExpand` for its own disclosure, and two identical
                // chevrons on one screen read as the same control twice.
                SemanticIcons.aiEntry,
                size: 12,
                color: expanded
                    ? context.theme.colors.primary
                    : SemanticColor.neutral.solid(context),
              ),
              const SizedBox(width: Spacing.xs),
              // `maxLines: 1` + ellipsis rather than letting the label set the
              // row's width: the capsule shares this row with the send control,
              // and a long caption must not squeeze it.
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 140),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.theme.typography.body.xs.copyWith(
                    color: SemanticColor.neutral.solid(context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The options, rendered above the input while [AssistantEnginePill] is
/// expanded.
///
/// Kept a separate widget from the pill because the two live in different
/// slots of the composer (`attachmentPreviewBuilder` above the field,
/// `inputToolbarBuilder` below it); the expanded flag is owned by the surface
/// so both stay in step.
class AssistantEngineOptions extends ConsumerWidget {
  const AssistantEngineOptions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(userSettingsControllerProvider).value;
    final selected =
        settings?.assistantAgentMode ?? AssistantAgentMode.followOperator;

    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.sm),
      child: Wrap(
        spacing: Spacing.sm,
        runSpacing: Spacing.sm,
        children: [
          for (final mode in AssistantAgentMode.values)
            AssistantEngineOption(
              label: assistantEngineLabel(l10n, mode),
              selected: selected == mode,
              onSelect: selected == mode
                  ? null
                  : () => unawaited(_apply(context, ref, mode)),
            ),
        ],
      ),
    );
  }

  /// Applies the choice. A failure surfaces a toast and leaves the composer
  /// untouched — the previous engine stays selected, which is the honest state.
  Future<void> _apply(
    BuildContext context,
    WidgetRef ref,
    AssistantAgentMode mode,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await ref
          .read(userSettingsControllerProvider.notifier)
          .setAssistantAgentMode(mode);
    } catch (error) {
      if (!context.mounted) return;
      await showEngineApplyFailed(context, l10n, error);
    }
  }
}

/// Separated so the `catch` in [AssistantEngineOptions] stays one statement and
/// the toast construction reads as a distinct concern.
Future<void> showEngineApplyFailed(
  BuildContext context,
  AppLocalizations l10n,
  Object error,
) async {
  await Toast.show(
    context,
    userMessageFromError(error, fallback: l10n.settingsSyncFailed, l10n: l10n),
  );
}
