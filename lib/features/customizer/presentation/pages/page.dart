import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

import 'package:luminous/core/composition/composition.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/customizer/domain/entities/draft.dart';
import 'package:luminous/features/customizer/domain/entities/edit.dart';
import 'package:luminous/features/customizer/presentation/providers/draft.dart';
import 'package:luminous/features/customizer/presentation/widgets/palette.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// 编排页：编辑**一个** surface 的组件列表，并可把别的 surface 的组件加入。
///
/// 用户从某个 tab 点标题进来，心智是"我在改这一页"；跨 tab 能力由右侧
/// 面板提供——拖到左侧、或点一下即加入。
///
/// 用 `flutter_reorderable_grid_view` 而不是内置 `ReorderableListView`：内置版
/// 只能在一维列表内排序，既不能跨列表拖入，也展示不了组件的真实尺寸
/// （compact/regular/wide 三档正是编排页要让用户看到的东西）。
class CustomizerPage extends ConsumerStatefulWidget {
  const CustomizerPage({super.key, required this.surface});

  final SurfaceId surface;

  @override
  ConsumerState<CustomizerPage> createState() => _CustomizerPageState();
}

class _CustomizerPageState extends ConsumerState<CustomizerPage> {
  @override
  void initState() {
    super.initState();
    // 进入编排即读现有布局生成草稿。用 postFrame 是因为 begin() 会写 provider
    // 状态，不能在 build/initState 期间同步改。
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(
        ref
            .read(editSessionProvider.notifier)
            .begin(ref.read(surfaceCatalogProvider)),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final draft = ref.watch(editSessionProvider);
    final catalog = ref.watch(surfaceCatalogProvider);

    if (draft == null) {
      return const FScaffold(child: Center(child: FProgress()));
    }

    final placements = draft.layoutOf(widget.surface).placements;

    // children 与 onReorder 共用同一份列表：它既是渲染来源，也是重排回调
    // 算新顺序的输入。key 用组件 id，重排后据此还原是哪个组件动了。
    final children = <Widget>[
      for (var index = 0; index < placements.length; index += 1)
        _PlacementTile(
          key: ValueKey(placements[index].id.value),
          surface: widget.surface,
          placement: placements[index],
          isLast: index == placements.length - 1,
        ),
    ];

    // 窄屏放不下两栏：主列表占满，可选组件走底部面板。
    // 桌面/平板仍然并排——那里宽度足够，两栏能同时看见。
    final isNarrow = MediaQuery.sizeOf(context).width < Breakpoints.tablet;

    final builder = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Header(
          title: surfaceTitle(l10n, widget.surface),
          onDone: () => _finish(context),
          onReset: () => ref.read(editSessionProvider.notifier).resetToDefaults(),
          onAdd: isNarrow ? () => _openPalette(context, catalog, draft) : null,
        ),
        Expanded(
          child: isNarrow
              ? _buildList(context, children, placements)
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: _buildList(context, children, placements),
                    ),
                    Expanded(
                      flex: 2,
                      child: CustomizerPalette(
                        current: widget.surface,
                        catalog: catalog,
                        draft: draft,
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );

    // 顶部安全区由 Scaffold 的 SafeArea 负责：编排页是自定义 header，不是
    // `page_scaffold` 那套带返回箭头的顶栏，不包 SafeArea 时标题会被状态栏压住。
    return Scaffold(
      backgroundColor: context.theme.scaffoldStyle.backgroundColor,
      body: SafeArea(bottom: false, child: builder),
    );
  }

  /// 主列表 + 跨 tab 拖入落点。
  Widget _buildList(
    BuildContext context,
    List<Widget> children,
    List<ComponentPlacement> placements,
  ) {
    return DragTarget<ComponentId>(
      onAcceptWithDetails: (details) {
        ref
            .read(editSessionProvider.notifier)
            .applyEdit(
              LayoutEdit.add(
                surface: widget.surface,
                id: details.data,
                toIndex: placements.length,
              ),
            );
      },
      builder: (context, candidates, _) {
        return DecoratedBox(
          decoration: BoxDecoration(
            border: candidates.isEmpty
                ? null
                : Border.all(
                    color: SemanticColor.primary.solid(context),
                    width: 2,
                  ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              Spacing.lg,
              0,
              Spacing.lg,
              Spacing.xl,
            ),
            child: ReorderableBuilder<Widget>(
              onReorder: (reorder) =>
                  _onReorder(reorder, children, placements),
              children: children,
              builder: (ordered) => Column(children: ordered.toList()),
            ),
          ),
        );
      },
    );
  }

  /// 窄屏的「添加组件」面板：底部弹出，占屏幕一半高度。
  Future<void> _openPalette(
    BuildContext context,
    SurfaceCatalog catalog,
    LayoutDraft draft,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.theme.scaffoldStyle.backgroundColor,
      builder: (sheetContext) => SafeArea(
        top: false,
        child: SizedBox(
          height: MediaQuery.sizeOf(sheetContext).height * 0.55,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(Spacing.lg),
                child: Text(
                  AppLocalizations.of(sheetContext)!.customizerAddComponents,
                  style: context.theme.typography.body.md.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                child: CustomizerPalette(
                  current: widget.surface,
                  catalog: catalog,
                  draft: draft,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 「完成」：写回布局并离开。取消（返回手势/返回键）直接丢弃草稿。
  Future<void> _finish(BuildContext context) async {
    await ref.read(editSessionProvider.notifier).commit();
    if (!context.mounted) return;
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/');
    }
  }

  /// 把重排结果翻译成一次 `move` 编辑。
  ///
  /// 拖拽库回传的是「给我当前 children，我给你新顺序」的函数；我们只在找到
  /// 第一个位置变化的组件时落一次编辑——草稿是唯一真相来源，UI 不自己维护
  /// 顺序，避免"界面顺序"和"草稿顺序"两份状态打架。
  void _onReorder(
    List<Widget> Function(List<Widget>) reorder,
    List<Widget> children,
    List<ComponentPlacement> placements,
  ) {
    final reordered = reorder(children);
    for (var index = 0; index < reordered.length; index += 1) {
      final id = _idOfKey(reordered[index].key);
      if (id == null) continue;
      if (placements.elementAtOrNull(index)?.id == id) continue;
      ref
          .read(editSessionProvider.notifier)
          .applyEdit(
            LayoutEdit.move(
              from: widget.surface,
              to: widget.surface,
              id: id,
              toIndex: index,
            ),
          );
      return;
    }
  }
}

/// 从 `ValueKey<String>` 还原组件 id —— 拖拽库只回传 key，不认业务类型。
ComponentId? _idOfKey(Object? key) {
  if (key is ValueKey<String>) return ComponentId(key.value);
  return null;
}

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.onReset,
    required this.onDone,
    this.onAdd,
  });

  final String title;
  final VoidCallback onReset;
  final VoidCallback onDone;

  /// 窄屏才有：打开「添加组件」面板（宽屏上面板常驻，不需要入口）。
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final titleText = Text(
      title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: context.theme.typography.body.lg,
    );
    final resetButton = FTooltip(
      tipBuilder: (context, controller) => Text(l10n.customizerResetAction),
      child: FButton.icon(
        variant: FButtonVariant.outline,
        size: FButtonSizeVariant.sm,
        onPress: onReset,
        semanticsLabel: l10n.customizerResetAction,
        child: const Icon(SemanticIcons.actionReset),
      ),
    );
    final addButton = onAdd == null
        ? null
        : FTooltip(
            tipBuilder: (context, controller) =>
                Text(l10n.customizerAddComponents),
            child: FButton.icon(
              size: FButtonSizeVariant.sm,
              onPress: onAdd,
              semanticsLabel: l10n.customizerAddComponents,
              child: const Icon(SemanticIcons.actionAdd),
            ),
          );
    final doneButton = FTooltip(
      tipBuilder: (context, controller) => Text(l10n.customizerDoneAction),
      child: FButton.icon(
        size: FButtonSizeVariant.sm,
        onPress: onDone,
        semanticsLabel: l10n.customizerDoneAction,
        child: const Icon(SemanticIcons.actionDone),
      ),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Spacing.lg,
        Spacing.md,
        Spacing.lg,
        Spacing.md,
      ),
      // 结构化装配：标题吃剩余宽度，操作按钮以 `Flexible` 参与分配，
      // 窄屏 + 大字号时也不会把标题挤成多行（见 luminous_lints 规则
      // `non_shrinking_row_child`）。
      child: Row(
        children: [
          Expanded(child: titleText),
          const SizedBox(width: Spacing.sm),
          if (addButton != null) ...[
            Flexible(child: addButton),
            const SizedBox(width: Spacing.xs),
          ],
          Flexible(child: resetButton),
          const SizedBox(width: Spacing.xs),
          Flexible(child: doneButton),
        ],
      ),
    );
  }
}

/// 列表里的一行：把手 + 名称 + 显隐 + 移除。
class _PlacementTile extends ConsumerWidget {
  const _PlacementTile({
    super.key,
    required this.surface,
    required this.placement,
    required this.isLast,
  });

