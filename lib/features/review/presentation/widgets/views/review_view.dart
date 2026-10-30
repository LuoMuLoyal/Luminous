import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/composition/composition.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/features/review/domain/entities/dashboard.dart';
import 'package:luminous/features/review/presentation/providers/dashboard.dart';
import 'package:luminous/features/review/presentation/providers/review.dart';
import 'package:luminous/features/review/presentation/providers/surface.dart';
import 'package:luminous/features/review/presentation/widgets/views/skeleton_view.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// 洞察优先的回顾首屏（移动端约束布局）。
///
/// 组件顺序来自 `reviewSurfaceDefinition`（`components/catalog.dart`），不再在
/// 本文件里硬编码：默认布局与组件化之前逐段一致，零视觉变化。
///
/// 六种状态：
/// 1. loading —— 无数据时的骨架屏；
/// 2. active —— 事件头部提供「去今日 check-in」浅链接 + 四段；
/// 3. ended —— 事件头部展示 outcome + 四段；
/// 4. partial —— 个别段落 unknown，只显示简短缺失原因，无分数/红色告警；
/// 5. no-event —— 数据过稀时记录引导卡（去 record 补记），否则轻量解释卡；
///    无事件时不生成周报、不渲染任何事件动作；
/// 6. error-with-cache —— 刷新失败但保留上次成功数据，顶部轻量提示；
///    无缓存的错误在 [StateErrorView] 中给出重试。
///
/// 事件动作（开始观察 / check-in / end）已收口 Today，本视图不承接任何
/// 事件动作回调。
class ReviewView extends ConsumerWidget {
  const ReviewView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentAsync = ref.watch(reviewCurrentProvider);
    final cached = ref.watch(reviewLastCurrentProvider);

    // 把每次成功的周期看板写入缓存，「切周期期间用旧数据承接」由
    // reviewSurfaceStateProvider 读取该缓存实现。写入放在页面层而不是
    // provider 内部：provider 若既读又写同一份缓存，会形成自引用，
    // Riverpod 3 下新值不会向下游传播，组件会永远停在 loading。
    ref.listen<AsyncValue<ReviewDashboard>>(
      reviewDashboardProvider(ref.watch(reviewDashboardSelectedQueryProvider)),
      (_, next) {
        final dashboard = next.value;
        if (dashboard != null) {
          ref.read(reviewLastDashboardProvider.notifier).set(dashboard);
        }
      },
    );

    if (currentAsync.isLoading && !currentAsync.hasValue && cached == null) {
      return const ReviewSkeletonView();
    }

    if (currentAsync.hasError && !currentAsync.hasValue && cached == null) {
      return StateErrorView(
        title: l10n.reviewReviewErrorTitle,
        description: l10n.reviewReviewErrorDescription,
        icon: SemanticIcons.statusError,
        actionLabel: l10n.todayRetryAction,
        onAction: () => ref.invalidate(reviewCurrentProvider),
        tone: StateTone.warning,
      );
    }

    // 组件在 `ComponentHost.build` 期间求值，host 只在自身重建时才会重新
    // resolve 一遍。它只 watch 注册表与布局，数据态变化不会传到它身上，
    // 所以这里显式订阅两条数据链，让宿主随数据一起重建——否则首帧（loading）
    // 求出的 null 会一直留在树上。
    ref.watch(reviewSurfaceStateProvider);
    ref.watch(reviewSurfaceReviewProvider);

    return ComponentHost(
      surface: SurfaceId.review,
      layout: ref.watch(surfaceLayoutProvider(SurfaceId.review)),
      spacing: Spacing.lg,
    );
  }
}
