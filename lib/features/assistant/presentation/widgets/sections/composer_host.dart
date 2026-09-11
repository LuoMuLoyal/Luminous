import 'dart:async';

import 'package:flow_ui/flow_ui.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Direct assistant host for FlowUI's multiline composer.
///
/// The page owns the shared controller and the no-argument send callback;
/// FlowComposer continues to own text editing, multiline behavior, and the
/// send action.
class AssistantComposerHost extends StatelessWidget {
  const AssistantComposerHost({
    super.key,
    required this.controller,
    required this.isSending,
    required this.canSendMessages,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool isSending;
  final bool canSendMessages;
  final Future<void> Function() onSend;

  void _handleSend(String text) {
    final trimmedText = text.trim();
    if (trimmedText.isEmpty) return;

    controller.value = TextEditingValue(
      text: trimmedText,
      selection: TextSelection.collapsed(offset: trimmedText.length),
    );
    unawaited(onSend());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!canSendMessages)
          Padding(
            padding: const EdgeInsets.only(bottom: Spacing.md),
            child: Row(
              children: [
                Icon(
                  SemanticIcons.statusPaused,
                  size: 14,
                  color: SemanticColor.neutral.solid(context),
                ),
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: Text(
                    l10n.assistantInputDisabledHint,
                    style: context.theme.typography.body.xs.copyWith(
                      color: SemanticColor.neutral.solid(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
        Material(
          type: MaterialType.transparency,
          child: FlowComposer(
            key: const Key('assistant-input'),
            controller: controller,
            placeholder: l10n.assistantComposerPlaceholder,
            maxLines: 5,
            submitOnEnter: false,
            enabled: canSendMessages && !isSending,
            isStreaming: false,
            clearOnSend: true,
            onSend: _handleSend,
          ),
        ),
      ],
    );
  }
}
