import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/core/widgets/layout/responsive_content_frame.dart';
import 'package:luminous/features/search/domain/entities/entities.dart';
import 'package:luminous/features/search/presentation/providers/medicine_search.dart';
import 'package:luminous/features/search/presentation/providers/recent_searches.dart';
import 'package:luminous/features/search/presentation/widgets/sections/categories.dart';
import 'package:luminous/features/search/presentation/widgets/sections/desktop_tabs.dart';
import 'package:luminous/features/search/presentation/widgets/sections/input.dart';
import 'package:luminous/features/search/presentation/widgets/sections/quick_actions.dart';
import 'package:luminous/features/search/presentation/widgets/sections/recent_searches.dart';
import 'package:luminous/features/search/presentation/widgets/sections/source_switch.dart';
import 'package:luminous/features/search/presentation/widgets/shared/results.dart';
// shell 的详情面板是**共享外壳基础设施**（`lib/features/shell/presentation/` 在
// `cross_feature_import` 里对 presentation 例外开放）：桌面上同一份详情要能并排
// 展开，而不是每个列表页各自造一个「预览」面板。用药页药盒已经在用它。
import 'package:luminous/features/shell/presentation/detail_pane.dart';
import 'package:luminous/features/shell/presentation/detail_pane_state.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:shimmer/shimmer.dart';

final _scanQuickActions = (!kIsWeb && (Platform.isAndroid || Platform.isIOS))
    ? <MedicineSearchQuickAction>[
        const MedicineSearchQuickAction(type: MedicineSearchActionType.barcode),
        const MedicineSearchQuickAction(type: MedicineSearchActionType.photo),
      ]
    : <MedicineSearchQuickAction>[];

class MedicineSearchView extends ConsumerWidget {
  const MedicineSearchView({
    super.key,
    required this.state,
    required this.onQueryChanged,
    required this.onQuerySubmitted,
    required this.onSourceSwitched,
    required this.onResultSelected,
    required this.onRetry,
    this.onAddToCurrentMedicines,
    this.addedMedicineIds = const <String>{},
  });

  final MedicineSearchState state;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<String> onQuerySubmitted;
  final ValueChanged<MedicineSearchSource> onSourceSwitched;
  final ValueChanged<String> onResultSelected;
  final VoidCallback onRetry;
  final void Function(MedicineSearchResult result)? onAddToCurrentMedicines;
  final Set<String> addedMedicineIds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.theme.colors;
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= Breakpoints.desktop;

