import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/providers/session/session_snapshot.dart';
import 'package:luminous/core/widgets/common/feedback/page_state.dart';
import 'package:luminous/features/medicine/domain/entities/workspace.dart';
import 'package:luminous/features/medicine/presentation/providers/workspace.dart';

/// `medicine` 表面的工作区数据，解析成共享的页面状态机而不是裸值。
///
/// 刻意**不**做的事：
///
/// - 不用 `?? MedicineWorkspace.empty()` 把加载失败吃掉。用药数据把失败渲染成
///   「没有药品」比任何错误页都危险：用户会据此以为自己的药箱是空的。
/// - 不在刷新时退回骨架。`isLoading` 与 `hasValue` 可以同时为真，而工作区会随
///   `DataChangeBus` 的用药/打卡/提醒三个主题重建，"刷新中"在这页是常态。
///
/// 组件统一 `ref.watch(medicineSurfaceStateProvider).dataOrNull`，状态处理只在这里
/// 写一次，而不是在四个区块里各写一遍。
final medicineSurfaceStateProvider = Provider<PageViewState<MedicineWorkspace>>(
  (ref) {
    return resolvePageViewState<MedicineWorkspace>(
      session: ref.watch(authSessionProvider),
      data: ref.watch(medicineWorkspaceProvider),
    );
  },
  name: 'medicineSurfaceState',
);
