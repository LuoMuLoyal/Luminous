import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen_ai_chat_ui/flutter_gen_ai_chat_ui.dart';
import 'package:forui/forui.dart';
import 'package:intl/intl.dart' as intl;
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/widgets/common/dialog/dialog_shell.dart';
import 'package:luminous/features/assistant/domain/entities/models.dart';
import 'package:luminous/features/assistant/presentation/utils/message_id.dart';
import 'package:luminous/features/assistant/presentation/widgets/disclaimer_bar.dart';
import 'package:luminous/features/assistant/presentation/widgets/shared/proposal_card.dart';
import 'package:luminous/features/assistant/presentation/widgets/source_strip.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// The user and AI identities the assistant thread renders under.
const ChatUser chatCurrentUser = ChatUser(id: 'user');
const ChatUser chatAssistantUser = ChatUser(id: 'assistant');

/// The `customProperties` key carrying the originating [AssistantMessage] on a
/// gen_ai [ChatMessage], so the bubble builder can render the assistant-only
/// chrome (sources, disclaimer, proposals, actions) without re-deriving it.
const String _assistantMessageKey = 'assistantMessage';

/// The gen_ai list identities the adapter owns.
const String assistantStreamingMessageId = 'assistant:streaming';
const String assistantLoadingMessageId = 'assistant:loading';
const String assistantOpeningMessageId = 'assistant:opening';

/// Maps assistant domain messages into gen_ai view models and appends the
/// assistant-specific chrome (sources, disclaimer, proposals, actions) around
/// gen_ai's own markdown/streaming bubble.
///
/// The adapter owns no assistant state: the canonical message id stays the
/// value produced by [messageIdFor], while gen_ai receives a separate list
/// identity carrying the conversation id and position.
class AssistantChatAdapter {
  const AssistantChatAdapter({
    this.onConfirmProposal,
    this.onDismissProposal,
    this.onRegenerateProposal,
    this.onRegenerate,
    this.onResend,
    this.onOpenLink,
  });

  final Future<void> Function({
    required String messageId,
    required String proposalId,
  })?
  onConfirmProposal;
  final void Function({required String messageId, required String proposalId})?
  onDismissProposal;
  final void Function({required String messageId, required String proposalId})?
  onRegenerateProposal;
  final VoidCallback? onRegenerate;
  final void Function(String content)? onResend;
  final Future<bool> Function(Uri uri)? onOpenLink;

  /// Maps all persisted messages and, when requested, appends the draft turn.
  List<ChatMessage> mapMessages({
    required String conversationId,
    required List<AssistantMessage> messages,
    required String thinkingLabel,
    String streamingDraft = '',
    DateTime? streamingDraftCreatedAt,
    bool isSending = false,
    bool pending = false,
  }) {
    final mapped = <ChatMessage>[
      for (var index = 0; index < messages.length; index++)
        mapMessage(
          messages[index],
          conversationId: conversationId,
          index: index,
        ),
    ];
    if (streamingDraft.isNotEmpty) {
      mapped.add(
        mapStreamingDraft(streamingDraft, createdAt: streamingDraftCreatedAt),
      );
    } else if (isSending && pending) {
      mapped.add(mapLoading(thinkingLabel));
    }
    return mapped;
  }

  /// Maps one domain message to a stable gen_ai list item.
  ChatMessage mapMessage(
    AssistantMessage message, {
    required String conversationId,
    required int index,
  }) {
    final id = chatMessageId(
      message,
      conversationId: conversationId,
      index: index,
    );
    if (message.role == AssistantMessageRole.user) {
      return ChatMessage(
        text: message.content,
        user: chatCurrentUser,
        createdAt: message.createdAt,
        customProperties: {'id': id},
      );
    }
    return ChatMessage(
      text: message.content,
      user: chatAssistantUser,
      createdAt: message.createdAt,
      isMarkdown: true,
      customProperties: {'id': id, _assistantMessageKey: message},
    );
  }

  /// Returns the gen_ai identity without changing the domain message.
  String chatMessageId(
    AssistantMessage message, {
    required String conversationId,
    required int index,
  }) {
    return '$conversationId:$index:${messageIdFor(message)}';
  }

