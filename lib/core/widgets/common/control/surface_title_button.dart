import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import 'package:luminous/core/composition/composition.dart';
import 'package:luminous/core/design/design.dart';

/// Tab 页顶部的标题。
///
/// 标题不只是标题：有编排能力时它就是一个按钮，点一下进入**这一页**的编排
/// 页。配置入口长在页面自身，而不是藏进「设置 → 页面编辑」。
///
/// 放在 `core/` 而不是 `customizer/` 的理由：五个 tab 页都要用它，而
/// presentation 不许跨 feature import；`core/` 又不许 import feature。所以
/// 这里只认 [surfaceCustomizerOpenerProvider] 这个注入口，真正的路由由组合根
/// 注入。没有注入时退化成纯文本标题，不假装可点。
class SurfaceTitleButton extends StatelessWidget {
  const SurfaceTitleButton({
    super.key,
    required this.surface,
    required this.title,
    required this.open,
  });

  final SurfaceId surface;

  /// 已本地化的标题（各 tab 复用 ARB 里的 tab 名称）。
  final String title;

  /// 组合根注入的编排入口；`null` 表示当前构建没有编排能力。
  final SurfaceCustomizerOpener? open;

  @override
  Widget build(BuildContext context) {
    final label = Text(
      title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: context.theme.typography.display.sm.copyWith(
        fontWeight: FontWeight.w500,
      ),
    );

    final opener = open;
    if (opener == null) return label;

    return FButton(
      key: Key('surface-title-${surface.wireValue}'),
      variant: FButtonVariant.ghost,
      size: FButtonSizeVariant.sm,
      mainAxisSize: MainAxisSize.min,
      onPress: () => opener(context, surface),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 图标在文字之前：先拿到自己的固有宽度，文字再占剩下的空间。
          Icon(
            SemanticIcons.actionEdit,
            size: IconSizeTokens.sm,
            color: SemanticColor.neutral.solid(context),
          ),
          const SizedBox(width: Spacing.xs),
          Flexible(child: label),
        ],
      ),
    );
  }
}

/// 读注入口并渲染 [SurfaceTitleButton]，供各 tab 顶栏直接使用。
///
/// 单独一层是为了让顶栏不必各自变成 `ConsumerWidget`：它们只关心「标题放哪」，
/// 不关心入口从哪来。
class SurfaceTitleEntry extends ConsumerWidget {
  const SurfaceTitleEntry({
    super.key,
    required this.surface,
    required this.title,
  });

  final SurfaceId surface;
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SurfaceTitleButton(
      surface: surface,
      title: title,
      open: ref.watch(surfaceCustomizerOpenerProvider),
    );
  }
}
