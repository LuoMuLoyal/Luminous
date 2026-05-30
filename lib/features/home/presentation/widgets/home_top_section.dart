part of '../home.dart';

/// 首页顶部“健康助手”区域。
class HomeTopSection extends StatelessWidget {
  const HomeTopSection({
    super.key,
    required this.palette,
    required this.todayTipListenable,
    required this.nextText,
    required this.loadingReminders,
    required this.reminderCount,
    required this.onTapTip,
    required this.onLongPressTip,
  });

  final SoftBannerPalette palette;
  final ValueListenable<String> todayTipListenable;
  final String nextText;
  final bool loadingReminders;
  final int reminderCount;
  final VoidCallback onTapTip;
  final VoidCallback onLongPressTip;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = isCompactLayoutWidth(constraints.maxWidth);
          final statusText = loadingReminders
              ? (l10n?.homeStatusSyncing ?? '同步中')
              : reminderCount == 0
              ? (l10n?.homeStatusRelaxed ?? '今天较轻松')
              : (l10n?.homeStatusReady ?? '已整理');

          return SoftBannerCard(
            palette: palette,
            padding: EdgeInsets.all(compact ? 14 : 17),
            builder: (context, theme) {
              final pills = <Widget>[
                HomeInfoPill(
                  text: loadingReminders
                      ? (l10n?.homePillLoading ?? '提醒加载中...')
                      : (l10n?.homePillCount(reminderCount) ??
                            '今日提醒 $reminderCount 条'),
                  backgroundColor: theme.surfaceColor.withValues(alpha: 0.70),
                  textColor: theme.surfaceTextColor,
                ),
                HomeInfoPill(
                  text: l10n?.homePillTips ?? '健康小贴士',
                  backgroundColor: theme.surfaceColor.withValues(alpha: 0.70),
                  textColor: theme.surfaceTextColor,
                  onTap: onTapTip,
                  onLongPress: onLongPressTip,
                ),
              ];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: compact ? 38 : 40,
                        height: compact ? 38 : 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.surfaceColor.withValues(alpha: 0.76),
                          border: Border.all(color: theme.borderColor),
                        ),
                        child: Icon(
                          Icons.health_and_safety_rounded,
                          color: theme.accentColor,
                          size: compact ? 20 : 24,
                        ),
                      ),
                      SizedBox(width: compact ? 8 : 10),
                      Expanded(
                        child: Text(
                          '${l10n?.homeHeroTitle ?? '健康助手'} | Luminous',
                          style: TextStyle(
                            color: theme.textColor,
                            fontSize: compact ? 18 : 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      HomeStatusChip(
                        text: statusText,
                        backgroundColor: theme.surfaceColor.withValues(
                          alpha: 0.74,
                        ),
                        textColor: theme.surfaceTextColor,
                      ),
                    ],
                  ),
                  SizedBox(height: compact ? 6 : 8),
                  ValueListenableBuilder<String>(
                    valueListenable: todayTipListenable,
                    builder: (context, todayTip, _) {
                      final minTipHeight = compact ? 24.0 : 26.0;

                      return ConstrainedBox(
                        constraints: BoxConstraints(minHeight: minTipHeight),
                        child: ClipRect(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 240),
                            switchInCurve: Curves.easeOutCubic,
                            switchOutCurve: Curves.easeInCubic,
                            layoutBuilder: (currentChild, previousChildren) {
                              final currentChildren = currentChild == null
                                  ? null
                                  : <Widget>[currentChild];

                              return Stack(
                                alignment: Alignment.topLeft,
                                children: [
                                  ...previousChildren,
                                  ...?currentChildren,
                                ],
                              );
                            },
                            transitionBuilder: (child, animation) {
                              final isIncoming =
                                  child.key == ValueKey<String>(todayTip);
                              final offsetAnimation = animation.drive(
                                Tween<Offset>(
                                  begin: isIncoming
                                      ? const Offset(0, 0.35)
                                      : const Offset(0, -0.22),
                                  end: Offset.zero,
                                ),
                              );

                              return FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: offsetAnimation,
                                  child: child,
                                ),
                              );
                            },
                            child: Text(
                              todayTip,
                              key: ValueKey<String>(todayTip),
                              style: TextStyle(
                                color: theme.textColor,
                                fontSize: compact ? 15.2 : 17,
                                fontWeight: FontWeight.w800,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: compact ? 10 : 13),
                  _HomeTopSummaryCard(
                    bannerTheme: theme,
                    compact: compact,
                    nextText: nextText,
                    loadingReminders: loadingReminders,
                    reminderCount: reminderCount,
                  ),
                  SizedBox(height: compact ? 10 : 12),
                  compact
                      ? Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 8,
                          runSpacing: 8,
                          children: pills,
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            pills.first,
                            const SizedBox(width: 8),
                            pills.last,
                          ],
                        ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _HomeTopSummaryCard extends StatelessWidget {
  const _HomeTopSummaryCard({
    required this.bannerTheme,
    required this.compact,
    required this.nextText,
    required this.loadingReminders,
    required this.reminderCount,
  });

  final SoftBannerTheme bannerTheme;
  final bool compact;
  final String nextText;
  final bool loadingReminders;
  final int reminderCount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final title = loadingReminders
        ? (l10n?.homeSummaryTitleLoading ?? '正在整理提醒')
        : reminderCount == 0
        ? (l10n?.homeSummaryTitleNone ?? '今日状态')
        : (l10n?.homeSummaryTitleNext ?? '下一条提醒');
    final detail = loadingReminders
        ? (l10n?.homeSummaryDetailLoading ?? '正在同步今天的提醒安排，请稍等一下')
        : reminderCount == 0
        ? (l10n?.homeSummaryDetailNone ?? '今天暂无待完成提醒，可以安心继续当前节奏')
        : nextText;
    final badgeText = loadingReminders
        ? (l10n?.homeSummaryBadgeLoading ?? '同步中')
        : reminderCount == 0
        ? (l10n?.homeSummaryBadgeRelaxed ?? '轻松日')
        : (l10n?.homeSummaryBadgeCount(reminderCount) ?? '$reminderCount 条安排');
    final icon = loadingReminders
        ? Icons.sync_rounded
        : reminderCount == 0
        ? Icons.done_all_rounded
        : Icons.alarm_rounded;

    return Container(
      padding: EdgeInsets.fromLTRB(
        compact ? 10 : 13,
        compact ? 10 : 12,
        compact ? 10 : 13,
        compact ? 10 : 12,
      ),
      decoration: BoxDecoration(
        color: bannerTheme.surfaceColor.withValues(
          alpha: Theme.of(context).brightness == Brightness.dark ? 0.74 : 0.44,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: bannerTheme.borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: compact ? 34 : 36,
            height: compact ? 34 : 36,
            decoration: BoxDecoration(
              color: bannerTheme.accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: compact ? 17 : 19,
              color: bannerTheme.accentColor,
            ),
          ),
          SizedBox(width: compact ? 10 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: bannerTheme.textColor,
                        fontSize: compact ? 13 : 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    TintedStatusChip(
                      text: badgeText,
                      color: bannerTheme.accentColor,
                      backgroundColor: bannerTheme.accentColor.withValues(
                        alpha: 0.12,
                      ),
                      enablePopup: false,
                      showBorder: false,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: compact ? 4 : 5),
                Text(
                  detail,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _homeBannerSecondaryTextColor(
                      bannerTheme,
                      emphasis: 0.34,
                    ),
                    fontSize: compact ? 12.5 : 13.5,
                    height: 1.45,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
