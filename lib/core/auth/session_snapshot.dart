import 'package:flutter/foundation.dart' show immutable, listEquals;

/// Neutral, feature-free projection of the signed-in account.
///
/// `lib/core/**` may not import `lib/features/**` (rule `core_not_import_features`),
/// so core cannot hold the feature-owned `AuthUser` entity. Instead it stores
/// this value type, which mirrors the account fields cross-cutting layers read
/// (push alias syncing, display names, the signed-out banner, profile summary).
///
/// Feature code keeps using its own `AuthUser`; `lib/app/` adapts between the
/// two at the composition root.
@immutable
class SessionUserSnapshot {
  const SessionUserSnapshot({
    required this.id,
    this.email,
    this.nickname,
    this.avatar,
    this.emailVerifiedAt,
    this.hasPassword = false,
    this.lastLoginAt,
    this.linkedIdentities = const <SessionLinkedIdentity>[],
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String? email;
  final String? nickname;
  final String? avatar;
  final DateTime? emailVerifiedAt;
  final bool hasPassword;
  final DateTime? lastLoginAt;
  final List<SessionLinkedIdentity> linkedIdentities;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get emailVerified => emailVerifiedAt != null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionUserSnapshot &&
          other.id == id &&
          other.email == email &&
          other.nickname == nickname &&
          other.avatar == avatar &&
          other.emailVerifiedAt == emailVerifiedAt &&
          other.hasPassword == hasPassword &&
          other.lastLoginAt == lastLoginAt &&
          listEquals(other.linkedIdentities, linkedIdentities) &&
          other.createdAt == createdAt &&
          other.updatedAt == updatedAt;

  @override
  int get hashCode => Object.hash(
    id,
    email,
    nickname,
    avatar,
    emailVerifiedAt,
    hasPassword,
    lastLoginAt,
    Object.hashAll(linkedIdentities),
    createdAt,
    updatedAt,
  );

  @override
  String toString() =>
      'SessionUserSnapshot(id: $id, email: $email, nickname: $nickname)';
}

/// Neutral projection of one OAuth/mail identity linked to the account.
@immutable
class SessionLinkedIdentity {
  const SessionLinkedIdentity({
    required this.id,
    required this.provider,
    this.email,
    this.emailVerifiedAt,
    this.linkedAt,
  });

  final String id;
  final String provider;
  final String? email;
  final DateTime? emailVerifiedAt;
  final DateTime? linkedAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionLinkedIdentity &&
          other.id == id &&
          other.provider == provider &&
          other.email == email &&
          other.emailVerifiedAt == emailVerifiedAt &&
          other.linkedAt == linkedAt;

  @override
  int get hashCode =>
      Object.hash(id, provider, email, emailVerifiedAt, linkedAt);
}

/// Successful remote authentication, reduced to what core needs.
///
/// The token pair stays in the feature repository / session store; core only
/// needs the account identity to update the UI session state.
@immutable
class SessionSnapshot {
  const SessionSnapshot({required this.user});

  final SessionUserSnapshot user;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is SessionSnapshot && other.user == user;

  @override
  int get hashCode => user.hashCode;

  @override
  String toString() => 'SessionSnapshot(user: $user)';
}