  /// Maps the current draft to a streaming assistant turn. The caller enrols
  /// [assistantStreamingMessageId] on the controller to drive the reveal.
  ///
  /// [createdAt] is stable for the lifetime of one stream: the renderer keys
  /// the reveal animation off the message id, but a `createdAt` that changed
  /// every chunk would make the streaming bubble's timestamp jump.
  ChatMessage mapStreamingDraft(String draft, {DateTime? createdAt}) {
    return ChatMessage(
      text: draft,
      user: chatAssistantUser,
      createdAt: createdAt ?? DateTime.now(),
      isMarkdown: true,
      customProperties: const {'id': assistantStreamingMessageId},
    );
  }

  /// Maps the "thinking" placeholder shown before the first chunk arrives.
  ChatMessage mapLoading(
    String label, {
    String id = assistantLoadingMessageId,
  }) {
    return ChatMessage.loading(user: chatAssistantUser, id: id, text: label);
  }

  /// `MessageOptions.bubbleBuilder`: keeps gen_ai's own bubble (markdown,
  /// streaming caret, styling) and appends the assistant chrome, or the resend
  /// action for a user turn.
  Widget buildBubble(
    BuildContext context,
    ChatMessage message,
    bool isUser,
    Widget defaultBubble,
  ) {
    if (isUser) {
      final actions = onResend == null
          ? null
          : _ActionRow(
              actions: [
                _ChatAction(
                  icon: SemanticIcons.actionRefresh,
                  tooltip: AppLocalizations.of(context)!.assistantResendAction,
                  onPressed: () => onResend!(message.text),
                ),
              ],
              timestamp: _formatTimestamp(context, message.createdAt),
            );
      if (actions == null) return defaultBubble;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [defaultBubble, actions],
      );
    }

    final domain = message.customProperties?[_assistantMessageKey];
    if (domain is! AssistantMessage) return defaultBubble;

    Widget body = defaultBubble;
    if (domain.replaced) {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ReplacedBadge(
            label: AppLocalizations.of(context)!.assistantReplacedLabel,
          ),
          const SizedBox(height: Spacing.sm),
          Opacity(
            key: const Key('assistant-replaced-muted'),
            opacity: 0.55,
            child: body,
          ),
        ],
      );
    }

    final trailer = _AssistantMessageChrome(
      message: domain,
      timestamp: _formatTimestamp(context, message.createdAt),
      onRegenerate: onRegenerate,
      onConfirmProposal: onConfirmProposal,
      onDismissProposal: onDismissProposal,
      onRegenerateProposal: onRegenerateProposal,
      onCopy: () => unawaited(_copy(context, domain.content)),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [body, trailer],
    );
  }

  Future<void> _copy(BuildContext context, String content) async {
    await Clipboard.setData(ClipboardData(text: content));
    if (context.mounted) {
      await Toast.show(
        context,
        AppLocalizations.of(context)!.assistantCopySuccess,
      );
    }
  }

  String _formatTimestamp(BuildContext context, DateTime dateTime) {
    final locale = Localizations.localeOf(context).toString();
    return intl.DateFormat.Hm(locale).format(dateTime.toLocal());
  }

  /// Confirms and opens an external link tapped in a markdown body.
  ///
  /// The dialog is opened from the navigator's context, above the assistant
  /// subtree's local framework theme.
  void handleLinkTap(BuildContext context, String? href) {
    final uri = Uri.tryParse(href ?? '');
    if (uri == null ||
        !uri.hasScheme ||
        !(uri.isScheme('http') || uri.isScheme('https')) ||
        onOpenLink == null) {
      return;
    }
    unawaited(_confirmAndOpen(Navigator.of(context).context, uri));
  }

  Future<void> _confirmAndOpen(BuildContext context, Uri uri) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showAppDialog<bool>(
      context: context,
      maxWidth: LayoutScaleResolver.dialogStandardMaxWidth,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.assistantMarkdownLinkConfirmTitle,
            style: context.theme.typography.body.lg,
          ),
          const SizedBox(height: Spacing.md),
          Text(
            l10n.assistantMarkdownLinkConfirmDescription,
            style: context.theme.typography.body.sm,
          ),
          const SizedBox(height: Spacing.xl),
          DialogActionRow(
            actions: [
              DialogActionButton(
                label: l10n.commonCancel,
                variant: FButtonVariant.ghost,
                onPress: () => Navigator.of(context).pop(false),
              ),
              DialogActionButton(
                label: l10n.assistantMarkdownLinkOpenAction,
                onPress: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await onOpenLink?.call(uri);
    }
  }
}

