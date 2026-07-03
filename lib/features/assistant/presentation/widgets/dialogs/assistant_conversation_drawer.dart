import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/widgets/common/app_state_views.dart';
import 'package:luminous/features/assistant/presentation/providers/assistant_controller.dart';
import 'package:luminous/features/assistant/presentation/utils/assistant_ui_formatters.dart';
import 'package:luminous/l10n/app_localizations.dart';

class AssistantConversationDrawer extends StatelessWidget {
  const AssistantConversationDrawer({
    super.key,
    required this.state,
    required this.title,
    required this.emptyTitle,
    required this.emptyDescription,
    required this.onRetry,
    required this.onSelect,
  });

  final AssistantState state;
  final String title;
  final String emptyTitle;
  final String emptyDescription;
  final VoidCallback onRetry;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    final items = state.recentConversations;
    final width = MediaQuery.sizeOf(context).width < 600
        ? MediaQuery.sizeOf(context).width * 0.8
        : 360.0;

    return SizedBox(
      width: width,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacingTokens.level5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: AppTypographyToken.level7.display(context),
                    ),
                  ),
                  FButton.icon(
                    variant: FButtonVariant.ghost,
                    onPress: () => Navigator.of(context).pop(),
                    child: const Icon(FLucideIcons.x),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacingTokens.level4),
              Expanded(
                child: Builder(
                  builder: (context) {
                    if (state.isLoadingRecentConversations && items.isEmpty) {
                      return const AppStateSkeletonView(
                        blocks: <AppStateSkeletonBlock>[
                          AppStateSkeletonBlock(height: 72),
                          AppStateSkeletonBlock(height: 72),
                          AppStateSkeletonBlock(height: 72),
                        ],
                      );
                    }
                    if (state.recentConversationError != null &&
                        items.isEmpty) {
                      return AppStateMessageView(
                        title: title,
                        description: state.recentConversationError!,
                        icon: FLucideIcons.clock4,
                        tone: AppStateTone.warning,
                        actionLabel: AppLocalizations.of(
                          context,
                        )!.todayRetryAction,
                        onAction: onRetry,
                      );
                    }
                    if (items.isEmpty) {
                      return AppStateMessageView(
                        title: emptyTitle,
                        description: emptyDescription,
                        icon: FLucideIcons.messageSquareMore,
                      );
                    }

                    return ListView.separated(
                      key: const Key('assistant-recent-conversation-list'),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final selected = item.id == state.conversationId;
                        final borderColor = selected
                            ? colors.primary
                            : colors.border;
                        final backgroundColor = selected
                            ? colors.primary.withValues(alpha: 0.1)
                            : colors.background;

                        return FTappable(
                          key: Key('assistant-recent-conversation-${item.id}'),
                          onPress: state.isOpeningConversation
                              ? null
                              : () => onSelect(item.id),
                          child: FCard.raw(
                            style: .delta(
                              decoration: .shapeDelta(
                                color: backgroundColor,
                                shape: RoundedSuperellipseBorder(
                                  side: BorderSide(color: borderColor),
                                  borderRadius:
                                      context.theme.style.borderRadius.lg,
                                ),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(
                                AppSpacingTokens.level4,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    conversationTitle(context, item),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypographyToken.level5
                                        .body(context)
                                        .copyWith(fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(
                                    height: AppSpacingTokens.level2,
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          conversationTimestampLabel(
                                            context,
                                            item,
                                          ),
                                          style: AppTypographyToken.level3
                                              .body(context)
                                              .copyWith(
                                                color: colors.mutedForeground,
                                              ),
                                        ),
                                      ),
                                      if (selected)
                                        Text(
                                          AppLocalizations.of(
                                            context,
                                          )!.assistantRecentConversationCurrentLabel,
                                          style: AppTypographyToken.level4
                                              .body(context)
                                              .copyWith(
                                                color: colors.primary,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSpacingTokens.level3),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
