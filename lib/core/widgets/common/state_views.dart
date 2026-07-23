/// Barrel export for state views and skeleton components.
///
/// Historical note: these components were originally all in this file. They have
/// been split into:
/// - [state_message.dart] — empty state / error message views
/// - [skeleton.dart] — shimmer skeleton components
///
/// New code should import specific files directly rather than relying on this barrel.
library;

export 'page_state.dart';
export 'skeleton.dart';
export 'state_message.dart';
