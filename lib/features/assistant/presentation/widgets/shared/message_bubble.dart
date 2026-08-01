import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:forui/forui.dart';
import 'package:intl/intl.dart' as intl;
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/features/assistant/domain/entities/models.dart';
import 'package:luminous/features/assistant/presentation/widgets/shared/proposal_card.dart';
import 'package:luminous/l10n/app_localizations.dart';

class AssistantMessageBubble extends StatelessWidget {
  const AssistantMessageBubble({
    super.key,
    required this.messageId,
    required this.role,
    required this.content,
    required this.usedTools,
    this.proposedActions = const <AssistantProposedAction>[],
    this.isStreaming = false,
    this.createdAt,
    this.onConfirmProposal,
    this.onDismissProposal,
  });

  final String messageId;
  final AssistantMessageRole role;
  final String content;
  final List<String> usedTools;
  final List<AssistantProposedAction> proposedActions;
  final bool isStreaming;
  final DateTime? createdAt;
  final Future<void> Function({
    required String messageId,
    required String proposalId,
  })?
  onConfirmProposal;
  final void Function({required String messageId, required String proposalId})?
  onDismissProposal;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final l10n = AppLocalizations.of(context)!;

    final isUser = role == AssistantMessageRole.user;
    final align = isUser ? Alignment.centerRight : Alignment.centerLeft;
    final background = isUser
        ? SemanticColor.primary.muted(context)
        : colors.secondary;
    final foreground = isUser ? colors.primaryForeground : colors.foreground;

    return Align(
      alignment: align,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: Breakpoints.assistantContent,
        ),
        child: FContextMenu.tiles(
          menu: _buildContextMenu(context, l10n),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(RadiusTokens.level4),
              border: Border.all(color: colors.border),
            ),
            child: Padding(
              padding: const EdgeInsets.all(Spacing.level4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isUser)
                    SelectableText(
                      content,
                      style: TypographyToken.level4
                          .body(context)
                          .copyWith(color: foreground),
                    )
                  else if (isStreaming)
                    Text(
                      content,
                      style: TypographyToken.level4
                          .body(context)
                          .copyWith(color: foreground),
                    )
                  else
                    MarkdownBody(
                      data: content,
                      selectable: true,
                      styleSheet:
                          MarkdownStyleSheet.fromTheme(
                            Theme.of(context),
                          ).copyWith(
                            p: TypographyToken.level4
                                .body(context)
                                .copyWith(color: foreground),
                            blockquote: TypographyToken.level3
                                .body(context)
                                .copyWith(color: colors.mutedForeground),
                          ),
                    ),
                  if (isStreaming) ...[
                    const SizedBox(height: Spacing.level3),
                    _AnimatedDots(color: colors.primary),
                  ],
                  if (!isStreaming &&
                      !isUser &&
                      proposedActions.any(
                        (proposal) => proposal.isVisible,
                      )) ...[
                    const SizedBox(height: Spacing.level4),
                    for (final proposal in proposedActions.where(
                      (proposal) => proposal.isVisible,
                    ))
                      Padding(
                        padding: const EdgeInsets.only(bottom: Spacing.level3),
                        child: AssistantProposalCard(
                          messageId: messageId,
                          proposal: proposal,
                          onConfirmProposal: onConfirmProposal,
                          onDismissProposal: onDismissProposal,
                        ),
                      ),
                  ],
                  if (!isStreaming && createdAt != null) ...[
                    const SizedBox(height: Spacing.level2),
                    Text(
                      _formatTimestamp(context, createdAt!),
                      style: TypographyToken.level2
                          .body(context)
                          .copyWith(color: colors.mutedForeground),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(BuildContext context, DateTime dateTime) {
    final locale = Localizations.localeOf(context).toString();
    final local = dateTime.toLocal();
    return intl.DateFormat.Hm(locale).format(local);
  }

  List<FTileGroup> _buildContextMenu(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    final isUser = role == AssistantMessageRole.user;
    return [
      FTileGroup(
        children: [
          FTile(
            title: Text(l10n.assistantCopyAction),
            onPress: () async {
              await Clipboard.setData(ClipboardData(text: content));
              if (context.mounted) {
                await Toast.show(context, l10n.assistantCopySuccess);
              }
            },
          ),
          // TODO: wire regenerate / resend once the controller supports it.
          if (!isUser && !isStreaming)
            FTile(title: Text(l10n.assistantRegenerateAction), onPress: null),
          if (isUser && !isStreaming)
            FTile(title: Text(l10n.assistantResendAction), onPress: null),
        ],
      ),
    ];
  }
}

/// Three pulsing dots used as a compact "typing" indicator for streaming
/// messages. Replaces the previous static text-only label.
class _AnimatedDots extends StatelessWidget {
  const _AnimatedDots({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return Padding(
          padding: EdgeInsets.only(right: index < 2 ? 3.0 : 0),
          child:
              DecoratedBox(
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                    child: const SizedBox(width: 6, height: 6),
                  )
                  .animate(onPlay: (controller) => controller.repeat())
                  .scale(
                    duration: 600.ms,
                    delay: (index * 200).ms,
                    begin: Offset.zero,
                    end: const Offset(1, 1),
                  )
                  .then()
                  .scale(
                    duration: 600.ms,
                    begin: const Offset(1, 1),
                    end: Offset.zero,
                  ),
        );
      }),
    );
  }
}
