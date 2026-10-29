import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart' show OrdinalSortKey;
import 'package:forui/forui.dart';
import 'package:luminous/features/review/domain/entities/dashboard.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// 周期切换组件：周|月 FTabs，映射 [ReviewDashboardRange.last7Days] /
/// [ReviewDashboardRange.last30Days]。
///
/// 放置于 review 首屏顶栏下首行，直接生效——切换后 dashboard 数据重新请求，
/// 切换期间用 `reviewLastDashboardProvider` 旧数据展示（轻量加载态，
/// 不整页骨架）。
class ReviewPeriodSwitch extends StatelessWidget {
  const ReviewPeriodSwitch({
    super.key,
    required this.selectedRange,
    required this.onRangeChanged,
  });

  /// 当前选中的周期范围；仅接受 [ReviewDashboardRange.last7Days] 或
  /// [ReviewDashboardRange.last30Days]，custom 不在本组件路径。
  final ReviewDashboardRange selectedRange;

  /// 周期切换回调；参数为用户选中的 [ReviewDashboardRange]。
  final ValueChanged<ReviewDashboardRange> onRangeChanged;

  static const _ranges = [
    ReviewDashboardRange.last7Days,
    ReviewDashboardRange.last30Days,
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final selectedIndex = _ranges.indexOf(selectedRange);
    final safeIndex = selectedIndex < 0 ? 0 : selectedIndex;

    return Semantics(
      container: true,
      sortKey: const OrdinalSortKey(0.5),
      explicitChildNodes: true,
      child: FTabs(
        key: const ValueKey('review-period-switch'),
        control: FTabControl.lifted(
          index: safeIndex,
          onChange: (index) => onRangeChanged(_ranges[index]),
        ),
        children: [
          FTabEntry(
            label: Text(l10n.reviewPeriodWeek),
            child: const SizedBox.shrink(),
          ),
          FTabEntry(
            label: Text(l10n.reviewPeriodMonth),
            child: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
