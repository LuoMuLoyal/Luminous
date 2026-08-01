import 'dart:async';

import 'package:luminous/core/network/trace_context.dart';
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
///
/// The latest backend trace id ([TraceContext.lastTraceId]) is attached to the
/// [Hint] of every forwarded event so reports can be correlated with Jaeger
/// traces. talker_flutter 5.1.17 has no middleware API (see Task E3), so trace
/// injection happens on the Sentry path only.
class SentryTalkerObserver extends TalkerObserver {
  @override
  void onError(TalkerError err) {
    unawaited(
      Sentry.captureException(
        err.error,
        stackTrace: err.stackTrace,
        hint: _buildHint(err.message),
      ),
    );
  }

  @override
  void onException(TalkerException err) {
    unawaited(
      Sentry.captureException(
        err.exception,
        stackTrace: err.stackTrace,
        hint: _buildHint(err.message),
      ),
    );
  }

  /// Builds the [Hint] forwarded to Sentry, attaching the latest backend
  /// trace id (when available) for Jaeger correlation.
  Hint _buildHint(String? message) {
    final traceId = TraceContext.lastTraceId;
    return Hint.withMap({
      'talker_message': message,
      if (traceId != null) 'trace_id': traceId,
    });
  }
}
