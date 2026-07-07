import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/app/app.dart';
import 'package:luminous/features/today/data/repositories/mock_repository.dart';
import 'package:luminous/features/report/data/repositories/mock_repository.dart';
import 'package:luminous/features/record/data/repositories/mock_repository.dart';
import 'package:luminous/features/mine/data/repositories/mock_repository.dart';
import 'package:luminous/features/mine/presentation/providers/dashboard_provider.dart';
import 'package:luminous/features/medicine/data/repositories/mock_workspace_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
}
