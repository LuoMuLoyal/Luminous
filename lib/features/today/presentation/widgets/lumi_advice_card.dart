part of '../today.dart';

/// Lumi AI 建议卡片。
///
/// 展示 AI 生成的个性化健康建议，带有 Lumi 头像和品牌色。
class _LumiAdviceCard extends StatelessWidget {
  const _LumiAdviceCard({required this.advice});

  final String advice;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textPrimary = isDark
        ? AppUiConstants.TEXT_PRIMARY_DARK
        : AppUiConstants.TEXT_PRIMARY;
    final textMuted = AppUiConstants.TEXT_MUTED;

    return AppSectionCard(
      accentColor: TodayConstants.lumiColor,
      padding: const EdgeInsets.all(TodayConstants.cardHorizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Lumi 头像。
              Container(
                width: TodayConstants.lumiAvatarSize,
                height: TodayConstants.lumiAvatarSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      TodayConstants.lumiColor,
                      TodayConstants.lumiColor.withValues(alpha: 0.6),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  size: 18,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  l10n.todayLumiTitle,
                  style: TextStyle(
                    fontSize: AppTypography.body,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: AppUiConstants.TEXT_MUTED,
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            advice,
            style: TextStyle(
              fontSize: AppTypography.bodySmall,
              color: textMuted,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
