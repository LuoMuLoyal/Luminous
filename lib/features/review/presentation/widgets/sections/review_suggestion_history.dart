import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:intl/intl.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/divider.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/features/today/domain/entities/suggestion.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// 建议历史段落：从 Today 域的建议历史数据源拉取，按 title|reason|type
/// 去重取最高生命周期状态。
///
/// 从旧 `ReviewSuggestionHistorySection` 改名而来，装配到 Review 主路径。
class ReviewSuggestionHistorySection extends StatelessWidget {
  const ReviewSuggestionHistorySection({
    super.key,
    required this.suggestions,
    required this.l10n,
    this.isLoading = false,
    this.onSuggestionTap,
  });

  final List<TodaySuggestionHistoryItem> suggestions;
  final AppLocalizations l10n;
  final bool isLoading;
  final ValueChanged<TodaySuggestionHistoryItem>? onSuggestionTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const Key('review-suggestion-history-section'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.reviewSuggestionHistorySectionTitle,
          style: context.theme.typography.body.md.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: Spacing.level3),
        const AppDivider(),
        const SizedBox(height: Spacing.level4),
        if (isLoading)
          const _LoadingList()
        else if (suggestions.isEmpty)
          _EmptyView(l10n: l10n)
        else
          FTileGroup(
            divider: FItemDivider.full,
            children: [
              for (final suggestion in suggestions)
                FTile(
                  key: Key('review-suggestion-${suggestion.id}'),
                  prefix: FAvatar.raw(
                    child: Icon(_iconForType(suggestion.type), size: 18),
                  ),
                  title: Text(
                    suggestion.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    suggestion.reason,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  details: Text(_formatTime(context, suggestion.generatedAt)),
                  suffix: _SuggestionBadge(
                    lifecycleState: suggestion.lifecycleState,
                    l10n: l10n,
                  ),
                  onPress: onSuggestionTap == null
                      ? null
                      : () => onSuggestionTap!(suggestion),
                ),
            ],
          ),
      ],
    );
  }

  IconData _iconForType(TodaySuggestionType type) {
    return switch (type) {
      TodaySuggestionType.confirmedRisk => SemanticIcons.statusWarning,
      TodaySuggestionType.compliance => SemanticIcons.recordClipboard,
      TodaySuggestionType.trend => SemanticIcons.reportTrend,
      TodaySuggestionType.behaviorAdvice => SemanticIcons.aiTip,
      TodaySuggestionType.coverage => SemanticIcons.recordActivity,
    };
  }

  String _formatTime(BuildContext context, String iso8601) {
    final dateTime = DateTime.tryParse(iso8601)?.toLocal();
    if (dateTime == null) {
      return iso8601;
    }
    final locale = Localizations.localeOf(context).toLanguageTag();
    return DateFormat.Md(locale).add_Hm().format(dateTime);
  }
}

class _SuggestionBadge extends StatelessWidget {
  const _SuggestionBadge({required this.lifecycleState, required this.l10n});

  final TodaySuggestionLifecycleState lifecycleState;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final (semanticColor, label) = switch (lifecycleState) {
      TodaySuggestionLifecycleState.generated ||
      TodaySuggestionLifecycleState.active ||
      TodaySuggestionLifecycleState.fading => (
        SemanticColor.primary,
        l10n.reviewSuggestionHistoryActiveBadge,
      ),
      TodaySuggestionLifecycleState.expired => (
        SemanticColor.neutral,
        l10n.reviewSuggestionHistoryExpiredBadge,
      ),
      TodaySuggestionLifecycleState.dismissed => (
        SemanticColor.neutral,
        l10n.reviewSuggestionHistoryDismissedBadge,
      ),
    };

    final color = semanticColor.solid(context);

    return FBadge.raw(
      style: .delta(
        decoration: .shapeDelta(
          color: semanticColor.muted(context),
          shape: RoundedRectangleBorder(
            borderRadius: context.theme.style.borderRadius.pill,
          ),
        ),
      ),
      builder: (context, style) => Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.level3,
          vertical: Spacing.level1,
        ),
        child: Text(
          label,
          style: context.theme.typography.body.xs.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return Container(
      padding: const EdgeInsets.all(Spacing.level5),
      decoration: BoxDecoration(
        color: SemanticColor.neutral.subtle(context),
        borderRadius: context.theme.style.borderRadius.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            SemanticIcons.reportHistory,
            color: colors.secondary,
            size: Spacing.level5,
          ),
          const SizedBox(width: Spacing.level3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.reviewSuggestionHistoryEmptyTitle,
                  style: context.theme.typography.body.md.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: Spacing.level1),
                Text(
                  l10n.reviewSuggestionHistoryEmptyBody,
                  style: context.theme.typography.body.xs.copyWith(
                    color: SemanticColor.neutral.solid(context),
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

class _LoadingList extends StatelessWidget {
  const _LoadingList();

  @override
  Widget build(BuildContext context) {
    return const SkeletonShimmer(
      child: Column(
        children: [
          InlineSkeletonBlock(height: 72, widthFactor: 1),
          SizedBox(height: Spacing.level3),
          InlineSkeletonBlock(height: 72, widthFactor: 1),
          SizedBox(height: Spacing.level3),
          InlineSkeletonBlock(height: 72, widthFactor: 1),
        ],
      ),
    );
  }
}
