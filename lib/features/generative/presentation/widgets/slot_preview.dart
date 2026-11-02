import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:luminous/core/design/design.dart';

/// 生成式区块的**预览内容**：三张并排的小卡。
///
/// ## 这是做什么的
///
/// 真实生成结果要经过「KV 冷启动恢复 → 消息重放 → genui 渲染」这条异步链路，
/// 在 `flutter_test` 里跑不通（`pump` 推不动真实 Future）。为了让截图能展示
/// 「用户配置之后，页面上这块地方长什么样」，这个 provider 提供一份**纯手绘**
/// 的等价外观——不经过 genui，也不依赖任何后端数据。
///
/// ## 不是替代实现
///
/// 真实路径仍然是 genui 重放（见 `GenerativeSurface`）。这里只覆盖一个场景：
/// 区块已配置、但**本次会话还没有生成结果**时的落位预览。默认值是 `null`，
/// 即生产环境不显示任何预览——只有截图生成器会覆盖它。
final generativeSlotPreviewProvider = Provider<bool>(
  (ref) => false,
  name: 'generativeSlotPreview',
);

/// 三张并排的小卡。
///
/// 与生成式内容同构：外面一层是区块内容，里面是等宽三列。用 `Expanded`
/// 而不是固定宽度——桌面与手机都要能用，固定宽度在窄屏会溢出。
class GenerativeSlotPreview extends StatelessWidget {
  const GenerativeSlotPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      key: Key('generative-slot-preview'),
      // `stretch` 会让 Row 给子节点无界高度约束（外层是 Column 的自然高度），`      // 布局期直接崩。用 `start`：三张卡各自按内容高度排，视觉上仍然对齐顶部。`r`n      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PreviewCard(
          icon: SemanticIcons.recordWater,
          label: '饮水',
          value: '1800 ml',
        ),
        SizedBox(width: Spacing.md),
        _PreviewCard(
          icon: SemanticIcons.recordSleep,
          label: '睡眠',
          value: '7.2 h',
        ),
        SizedBox(width: Spacing.md),
        _PreviewCard(
          icon: SemanticIcons.tabMedicine,
          label: '依从率',
          value: '82%',
        ),
      ],
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final typography = context.theme.typography;

    return Expanded(
      child: FCard(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: IconSizeTokens.md,
                color: SemanticColor.primary.solid(context),
              ),
              const SizedBox(height: Spacing.sm),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: typography.body.xs2.copyWith(
                  color: SemanticColor.neutral.solid(context),
                ),
              ),
              const SizedBox(height: Spacing.xs),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: typography.body.md.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
