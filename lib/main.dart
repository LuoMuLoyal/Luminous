import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/app/bootstrap.dart';
import 'package:luminous/app/window_manager_setup.dart';
import 'package:luminous/core/config/env_keys.dart';
import 'package:luminous/core/config/env_reader.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> main() async {
  // Keep binding initialization in the root zone so that a synchronous
  // failure during init crashes visibly instead of being silently swallowed.
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize desktop window management (no-op on web/mobile).
  await initDesktopWindow();

  await _initSentry();

  // Catch framework errors (sync errors in widget build / layout / paint).
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    unawaited(
      Sentry.captureException(details.exception, stackTrace: details.stack),
    );
  };

  // Catch uncaught async errors without creating a new zone — avoids
  // "Zone mismatch" between binding init and runApp.
  PlatformDispatcher.instance.onError = (error, stack) {
    unawaited(Sentry.captureException(error, stackTrace: stack));
    return true;
  };

  runApp(const ProviderScope(child: LuminousApp()));
}

/// Initializes Sentry if a DSN is configured.
///
/// When the DSN is empty (e.g. debug builds without Sentry configured),
/// the entire [SentryFlutter.init] call is skipped to avoid any SDK
/// overhead. All [Sentry.captureException] calls are safe no-ops when
/// the SDK has not been initialized.
///
/// If the DSN is non-empty but invalid (e.g. a placeholder URL was
/// accidentally injected), the error is caught and logged so the app
/// can still start — Sentry simply won't be active.
Future<void> _initSentry() async {
  final dsn = EnvReader.string(EnvKey.sentryDsn);
  if (dsn.isEmpty) return;

  try {
    await SentryFlutter.init((options) {
      options.dsn = dsn;
      // Trace every request so the propagated W3C `traceparent` always
      // carries the sampled flag (`01`). With a lower rate, unsampled
      // requests would send sampled=`00` and Lucent's OTel (parent-based
      // sampler) would drop their spans in Jaeger.
      options.tracesSampleRate = 1.0;
      // Propagate the W3C `traceparent` header on outgoing requests so the
      // backend OTel SDK continues the same trace — one traceId across
      // Sentry + Jaeger + the help-page "last trace id" display.
      options.propagateTraceparent = true;
      options.attachStacktrace = true;
      options.sendDefaultPii = false;
      // Request-bound errors get their trace context auto-bound by
      // `SentryDioInterceptor`; for errors forwarded by the Talker observer
      // we attach the per-error backend traceId (`trace_id` tag) carried in
      // the hint — no more global "last request" tag.
      options.beforeSend = (event, hint) {
        final traceId = hint.get('trace_id') as String?;
        if (traceId != null && traceId.isNotEmpty) {
          event.tags ??= <String, String>{};
          event.tags!['trace_id'] = traceId;
        }
        return event;
      };
    });
  } catch (e, st) {
    debugPrint(
      '⚠️ Sentry initialization failed (DSN invalid?), '
      'Sentry disabled for this session.\n  Error: $e\n  Stack: $st',
    );
  }
}
