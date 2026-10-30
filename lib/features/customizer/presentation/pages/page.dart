import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import 'package:luminous/core/composition/composition.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/customizer/domain/entities/edit.dart';
import 'package:luminous/features/customizer/presentation/providers/draft.dart';
import 'package:luminous/features/customizer/presentation/widgets/palette.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// 编排页：编辑**一个** surface 的组件列表，并可把别的 surface 的组件拖进来。
///
/// 用户从某个 tab 点「编辑」进来，心智是"我在改这一页"；跨 tab 能力由右侧
/// 面板提供——把组件拖到左侧即加入。
///
/// 用 `flutter_reorderable_grid_view` 而不是内置 `ReorderableListView`：内置版
/// 只能在一维列表内排序，既不能跨列表拖入，也展示不了组件的真实尺寸
/// （compact/regular/wide 三档正是编排页要让用户看到的东西）。
class CustomizerPage extends ConsumerStatefulWidget {
  const CustomizerPage({
    super.key,
    required this.surface,
    required this.catalog,
    this.onDone,
  });

  final SurfaceId surface;
  final SurfaceCatalog catalog;

  /// 点「完成」后的回调（由调用方负责关闭编排页并提交草稿）。
  final VoidCallback? onDone;

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
      unawaited(ref.read(editSessionProvider.notifier).begin(widget.catalog));
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final draft = ref.watch(editSessionProvider);

    if (draft == null) {
      return const FScaffold(child: Center(child: FProgress()));
    }

    final placements = draft.layoutOf(widget.surface).placements;

    // children 与 onReorder 共用同一份列表：它既是渲染来源，也是重排回调
    // 算新顺序的输入。key 用组件 id，重排后据此还原是哪个组件动了。
    final children = <Widget>[
      for (final placement in placements)
        _PlacementTile(
          key: ValueKey(placement.id.value),
          surface: widget.surface,
          placement: placement,
        ),
    ];

    return FScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(
            title: l10n.customizerTitle,
            onDone: widget.onDone,
            onReset: () =>
                ref.read(editSessionProvider.notifier).resetToDefaults(),
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 跨 tab 拖入的落点。
                Expanded(
                  flex: 3,
                  child: DragTarget<ComponentId>(
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
                          padding: const EdgeInsets.all(Spacing.lg),
                          child: ReorderableBuilder<Widget>(
                            onReorder: (reorder) =>
                                _onReorder(reorder, children, placements),
                            children: children,
                            builder: (ordered) =>
                                Column(children: ordered.toList()),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: CustomizerPalette(
                    current: widget.surface,
                    catalog: widget.catalog,
                    draft: draft,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
    this.onDone,
  });

  final String title;
  final VoidCallback onReset;
  final VoidCallback? onDone;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Spacing.lg),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: context.theme.typography.body.lg),
          ),
          FButton(
            variant: FButtonVariant.outline,
            onPress: onReset,
            child: const Text('恢复默认'),
          ),
          const SizedBox(width: Spacing.sm),
          FButton(onPress: onDone, child: const Text('完成')),
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
  });

  final SurfaceId surface;
  final ComponentPlacement placement;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(editSessionProvider.notifier);

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
            Expanded(
              child: Text(
                placement.id.value,
                style: context.theme.typography.body.sm,
              ),
            ),
            FSwitch(
              value: placement.visible,
              onChange: (value) => notifier.applyEdit(
                LayoutEdit.toggle(
                  surface: surface,
                  id: placement.id,
                  visible: value,
                ),
              ),
            ),
            FButton(
              variant: FButtonVariant.ghost,
              size: FButtonSizeVariant.xs,
              onPress: () => notifier.applyEdit(
                LayoutEdit.remove(surface: surface, id: placement.id),
              ),
              child: const Text('移除'),
            ),
          ],
        ),
      ),
    );
  }
}
