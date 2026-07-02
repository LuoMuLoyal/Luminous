import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/app_breakpoints.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/widgets/common/app_state_views.dart';
import 'package:luminous/core/widgets/layout/responsive_content_frame.dart';
import 'package:shimmer/shimmer.dart';
import 'package:luminous/features/search/domain/entities/search_entities.dart';
import 'package:luminous/features/search/presentation/providers/search_provider.dart';
import 'package:luminous/features/search/presentation/widgets/search_header_widgets.dart';
import 'package:luminous/features/search/presentation/widgets/shared/search_result_widgets.dart';
import 'package:luminous/l10n/app_localizations.dart';

final _scanQuickActions = (!kIsWeb && (Platform.isAndroid || Platform.isIOS))
    ? <MedicineSearchQuickAction>[
        const MedicineSearchQuickAction(
          type: MedicineSearchActionType.barcode,
          icon: FLucideIcons.scanLine,
          accent: AppColorTokens.cyanDeep,
        ),
        const MedicineSearchQuickAction(
          type: MedicineSearchActionType.photo,
          icon: FLucideIcons.camera,
          accent: AppColorTokens.gradientDevelopStart,
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
    final isDesktop = width >= AppBreakpoints.desktop;

    return DecoratedBox(
      decoration: BoxDecoration(color: colors.background),
      child: SafeArea(
        child: ResponsiveContentFrame(
          expand: true,
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: isDesktop ? AppSpacingTokens.lg : AppSpacingTokens.md,
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
      baseColor: colors.secondary.withValues(alpha: 0.35),
      highlightColor: colors.background,
      child: const Padding(
        padding: EdgeInsets.all(AppSpacingTokens.md),
        child: SingleChildScrollView(
          child: Column(
            children: [
              AppInlineSkeletonBlock(height: 48),
              SizedBox(height: AppSpacingTokens.md),
              AppInlineSkeletonBlock(height: 160),
              SizedBox(height: AppSpacingTokens.md),
              AppInlineSkeletonBlock(height: 160),
              SizedBox(height: AppSpacingTokens.md),
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
    final textTheme = Theme.of(context).textTheme;

    if (state.isSearching) {
      return const MedicineSearchLoadingView();
    }

    if (state.errorMessage != null) {
      return MedicineSearchErrorView(onRetry: onRetry);
    }

    return ListView(
      key: const PageStorageKey<String>('medicine-search-scroll'),
      padding: const EdgeInsets.only(bottom: AppSpacingTokens.xl),
      children: [
        SearchTopBar(l10n: l10n),
        const SizedBox(height: AppSpacingTokens.lg),
        SearchInput(l10n: l10n, query: state.query, onChanged: onQueryChanged),
        const SizedBox(height: AppSpacingTokens.md),
        SourceSwitch(
          selectedSource: state.source,
          l10n: l10n,
          onChanged: onSourceSwitched,
        ),
        const SizedBox(height: AppSpacingTokens.lg),
        if (state.query.trim().isEmpty) ...[
          RecentSearches(
            keywords: const <String>[],
            l10n: l10n,
            onKeywordSelected: onQueryChanged,
          ),
          const SizedBox(height: AppSpacingTokens.lg),
          QuickActions(actions: _scanQuickActions, l10n: l10n),
          const SizedBox(height: AppSpacingTokens.xl),
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
            style: textTheme.labelLarge?.copyWith(
              color: colors.mutedForeground,
            ),
          ),
          const SizedBox(height: AppSpacingTokens.md),
          ...state.results.map(
            (result) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacingTokens.md),
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
        const SizedBox(width: AppSpacingTokens.lg),
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
    final textTheme = Theme.of(context).textTheme;

    return FCard.raw(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacingTokens.xl),
        child: ListView(
          children: [
            DesktopTabs(l10n: l10n),
            const SizedBox(height: AppSpacingTokens.xl),
            Text(
              l10n.medicineSearchPageTitle,
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacingTokens.md),
            SearchInput(
              l10n: l10n,
              query: state.query,
              onChanged: onQueryChanged,
            ),
            const SizedBox(height: AppSpacingTokens.md),
            SourceSwitch(
              selectedSource: state.source,
              l10n: l10n,
              onChanged: onSourceSwitched,
            ),
            const SizedBox(height: AppSpacingTokens.lg),
            if (state.query.trim().isEmpty) ...[
              RecentSearches(keywords: const <String>[], l10n: l10n),
              const SizedBox(height: AppSpacingTokens.lg),
              QuickActions(
                actions: const <MedicineSearchQuickAction>[],
                l10n: l10n,
              ),
              const SizedBox(height: AppSpacingTokens.xl),
              Categories(
                categories: const <MedicineSearchCategory>[],
                l10n: l10n,
              ),
            ],
            if (state.query.trim().isNotEmpty) ...[
              Text(
                l10n.medicineSearchResultCount(state.results.length),
                style: textTheme.labelLarge?.copyWith(
                  color: colors.mutedForeground,
                ),
              ),
              const SizedBox(height: AppSpacingTokens.md),
              ...state.results.map(
                (result) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacingTokens.md),
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
