import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/app/bootstrap.dart';
import 'package:luminous/core/config/env_reader.dart';
import 'package:luminous/core/config/env_keys.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> main() async {
  await _initSentry();

  // Keep binding initialization outside the zone so that a synchronous
  // failure during init crashes visibly instead of being silently swallowed
  // by the zone's onError handler (which would leave the app in a limbo
  // state with no UI and no crash).
  WidgetsFlutterBinding.ensureInitialized();

  await runZonedGuarded(
    () async {
      FlutterError.onError = (details) {
        FlutterError.presentError(details);
        Sentry.captureException(details.exception, stackTrace: details.stack);
      };

      runApp(const ProviderScope(child: LuminousApp()));
    },
    (error, stackTrace) {
      Sentry.captureException(error, stackTrace: stackTrace);
    },
  );
}

/// Initializes Sentry if a DSN is configured.
///
/// When the DSN is empty (e.g. debug builds without Sentry configured),
/// the entire [SentryFlutter.init] call is skipped to avoid any SDK
/// overhead. All [Sentry.captureException] calls are safe no-ops when
/// the SDK has not been initialized.
Future<void> _initSentry() async {
  final dsn = EnvReader.string(EnvKey.sentryDsn);
  if (dsn.isEmpty) return;

  await SentryFlutter.init((options) {
    options.dsn = dsn;
    options.tracesSampleRate = kReleaseMode ? 0.2 : 1.0;
    options.attachStacktrace = true;
    options.sendDefaultPii = false;
  });
}
