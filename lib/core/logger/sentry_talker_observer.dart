import 'dart:async';

import 'package:luminous/core/network/api_exception.dart';
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
/// The trace id attached to the [Hint] is per-error: the backend trace id of
/// the failing request ([LucentApiException.traceId]) when the wrapped error
/// is an API exception, otherwise the best-effort [TraceContext.lastTraceId].
/// `main.dart`'s `beforeSend` promotes this hint value to the `trace_id` tag.
class SentryTalkerObserver extends TalkerObserver {
  @override
  void onError(TalkerError err) {
    unawaited(
      Sentry.captureException(
        err.error,
        stackTrace: err.stackTrace,
        hint: _buildHint(err.message, err.error),
      ),
    );
  }

  @override
  void onException(TalkerException err) {
    unawaited(
      Sentry.captureException(
        err.exception,
        stackTrace: err.stackTrace,
        hint: _buildHint(err.message, err.exception),
      ),
    );
  }

  /// Builds the [Hint] forwarded to Sentry, attaching the trace id of the
  /// failing request (when available) for Jaeger correlation.
  Hint _buildHint(String? message, Object? error) {
    final traceId = switch (error) {
      LucentApiException(:final traceId) => traceId,
      _ => TraceContext.lastTraceId,
    };
    return Hint.withMap({
      'talker_message': message,
      if (traceId != null) 'trace_id': traceId,
    });
  }
}
