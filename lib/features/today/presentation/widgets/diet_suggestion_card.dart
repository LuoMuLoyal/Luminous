part of '../today.dart';

/// 今日饮食建议卡片。
///
/// 展示 AI 推荐的饮食方案，包含食物图片、标题和描述。
class _DietSuggestionCard extends StatelessWidget {
  const _DietSuggestionCard({
    required this.title,
    required this.description,
    this.imageUrl,
  });

  final String title;
  final String description;
  final String? imageUrl;

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
      accentColor: AppUiConstants.SUCCESS,
      padding: const EdgeInsets.all(TodayConstants.cardHorizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TodaySectionHeader(
            title: l10n.todayDietTitle,
            trailing: l10n.todayDietChangeAction,
          ),
          SizedBox(height: TodayConstants.cardTitleContentSpacing),
          Row(
            children: [
              // 食物图片占位。
              Container(
                width: TodayConstants.dietImageSize,
                height: TodayConstants.dietImageSize,
                decoration: BoxDecoration(
                  color: AppUiConstants.SUCCESS.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(
                    TodayConstants.dietCardRadius,
                  ),
                ),
                child: imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(
                          TodayConstants.dietCardRadius,
                        ),
                        child: Image.network(
                          imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _buildPlaceholder(),
                        ),
                      )
                    : _buildPlaceholder(),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: AppTypography.body,
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xs),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: AppTypography.bodySmall,
                        color: textMuted,
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
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Icon(
        Icons.restaurant_rounded,
        size: 24,
        color: AppUiConstants.SUCCESS.withValues(alpha: 0.5),
      ),
    );
  }
}
