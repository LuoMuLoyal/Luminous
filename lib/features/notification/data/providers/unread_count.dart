import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/logger/logger.dart';
import 'package:luminous/core/providers/auth_guarded.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/lucent.dart';

part 'unread_count.g.dart';

/// Unread notification count provider.
///
/// This is a pure data-fetching provider (no presentation state) that
/// lives in the data layer so that other features (e.g. mine) can depend
/// on it without importing notification/presentation/.
///
/// 未读徽章是后台轮询类展示（shell / mine / today / medicine 多处消费）：
/// repository 边界如实把失败映射为 Left，这里 fold 降级返回 0 并记录日志
/// （原 repository 内 catch→0 的 best-effort 合同上移到消费方，产品行为不变
/// ——单次失败不打断页面，下次轮询自然恢复）。
@Riverpod(keepAlive: true)
Future<int> notificationUnreadCount(Ref ref) async {
  return authGuarded(
    ref: ref,
    fetch: () async {
      try {
        final repo = ref.watch(notificationRepositoryProvider);
        final result = await repo.getUnreadCount().run();
        final count = result.fold((failure) {
          appTalker.warning('notificationUnreadCount 获取失败,降级为 0: $failure');
          return 0;
        }, (count) => count);
        return count;
      } catch (e) {
        // 协议异常（非 problem+json 错误体）逃逸 .run()：未读徽章属后台
        // 轮询类 best-effort 展示，与 Left 一样降级为 0 并记录，不打断页面
        // （today _unreadNotificationsFlag 同款合同），下次轮询自然恢复。
        appTalker.warning('notificationUnreadCount 协议异常,降级为 0: $e');
        return 0;
      }
    },
    signedOutFallback: () => pendingAuthSessionResolution(),
  );
}
