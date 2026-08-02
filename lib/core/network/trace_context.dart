/// Global, ref-free access to the latest backend trace id.
///
/// Kept outside Riverpod so non-widget / non-provider code (Talker
/// middleware, Sentry `beforeSend`) can read the value without a `Ref`.
/// Written by the `onTraceId` callback of `LucentDioClient`, which keeps
/// `lastTraceIdProvider` in sync.
class TraceContext {
  TraceContext._();

  /// The most recent backend trace id seen by the trace interceptor, or
  /// null before the first request.
  ///
  /// Best-effort value: with concurrent requests the last one to complete
  /// wins, so this is an approximation for diagnostics, not a per-request
  /// correlation guarantee. A plain mutable field (no notifier) is
  /// intentional so sync, non-widget code (Talker / Sentry hooks) can read
  /// it without a `Ref`.
  static String? lastTraceId;
}
