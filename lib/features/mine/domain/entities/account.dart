/// The subset of the signed-in account the Mine dashboard renders.
///
/// Mine's repository needs the account header (name / avatar / email / linked
/// identities) but must not depend on the auth feature's `AuthUser` — `data/`
/// may only read its own feature's `domain/`. The composition root maps
/// `AuthUser` onto this value at construction time.
library;

final class AccountIdentity {
  const AccountIdentity({
    required this.id,
    this.email,
    this.nickname,
    this.avatar,
    this.emailVerifiedAt,
    this.hasPassword = false,
    this.linkedIdentityCount = 0,
    this.lastLoginAt,
  });

  final String id;
  final String? email;
  final String? nickname;
  final String? avatar;
  final DateTime? emailVerifiedAt;
  final bool hasPassword;
  final int linkedIdentityCount;
  final DateTime? lastLoginAt;

  bool get emailVerified => emailVerifiedAt != null;
}
