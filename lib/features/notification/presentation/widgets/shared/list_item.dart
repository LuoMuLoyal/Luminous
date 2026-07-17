import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';

import 'package:luminous/features/notification/domain/entities/notification.dart';

class NotificationListItemWidget extends StatelessWidget {
  const NotificationListItemWidget({
    super.key,
    required this.item,
    required this.onTap,
    required this.onDismiss,
  });

  final NotificationItem item;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return Slidable(
      key: ValueKey(item.id),
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            onPressed: (_) => onDismiss(),
            backgroundColor: colors.destructive,
            foregroundColor: colors.destructiveForeground,
            icon: FLucideIcons.trash2,
            borderRadius: BorderRadius.circular(RadiusTokens.level3),
          ),
        ],
      ),
      child: FCard.raw(
        style: .delta(
          decoration: .shapeDelta(
            color: item.isRead
                ? colors.background
                : SemanticColor.primary.subtle(context),
            shape: RoundedSuperellipseBorder(
              side: BorderSide(
                color: item.isRead ? colors.border : colors.primary,
                width: item.isRead ? 1 : 1.2,
              ),
              borderRadius: context.theme.style.borderRadius.md,
            ),
          ),
        ),
        child: FTappable(
          onPress: onTap,
          child: Padding(
            padding: const EdgeInsets.all(Spacing.level4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                            _formatTime(item.createdAt),
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
                if (!item.isRead) ...[
                  const SizedBox(width: Spacing.level3),
                  FAvatar.raw(
                    size: 8,
                    style: .delta(backgroundColor: colors.primary),
                    child: const SizedBox.shrink(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(String iso8601) {
    final dt = DateTime.tryParse(iso8601);
    if (dt == null) return '';
    final now = clock.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(dt.year, dt.month, dt.day);
    if (date == today) {
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
    return '${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }
}
