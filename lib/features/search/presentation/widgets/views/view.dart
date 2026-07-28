import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/core/widgets/layout/responsive_content_frame.dart';
import 'package:luminous/features/search/domain/entities/entities.dart';
import 'package:luminous/features/search/presentation/providers/medicine_search.dart';
import 'package:luminous/features/search/presentation/widgets/sections/categories.dart';
import 'package:luminous/features/search/presentation/widgets/sections/desktop_tabs.dart';
import 'package:luminous/features/search/presentation/widgets/sections/input.dart';
import 'package:luminous/features/search/presentation/widgets/sections/quick_actions.dart';
import 'package:luminous/features/search/presentation/widgets/sections/recent_searches.dart';
import 'package:luminous/features/search/presentation/widgets/sections/source_switch.dart';
import 'package:luminous/features/search/presentation/widgets/shared/results.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:shimmer/shimmer.dart';

final _scanQuickActions = (!kIsWeb && (Platform.isAndroid || Platform.isIOS))
    ? <MedicineSearchQuickAction>[
        const MedicineSearchQuickAction(
          type: MedicineSearchActionType.barcode,
          icon: SemanticIcons.actionScan,
          accent: SemanticColor.primary,
        ),
        const MedicineSearchQuickAction(
          type: MedicineSearchActionType.photo,
          icon: SemanticIcons.actionCamera,
          accent: SemanticColor.primary,
        ),
      ]
    : <MedicineSearchQuickAction>[];

class MedicineSearchView extends StatelessWidget {
  const MedicineSearchView({
    super.key,
    required this.state,
    required this.onQueryChanged,
    required this.onSourceSwitched,
    required this.onResultSelected,
    required this.onRetry,
    this.onAddToCurrentMedicines,
    this.addedMedicineIds = const <String>{},
  });

  final MedicineSearchState state;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<MedicineSearchSource> onSourceSwitched;
  final ValueChanged<String> onResultSelected;
  final VoidCallback onRetry;
  final void Function(MedicineSearchResult result)? onAddToCurrentMedicines;
  final Set<String> addedMedicineIds;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.theme.colors;
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= Breakpoints.desktop;

    return DecoratedBox(
      decoration: BoxDecoration(color: colors.background),
      child: SafeArea(
        child: ResponsiveContentFrame(
          expand: true,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: isDesktop ? Spacing.level5 : Spacing.level4,
              top: isDesktop ? Spacing.level5 : Spacing.level3,
            ),
            child: isDesktop
                ? _DesktopSearchLayout(
                    state: state,
                    l10n: l10n,
                    onQueryChanged: onQueryChanged,
                    onSourceSwitched: onSourceSwitched,
                    onResultSelected: onResultSelected,
                    onRetry: onRetry,
                    onAddToCurrentMedicines: onAddToCurrentMedicines,
                    addedMedicineIds: addedMedicineIds,
                  )
                : _MobileSearchLayout(
                    state: state,
                    l10n: l10n,
                    onQueryChanged: onQueryChanged,
                    onSourceSwitched: onSourceSwitched,
                    onResultSelected: onResultSelected,
                    onRetry: onRetry,
                    onAddToCurrentMedicines: onAddToCurrentMedicines,
                    addedMedicineIds: addedMedicineIds,
                  ),
          ),
        ),
      ),
    );
  }
}

class MedicineSearchLoadingView extends StatelessWidget {
  const MedicineSearchLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return Shimmer.fromColors(
      baseColor: SemanticColor.neutral.shimmerBase(context),
      highlightColor: colors.background,
      child: const Padding(
        padding: EdgeInsets.all(Spacing.level4),
        child: SingleChildScrollView(
          child: Column(
            children: [
              InlineSkeletonBlock(height: 48),
              SizedBox(height: Spacing.level4),
              InlineSkeletonBlock(height: 160),
              SizedBox(height: Spacing.level4),
              InlineSkeletonBlock(height: 160),
              SizedBox(height: Spacing.level4),
              InlineSkeletonBlock(height: 160),
            ],
          ),
        ),
      ),
    );
  }
}

