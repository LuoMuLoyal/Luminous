import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/features/medicine/presentation/pages/detail.dart';
import 'package:luminous/features/medicine/presentation/pages/medicine_detail_content.dart';
import 'package:luminous/features/medicine/presentation/providers/medicine_detail.dart';
import 'package:luminous/features/shell/presentation/detail_pane_state.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// 面板默认宽度：22rem。与 Lumine 的 Infobar 同档——它是「辅助信息」，
/// 不是并列主区域；再宽就抢了内容区的主次关系。
const double _paneWidth = 352;

/// 面板能被拖到的最窄宽度。
///
/// 再窄，卡片内边距（20）与两侧留白会把正文挤成一列字。上限不在这里写死，
/// 由主内容区的 `minFlex: 2` 反向给出——保证内容区始终至少是面板的两倍宽，
/// 「辅助」的主次关系因此不会被拖拽破坏。
const double _paneMinWidth = 280;

/// 桌面端右侧详情面板：内容区右侧推开的一块可拖宽区域。
///
/// ## 为什么是「第二种呈现」而不是另一个页面
///
/// 手机上一个列表项点开就整页 push，返回时列表滚动位置丢失、上下文断掉。
/// 桌面上有横向空间，同一份详情可以并排展开：左侧列表停在原处，右侧看细节。
/// 这**不新增任何数据或页面**，只是把已有详情内容换个容器渲染。
///
/// ## 为什么用 FResizable
///
/// 拖拽分隔条要处理 pointer capture、悬停光标、最小/最大宽度、键盘可达
/// （方向键调整宽度）。这些都是 Forui `FResizable` 已经做对的，
/// 自写唯一的结果是把同一批边界 bug 重新养一遍。
class DesktopDetailPane extends ConsumerWidget {
  const DesktopDetailPane({super.key, required this.child});

  /// 主内容（列表页）。面板关闭时它就是全部宽度。
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final target = ref.watch(detailPaneProvider);

    // 关闭态直接返回内容：不保留一条空边，否则开关面板时内容宽度变化，
    // 文字会重新折行。
    if (target == null) return child;

    return FResizable(
      axis: Axis.horizontal,
      // 带拖拽手柄的分隔条：没有手柄时用户不知道这里能拖。
      divider: FResizableDivider.dividerWithThumb,
      children: [
        // 主内容吃剩余宽度。`flex: 2` + `minFlex: 2`：面板再宽，内容区也不会
        // 被压到比它自己还窄——`minFlex` 必须 ≤ `flex`，两个都写 2 表示
        // 「这块区域占 2 份且不得少于 2 份」，即内容区宽度不随面板拖动缩水。
        FResizableRegion.flex(
          flex: 2,
          minFlex: 2,
          builder: (context, data, _) => child,
        ),
        FResizableRegion.fixed(
          extent: _paneWidth,
          // 只有下限：宽度上限由「主内容至少两倍宽」这个 flex 约束反向给出，
          // 再写一个 maxExtent 会与之互相打架。
          minExtent: _paneMinWidth,
          builder: (context, data, _) => _PaneSurface(
            onClose: () => ref.read(detailPaneProvider.notifier).close(),
            child: switch (target) {
              MedicineDetailTarget() => _MedicineDetail(target),
            },
          ),
        ),
      ],
    );
  }
}

/// 面板的外观：与左侧侧边栏同色，只留左上圆角。
///
/// 左右同色是一组对位关系——导航在左、详情在右，两者都是「外围」，
/// 中间的内容区才是主体。面板若用内容区的底色，右栏就变成了第二块主内容。
class _PaneSurface extends StatelessWidget {
  const _PaneSurface({required this.child, required this.onClose});

  final Widget child;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final l10n = AppLocalizations.of(context)!;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.scaffoldStyle.sidebarBackgroundColor,
        border: Border(left: BorderSide(color: theme.colors.border)),
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(14)),
      ),
      child: Column(
        children: [
          _PaneHeader(onClose: onClose, title: l10n.detailPaneTitle),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                Spacing.xl2,
                0,
                Spacing.xl2,
                Spacing.xl2,
              ),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaneHeader extends StatelessWidget {
  const _PaneHeader({required this.title, required this.onClose});

  final String title;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Spacing.xl2,
        Spacing.lg,
        Spacing.sm,
        Spacing.md,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.typography.body.lg.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          FTooltip(
            tipBuilder: (_, __) =>
                Text(AppLocalizations.of(context)!.commonClose),
            child: FButton.icon(
              variant: FButtonVariant.ghost,
              size: FButtonSizeVariant.xs,
              onPress: onClose,
              semanticsLabel: AppLocalizations.of(context)!.commonClose,
              child: const Icon(SemanticIcons.actionClose),
            ),
          ),
        ],
      ),
    );
  }
}

/// 药品详情在面板里的渲染。
///
/// 复用 `MedicineDetailContent`——它本来就是 `MedicineDetailPage` 里的内容体，
/// 页面壳（`PageScaffold` + AppBar）由面板自己的头部取代。数据来源仍是
/// `medicineDetailProvider`，与整页版完全一致（同一个 family、同一份缓存）。
class _MedicineDetail extends ConsumerWidget {
  const _MedicineDetail(this.target);

  final MedicineDetailTarget target;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    if (target.source != 'cn' && target.source != 'drugbank') {
      return StateMessageView(
        title: l10n.medicineDetailUnknownSourceTitle,
        icon: SemanticIcons.statusError,
      );
    }

    final detailAsync = ref.watch(
      medicineDetailProvider(target.source, target.id),
    );

    return detailAsync.when(
      data: (detail) =>
          MedicineDetailContent(detail: detail, source: target.source),
      loading: () => const MedicineDetailLoading(),
      error: (_, __) => StateErrorView(
        title: l10n.medicineDetailErrorTitle,
        description: l10n.medicineDetailErrorDescription,
        icon: SemanticIcons.statusError,
        actionLabel: l10n.todayRetryAction,
        onAction: () =>
            ref.invalidate(medicineDetailProvider(target.source, target.id)),
      ),
    );
  }
}
