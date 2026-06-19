import 'package:flutter/material.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/core/widgets/app_state_views.dart';
import 'package:luminous/features/assistant/presentation/providers/assistant_controller.dart';
import 'package:luminous/features/assistant/presentation/utils/assistant_ui_formatters.dart';
import 'package:luminous/l10n/app_localizations.dart';

class AssistantRecentConversationSheet extends StatelessWidget {
  const AssistantRecentConversationSheet({
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
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final items = state.recentConversations;

    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.72,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: assistantTypography(context).displaySm),
          const SizedBox(height: AppSpacingTokens.md),
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
                if (state.recentConversationError != null && items.isEmpty) {
                  return AppStateMessageView(
                    title: title,
                    description: state.recentConversationError!,
                    icon: Icons.history_toggle_off_rounded,
                    tone: AppStateTone.warning,
                    actionLabel:
                        AppLocalizations.of(context)!.todayRetryAction,
                    onAction: onRetry,
                  );
                }
                if (items.isEmpty) {
                  return AppStateMessageView(
                    title: emptyTitle,
                    description: emptyDescription,
                    icon: Icons.chat_bubble_outline_rounded,
                  );
                }

                return ListView.separated(
                  key: const Key('assistant-recent-conversation-list'),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final selected = item.id == state.conversationId;
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        key: Key('assistant-recent-conversation-${item.id}'),
                        borderRadius:
                            BorderRadius.circular(AppRadiusTokens.lg),
                        onTap: state.isOpeningConversation
                            ? null
                            : () => onSelect(item.id),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: selected
                                ? theme.colorScheme.primary.withValues(
                                    alpha: 0.12,
                                  )
                                : surface.canvas,
                            borderRadius: BorderRadius.circular(
                              AppRadiusTokens.lg,
                            ),
                            border: Border.all(color: surface.hairline),
                          ),
                          child: Padding(
                            padding:
                                const EdgeInsets.all(AppSpacingTokens.md),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  conversationTitle(context, item),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: assistantTypography(context)
                                      .bodyMdStrong,
                                ),
                                const SizedBox(
                                  height: AppSpacingTokens.xs,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        conversationTimestampLabel(
                                          context,
                                          item,
                                        ),
                                        style: assistantTypography(context)
                                            .bodySm
                                            .copyWith(color: surface.body),
                                      ),
                                    ),
                                    if (selected)
                                      Text(
                                        AppLocalizations.of(context)!
                                            .assistantRecentConversationCurrentLabel,
                                        style: assistantTypography(context)
                                            .bodySm
                                            .copyWith(
                                              color:
                                                  theme.colorScheme.primary,
                                            ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacingTokens.sm),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
