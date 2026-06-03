import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/constants/app_breakpoints.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/feedback/app_toast.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/core/widgets/responsive_content_frame.dart';
import 'package:shimmer/shimmer.dart';
import 'package:luminous/core/widgets/app_state_views.dart';
import 'package:luminous/features/search/domain/entities/search_entities.dart';
import 'package:luminous/features/search/presentation/providers/search_provider.dart';
import 'package:luminous/l10n/app_localizations.dart';

part 'search_parts.dart';

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
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final surface = theme.extension<AppThemeSurface>()!;
    final width = MediaQuery.sizeOf(context).width;
    final typography = width < AppBreakpoints.mobile
        ? AppTypographyTokens.mobile(scheme.onSurface)
        : AppTypographyTokens.desktop(scheme.onSurface);
    final isDesktop = width >= AppBreakpoints.desktop;

    return DecoratedBox(
      decoration: BoxDecoration(color: surface.canvasSoft),
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
                    typography: typography,
                    surface: surface,
                    onQueryChanged: onQueryChanged,
                    onSourceSwitched: onSourceSwitched,
                    onResultSelected: onResultSelected,
                    onRetry: onRetry,
                    onAddToCurrentMedicines: onAddToCurrentMedicines,
                  )
                : _MobileSearchLayout(
                    state: state,
                    l10n: l10n,
                    typography: typography,
                    surface: surface,
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
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;

    return Shimmer.fromColors(
      baseColor: surface.canvas.withValues(
        alpha: theme.brightness == Brightness.dark ? 0.42 : 1,
      ),
      highlightColor: surface.canvasSoft2,
      child: const Padding(
        padding: EdgeInsets.all(AppSpacingTokens.md),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _SkeletonBlock(height: 48),
              SizedBox(height: AppSpacingTokens.md),
              _SkeletonBlock(height: 160),
              SizedBox(height: AppSpacingTokens.md),
              _SkeletonBlock(height: 160),
              SizedBox(height: AppSpacingTokens.md),
              _SkeletonBlock(height: 160),
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
      icon: Icons.search_off_rounded,
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
    required this.typography,
    required this.surface,
    required this.onQueryChanged,
    required this.onSourceSwitched,
    required this.onResultSelected,
    required this.onRetry,
    this.onAddToCurrentMedicines,
  });

  final MedicineSearchState state;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
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

    return ListView(
      key: const PageStorageKey<String>('medicine-search-scroll'),
      padding: const EdgeInsets.only(bottom: AppSpacingTokens.xl),
      children: [
        _SearchTopBar(l10n: l10n, typography: typography, surface: surface),
        const SizedBox(height: AppSpacingTokens.lg),
        _SearchInput(
          l10n: l10n,
          typography: typography,
          surface: surface,
          query: state.query,
          onChanged: onQueryChanged,
        ),
        const SizedBox(height: AppSpacingTokens.md),
        _SourceSwitch(
          selectedSource: state.source,
          l10n: l10n,
          typography: typography,
          surface: surface,
          onChanged: onSourceSwitched,
        ),
        const SizedBox(height: AppSpacingTokens.lg),
        if (state.query.trim().isEmpty) ...[
          _RecentSearches(
            keywords: const <String>[],
            l10n: l10n,
            typography: typography,
            surface: surface,
          ),
          const SizedBox(height: AppSpacingTokens.lg),
          _QuickActions(
            actions: const <MedicineSearchQuickAction>[],
            l10n: l10n,
            typography: typography,
            surface: surface,
          ),
          const SizedBox(height: AppSpacingTokens.xl),
          _Categories(
            categories: const <MedicineSearchCategory>[],
            l10n: l10n,
            typography: typography,
          ),
        ],
        if (state.query.trim().isNotEmpty) ...[
          Text(
            l10n.medicineSearchResultCount(state.results.length),
            style: typography.bodySmStrong.copyWith(color: surface.mute),
          ),
          const SizedBox(height: AppSpacingTokens.md),
          ...state.results.map(
            (result) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacingTokens.md),
              child: _SearchResultTile(
                result: result,
                l10n: l10n,
                typography: typography,
                surface: surface,
                expandedAction: true,
                onTap: () => onResultSelected(result.id),
                onAddToCurrentMedicines:
                    onAddToCurrentMedicines != null
                        ? () => onAddToCurrentMedicines!(result)
                        : null,
              ),
            ),
          ),
          if (state.results.isEmpty)
            _NoResultTools(l10n: l10n, typography: typography, surface: surface),
        ],
      ],
    );
  }
}