    // F-12: persisted recent search keywords (latest first), rendered on the
    // empty-query state so previously searched keywords are one tap away.
    final recentKeywords =
        ref.watch(recentSearchesProvider).asData?.value ?? const <String>[];
    return DecoratedBox(
      decoration: BoxDecoration(color: colors.background),
      child: SafeArea(
        child: ResponsiveContentFrame(
          expand: true,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: isDesktop ? Spacing.xl : Spacing.lg,
              top: isDesktop ? Spacing.xl : Spacing.md,
            ),
            child: isDesktop
                ? _DesktopSearchLayout(
                    state: state,
                    l10n: l10n,
                    recentKeywords: recentKeywords,
                    onClearRecentSearches: () =>
                        ref.read(recentSearchesProvider.notifier).clearAll(),
                    onQueryChanged: onQueryChanged,
                    onQuerySubmitted: onQuerySubmitted,
                    onSourceSwitched: onSourceSwitched,
                    onResultSelected: onResultSelected,
                    onRetry: onRetry,
                    onAddToCurrentMedicines: onAddToCurrentMedicines,
                    addedMedicineIds: addedMedicineIds,
                  )
                : _MobileSearchLayout(
                    state: state,
                    l10n: l10n,
                    recentKeywords: recentKeywords,
                    onClearRecentSearches: () =>
                        ref.read(recentSearchesProvider.notifier).clearAll(),
                    onQueryChanged: onQueryChanged,
                    onQuerySubmitted: onQuerySubmitted,
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
        padding: EdgeInsets.all(Spacing.lg),
        child: SingleChildScrollView(
          child: Column(
            children: [
              InlineSkeletonBlock(height: 48),
              SizedBox(height: Spacing.lg),
              InlineSkeletonBlock(height: 160),
              SizedBox(height: Spacing.lg),
              InlineSkeletonBlock(height: 160),
              SizedBox(height: Spacing.lg),
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
    required this.recentKeywords,
    required this.onClearRecentSearches,
    required this.onQueryChanged,
    required this.onQuerySubmitted,
    required this.onSourceSwitched,
    required this.onResultSelected,
    required this.onRetry,
    this.onAddToCurrentMedicines,
    this.addedMedicineIds = const <String>{},
  });

  final MedicineSearchState state;
  final AppLocalizations l10n;
  final List<String> recentKeywords;
  final VoidCallback onClearRecentSearches;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<String> onQuerySubmitted;
  final ValueChanged<MedicineSearchSource> onSourceSwitched;
  final ValueChanged<String> onResultSelected;
  final VoidCallback onRetry;
  final void Function(MedicineSearchResult result)? onAddToCurrentMedicines;
  final Set<String> addedMedicineIds;

  @override
  Widget build(BuildContext context) {
    // Keep old results visible during search; only show full loading on first search.
    if (state.isSearching && state.results.isEmpty) {
      return const MedicineSearchLoadingView();
    }

    if (state.errorMessage != null && state.results.isEmpty) {
      return MedicineSearchErrorView(onRetry: onRetry);
    }

    return ListView(
      key: const PageStorageKey<String>('medicine-search-scroll'),
      padding: const EdgeInsets.only(bottom: Spacing.xl2),
      children: [
        SearchInput(
          l10n: l10n,
          query: state.query,
          onChanged: onQueryChanged,
          onSubmitted: onQuerySubmitted,
        ),
        if (state.isSearching)
          // 搜索为不确定时长，用 Forui 的循环指示器而不是 Material 的
          // LinearProgressIndicator（后者是无限循环条，属 Material 残留）。
          const Padding(
            padding: EdgeInsets.only(top: Spacing.sm),
            child: Center(
              child: FCircularProgress.loader(
                size: FCircularProgressSizeVariant.sm,
              ),
            ),
          ),
        const SizedBox(height: Spacing.lg),
        SourceSwitch(
          selectedSource: state.source,
          l10n: l10n,
          onChanged: onSourceSwitched,
        ),
        const SizedBox(height: Spacing.xl),
        // Suggestions and results are gated on an explicit, still-matching
        // submit (`hasSubmittedResults`), not on the raw text: otherwise typing
        // swaps the suggestions out for a "0 results" list, which reads as an
        // automatic search.
        if (!state.hasSubmittedResults) ...[
          RecentSearches(
            keywords: recentKeywords,
            l10n: l10n,
            // Tapping a stored keyword is an explicit search request (not
            // typing), so it records the query and submits it in one go —
            // `updateQuery` sets the state synchronously, so the submit that
            // follows reads the tapped keyword.
            onKeywordSelected: (keyword) {
              onQueryChanged(keyword);
              onQuerySubmitted(keyword);
            },
            onClear: onClearRecentSearches,
          ),
          QuickActions(actions: _scanQuickActions, l10n: l10n),
          // F-12：分类数据源未接通（后端无聚合分类字段），保持隐藏。
          Categories(
            categories: const <MedicineSearchCategory>[],
            l10n: l10n,
            onCategorySelected: (category) =>
                onQueryChanged(categoryLabel(l10n, category.type)),
          ),
        ],
        if (state.hasSubmittedResults) ...[
          Text(
            l10n.medicineSearchResultCount(state.results.length),
            style: context.theme.typography.body.md.copyWith(
              color: SemanticColor.neutral.solid(context),
            ),
          ),
          const SizedBox(height: Spacing.lg),
          ...state.results.map(
            (result) => Padding(
              padding: const EdgeInsets.only(bottom: Spacing.lg),
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

/// 桌面端搜索：列表 + 右侧详情，**主从两栏**。
///
/// ## 为什么复用 shell 的详情面板
///
/// 手机上一个结果点开就整页 push；桌面上有横向空间，同一份详情应当并排展开，
/// 列表的滚动位置和搜索上下文都还在。这正是 `DesktopDetailPane` 的语义——它
/// 渲染的就是**药品详情页本身**（`MedicineDetailContent`，同一个
/// `medicineDetailProvider` family），不是另造的精简预览卡。用药页药盒的桌面
/// 列表已经用它打开详情，搜索页只是把同一套主从关系接上。
///
/// 之前右栏是一张「选中项预览」卡：只显示药名，因为 F-11 去掉了把 subtitle
/// 拆成假临床提示的映射。结果就是桌面端搜到药品后右边几乎空白——详情本该在
/// 这里。
class _DesktopSearchLayout extends ConsumerStatefulWidget {
  const _DesktopSearchLayout({
    required this.state,
    required this.l10n,
    required this.recentKeywords,
    required this.onClearRecentSearches,
    required this.onQueryChanged,
    required this.onQuerySubmitted,
    required this.onSourceSwitched,
    required this.onResultSelected,
    required this.onRetry,
    this.onAddToCurrentMedicines,
    this.addedMedicineIds = const <String>{},
  });

  final MedicineSearchState state;
  final AppLocalizations l10n;
  final List<String> recentKeywords;
  final VoidCallback onClearRecentSearches;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<String> onQuerySubmitted;
  final ValueChanged<MedicineSearchSource> onSourceSwitched;
  final ValueChanged<String> onResultSelected;
  final VoidCallback onRetry;
  final void Function(MedicineSearchResult result)? onAddToCurrentMedicines;
  final Set<String> addedMedicineIds;

  @override
  ConsumerState<_DesktopSearchLayout> createState() =>
      _DesktopSearchLayoutState();
}

class _DesktopSearchLayoutState extends ConsumerState<_DesktopSearchLayout> {
  @override
  void initState() {
    super.initState();
    // 首次构建时结果可能已经在了（滚动恢复、返回本页），listener 不会补发。
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncDetailPane());
  }

  @override
  Widget build(BuildContext context) {
    // 搜索提交后 notifier 会把第一条结果设为选中；选中必须在右栏有可见结果，
    // 否则「选中」就只是个没有下文的状态。
    ref.listen(medicineSearchNotifierProvider, (_, __) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _syncDetailPane());
    });

    final state = widget.state;
    if (state.isSearching && state.results.isEmpty) {
      return const MedicineSearchLoadingView();
    }
    if (state.errorMessage != null && state.results.isEmpty) {
      return MedicineSearchErrorView(onRetry: widget.onRetry);
    }

    return DesktopDetailPane(
      child: _DesktopSearchPanel(
        state: state,
        l10n: widget.l10n,
        recentKeywords: widget.recentKeywords,
        onClearRecentSearches: widget.onClearRecentSearches,
        onQueryChanged: widget.onQueryChanged,
        onQuerySubmitted: widget.onQuerySubmitted,
        onSourceSwitched: widget.onSourceSwitched,
        onResultSelected: widget.onResultSelected,
        onAddToCurrentMedicines: widget.onAddToCurrentMedicines,
        addedMedicineIds: widget.addedMedicineIds,
      ),
    );
  }

  /// 把「当前选中的搜索结果」同步到右侧详情面板。
  ///
  /// 用 `widget.state`（父级每次 provider 变化都会把新 state 传下来）而不是
  /// 重新 `ref.read` provider：布局是受控的，state 只有一个来源。
  /// `open` 对同一目标是幂等的，所以 post-frame 里重复调用不会造成重建循环。
  void _syncDetailPane() {
    if (!mounted) return;
    final state = widget.state;
    final selectedId = state.selectedResultId;
    final result = selectedId == null
        ? null
        : state.results.firstWhereOrNull((item) => item.id == selectedId);
    final pane = ref.read(detailPaneProvider.notifier);
    if (result == null) {
      pane.close();
      return;
    }
    pane.open(
      MedicineDetailTarget(source: _detailSource(result.source), id: result.id),
    );
  }
}

/// 搜索来源 → 详情链路的 `source` 参数（`cn` | `drugbank`）。
String _detailSource(MedicineSearchSource source) =>
    source == MedicineSearchSource.drugbank ? 'drugbank' : 'cn';

class _DesktopSearchPanel extends StatelessWidget {
  const _DesktopSearchPanel({
    required this.state,
    required this.l10n,
    required this.recentKeywords,
    required this.onClearRecentSearches,
    required this.onQueryChanged,
    required this.onQuerySubmitted,
    required this.onSourceSwitched,
    required this.onResultSelected,
    this.onAddToCurrentMedicines,
    this.addedMedicineIds = const <String>{},
  });

  final MedicineSearchState state;
  final AppLocalizations l10n;
  final List<String> recentKeywords;
  final VoidCallback onClearRecentSearches;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<String> onQuerySubmitted;
  final ValueChanged<MedicineSearchSource> onSourceSwitched;
  final ValueChanged<String> onResultSelected;
  final void Function(MedicineSearchResult result)? onAddToCurrentMedicines;
  final Set<String> addedMedicineIds;

  @override
  Widget build(BuildContext context) {
    final typography = context.theme.typography;
    return FCard(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.xl2),
        child: ListView(
          children: [
            DesktopTabs(l10n: l10n),
            const SizedBox(height: Spacing.xl2),
            Text(
              l10n.medicineSearchPageTitle,
              style: typography.display.xl2.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: Spacing.lg),
            SearchInput(
              l10n: l10n,
              query: state.query,
              onChanged: onQueryChanged,
              onSubmitted: onQuerySubmitted,
            ),
            const SizedBox(height: Spacing.lg),
            SourceSwitch(
              selectedSource: state.source,
              l10n: l10n,
              onChanged: onSourceSwitched,
            ),
            const SizedBox(height: Spacing.xl),
            if (!state.hasSubmittedResults) ...[
              RecentSearches(
                keywords: recentKeywords,
                l10n: l10n,
                // Same as the mobile layout: selecting a stored keyword is an
                // explicit search request.
                onKeywordSelected: (keyword) {
                  onQueryChanged(keyword);
                  onQuerySubmitted(keyword);
                },
                onClear: onClearRecentSearches,
              ),
              QuickActions(
                actions: const <MedicineSearchQuickAction>[],
                l10n: l10n,
              ),
              // F-12：分类数据源未接通（后端无聚合分类字段），保持隐藏。
              Categories(
                categories: const <MedicineSearchCategory>[],
                l10n: l10n,
              ),
            ],
            if (state.hasSubmittedResults) ...[
              Text(
                l10n.medicineSearchResultCount(state.results.length),
                style: typography.body.md.copyWith(
                  color: SemanticColor.neutral.solid(context),
                ),
              ),
              const SizedBox(height: Spacing.lg),
              ...state.results.map(
                (result) => Padding(
                  padding: const EdgeInsets.only(bottom: Spacing.lg),
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
