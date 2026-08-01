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
  static String? lastTraceId;
}
