// Feature-side (presentation) barrel for the core auth session state.
//
// `AuthSessionState.user` is an opaque `Object?` inside `lib/core/auth` (core
// may not import `features/auth`), so the typed accessor lives here, in the
// only layer allowed to know the account entity. Feature code imports this
// barrel instead of `core/auth/session_provider.dart` when it needs `.user`.
export 'package:luminous/app/auth_session_adapter.dart';
export 'package:luminous/features/auth/presentation/providers/session/account_view.dart';
