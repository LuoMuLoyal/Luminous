import 'dart:async';

import 'package:flow_ui/flow_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:forui/forui.dart';
import 'package:intl/intl.dart' as intl;
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/widgets/common/dialog_shell.dart';
import 'package:luminous/features/assistant/domain/entities/models.dart';
import 'package:luminous/features/assistant/presentation/utils/message_id.dart';
import 'package:luminous/features/assistant/presentation/widgets/disclaimer_bar.dart';
import 'package:luminous/features/assistant/presentation/widgets/shared/proposal_card.dart';
import 'package:luminous/features/assistant/presentation/widgets/source_strip.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// The completed assistant content rendered through FlowUI's custom-part seam.
@immutable
class AssistantMarkdownPart {
  const AssistantMarkdownPart({
    required this.content,
    this.usedTools = const <String>[],
    this.toolDetails = const <AssistantToolDetail>[],
    this.replaced = false,
  });

  final String content;
  final List<String> usedTools;
  final List<AssistantToolDetail> toolDetails;
  final bool replaced;
}

/// A visible proposal and the canonical id used by [AssistantController].
@immutable
class AssistantProposalPart {
  const AssistantProposalPart({
    required this.messageId,
    required this.proposal,
  });

  final String messageId;
  final AssistantProposedAction proposal;
}

