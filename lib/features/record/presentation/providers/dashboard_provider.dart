import 'package:clock/clock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'package:luminous/core/providers/auth_guarded.dart';
import 'package:luminous/features/record/data/repositories/mock_repository.dart';
import 'package:luminous/features/record/domain/entities/dashboard.dart';

class SelectedRecordDateNotifier extends Notifier<DateTime> {
  @override
  DateTime build() => _dateOnly(clock.now());

  void setDate(DateTime value) {
    state = _dateOnly(value);
  }
}

final selectedRecordDateProvider =
    NotifierProvider<SelectedRecordDateNotifier, DateTime>(
      SelectedRecordDateNotifier.new,
    );

class SelectedRecordFilterNotifier extends Notifier<RecordEntryType?> {
  @override
  RecordEntryType? build() => null;

  void setFilter(RecordEntryType? value) {
    state = value;
  }
}

final selectedRecordFilterProvider =
    NotifierProvider<SelectedRecordFilterNotifier, RecordEntryType?>(
      SelectedRecordFilterNotifier.new,
    );

final recordDashboardProvider = FutureProvider<RecordDashboard>((ref) async {
  final selectedDate = ref.watch(selectedRecordDateProvider);
  final selectedFilter = ref.watch(selectedRecordFilterProvider);

  return authGuarded(
    ref: ref,
    fetch: () => ref
        .watch(recordRepositoryProvider)
        .fetchDashboard(selectedDate, filterType: selectedFilter)
        .timeout(
          const Duration(seconds: 5),
          onTimeout: () => throw TimeoutException('请求超时，请检查网络后重试。'),
        ),
    signedOutFallback: () => ref
        .watch(recordRepositoryProvider)
        .signedOutDashboard(selectedDate, filterType: selectedFilter),
  );
});

DateTime _dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);
