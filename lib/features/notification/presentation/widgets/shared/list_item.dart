import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/utils/date_format_utils.dart';
import 'package:luminous/features/notification/domain/entities/notification.dart';
import 'package:luminous/l10n/app_localizations.dart';

class NotificationListItemWidget extends StatefulWidget {
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
  State<NotificationListItemWidget> createState() =>
      _NotificationListItemWidgetState();
}

class _NotificationListItemWidgetState
    extends State<NotificationListItemWidget> {
  final ValueNotifier<bool> _isHovered = ValueNotifier(false);

  @override
  void dispose() {
    _isHovered.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final l10n = AppLocalizations.of(context)!;
    final isDesktop = MediaQuery.sizeOf(context).width >= Breakpoints.desktop;

    // Toggle action color/icon: unread -> mark as read (info);
    // read -> mark as unread (warning).
    final toggleColor = widget.item.isRead
        ? SemanticColor.warning.solid(context)
        : SemanticColor.info.solid(context);
    final toggleIcon = widget.item.isRead
        ? FLucideIcons.mailMinus
        : FLucideIcons.checkCheck;
    final toggleLabel = widget.item.isRead
        ? l10n.notificationActionMarkUnread
        : l10n.notificationActionMarkRead;

    // Desktop hover action buttons — replace Slidable drag with explicit
    // buttons that appear on hover. Slidable remains on mobile/touch.
    if (isDesktop) {
      return MouseRegion(
        onEnter: (_) => _isHovered.value = true,
        onExit: (_) => _isHovered.value = false,
        child: FCard(
          child: FTappable(
            onPress: widget.onTap,
            child: Padding(
              padding: const EdgeInsets.all(Spacing.level4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!widget.item.isRead) ...[
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
                                widget.item.title,
                                style: TypographyToken.level5
                                    .body(context)
                                    .copyWith(
                                      fontWeight: widget.item.isRead
                                          ? FontWeight.w500
                                          : FontWeight.w700,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: Spacing.level2),
                            Text(
                              _formatTime(context, widget.item.createdAt),
                              style: TypographyToken.level3
                                  .body(context)
                                  .copyWith(color: colors.mutedForeground),
                            ),
                          ],
                        ),
                        const SizedBox(height: Spacing.level1),
                        Text(
                          widget.item.content,
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
                  // Hover action buttons
                  ValueListenableBuilder<bool>(
                    valueListenable: _isHovered,
                    builder: (context, isHovered, _) {
                      if (!isHovered) return const SizedBox.shrink();
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(width: Spacing.level3),
                          _HoverActionButton(
                            icon: toggleIcon,
                            color: toggleColor,
                            tooltip: toggleLabel,
                            onPressed: widget.onToggleRead,
                          ),
                          const SizedBox(width: Spacing.level2),
                          _HoverActionButton(
                            icon: FLucideIcons.trash2,
                            color: colors.destructive,
                            tooltip: l10n.notificationActionDelete,
                            onPressed: widget.onDismiss,
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Mobile: Slidable swipe actions (unchanged)
    return Slidable(
      key: ValueKey(widget.item.id),
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio: 0.5,
        children: [
          SlidableAction(
            onPressed: (_) => widget.onToggleRead(),
            backgroundColor: toggleColor,
            foregroundColor: SemanticColor.info.foreground(context),
            icon: toggleIcon,
            label: toggleLabel,
            spacing: 4,
            borderRadius: BorderRadius.circular(RadiusTokens.level3),
          ),
          SlidableAction(
            onPressed: (_) => widget.onDismiss(),
            backgroundColor: colors.destructive,
            foregroundColor: colors.destructiveForeground,
            icon: FLucideIcons.trash2,
            label: l10n.notificationActionDelete,
            spacing: 4,
            borderRadius: BorderRadius.circular(RadiusTokens.level3),
          ),
        ],
      ),
      child: FCard(
        child: FTappable(
          onPress: widget.onTap,
          child: Padding(
            padding: const EdgeInsets.all(Spacing.level4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!widget.item.isRead) ...[
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
                              widget.item.title,
                              style: TypographyToken.level5
                                  .body(context)
                                  .copyWith(
                                    fontWeight: widget.item.isRead
                                        ? FontWeight.w500
                                        : FontWeight.w700,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: Spacing.level2),
                          Text(
                            _formatTime(context, widget.item.createdAt),
                            style: TypographyToken.level3
                                .body(context)
                                .copyWith(color: colors.mutedForeground),
                          ),
                        ],
                      ),
                      const SizedBox(height: Spacing.level1),
                      Text(
                        widget.item.content,
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

class _HoverActionButton extends StatelessWidget {
  const _HoverActionButton({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: SizedBox(
        width: 32,
        height: 32,
        child: IconButton(
          icon: Icon(icon, size: 16),
          color: color,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          onPressed: onPressed,
        ),
      ),
    );
  }
}