/// Maps assistant domain messages into FlowUI view models and renders the
/// assistant-specific custom parts and footer.
///
/// The adapter intentionally owns no assistant state. In particular, the
/// canonical message id remains the same value produced by [messageIdFor],
/// while FlowUI receives a separate list identity containing the conversation
/// id and position.
class AssistantFlowUiAdapter {
  const AssistantFlowUiAdapter({
    this.onConfirmProposal,
    this.onDismissProposal,
    this.onRegenerateProposal,
    this.onRegenerate,
    this.onResend,
    this.onOpenLink,
    this.thinkingLabel,
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
  final String? thinkingLabel;

  /// Maps all persisted messages and, when requested, appends the draft turn.
  List<FlowMessageData> mapMessages({
    required String conversationId,
    required List<AssistantMessage> messages,
    String streamingDraft = '',
    bool isSending = false,
    bool pending = false,
  }) {
    final mapped = <FlowMessageData>[
      for (var index = 0; index < messages.length; index++)
        mapMessage(
          messages[index],
          conversationId: conversationId,
          index: index,
        ),
    ];
    if (streamingDraft.isNotEmpty || (isSending && pending)) {
      mapped.add(mapStreamingDraft(streamingDraft));
    }
    return mapped;
  }

  /// Maps one domain message to a stable FlowUI list item identity.
  FlowMessageData mapMessage(
    AssistantMessage message, {
    required String conversationId,
    required int index,
  }) {
    final canonicalMessageId = messageIdFor(message);
    final parts = <FlowMessagePart>[];
    if (message.role == AssistantMessageRole.assistant) {
      parts.add(
        FlowCustomPart(
          type: 'markdown',
          data: AssistantMarkdownPart(
            content: message.content,
            usedTools: message.usedTools,
            toolDetails: message.toolDetails,
            replaced: message.replaced,
          ),
        ),
      );
      parts.addAll(
        message.proposedActions
            .where((proposal) => proposal.isVisible)
            .map(
              (proposal) => FlowCustomPart(
                type: 'proposal',
                data: AssistantProposalPart(
                  messageId: canonicalMessageId,
                  proposal: proposal,
                ),
              ),
            ),
      );
    } else {
      parts.add(FlowTextPart(message.content));
    }

    return FlowMessageData(
      id: flowMessageId(message, conversationId: conversationId, index: index),
      role: switch (message.role) {
        AssistantMessageRole.user => FlowMessageRole.user,
        AssistantMessageRole.assistant => FlowMessageRole.assistant,
      },
      parts: parts,
      status: FlowMessageStatus.complete,
      timestamp: message.createdAt,
    );
  }

  /// Returns the FlowUI identity without changing the domain message.
  String flowMessageId(
    AssistantMessage message, {
    required String conversationId,
    required int index,
  }) {
    return '$conversationId:$index:${messageIdFor(message)}';
  }

  /// Maps the current draft to a streaming assistant turn.
  FlowMessageData mapStreamingDraft(String draft) {
    final isEmpty = draft.isEmpty;
    return FlowMessageData(
      id: 'streaming',
      role: FlowMessageRole.assistant,
      parts: isEmpty
          ? const <FlowMessagePart>[]
          : <FlowMessagePart>[FlowTextPart(draft)],
      status: isEmpty ? FlowMessageStatus.pending : FlowMessageStatus.streaming,
    );
  }

  /// Builder passed to [FlowThread.messageBuilder].
  Widget buildMessage(BuildContext context, FlowMessageData message) {
    final isComplete = message.status == FlowMessageStatus.complete;
    return FlowMessage(
      message,
      customPartBuilder: buildCustomPart,
      footer: isComplete ? _buildFooter(context, message) : null,
      thinkingLabel: thinkingLabel,
    );
  }

  /// Renders the adapter-owned FlowUI custom parts.
  Widget? buildCustomPart(
    BuildContext context,
    FlowMessageData message,
    FlowCustomPart part,
  ) {
    switch (part.type) {
      case 'markdown':
        final data = part.data;
        if (data is! AssistantMarkdownPart) return null;
        Widget content = MarkdownBody(
          data: data.content,
          selectable: true,
          styleSheet: MarkdownStyle.ai(
            context,
            background: context.theme.colors.secondary,
          ),
          onTapLink: (text, href, title) => _handleLinkTap(context, href),
        );
        if (data.replaced) {
          content = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: _ReplacedBadge(
                  label: AppLocalizations.of(context)!.assistantReplacedLabel,
                ),
              ),
              const SizedBox(height: Spacing.level2),
              Opacity(
                key: const Key('assistant-replaced-muted'),
                opacity: 0.55,
                child: content,
              ),
            ],
          );
        }
        return content;
      case 'proposal':
        final data = part.data;
        if (data is! AssistantProposalPart) return null;
        return AssistantProposalCard(
          messageId: data.messageId,
          proposal: data.proposal,
          onConfirmProposal: onConfirmProposal,
          onDismissProposal: onDismissProposal,
          onRegenerateProposal: onRegenerateProposal,
        );
      default:
        return null;
    }
  }

  Widget? _buildFooter(BuildContext context, FlowMessageData message) {
    final l10n = AppLocalizations.of(context)!;
    final markdown = _markdownPart(message);
    final isAssistant = message.role == FlowMessageRole.assistant;
    final children = <Widget>[];

    if (message.timestamp case final timestamp?) {
      children.add(
        Text(
          _formatTimestamp(context, timestamp),
          style: TypographyToken.level2
              .body(context)
              .copyWith(color: context.theme.colors.mutedForeground),
        ),
      );
    }
    if (isAssistant && markdown != null && markdown.usedTools.isNotEmpty) {
      children.add(
        AssistantSourceStrip(
          usedTools: markdown.usedTools,
          toolDetails: markdown.toolDetails,
        ),
      );
    }
    if (isAssistant && markdown != null) {
      children.add(
        AssistantDisclaimerBar(text: _disclaimerText(l10n, markdown)),
      );
    }

    final actions = <FlowMessageAction>[
      FlowMessageAction.copy(
        tooltip: l10n.assistantCopyAction,
        onPressed: () => unawaited(_copy(context, _messageText(message), l10n)),
      ),
    ];
    if (isAssistant) {
      if (message.status != FlowMessageStatus.streaming) {
        actions.add(
          FlowMessageAction.regenerate(
            tooltip: l10n.assistantRegenerateAction,
            onPressed: onRegenerate,
          ),
        );
      }
    } else if (message.status != FlowMessageStatus.streaming) {
      actions.add(
        FlowMessageAction(
          icon: Icons.refresh,
          tooltip: l10n.assistantResendAction,
          onPressed: onResend == null
              ? null
              : () => onResend!(_messageText(message)),
        ),
      );
    }
    children.add(FlowMessageActions(actions: actions));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var index = 0; index < children.length; index++) ...[
          if (index > 0) const SizedBox(height: Spacing.level2),
          children[index],
        ],
      ],
    );
  }

  Future<void> _copy(
    BuildContext context,
    String content,
    AppLocalizations l10n,
  ) async {
    await Clipboard.setData(ClipboardData(text: content));
    if (context.mounted) {
      await Toast.show(context, l10n.assistantCopySuccess);
    }
  }

  String _messageText(FlowMessageData message) {
    for (final part in message.parts) {
      if (part is FlowTextPart) return part.text;
      if (part is FlowCustomPart && part.data is AssistantMarkdownPart) {
        return (part.data! as AssistantMarkdownPart).content;
      }
    }
    return '';
  }

  AssistantMarkdownPart? _markdownPart(FlowMessageData message) {
    for (final part in message.parts) {
      if (part is FlowCustomPart && part.data is AssistantMarkdownPart) {
        return part.data! as AssistantMarkdownPart;
      }
    }
    return null;
  }

  String _formatTimestamp(BuildContext context, DateTime dateTime) {
    final locale = Localizations.localeOf(context).toString();
    return intl.DateFormat.Hm(locale).format(dateTime.toLocal());
  }

  String _disclaimerText(
    AppLocalizations l10n,
    AssistantMarkdownPart markdown,
  ) {
    for (final detail in markdown.toolDetails) {
      final disclaimer = detail.disclaimer;
      if (disclaimer != null && disclaimer.isNotEmpty) return disclaimer;
    }
    return l10n.assistantDisclaimerText;
  }

  void _handleLinkTap(BuildContext context, String? href) {
    final uri = Uri.tryParse(href ?? '');
    if (uri == null ||
        !uri.hasScheme ||
        !(uri.isScheme('http') || uri.isScheme('https')) ||
        onOpenLink == null) {
      return;
    }
    unawaited(_confirmAndOpen(context, uri));
  }

  Future<void> _confirmAndOpen(BuildContext context, Uri uri) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showAppDialog<bool>(
      context: context,
      maxWidth: LayoutScaleResolver.dialogStandardMaxWidth,
      scrollable: false,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.assistantMarkdownLinkConfirmTitle,
            style: TypographyToken.level6.body(context),
          ),
          const SizedBox(height: Spacing.level3),
          Text(
            l10n.assistantMarkdownLinkConfirmDescription,
            style: TypographyToken.level4.body(context),
          ),
          const SizedBox(height: Spacing.level5),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FButton(
                variant: FButtonVariant.ghost,
                onPress: () => Navigator.of(context).pop(false),
                child: Text(l10n.commonCancel),
              ),
              const SizedBox(width: Spacing.level3),
              FButton(
                onPress: () => Navigator.of(context).pop(true),
                child: Text(l10n.assistantMarkdownLinkOpenAction),
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

class _ReplacedBadge extends StatelessWidget {
  const _ReplacedBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.secondary,
        borderRadius: BorderRadius.circular(RadiusTokens.level2),
        border: Border.all(color: colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.level2,
          vertical: 1,
        ),
        child: Text(
          label,
          key: const Key('assistant-replaced-label'),
          style: TypographyToken.level1
              .body(context)
              .copyWith(color: colors.mutedForeground, height: 1.2),
        ),
      ),
    );
  }
}
