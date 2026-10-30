import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/composition/composition.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/customizer/domain/entities/draft.dart';
import 'package:luminous/features/customizer/domain/entities/edit.dart';
import 'package:luminous/features/customizer/presentation/providers/draft.dart';

/// 跨 tab 组件面板。
///
/// 列出**所有** surface 的组件（按来源分组），每个组件是一个 `Draggable`：
/// 拖到左侧网格即加入当前 surface；也可以点一下追加到末尾。
///
/// 为什么要按来源分组而不是一个大列表：用户的心智是"这是今日页的组件"，
/// 分组让他在跨 tab 时知道自己在拿谁的东西，而不是面对一堆陌生名字。
class CustomizerPalette extends ConsumerWidget {
  const CustomizerPalette({
    super.key,
    required this.current,
    required this.catalog,
    required this.draft,
  });

  final SurfaceId current;
  final SurfaceCatalog catalog;
  final LayoutDraft draft;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(editSessionProvider.notifier);

    // 当前 surface 已经挂着的（含隐藏的）不再列出——它们已经在网格里了。
    final mounted = draft
        .layoutOf(current)
        .placements
        .map((placement) => placement.id)
        .toSet();

    // 每个 surface 能挂、且当前没挂的组件。这就是跨 tab 的候选集。
    final candidates = <SurfaceId, List<ComponentId>>{};
    for (final definition in catalog.definitions) {
      final ids = [
        for (final id in definition.available)
          if (!mounted.contains(id)) id,
      ];
      if (ids.isNotEmpty) candidates[definition.surface] = ids;
    }

    if (candidates.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Text(
          '所有组件都已添加',
          style: context.theme.typography.body.sm.copyWith(
            color: SemanticColor.neutral.solid(context),
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(Spacing.lg),
      children: [
        for (final entry in candidates.entries) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: Spacing.sm),
            child: Text(
              entry.key.wireValue,
              style: context.theme.typography.body.xs.copyWith(
                color: SemanticColor.neutral.solid(context),
              ),
            ),
          ),
          for (final id in entry.value)
            Padding(
              padding: const EdgeInsets.only(bottom: Spacing.sm),
              child: Draggable<ComponentId>(
                data: id,
                feedback: _PaletteDragFeedback(label: id.value),
                childWhenDragging: Opacity(
                  opacity: 0.4,
                  child: _PaletteTile(
                    id: id,
                    onTap: () => _add(notifier, id),
                  ),
                ),
                child: _PaletteTile(
                  id: id,
                  onTap: () => _add(notifier, id),
                ),
              ),
            ),
        ],
      ],
    );
  }

  void _add(EditSessionNotifier notifier, ComponentId id) {
    notifier.applyEdit(
      LayoutEdit.add(
        surface: current,
        id: id,
        toIndex: draft.layoutOf(current).placements.length,
      ),
    );
  }
}

class _PaletteTile extends StatelessWidget {
  const _PaletteTile({required this.id, required this.onTap});

  final ComponentId id;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: FCard(
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(Spacing.sm),
              child: Icon(
                SemanticIcons.actionAddCard,
                size: IconSizeTokens.md,
                color: SemanticColor.neutral.solid(context),
              ),
            ),
            Expanded(
              child: Text(
                id.value,
                style: context.theme.typography.body.sm,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaletteDragFeedback extends StatelessWidget {
  const _PaletteDragFeedback({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SizedBox(
        width: 220,
        child: FCard(
          child: Padding(
            padding: const EdgeInsets.all(Spacing.md),
            child: Text(label, style: context.theme.typography.body.sm),
          ),
        ),
      ),
    );
  }
}
