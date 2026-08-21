import 'dart:async';

import 'package:flow_ui/flow_ui.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Transitional host facade for the assistant composer.
///
/// The page still owns the shared controller and its existing no-argument
/// send callback. FlowComposer owns text editing, multiline behavior and the
/// send action; the facade only adapts FlowUI's trimmed payload to that
/// existing callback and renders the host disabled hint.
class AssistantInputBar extends StatelessWidget {
  const AssistantInputBar({
    super.key,
    required this.controller,
    required this.canSend,
    required this.isSending,
    required this.canSendMessages,
    required this.onSend,
  });

  final TextEditingController controller;

  /// Kept for the existing page-body call site during the 2b transition.
  /// FlowComposer derives its enabled state from [canSendMessages] and
  /// [isSending].
  final bool canSend;

  final bool isSending;
  final bool canSendMessages;
  final Future<void> Function() onSend;

  static const int _maxLines = 5;

  void _handleSend(String text) {
    final trimmedText = text.trim();
    if (trimmedText.isEmpty) return;

    // The existing page callback reads this shared controller rather than
    // accepting a text argument. Keep that contract while passing along
    // FlowComposer's trimmed payload.
    controller.value = TextEditingValue(
      text: trimmedText,
      selection: TextSelection.collapsed(offset: trimmedText.length),
    );
    unawaited(onSend());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.theme.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!canSendMessages) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: Spacing.level3),
            child: Row(
              children: [
                Icon(
                  SemanticIcons.statusPaused,
                  size: 14,
                  color: colors.mutedForeground,
                ),
                const SizedBox(width: Spacing.level2),
                Expanded(
                  child: Text(
                    l10n.assistantInputDisabledHint,
                    style: TypographyToken.level3
                        .body(context)
                        .copyWith(color: colors.mutedForeground),
                  ),
                ),
              ],
            ),
          ),
        ],
        Material(
          type: MaterialType.transparency,
          child: FlowComposer(
            key: const Key('assistant-input'),
            controller: controller,
            placeholder: l10n.assistantInputHint,
            maxLines: _maxLines,
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
