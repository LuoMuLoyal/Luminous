/// 把 feature 侧的 auth 实体映射成 `core/auth` 的 feature-free 快照类型。
///
/// 放在 `core/auth/` 而不是组合根：这是一次**纯值映射**（无 I/O、无 Riverpod），
/// 而 `features/auth` 的登录/账号表单要用它把结果交给会话层。若留在
/// `lib/app/`，feature 就只能 import 组合根，那是主依赖环上的一条边。
///
/// 注意这仍是 core → feature(domain) 的单向引用：只取领域实体字段，不碰
/// feature 的 data / presentation。
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