class MedicineSearchErrorView extends StatelessWidget {
  const MedicineSearchErrorView({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return StateErrorView(
      title: l10n.medicineSearchErrorTitle,
      description: l10n.medicineSearchErrorDescription,
      icon: SemanticIcons.safetyCoverage,
      actionLabel: l10n.todayRetryAction,
      onAction: onRetry,
      tone: StateTone.warning,
    );
  }
}

class _MobileSearchLayout extends StatelessWidget {
  const _MobileSearchLayout({
    required this.state,
    required this.l10n,
    required this.onQueryChanged,
    required this.onSourceSwitched,
    required this.onResultSelected,
    required this.onRetry,
    this.onAddToCurrentMedicines,
    this.addedMedicineIds = const <String>{},
  });

  final MedicineSearchState state;
  final AppLocalizations l10n;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<MedicineSearchSource> onSourceSwitched;
  final ValueChanged<String> onResultSelected;
  final VoidCallback onRetry;
  final void Function(MedicineSearchResult result)? onAddToCurrentMedicines;
  final Set<String> addedMedicineIds;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    // Keep old results visible during search; only show full loading on first search.
    if (state.isSearching && state.results.isEmpty) {
      return const MedicineSearchLoadingView();
    }

    if (state.errorMessage != null && state.results.isEmpty) {
      return MedicineSearchErrorView(onRetry: onRetry);
    }

    return ListView(
      key: const PageStorageKey<String>('medicine-search-scroll'),
      padding: const EdgeInsets.only(bottom: Spacing.level6),
      children: [
        SearchInput(l10n: l10n, query: state.query, onChanged: onQueryChanged),
        if (state.isSearching)
          const Padding(
            padding: EdgeInsets.only(top: Spacing.level2),
            child: LinearProgressIndicator(),
          ),
        const SizedBox(height: Spacing.level4),
        SourceSwitch(
          selectedSource: state.source,
          l10n: l10n,
          onChanged: onSourceSwitched,
        ),
        const SizedBox(height: Spacing.level5),
        if (state.query.trim().isEmpty) ...[
          RecentSearches(
            keywords: const <String>[],
            l10n: l10n,
            onKeywordSelected: onQueryChanged,
          ),
          QuickActions(actions: _scanQuickActions, l10n: l10n),
          Categories(
            categories: const <MedicineSearchCategory>[],
            l10n: l10n,
            onCategorySelected: (category) =>
                onQueryChanged(categoryLabel(l10n, category.type)),
          ),
        ],
        if (state.query.trim().isNotEmpty) ...[
          Text(
            l10n.medicineSearchResultCount(state.results.length),
            style: TypographyToken.level5
                .body(context)
                .copyWith(color: colors.mutedForeground),
          ),
          const SizedBox(height: Spacing.level4),
          ...state.results.map(
            (result) => Padding(
              padding: const EdgeInsets.only(bottom: Spacing.level4),
              child: SearchResultTile(
                result: result,
                l10n: l10n,
                expandedAction: true,
                alreadyAdded: addedMedicineIds.contains(
                  '${result.source.name}:${result.id}',
                ),
                onAddToCurrentMedicines: onAddToCurrentMedicines != null
                    ? () => onAddToCurrentMedicines!(result)
                    : null,
              ),
            ),
          ),
          if (state.results.isEmpty)
            NoResultTools(
              l10n: l10n,
              onClearQuery: () => onQueryChanged(''),
              onSwitchSource: () => onSourceSwitched(
                state.source == MedicineSearchSource.cn
                    ? MedicineSearchSource.drugbank
                    : MedicineSearchSource.cn,
              ),
            ),
        ],
      ],
    );
  }
}

class _DesktopSearchLayout extends StatelessWidget {
  const _DesktopSearchLayout({
    required this.state,
    required this.l10n,
    required this.onQueryChanged,
    required this.onSourceSwitched,
    required this.onResultSelected,
    required this.onRetry,
    this.onAddToCurrentMedicines,
    this.addedMedicineIds = const <String>{},
  });

