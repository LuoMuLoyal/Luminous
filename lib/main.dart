import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/app/app.dart';
import 'package:luminous/core/config/env_reader.dart';
import 'package:luminous/core/config/env_keys.dart';
import 'package:luminous/features/today/data/repositories/mock_repository.dart';
import 'package:luminous/features/report/data/repositories/mock_repository.dart';
import 'package:luminous/features/record/data/repositories/mock_repository.dart';
import 'package:luminous/features/mine/data/repositories/mock_repository.dart';
import 'package:luminous/features/mine/presentation/providers/dashboard_provider.dart';
import 'package:luminous/features/medicine/data/repositories/mock_workspace_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> main() async {
  await _initSentry();

  unawaited(
    runZonedGuarded(
      () async {
        WidgetsFlutterBinding.ensureInitialized();

        FlutterError.onError = (details) {
          FlutterError.presentError(details);
          Sentry.captureException(details.exception, stackTrace: details.stack);
        };

        runApp(
          ProviderScope(
            overrides: kDebugMode
                ? [
                    todayRepositoryProvider.overrideWith(
                      (ref) => const MockTodayRepository(),
                    ),
                    reportRepositoryProvider.overrideWith(
                      (ref) => const MockReportRepository(),
                    ),
                    recordRepositoryProvider.overrideWith(
                      (ref) => const MockRecordRepository(),
                    ),
                    mineRepositoryProvider.overrideWith(
                      (ref) => const MockMineRepository(),
                    ),
                    medicineWorkspaceRepositoryProvider.overrideWith(
                      (ref) => const MockMedicineWorkspaceRepository(),
                    ),
                  ]
                : [],
            child: const LuminousApp(),
          ),
        );
      },
      (error, stackTrace) {
        Sentry.captureException(error, stackTrace: stackTrace);
      },
    ),
  );
}

/// Initializes Sentry if a DSN is configured.
///
/// In debug mode without a DSN, this is a no-op — the Sentry SDK runs in
/// a disabled state and all capture calls are silently dropped.
Future<void> _initSentry() async {
  final dsn = EnvReader.string(EnvKey.sentryDsn);

  await SentryFlutter.init((options) {
    options.dsn = dsn.isEmpty ? null : dsn;
    options.tracesSampleRate = kReleaseMode ? 0.2 : 1.0;
    options.attachStacktrace = true;
    options.sendDefaultPii = false;
  });
}
