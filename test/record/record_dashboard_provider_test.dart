import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/record/presentation/providers/record_dashboard_provider.dart';

void main() {
  test('recordDashboardProvider is defined and accessible', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    // Verify the provider is defined and can be read (even if it returns a future)
    expect(c.read(recordDashboardProvider), isA<Object>());
  });

  test('selectedRecordFilterProvider initial state is null', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    expect(c.read(selectedRecordFilterProvider), isNull);
  });

  test('selectedRecordDateProvider defaults to today', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final d = c.read(selectedRecordDateProvider);
    final today = DateTime.now();
    expect(d.year, today.year);
    expect(d.month, today.month);
    expect(d.day, today.day);
  });
}
