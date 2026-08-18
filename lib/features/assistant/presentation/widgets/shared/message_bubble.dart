import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:forui/forui.dart';
import 'package:intl/intl.dart' as intl;
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/widgets/common/dialog_shell.dart';
import 'package:luminous/features/assistant/domain/entities/models.dart';
import 'package:luminous/features/assistant/presentation/widgets/disclaimer_bar.dart';
import 'package:luminous/features/assistant/presentation/widgets/shared/proposal_card.dart';
import 'package:luminous/features/assistant/presentation/widgets/source_strip.dart';
import 'package:luminous/l10n/app_localizations.dart';

class AssistantMessageBubble extends StatelessWidget {
  const AssistantMessageBubble({
    super.key,
    required this.messageId,
    required this.role,
    required this.content,
    required this.usedTools,
    this.toolDetails = const <AssistantToolDetail>[],
    this.proposedActions = const <AssistantProposedAction>[],
    this.isStreaming = false,
    this.createdAt,
    this.onConfirmProposal,
    this.onDismissProposal,
    this.onRegenerateProposal,
    this.onRegenerate,
    this.onResend,
    this.onOpenLink,
  });

  final String messageId;
  final AssistantMessageRole role;
  final String content;
  final List<String> usedTools;
  final List<AssistantToolDetail> toolDetails;
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
  final void Function({required String messageId, required String proposalId})?
  onRegenerateProposal;

  /// Regenerates the last assistant message (F-5b). Only meaningful for the
  /// final assistant message; the backend rejects other positions with 400,
  /// surfaced as a toast by the page.
  final VoidCallback? onRegenerate;

  /// Re-sends an existing user message (「重新发送」).
  final void Function(String content)? onResend;

  /// Opens an external URL after the user confirms the markdown link dialog
  /// (F-4). When null, markdown links in the bubble stay inert — they never
  /// auto-jump; the shipping surface wires this to `ExternalUrlLauncher`.
  final Future<bool> Function(Uri uri)? onOpenLink;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final l10n = AppLocalizations.of(context)!;

    final isUser = role == AssistantMessageRole.user;
    final align = isUser ? Alignment.centerRight : Alignment.centerLeft;
    final background = isUser
        ? SemanticColor.primary.muted(context)
        : colors.secondary;
    final foreground = isUser
        ? SemanticColor.primary.solid(context)
        : colors.foreground;

    // 内容区:保持 MarkdownStyle.ai 单一样式入口
    // (markdown_style.dart 注释约定 6 处渲染点不走本地 copyWith 漂移)。
    Widget contentArea;
    if (isUser) {
      contentArea = SelectableText(
        content,
        style: TypographyToken.level4.body(context).copyWith(color: foreground),
      );
    } else if (isStreaming) {
      contentArea = Text(
        content,
        style: TypographyToken.level4.body(context).copyWith(color: foreground),
      );
    } else {
      contentArea = MarkdownBody(
        data: content,
        selectable: true,
        styleSheet: MarkdownStyle.ai(context, background: background),
        onTapLink: (text, href, title) =>
            _handleLinkTap(context, text, href, title),
      );
    }

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
                  contentArea,
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
                          onRegenerateProposal: onRegenerateProposal,
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
                  if (!isStreaming && !isUser && usedTools.isNotEmpty) ...[
                    const SizedBox(height: Spacing.level2),
                    AssistantSourceStrip(
                      usedTools: usedTools,
                      toolDetails: toolDetails,
                    ),
                  ],
                  if (!isStreaming && !isUser) ...[
                    const SizedBox(height: Spacing.level2),
                    AssistantDisclaimerBar(text: _disclaimerText(l10n)),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// F-4 链接契约：链接默认不自动跳转，先弹确认对话框，确认后才交给
  /// [onOpenLink]（生产由 `ExternalUrlLauncher` 打开）。
  ///
  /// 仅放行 http/https 方案；无 opener 或方案不符时保持不响应（不硬校验链接域
  /// 白名单——规则未定，见计划不确定点）。
  void _handleLinkTap(
    BuildContext context,
    String text,
    String? href,
    String title,
  ) {
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

  /// First non-empty per-tool disclaimer, falling back to the fixed
  /// health-reference disclaimer for every assistant reply.
  String _disclaimerText(AppLocalizations l10n) {
    for (final detail in toolDetails) {
      final disclaimer = detail.disclaimer;
      if (disclaimer != null && disclaimer.isNotEmpty) {
        return disclaimer;
      }
    }
    return l10n.assistantDisclaimerText;
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
          if (!isUser && !isStreaming)
            FTile(
              key: const Key('assistant-message-regenerate'),
              title: Text(l10n.assistantRegenerateAction),
              onPress: onRegenerate,
            ),
          if (isUser && !isStreaming)
            FTile(
              key: const Key('assistant-message-resend'),
              title: Text(l10n.assistantResendAction),
              onPress: onResend == null ? null : () => onResend!(content),
            ),
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
