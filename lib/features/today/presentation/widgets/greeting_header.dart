part of '../today.dart';

/// 今日页顶部问候语区域。
///
/// 展示时间问候语、副标题和通知铃铛图标。
class _GreetingHeader extends StatelessWidget {
  const _GreetingHeader({
    required this.greeting,
    required this.subtitle,
    this.onNotificationTap,
  });

  final String greeting;
  final String subtitle;
  final VoidCallback? onNotificationTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textPrimary = isDark
        ? AppUiConstants.TEXT_PRIMARY_DARK
        : AppUiConstants.TEXT_PRIMARY;
    final textMuted = AppUiConstants.TEXT_MUTED;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.base,
        AppSpacing.sm,
        AppSpacing.base,
        TodayConstants.greetingBottomSpacing,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: TextStyle(
                    fontSize: AppTypography.display,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: AppTypography.bodySmall,
                    fontWeight: FontWeight.w400,
                    color: textMuted,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onNotificationTap,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.surface,
                border: Border.all(color: theme.colorScheme.outline),
              ),
              child: Icon(
                Icons.notifications_none_rounded,
                size: 20,
                color: textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
