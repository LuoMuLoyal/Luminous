import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/today/domain/entities/dashboard.dart';
import 'package:luminous/features/today/domain/entities/suggestion.dart';
import 'package:luminous/features/today/presentation/providers/suggestion.dart';
import 'package:luminous/features/today/presentation/widgets/sections/suggestion_primary_card.dart';
import 'package:luminous/features/today/presentation/widgets/sections/suggestion_state_views.dart';
import 'package:luminous/features/today/presentation/widgets/shared/card_style.dart';
import 'package:luminous/features/today/presentation/widgets/shared/components.dart';
import 'package:luminous/features/today/presentation/widgets/shared/section.dart';
import 'package:luminous/features/today/presentation/widgets/shared/suggestion_icon_mapping.dart';
import 'package:luminous/features/today/presentation/widgets/shared/view_models.dart';
import 'package:luminous/l10n/app_localizations.dart';

class TodayPrimarySuggestionSection extends ConsumerWidget {
  const TodayPrimarySuggestionSection({super.key, this.dashboard});

  /// Used for the water progress bar when the primary card's
  /// `subtype == 'water'`.
  final TodayDashboard? dashboard;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final suggestionAsync = ref.watch(todaySuggestionProvider);

    return TodaySection(
      title: l10n.todayPrimarySuggestionSectionTitle,
      child: suggestionAsync.when(
        data: (bundle) {
          final status =
              bundle?.materializationStatus ??
              TodaySuggestionMaterializationStatus.ready;
          final card = status == TodaySuggestionMaterializationStatus.empty
              ? null
              : bundle?.primary;
          if (card == null) {
            if (status == TodaySuggestionMaterializationStatus.pending) {
              return SuggestionMaterializationNotice(
                status: status,
                computedAt: bundle?.computedAt,
                l10n: l10n,
              );
            }
            if (status == TodaySuggestionMaterializationStatus.failed) {
              return SuggestionErrorState(
                l10n: l10n,
                onRetry: () =>
                    ref.read(todaySuggestionProvider.notifier).refresh(),
              );
            }
            return SuggestionEmptyState(l10n: l10n);
          }
          return Column(
            children: [
              SuggestionPrimaryCard(card: card, dashboard: dashboard),
              if (status != TodaySuggestionMaterializationStatus.ready)
                SuggestionMaterializationNotice(
                  status: status,
                  computedAt: bundle?.computedAt,
                  l10n: l10n,
                  onRetry: status == TodaySuggestionMaterializationStatus.failed
                      ? () =>
                            ref.read(todaySuggestionProvider.notifier).refresh()
                      : null,
                ),
            ],
          );
        },
        loading: () => const SuggestionSkeleton(),
        error: (_, __) => SuggestionErrorState(
          l10n: l10n,
          onRetry: () => ref.invalidate(todaySuggestionProvider),
        ),
      ),
    );
  }
}

class TodaySecondarySuggestionsSection extends ConsumerWidget {
  const TodaySecondarySuggestionsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final suggestionAsync = ref.watch(todaySuggestionProvider);

    return suggestionAsync.when(
      data: (bundle) {
        final items = bundle?.secondary ?? const [];
        if (items.isEmpty) return const SizedBox.shrink();

        final visible = items.take(2).toList();
        return TodaySection(
          title: l10n.todaySecondarySuggestionSectionTitle,
          child: Column(
            children: [
              for (var index = 0; index < visible.length; index += 1) ...[
                if (index > 0) const SizedBox(height: Spacing.level3),
                FCard(
                  key: Key('today-secondary-suggestion-$index'),
                  style: todayCardStyle(context, tone: TodayCardTone.soft),
                  child: FTappable(
                    onPress: () =>
                        openRoute(context, visible[index].primaryAction.route),
                    child: Padding(
                      padding: const EdgeInsets.all(Spacing.level4),
                      child: Row(
                        children: [
                          TodayGlyphTile(
                            icon: SuggestionIconMapping.resolve(
                              visible[index].icon,
                            ),
                            color: colorFor(visible[index].cardTone),
                            size: IconSizeTokens.level5,
                            radius:
                                context.theme.style.borderRadius.sm.topLeft.x,
                          ),
                          const SizedBox(width: Spacing.level3),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  visible[index].title,
                                  style: context.theme.typography.body.md
                                      .copyWith(fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: Spacing.level1),
                                Text(
                                  visible[index].reason,
                                  style: context.theme.typography.body.xs
                                      .copyWith(
                                        color: SemanticColor.neutral.solid(
                                          context,
                                        ),
                                      ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: Spacing.level2),
                          Icon(
                            SemanticIcons.actionNext,
                            size: IconSizeTokens.level2,
                            color: SemanticColor.neutral.solid(context),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
      loading: () => const SecondarySuggestionSkeleton(),
      error: (_, __) => SecondarySuggestionErrorState(
        onRetry: () => ref.invalidate(todaySuggestionProvider),
      ),
    );
  }
}
