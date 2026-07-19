import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/utils/date_format_utils.dart';
import 'package:luminous/l10n/app_localizations.dart';

import 'package:luminous/features/notification/domain/entities/notification.dart';

class NotificationListItemWidget extends StatelessWidget {
  const NotificationListItemWidget({
    super.key,
    required this.item,
    required this.onTap,
    required this.onDismiss,
    required this.onToggleRead,
  });

  final NotificationItem item;
  final VoidCallback onTap;
  final VoidCallback onDismiss;
  final VoidCallback onToggleRead;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final l10n = AppLocalizations.of(context)!;

    // Toggle action color/icon: unread -> mark as read (info);
    // read -> mark as unread (warning).
    final toggleColor = item.isRead
        ? SemanticColor.warning.solid(context)
        : SemanticColor.info.solid(context);
    final toggleForeground = item.isRead
        ? SemanticColor.warning.foreground(context)
        : SemanticColor.info.foreground(context);
    final toggleIcon = item.isRead
        ? FLucideIcons.mailMinus
        : FLucideIcons.checkCheck;
    final toggleLabel = item.isRead
        ? l10n.notificationActionMarkUnread
        : l10n.notificationActionMarkRead;

    return Slidable(
      key: ValueKey(item.id),
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio: 0.5,
        children: [
          SlidableAction(
            onPressed: (_) => onToggleRead(),
            backgroundColor: toggleColor,
            foregroundColor: toggleForeground,
            icon: toggleIcon,
            label: toggleLabel,
            spacing: 4,
            borderRadius: BorderRadius.circular(RadiusTokens.level3),
          ),
          SlidableAction(
            onPressed: (_) => onDismiss(),
            backgroundColor: colors.destructive,
            foregroundColor: colors.destructiveForeground,
            icon: FLucideIcons.trash2,
            label: l10n.notificationActionDelete,
            spacing: 4,
            borderRadius: BorderRadius.circular(RadiusTokens.level3),
          ),
        ],
      ),
      child: FCard.raw(
        child: FTappable(
          onPress: onTap,
          child: Padding(
            padding: const EdgeInsets.all(Spacing.level4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!item.isRead) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: Spacing.level2),
                    child: Semantics(
                      label: l10n.notificationUnreadSemantics,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: colors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: Spacing.level3),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              style: TypographyToken.level5
                                  .body(context)
                                  .copyWith(
                                    fontWeight: item.isRead
                                        ? FontWeight.w500
                                        : FontWeight.w700,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: Spacing.level2),
                          Text(
                            _formatTime(context, item.createdAt),
                            style: TypographyToken.level3
                                .body(context)
                                .copyWith(color: colors.mutedForeground),
                          ),
                        ],
                      ),
                      const SizedBox(height: Spacing.level1),
                      Text(
                        item.content,
                        style: TypographyToken.level4
                            .body(context)
                            .copyWith(
                              color: colors.mutedForeground,
                              height: 1.4,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(BuildContext context, String iso8601) {
    final locale = Localizations.localeOf(context);
    return formatRelativeTimeLabel(iso8601, locale);
  }
}