  final SurfaceId surface;
  final ComponentPlacement placement;

  /// 最后一项不允许移除：编辑器不提供「全空」状态（空 surface 没有可恢复的
  /// 入口，用户只能靠「恢复默认」脱困）。
  final bool isLast;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final notifier = ref.read(editSessionProvider.notifier);
    final registry = ref.watch(componentRegistryProvider);
    final id = placement.id;
    final known = registry.contains(id);

    // 结构化装配：名称吃剩余宽度；显隐与移除交给 `Flexible`，窄屏 + 大字号
    // 时不会把名称挤成多行（luminous_lints 规则 non_shrinking_row_child）。
    // 主行是用户能读懂的名字，id 作为副行保留——id 才是持久化与下架的真正
    // 身份，出问题时用户报的就是它。
    final nameText = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          componentDisplayName(l10n, id),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.theme.typography.body.sm.copyWith(
            color: known ? null : SemanticColor.neutral.solid(context),
          ),
        ),
        Text(
          id.value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.theme.typography.body.xs2.copyWith(
            color: SemanticColor.neutral.solid(context),
          ),
        ),
      ],
    );
    final visibilitySwitch = FSwitch(
      value: placement.visible,
      onChange: (value) => notifier.applyEdit(
        LayoutEdit.toggle(surface: surface, id: id, visible: value),
      ),
    );
    final removeButton = FTooltip(
      tipBuilder: (context, controller) => Text(l10n.customizerRemoveAction),
      child: FButton.icon(
        variant: FButtonVariant.ghost,
        size: FButtonSizeVariant.xs,
        onPress: () =>
            notifier.applyEdit(LayoutEdit.remove(surface: surface, id: id)),
        semanticsLabel: l10n.customizerRemoveAction,
        child: const Icon(SemanticIcons.actionDelete),
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.sm),
      child: FCard(
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(Spacing.sm),
              child: Icon(
                SemanticIcons.actionDragHandle,
                size: IconSizeTokens.md,
                color: SemanticColor.neutral.solid(context),
              ),
            ),
            Expanded(child: nameText),
            Flexible(child: visibilitySwitch),
            if (!isLast) Flexible(child: removeButton),
          ],
        ),
      ),
    );
  }
}
