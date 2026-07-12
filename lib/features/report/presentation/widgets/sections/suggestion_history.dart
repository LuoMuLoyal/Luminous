import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:intl/intl.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/divider.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/features/today/domain/entities/suggestion.dart';
import 'package:luminous/l10n/app_localizations.dart';

class ReportSuggestionHistorySection extends StatelessWidget {
  const ReportSuggestionHistorySection({
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
      key: const Key('report-suggestion-history-section'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.reportSuggestionHistorySectionTitle,
          style: TypographyToken.level5
              .body(context)
              .copyWith(fontWeight: FontWeight.w700),
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
                  key: Key('report-suggestion-${suggestion.id}'),
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
      TodaySuggestionType.confirmedRisk => FLucideIcons.triangleAlert,
      TodaySuggestionType.compliance => FLucideIcons.clipboardList,
      TodaySuggestionType.trend => FLucideIcons.trendingUp,
      TodaySuggestionType.behaviorAdvice => FLucideIcons.lightbulb,
      TodaySuggestionType.coverage => FLucideIcons.activity,
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
        l10n.reportSuggestionHistoryActiveBadge,
      ),
      TodaySuggestionLifecycleState.expired => (
        SemanticColor.neutral,
        l10n.reportSuggestionHistoryExpiredBadge,
      ),
      TodaySuggestionLifecycleState.dismissed => (
        SemanticColor.neutral,
        l10n.reportSuggestionHistoryDismissedBadge,
      ),
    };

    final color = semanticColor.solid(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: semanticColor.muted(context),
        borderRadius: BorderRadius.circular(RadiusTokens.levelFull),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.level3,
          vertical: Spacing.level1,
        ),
        child: Text(
          label,
          style: TypographyToken.level3
              .body(context)
              .copyWith(color: color, fontWeight: FontWeight.w700),
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
        borderRadius: BorderRadius.circular(RadiusTokens.level3),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            FLucideIcons.history,
            color: colors.secondary,
            size: Spacing.level5,
          ),
          const SizedBox(width: Spacing.level3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.reportSuggestionHistoryEmptyTitle,
                  style: TypographyToken.level5
                      .body(context)
                      .copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: Spacing.level1),
                Text(
                  l10n.reportSuggestionHistoryEmptyBody,
                  style: TypographyToken.level3
                      .body(context)
                      .copyWith(color: colors.mutedForeground),
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
    return const AppSkeletonShimmer(
      child: Column(
        children: [
          AppInlineSkeletonBlock(height: 72, widthFactor: 1),
          SizedBox(height: Spacing.level3),
          AppInlineSkeletonBlock(height: 72, widthFactor: 1),
          SizedBox(height: Spacing.level3),
          AppInlineSkeletonBlock(height: 72, widthFactor: 1),
        ],
      ),
    );
  }
}
