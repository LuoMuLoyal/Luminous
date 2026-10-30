import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import 'package:luminous/core/composition/composition.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/customizer/domain/entities/draft.dart';
import 'package:luminous/features/customizer/domain/entities/edit.dart';
import 'package:luminous/features/customizer/presentation/providers/draft.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// 跨 tab 组件面板。
///
/// 按来源 surface 分组列出**当前这张表能挂、但还没挂**的组件：这就是该
/// surface 的「未挂载池」（从这张表移走的组件回到这里，选中即放回去）。
/// 每个组件可拖到左侧网格，也可点一下追加到末尾。
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
    final l10n = AppLocalizations.of(context)!;
    final notifier = ref.read(editSessionProvider.notifier);

    // 已挂在表上的（含隐藏的）不再列出——它们已经在左侧网格里了。
    final mounted = draft
        .layoutOf(current)
        .placements
        .map((placement) => placement.id)
        .toSet();

    final candidates = [
      for (final id in catalog.availableOf(current))
        if (!mounted.contains(id)) id,
    ];

    if (candidates.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Text(
          l10n.customizerAllAdded,
          style: context.theme.typography.body.sm.copyWith(
            color: SemanticColor.neutral.solid(context),
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(Spacing.lg),
      children: [
        for (final id in candidates)
          Padding(
            padding: const EdgeInsets.only(bottom: Spacing.sm),
            child: Draggable<ComponentId>(
              data: id,
              feedback: _PaletteDragFeedback(label: id.value),
              childWhenDragging: Opacity(
                opacity: 0.4,
                child: _PaletteTile(id: id, onTap: () => _add(notifier, id)),
              ),
              child: _PaletteTile(id: id, onTap: () => _add(notifier, id)),
            ),
          ),
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
