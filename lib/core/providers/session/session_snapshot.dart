/// 会话快照的只读接缝。
///
/// presentation 层只应观察"当前会话是什么"，而不应依赖 `lib/core/auth/`
/// 的具体实现（那层持有 store、Dio 回调、refresh 流程等 I/O 细节）。
/// 这里统一再导出会话状态契约与只读 provider，作为展示层唯一入口。
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/app/auth_session_adapter.dart';

export 'package:luminous/app/auth_session_adapter.dart'
    show authSessionProvider;
export 'package:luminous/core/auth/session_state.dart'
    show
        AuthRequiredException,
        AuthSessionState,
        AuthSessionStateStatus,
        kSessionRestoreTimeout,
        pendingAuthSessionResolution;

/// 当前会话的只读快照。
///
/// 展示层用 `ref.watch(authSessionSnapshotProvider)` 读取会话状态；
/// 需要触发登录/登出等动作的少数组合根仍在 `core/auth/` 内完成。
final authSessionSnapshotProvider = Provider<AuthSessionState>((ref) {
  return ref.watch(authSessionProvider);
});