class _DesktopSearchLayout extends StatelessWidget {
  const _DesktopSearchLayout({
    required this.state,
    required this.l10n,
    required this.typography,
    required this.surface,
    required this.onQueryChanged,
    required this.onSourceSwitched,
    required this.onResultSelected,
    required this.onRetry,
    this.onAddToCurrentMedicines,
  });

  final MedicineSearchState state;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
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
            typography: typography,
            surface: surface,
            onQueryChanged: onQueryChanged,
            onSourceSwitched: onSourceSwitched,
            onResultSelected: onResultSelected,
            onRetry: onRetry,
            onAddToCurrentMedicines: onAddToCurrentMedicines,
          ),
        ),
        const SizedBox(width: AppSpacingTokens.lg),
        Expanded(
          flex: 3,
          child: _PreviewPanel(
            state: state,
            l10n: l10n,
            typography: typography,
            surface: surface,
          ),
        ),
      ],
    );
  }
}

class _DesktopSearchPanel extends StatelessWidget {
  const _DesktopSearchPanel({
    required this.state,
    required this.l10n,
    required this.typography,
    required this.surface,
    required this.onQueryChanged,
    required this.onSourceSwitched,
    required this.onResultSelected,
    required this.onRetry,
    this.onAddToCurrentMedicines,
  });

  final MedicineSearchState state;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<MedicineSearchSource> onSourceSwitched;
  final ValueChanged<String> onResultSelected;
  final VoidCallback onRetry;
  final void Function(MedicineSearchResult result)? onAddToCurrentMedicines;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: _panelDecoration(surface),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacingTokens.xl),
        child: ListView(
          children: [
            _DesktopTabs(l10n: l10n, typography: typography, surface: surface),
            const SizedBox(height: AppSpacingTokens.xl),
            Text(l10n.medicineSearchPageTitle, style: typography.displaySm),
            const SizedBox(height: AppSpacingTokens.md),
            _SearchInput(
              l10n: l10n,
              typography: typography,
              surface: surface,
              query: state.query,
              onChanged: onQueryChanged,
            ),
            const SizedBox(height: AppSpacingTokens.md),
            _SourceSwitch(
              selectedSource: state.source,
              l10n: l10n,
              typography: typography,
              surface: surface,
              onChanged: onSourceSwitched,
            ),
            const SizedBox(height: AppSpacingTokens.lg),
            if (state.query.trim().isEmpty) ...[
              _RecentSearches(
                keywords: const <String>[],
                l10n: l10n,
                typography: typography,
                surface: surface,
              ),
              const SizedBox(height: AppSpacingTokens.lg),
              _QuickActions(
                actions: const <MedicineSearchQuickAction>[],
                l10n: l10n,
                typography: typography,
                surface: surface,
              ),
              const SizedBox(height: AppSpacingTokens.xl),
              _Categories(
                categories: const <MedicineSearchCategory>[],
                l10n: l10n,
                typography: typography,
              ),
            ],
            if (state.query.trim().isNotEmpty) ...[
              Text(
                l10n.medicineSearchResultCount(state.results.length),
                style: typography.bodySmStrong.copyWith(color: surface.mute),
              ),
              const SizedBox(height: AppSpacingTokens.md),
              ...state.results.map(
                (result) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacingTokens.md),
                  child: _SearchResultTile(
                    result: result,
                    l10n: l10n,
                    typography: typography,
                    surface: surface,
                    onTap: () => onResultSelected(result.id),
                    onAddToCurrentMedicines:
                        onAddToCurrentMedicines != null
                            ? () => onAddToCurrentMedicines!(result)
                            : null,
                  ),
                ),
              ),
              if (state.results.isEmpty)
                _NoResultTools(l10n: l10n, typography: typography, surface: surface),
            ],
          ],
        ),
      ),
    );
  }
}

class _SkeletonBlock extends StatelessWidget {
  const _SkeletonBlock({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).extension<AppThemeSurface>()!;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: surface.canvas,
        borderRadius: BorderRadius.circular(AppRadiusTokens.xl),
      ),
      child: SizedBox(height: height, width: double.infinity),
    );
  }
}
