import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/core/widgets/layout/responsive_content_frame.dart';
import 'package:shimmer/shimmer.dart';
import 'package:luminous/features/search/domain/entities/entities.dart';
import 'package:luminous/features/search/presentation/providers/medicine_search.dart';
import 'package:luminous/features/search/presentation/widgets/shared/header_widgets.dart';
import 'package:luminous/features/search/presentation/widgets/shared/result_widgets.dart';
import 'package:luminous/l10n/app_localizations.dart';

final _scanQuickActions = (!kIsWeb && (Platform.isAndroid || Platform.isIOS))
    ? <MedicineSearchQuickAction>[
        const MedicineSearchQuickAction(
          type: MedicineSearchActionType.barcode,
          icon: FLucideIcons.scanLine,
          accent: SemanticColor.primary,
        ),
        const MedicineSearchQuickAction(
          type: MedicineSearchActionType.photo,
          icon: FLucideIcons.camera,
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
  });

  final MedicineSearchState state;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<MedicineSearchSource> onSourceSwitched;
  final ValueChanged<String> onResultSelected;
  final VoidCallback onRetry;
  final void Function(MedicineSearchResult result)? onAddToCurrentMedicines;

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
            padding: EdgeInsets.symmetric(
              vertical: isDesktop ? Spacing.level5 : Spacing.level4,
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
                  )
                : _MobileSearchLayout(
                    state: state,
                    l10n: l10n,
                    onQueryChanged: onQueryChanged,
                    onSourceSwitched: onSourceSwitched,
                    onResultSelected: onResultSelected,
                    onRetry: onRetry,
                    onAddToCurrentMedicines: onAddToCurrentMedicines,
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
      baseColor: SemanticColor.neutral.muted(context).withValues(alpha: 0.35),
      highlightColor: colors.background,
      child: const Padding(
        padding: EdgeInsets.all(Spacing.level4),
        child: SingleChildScrollView(
          child: Column(
            children: [
              AppInlineSkeletonBlock(height: 48),
              SizedBox(height: Spacing.level4),
              AppInlineSkeletonBlock(height: 160),
              SizedBox(height: Spacing.level4),
              AppInlineSkeletonBlock(height: 160),
              SizedBox(height: Spacing.level4),
              AppInlineSkeletonBlock(height: 160),
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

    return AppStateErrorView(
      title: l10n.medicineSearchErrorTitle,
      description: l10n.medicineSearchErrorDescription,
      icon: FLucideIcons.searchX,
      actionLabel: l10n.todayRetryAction,
      onAction: onRetry,
      tone: AppStateTone.warning,
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
  });

  final MedicineSearchState state;
  final AppLocalizations l10n;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<MedicineSearchSource> onSourceSwitched;
  final ValueChanged<String> onResultSelected;
  final VoidCallback onRetry;
  final void Function(MedicineSearchResult result)? onAddToCurrentMedicines;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    if (state.isSearching) {
      return const MedicineSearchLoadingView();
    }

    if (state.errorMessage != null) {
      return MedicineSearchErrorView(onRetry: onRetry);
    }

    return ListView(
      key: const PageStorageKey<String>('medicine-search-scroll'),
      padding: const EdgeInsets.only(bottom: Spacing.level6),
      children: [
        SearchInput(l10n: l10n, query: state.query, onChanged: onQueryChanged),
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
          const SizedBox(height: Spacing.level5),
          QuickActions(actions: _scanQuickActions, l10n: l10n),
          const SizedBox(height: Spacing.level6),
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
                onTap: () => onResultSelected(result.id),
                onAddToCurrentMedicines: onAddToCurrentMedicines != null
                    ? () => onAddToCurrentMedicines!(result)
                    : null,
              ),
            ),
          ),
          if (state.results.isEmpty) NoResultTools(l10n: l10n),
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
  });

  final MedicineSearchState state;
  final AppLocalizations l10n;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<MedicineSearchSource> onSourceSwitched;
  final ValueChanged<String> onResultSelected;
  final VoidCallback onRetry;
  final void Function(MedicineSearchResult result)? onAddToCurrentMedicines;

  @override
  Widget build(BuildContext context) {
    if (state.isSearching) {
      return const MedicineSearchLoadingView();
    }

    if (state.errorMessage != null) {
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
  });

  final MedicineSearchState state;
  final AppLocalizations l10n;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<MedicineSearchSource> onSourceSwitched;
  final ValueChanged<String> onResultSelected;
  final void Function(MedicineSearchResult result)? onAddToCurrentMedicines;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return FCard.raw(
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
              const SizedBox(height: Spacing.level5),
              QuickActions(
                actions: const <MedicineSearchQuickAction>[],
                l10n: l10n,
              ),
              const SizedBox(height: Spacing.level6),
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
                    onAddToCurrentMedicines: onAddToCurrentMedicines != null
                        ? () => onAddToCurrentMedicines!(result)
                        : null,
                  ),
                ),
              ),
              if (state.results.isEmpty) NoResultTools(l10n: l10n),
            ],
          ],
        ),
      ),
    );
  }
}
