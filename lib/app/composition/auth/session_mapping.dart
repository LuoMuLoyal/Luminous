/// 把 feature 侧的 auth 实体映射成 feature-free 的快照类型。
///
/// 住在**组合根**而不是 `core/auth/`：这一支直接认识 `features/auth` 的
/// `AuthUser` / `AuthSession`，而 `core_not_import_features` 不允许 `lib/core/**`
/// 反向依赖 feature——快照类型本身是 feature-free 的
/// (`core/auth/session_snapshot.dart`)，只有「从 feature 实体投影过来」这一步
/// 属于跨层接线，归 `lib/app/` 管。
///
/// `lib/core/auth/` 侧只依赖 [SessionUserSnapshot] / [SessionSnapshot] 这两个
/// feature-free 类型，因此 core 仍然不知道 feature 的存在。
library;

import 'package:luminous/core/auth/session_snapshot.dart';
import 'package:luminous/features/auth/domain/entities/session.dart';

extension AuthUserSnapshotX on AuthUser {
  SessionUserSnapshot toSessionSnapshot() => SessionUserSnapshot(
    id: id,
    email: email,
    nickname: nickname,
    avatar: avatar,
    emailVerifiedAt: emailVerifiedAt,
    hasPassword: hasPassword,
    lastLoginAt: lastLoginAt,
    linkedIdentities: linkedIdentities
        .map(
          (identity) => SessionLinkedIdentity(
            id: identity.id,
            provider: identity.provider,
            email: identity.email,
            emailVerifiedAt: identity.emailVerifiedAt,
            linkedAt: identity.linkedAt,
          ),
        )
        .toList(growable: false),
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}

extension AuthSessionSnapshotX on AuthSession {
  SessionSnapshot toSessionSnapshot() =>
      SessionSnapshot(user: user.toSessionSnapshot());
}
