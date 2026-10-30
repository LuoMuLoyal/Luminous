import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/providers/session/session_snapshot.dart';
import 'package:luminous/core/widgets/common/feedback/page_state.dart';
import 'package:luminous/features/record/domain/entities/dashboard.dart';
import 'package:luminous/features/record/presentation/providers/dashboard.dart';

/// Dashboard data for the `record` surface, resolved into the shared page-state
/// machine instead of a bare value.
///
/// 两个刻意不做的事：
///
/// - 不用 `?? RecordDashboard.signedOut(...)` 把 `AsyncValue` 压平。记录数据
///   （症状、用药、饮水）的加载失败一旦被译成「今天没有记录」，与真的空一天
///   在界面上无法区分——这一层必须保留 [PageViewStateFatalError]。
/// - 不在刷新时回落到骨架。`isLoading` 与 `hasValue` 可以同时为真，而看板挂在
///   六个 `DataChangeBus` 主题上，刷新才是这一页的常态。
///
/// 区块与页面都只消费这一个 provider，状态处理因此收敛在一处。
final recordSurfaceStateProvider = Provider<PageViewState<RecordDashboard>>(
  (ref) {
    return resolvePageViewState<RecordDashboard>(
      session: ref.watch(authSessionProvider),
      data: ref.watch(recordDashboardProvider),
    );
  },
  name: 'recordSurfaceState',
);
