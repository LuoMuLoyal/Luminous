import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// One-line health disclaimer shown under assistant messages.
///
/// Mirrors the source strip's visual language (muted, small text) so the
/// safety boundary reads as part of the message meta row rather than as
/// message content. Renders nothing when [text] is empty.
///
/// Collapsed it stays one line, but tapping expands the full text: this is the
/// medical disclaimer rendered under *every* assistant message, so a permanent
/// ellipsis truncated compliance-critical copy with no way to read the rest.
/// Reuses the welcome state's wording and interaction instead of introducing
/// parallel strings.
class AssistantDisclaimerBar extends StatefulWidget {
  const AssistantDisclaimerBar({super.key, required this.text});

  final String text;

  @override
  State<AssistantDisclaimerBar> createState() => _AssistantDisclaimerBarState();
}

class _AssistantDisclaimerBarState extends State<AssistantDisclaimerBar> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.text.isEmpty) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context)!;
    return Semantics(
      button: true,
      label: _expanded
          ? l10n.assistantDisclaimerCollapseAction
          : l10n.assistantDisclaimerShowAction,
      child: GestureDetector(
        key: const Key('assistant-message-disclaimer'),
        behavior: HitTestBehavior.opaque,
        onTap: () {
          setState(() {
            _expanded = !_expanded;
          });
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                SemanticIcons.statusInfo,
                size: 14,
                color: SemanticColor.neutral.solid(context),
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: Text(
                  widget.text,
                  maxLines: _expanded ? null : 1,
                  overflow: _expanded ? null : TextOverflow.ellipsis,
                  style: context.theme.typography.body.xs2.copyWith(
                    color: SemanticColor.neutral.solid(context),
                  ),
                ),
              ),
              const SizedBox(width: Spacing.sm),
              Icon(
                _expanded
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
