/// Mocktail-based mocks for commonly tested interfaces.
///
/// Usage:
/// ```dart
/// import 'package:luminous/test/helpers/mocks.dart';
///
/// void main() {
///   late MockReportRepository repo;
///
///   setUp(() {
///     repo = MockReportRepository();
///     when(() => repo.fetchDashboard(any())).thenAnswer(
///       (_) async => MockReportRepository.previewDashboard,
///     );
///   });
///
///   test('loads dashboard', () async {
///     final dashboard = await repo.fetchDashboard(ReportDashboardQuery(...));
///     verify(() => repo.fetchDashboard(any())).called(1);
///   });
/// }
/// ```
///
/// Prefer hand-written Fakes (e.g. `MockTodayRepository`) when you need
/// rich, reusable test data. Use these mocktail mocks when you need
/// interaction verification (`verify`) or fine-grained stub control.
library;

import 'package:luminous/core/network/session_store.dart';
import 'package:luminous/features/health_context/domain/repositories/snapshot.dart';
import 'package:luminous/features/medicine/domain/repositories/dose_log.dart';
import 'package:luminous/features/medicine/domain/repositories/workspace.dart';
import 'package:luminous/features/mine/domain/repositories/profile.dart';
import 'package:luminous/features/record/domain/repositories/record.dart';
import 'package:luminous/features/report/domain/repositories/report.dart';
import 'package:luminous/features/search/domain/repositories/search.dart';
import 'package:luminous/features/today/domain/repositories/dashboard.dart';
import 'package:mocktail/mocktail.dart';

// ── Session Store ─────────────────────────────────────────────

class MockLucentSessionStore extends Mock implements LucentSessionStore {}

// ── Feature Repositories ──────────────────────────────────────

class MockTodayRepository extends Mock implements TodayRepository {}

class MockRecordRepository extends Mock implements RecordRepository {}

class MockReportRepository extends Mock implements ReportRepository {}

class MockMedicineWorkspaceRepository extends Mock
    implements MedicineWorkspaceRepository {}

class MockDoseLogRepository extends Mock implements DoseLogRepository {}

class MockMineRepository extends Mock implements MineRepository {}

class MockHealthContextRepository extends Mock
    implements HealthContextRepository {}

class MockMedicineSearchRepository extends Mock
    implements MedicineSearchRepository {}

/// Register fallback values for mocktail's `any()` matcher.
///
/// Call this once in `setUpAll` when using mocks that have methods with
/// positional or named parameters requiring non-nullable fallbacks.
void registerMocktailFallbacks() {
  registerFallbackValue(_dummyDateTime);
}

final DateTime _dummyDateTime = DateTime(2026, 1, 1);