/// The assistant-only chrome under an AI bubble: source strip, disclaimer, the
/// proposals it carries, and the copy/regenerate action row + timestamp.
class _AssistantMessageChrome extends StatelessWidget {
  const _AssistantMessageChrome({
    required this.message,
    required this.timestamp,
    required this.onCopy,
    this.onRegenerate,
    this.onConfirmProposal,
    this.onDismissProposal,
    this.onRegenerateProposal,
  });

  final AssistantMessage message;
  final String timestamp;
  final VoidCallback onCopy;
  final VoidCallback? onRegenerate;
  final Future<void> Function({
    required String messageId,
    required String proposalId,
  })?
  onConfirmProposal;
  final void Function({required String messageId, required String proposalId})?
  onDismissProposal;
  final void Function({required String messageId, required String proposalId})?
  onRegenerateProposal;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final canonicalId = messageIdFor(message);
    final proposals = message.proposedActions
        .where((proposal) => proposal.isVisible)
        .toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (message.usedTools.isNotEmpty) ...[
          const SizedBox(height: Spacing.sm),
          AssistantSourceStrip(
            usedTools: message.usedTools,
            toolDetails: message.toolDetails,
          ),
        ],
        const SizedBox(height: Spacing.sm),
        AssistantDisclaimerBar(text: _disclaimerText(l10n, message)),
        for (final proposal in proposals) ...[
          const SizedBox(height: Spacing.md),
          AssistantProposalCard(
            messageId: canonicalId,
            proposal: proposal,
            onConfirmProposal: onConfirmProposal,
            onDismissProposal: onDismissProposal,
            onRegenerateProposal: onRegenerateProposal,
          ),
        ],
        _ActionRow(
          actions: [
            _ChatAction(
              icon: SemanticIcons.actionCopy,
              tooltip: l10n.assistantCopyAction,
              onPressed: onCopy,
            ),
            _ChatAction(
              icon: SemanticIcons.actionRefresh,
              tooltip: l10n.assistantRegenerateAction,
              onPressed: onRegenerate,
            ),
          ],
          timestamp: timestamp,
        ),
      ],
    );
  }

  String _disclaimerText(AppLocalizations l10n, AssistantMessage message) {
    for (final detail in message.toolDetails) {
      final disclaimer = detail.disclaimer;
      if (disclaimer != null && disclaimer.isNotEmpty) return disclaimer;
    }
    return l10n.assistantDisclaimerText;
  }
}

/// A single action in a [_ActionRow].
class _ChatAction {
  const _ChatAction({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
}

/// The copy/regenerate/resend row plus the turn timestamp, rendered under a
/// bubble. gen_ai's own action row is disabled (`showCopyButton: false`,
/// `showTime: false`) so this stays localized and matches the pre-migration
/// behavior.
class _ActionRow extends StatelessWidget {
  const _ActionRow({required this.actions, required this.timestamp});

  final List<_ChatAction> actions;
  final String timestamp;

  @override
  Widget build(BuildContext context) {
    final typography = context.theme.typography;
    // `Wrap` rather than `Row`: the icon buttons size to their intrinsic width,
    // so on a narrow bubble/large-font layout a `Row` would squeeze the
    // timestamp (or overflow). `Wrap` reflows the timestamp to a second line.
    return Padding(
      padding: const EdgeInsets.only(top: Spacing.xs),
      child: Wrap(
        spacing: Spacing.sm,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          for (final action in actions)
            FTooltip(
              tipBuilder: (context, controller) => Text(action.tooltip),
              child: FButton.icon(
                variant: FButtonVariant.ghost,
                onPress: action.onPressed,
                child: Icon(action.icon, size: 16),
              ),
            ),
          Text(
            timestamp,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: typography.body.xs2.copyWith(
              color: SemanticColor.neutral.solid(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReplacedBadge extends StatelessWidget {
  const _ReplacedBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.secondary,
        borderRadius: context.theme.style.borderRadius.xs,
        border: Border.all(color: SemanticColor.neutral.border(context)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.sm,
          vertical: 1,
        ),
        child: Text(
          label,
          key: const Key('assistant-replaced-label'),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.theme.typography.body.xs3.copyWith(
            color: SemanticColor.neutral.solid(context),
            height: 1.2,
          ),
        ),
      ),
    );
  }
}
