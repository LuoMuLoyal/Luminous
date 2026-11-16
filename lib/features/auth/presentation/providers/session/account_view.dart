import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/features/auth/domain/entities/session.dart';

/// Typed access to the account entity carried by [AuthSessionState].
///
/// `AuthSessionState.user` is declared `Object?` in core because `lib/core/**`
/// must not import `lib/features/**`; this extension is the feature-side
/// accessor, so `session.user` keeps its rich `AuthUser` type for
/// presentation code (unknown payloads read as `null`).
extension AuthSessionAccountView on AuthSessionState {
  AuthUser? get user => this.user as AuthUser?;
}
