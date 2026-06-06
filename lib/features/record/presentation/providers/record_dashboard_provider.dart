import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'package:luminous/features/record/data/repositories/mock_record_repository.dart';
import 'package:luminous/features/record/domain/entities/record_dashboard.dart';
import 'package:luminous/features/auth/presentation/providers/auth_session_provider.dart';

class SelectedRecordDateNotifier extends Notifier<DateTime> {
  @override
  DateTime build() => _dateOnly(DateTime.now());

  void setDate(DateTime value) {
    state = _dateOnly(value);
  }
}

final selectedRecordDateProvider =
    NotifierProvider<SelectedRecordDateNotifier, DateTime>(
      SelectedRecordDateNotifier.new,
    );

final recordDashboardProvider = FutureProvider<RecordDashboard>((ref) {
  final session = ref.watch(authSessionProvider);
  final selectedDate = ref.watch(selectedRecordDateProvider);
  if (!session.isAuthenticated) {
    return const MockRecordRepository().fetchDashboard(selectedDate);
  }

  return ref
      .watch(recordRepositoryProvider)
      .fetchDashboard(selectedDate)
      .timeout(
        const Duration(seconds: 5),
        onTimeout: () => throw TimeoutException("请求超时，请检查网络后重试。"),
      );
});

DateTime _dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);
