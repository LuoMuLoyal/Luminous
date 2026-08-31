/// Barrel export for state views and skeleton components.
///
/// Historical note: these components were originally all in this file. They have
/// been split into:
/// - [feedback/state_message.dart] — empty state / error message views
/// - [feedback/skeleton.dart] — shimmer skeleton components
///
/// New code should import specific files directly rather than relying on this barrel.
library;

export 'feedback/page_state.dart';
export 'feedback/skeleton.dart';
export 'feedback/state_message.dart';
