import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';

/// One-line health disclaimer shown under assistant messages.
///
/// Mirrors the source strip's visual language (muted, small text) so the
/// safety boundary reads as part of the message meta row rather than as
/// message content. Renders nothing when [text] is empty.
class AssistantDisclaimerBar extends StatelessWidget {
  const AssistantDisclaimerBar({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) {
      return const SizedBox.shrink();
    }

    final colors = context.theme.colors;

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
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.theme.typography.body.xs2.copyWith(
                color: colors.mutedForeground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
