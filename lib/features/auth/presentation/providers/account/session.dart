// Re-export from core/auth/ — session state is a cross-cutting concern.
// This file is kept for backward compatibility; new imports should use
// package:luminous/core/providers/session/session_snapshot.dart directly.
export 'package:luminous/core/auth/session_state.dart';
export 'package:luminous/core/providers/session/session_snapshot.dart';
