/// Barrel file for test-only mock repository implementations.
///
/// These hand-written fakes provide preview/placeholder data for widget
/// and integration tests. They were previously located in
/// `lib/features/*/data/repositories/mock*.dart` alongside real provider
/// definitions; after the mock-removal refactor they live here exclusively.
library;

export 'mocks/medicine.dart';
export 'mocks/mine.dart';
export 'mocks/record.dart';
export 'mocks/report.dart';
export 'mocks/today.dart';
