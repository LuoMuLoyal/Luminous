import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talker_flutter/talker_flutter.dart' as talker;

/// Application log severity levels.
///
/// Maps to [talker.Talker]'s internal log level filtering at runtime.
/// Setting a [LogLevel] suppresses all messages below that level.
enum LogLevel {
  verbose,
  info,
  warning,
  error,
  none;

  /// Parses a string into a [LogLevel], defaulting to [info].
  static LogLevel fromString(String? value) {
    return switch (value?.toLowerCase()) {
      'verbose' => LogLevel.verbose,
      'info' => LogLevel.info,
      'warning' => LogLevel.warning,
      'error' => LogLevel.error,
      'none' => LogLevel.none,
      _ => LogLevel.info,
    };
  }
}

/// Global [talker.Talker] instance provider.
///
/// Usage in widgets/providers:
/// ```dart
/// final talker = ref.read(talkerProvider);
/// talker.info('User logged in');
/// talker.error('Failed to fetch data: $e');
/// ```
///
/// In release builds, logging is disabled via [talker.TalkerSettings.enabled].
final talkerProvider = Provider<talker.Talker>((ref) {
  return talker.Talker(
    settings: talker.TalkerSettings(
      enabled: !kReleaseMode,
      useConsoleLogs: kDebugMode,
    ),
  );
});

/// Applies a [LogLevel] to the given [talker.Talker] instance at runtime.
///
/// For [LogLevel.none], disables the Talker entirely.
/// For other levels, reconfigures the internal logger filter.
void applyLogLevelToTalker(talker.Talker talkerInstance, LogLevel level) {
  if (level == LogLevel.none) {
    talkerInstance.disable();
    return;
  }
  talkerInstance.enable();
  talkerInstance.configure(
    logger: talker.TalkerLogger(
      settings: talker.TalkerLoggerSettings(
        level: switch (level) {
          LogLevel.verbose => talker.LogLevel.verbose,
          LogLevel.info => talker.LogLevel.info,
          LogLevel.warning => talker.LogLevel.warning,
          LogLevel.error => talker.LogLevel.error,
          LogLevel.none => talker.LogLevel.error,
        },
      ),
    ),
  );
}
