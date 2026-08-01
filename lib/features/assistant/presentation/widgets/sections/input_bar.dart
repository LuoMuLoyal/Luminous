import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/assistant/presentation/widgets/sections/input_bar_shortcut_hint.dart';
import 'package:luminous/features/assistant/presentation/widgets/sections/input_bar_starter_prompts.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Chat-style input bar for the assistant page.
///
/// - Single-line height by default, expanding to [maxLines] as the user types.
/// - Circular send icon button instead of a full text button.
/// - Optional starter prompt chips shown above the field when the conversation
///   is empty.
/// - Desktop shortcut hint (Ctrl/⌘ + Enter) appears only while the field is
///   focused and fades after a short delay.
class AssistantInputBar extends StatefulWidget {
  const AssistantInputBar({
    super.key,
    required this.controller,
    required this.canSend,
    required this.isSending,
    required this.canSendMessages,
    this.showStarterPrompts = false,
    required this.onSend,
    this.onStarterPrompt,
  });

  final TextEditingController controller;
  final bool canSend;
  final bool isSending;
  final bool canSendMessages;
  final bool showStarterPrompts;
  final Future<void> Function() onSend;
  final void Function(String prompt)? onStarterPrompt;

  @override
  State<AssistantInputBar> createState() => _AssistantInputBarState();
}

class _AssistantInputBarState extends State<AssistantInputBar> {
  final FocusNode _focusNode = FocusNode();
  bool _showShortcutHint = false;

  static const int _maxLines = 5;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (!mounted) return;
    setState(() {
      _showShortcutHint = _focusNode.hasFocus && _isDesktop(context);
    });
  }

  bool _isDesktop(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= Breakpoints.tablet;
  }

  void _hideShortcutHint() {
    if (!mounted || !_showShortcutHint) return;
    setState(() => _showShortcutHint = false);
  }

  Future<void> _handleSend() async {
    if (!widget.canSend) return;
    await widget.onSend();
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey != LogicalKeyboardKey.enter) {
      return KeyEventResult.ignored;
    }
    final withModifier =
        HardwareKeyboard.instance.isControlPressed ||
        HardwareKeyboard.instance.isMetaPressed;
    if (!withModifier) return KeyEventResult.ignored;
    if (widget.canSend) {
      unawaited(_handleSend());
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.theme.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!widget.canSendMessages) ...[
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
        if (widget.showStarterPrompts && widget.canSendMessages) ...[
          AssistantInputStarterPrompts(onSelected: widget.onStarterPrompt),
          const SizedBox(height: Spacing.level3),
        ],
        Focus(
          focusNode: _focusNode,
          onKeyEvent: _handleKeyEvent,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.background,
              borderRadius: BorderRadius.circular(RadiusTokens.level4),
              border: Border.all(color: colors.border),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.level4,
                      vertical: Spacing.level3,
                    ),
                    child: FTextField(
                      key: const Key('assistant-input'),
                      control: FTextFieldControl.managed(
                        controller: widget.controller,
                      ),
                      minLines: 1,
                      maxLines: _maxLines,
                      hint: l10n.assistantInputHint,
                      enabled: widget.canSendMessages,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    right: Spacing.level3,
                    bottom: Spacing.level3,
                  ),
                  child: FButton.icon(
                    key: const Key('assistant-send-action'),
                    variant: FButtonVariant.primary,
                    onPress: widget.canSend ? _handleSend : null,
                    child: widget.isSending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: FCircularProgress(),
                          )
                        : const Icon(SemanticIcons.actionSend, size: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_showShortcutHint) ...[
          const SizedBox(height: Spacing.level2),
          Padding(
            padding: const EdgeInsets.only(left: Spacing.level1),
            child: Text(
              l10n.assistantSendShortcutHint,
              style: TypographyToken.level2
                  .body(context)
                  .copyWith(color: colors.mutedForeground),
            ),
          ),
          // Fade the hint after a short delay so it does not linger forever.
          AssistantShortcutHintAutoHide(onHide: _hideShortcutHint),
        ],
      ],
    );
  }
}
