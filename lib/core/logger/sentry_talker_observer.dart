import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:talker_flutter/talker_flutter.dart';

/// Bridges [Talker] error/exception events to [Sentry].
///
/// Attached as a [TalkerObserver] on the global Talker instance so that any
/// `talker.error(...)` or `talker.handle(...)` call is automatically forwarded
/// to Sentry without changing call sites.
///
/// Only error and exception levels are forwarded — info/warning/debug logs
/// stay in Talker's in-memory history and console output only.
class SentryTalkerObserver extends TalkerObserver {
  @override
  void onError(TalkerError err) {
    Sentry.captureException(
      err.error,
      stackTrace: err.stackTrace,
      hint: Hint.withMap({'talker_message': err.message}),
    );
  }

  @override
  void onException(TalkerException err) {
    Sentry.captureException(
      err.exception,
      stackTrace: err.stackTrace,
      hint: Hint.withMap({'talker_message': err.message}),
    );
  }
}
