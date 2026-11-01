import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/feedback/skeleton.dart';
import 'package:luminous/features/generative/domain/entities/generation.dart';
import 'package:luminous/features/generative/presentation/components/catalog.dart'
    show generativeSurfaces;
import 'package:luminous/features/generative/presentation/providers/generation.dart';
import 'package:luminous/features/generative/presentation/providers/slot_spec.dart';
import 'package:luminous/features/generative/presentation/providers/surface_state.dart';
import 'package:luminous/features/generative/presentation/widgets/slot_preview.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/shared/domain/composition/surface.dart';

/// 生成式区块在**页面上**的呈现：标题 + 内容。
///
/// ## 这里没有输入框
///
/// 「让 agent 渲染什么」是一份**配置**，不是每次渲染的临时提问。用户配置
/// 一次（在编排页里给区块起名、写下意图），之后这个区块就像别的组件一样
/// 长期待在那里。把输入框放回页面，等于要求用户每次打开页面都重新描述一遍
/// 同一件事——那是把配置降级成了即时命令。
///
/// 所以这里只做三件事：显示用户起的标题、在生成中给骨架、在有结果时渲染。
/// 没有配置过时**什么都不显示**（返回 `SizedBox.shrink`）：一个用户没配置过
/// 的空区块不该在页面上留一行「这里要显示什么」的占位，那是编排页的语义。
class GenerativeComposeEntry extends ConsumerWidget {
  const GenerativeComposeEntry({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final surface = ref.watch(generativeSurfaceIdProvider);
    final spec = ref.watch(generativeSlotSpecProvider(surface));
    final state = ref.watch(generativeStateProvider);
    final typography = context.theme.typography;

    // `tab_chrome` 是底部栏，不是页面，服务端会以 400
    // `GENERATIVE_SURFACE_UNSUPPORTED` 拒绝。客户端在这里就不给入口。
    if (!isComposableSurface(surface)) return const SizedBox.shrink();

    // 没配置过 → 不占位。配置入口在编排页，不在页面上。
    if (spec == null) return const SizedBox.shrink();

    final hasResult = switch (state) {
      GenerationReady() => true,
      GenerationFailed(:final document) => document != null,
      GenerationIdle() || GenerationInFlight() => false,
    };

    // 与其它组件同构：区块标题在卡外、内容在 `FCard` 里。
    //
    // 之前这里只有标题 + 裸内容，于是生成式区块在页面上是一块**没有底**的
    // 浮字：周围的组件都是「标题 + 白卡」，它却是「标题 + 直接铺在页面底色上
    // 的东西」，一眼就能看出不是一类。衬底不是装饰——它承担「这一整块是一个
    // 组件」的分组语义。
    return Padding(
      key: const Key('generative-compose-entry'),
      padding: const EdgeInsets.only(bottom: Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            spec.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: typography.display.xl.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
          SizedBox(height: context.titleContentGap),
          FCard(
            key: const Key('generative-compose-card'),
            child: Padding(
              padding: const EdgeInsets.all(Spacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 生成中但还没有任何结果：骨架。已有结果时保持原样，不闪。
                  if (!hasResult && state is GenerationInFlight)
                    const _GenerativeSkeleton()
                  else if (!hasResult)
                    // 配置了但没生成过（例如刚配置完、或结果被清掉）：
                    // 用一句话说明这里的现状，而不是把输入框搬回来。
                    //
                    // 预览开启时（仅截图生成器覆盖）改为展示这个区块配置之后
                    // 的形态——三张并排小卡。生产环境该 provider 恒为 false。
                    if (ref.watch(generativeSlotPreviewProvider))
                      const GenerativeSlotPreview()
                    else
                      Text(
                        l10n.generativeSlotNotGenerated,
                        style: typography.body.xs.copyWith(
                          color: SemanticColor.neutral.solid(context),
                        ),
                      ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// surface 是否还能继续生成（`tab_chrome` 不是页面，不参与生成）。
///
/// 与服务端 `GENERATIVE_SURFACES` 对齐，判定依据是 [generativeSurfaces] 这份
/// 共享清单——不在这里重复写 `surface != SurfaceId.tabChrome`。
bool isComposableSurface(SurfaceId surface) =>
    generativeSurfaces.contains(surface);

/// 生成中的骨架：三行递减宽度的色块。
///
/// 复用 `SkeletonShimmer`（它统一了全应用骨架的基色与动画节奏），不自己拼
/// `Shimmer`——那需要手写渐变参数，且会和别处的骨架看起来不是一套。
class _GenerativeSkeleton extends StatelessWidget {
  const _GenerativeSkeleton();

  @override
  Widget build(BuildContext context) {
    final color = SemanticColor.neutral.shimmerBase(context);
    Widget bar(double widthFactor) => FractionallySizedBox(
      alignment: AlignmentDirectional.centerStart,
      widthFactor: widthFactor,
      child: Container(
        height: 12,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );

    return SkeletonShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          bar(0.6),
          const SizedBox(height: Spacing.sm),
          bar(0.9),
          const SizedBox(height: Spacing.sm),
          bar(0.4),
        ],
      ),
    );
  }
}