  final MedicineSearchState state;
  final AppLocalizations l10n;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<MedicineSearchSource> onSourceSwitched;
  final ValueChanged<String> onResultSelected;
  final VoidCallback onRetry;
  final void Function(MedicineSearchResult result)? onAddToCurrentMedicines;
  final Set<String> addedMedicineIds;

  @override
  Widget build(BuildContext context) {
    if (state.isSearching && state.results.isEmpty) {
      return const MedicineSearchLoadingView();
    }

    if (state.errorMessage != null && state.results.isEmpty) {
      return MedicineSearchErrorView(onRetry: onRetry);
    }

    return Row(
      children: [
        Expanded(
          flex: 7,
          child: _DesktopSearchPanel(
            state: state,
            l10n: l10n,
            onQueryChanged: onQueryChanged,
            onSourceSwitched: onSourceSwitched,
            onResultSelected: onResultSelected,
            onAddToCurrentMedicines: onAddToCurrentMedicines,
            addedMedicineIds: addedMedicineIds,
          ),
        ),
        const SizedBox(width: Spacing.level5),
        Expanded(
          flex: 3,
          child: PreviewPanel(state: state, l10n: l10n),
        ),
      ],
    );
  }
}

class _DesktopSearchPanel extends StatelessWidget {
  const _DesktopSearchPanel({
    required this.state,
    required this.l10n,
    required this.onQueryChanged,
    required this.onSourceSwitched,
    required this.onResultSelected,
    this.onAddToCurrentMedicines,
    this.addedMedicineIds = const <String>{},
  });

  final MedicineSearchState state;
  final AppLocalizations l10n;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<MedicineSearchSource> onSourceSwitched;
  final ValueChanged<String> onResultSelected;
  final void Function(MedicineSearchResult result)? onAddToCurrentMedicines;
  final Set<String> addedMedicineIds;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return FCard(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.level6),
        child: ListView(
          children: [
            DesktopTabs(l10n: l10n),
            const SizedBox(height: Spacing.level6),
            Text(
              l10n.medicineSearchPageTitle,
              style: TypographyToken.level8
                  .display(context)
                  .copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: Spacing.level4),
            SearchInput(
              l10n: l10n,
              query: state.query,
              onChanged: onQueryChanged,
            ),
            const SizedBox(height: Spacing.level4),
            SourceSwitch(
              selectedSource: state.source,
              l10n: l10n,
              onChanged: onSourceSwitched,
            ),
            const SizedBox(height: Spacing.level5),
            if (state.query.trim().isEmpty) ...[
              RecentSearches(keywords: const <String>[], l10n: l10n),
              QuickActions(
                actions: const <MedicineSearchQuickAction>[],
                l10n: l10n,
              ),
              Categories(
                categories: const <MedicineSearchCategory>[],
                l10n: l10n,
              ),
            ],
            if (state.query.trim().isNotEmpty) ...[
              Text(
                l10n.medicineSearchResultCount(state.results.length),
                style: TypographyToken.level5
                    .body(context)
                    .copyWith(color: colors.mutedForeground),
              ),
              const SizedBox(height: Spacing.level4),
              ...state.results.map(
                (result) => Padding(
                  padding: const EdgeInsets.only(bottom: Spacing.level4),
                  child: SearchResultTile(
                    result: result,
                    l10n: l10n,
                    onTap: () => onResultSelected(result.id),
                    alreadyAdded: addedMedicineIds.contains(
                      '${result.source.name}:${result.id}',
                    ),
                    onAddToCurrentMedicines: onAddToCurrentMedicines != null
                        ? () => onAddToCurrentMedicines!(result)
                        : null,
                  ),
                ),
              ),
              if (state.results.isEmpty)
                NoResultTools(
                  l10n: l10n,
                  onClearQuery: () => onQueryChanged(''),
                  onSwitchSource: () => onSourceSwitched(
                    state.source == MedicineSearchSource.cn
                        ? MedicineSearchSource.drugbank
                        : MedicineSearchSource.cn,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
