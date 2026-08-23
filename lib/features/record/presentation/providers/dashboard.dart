import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/providers/auth_guarded.dart';
import 'package:luminous/core/providers/data_change_bus.dart';
import 'package:luminous/features/record/data/providers/record_access.dart';
import 'package:luminous/features/record/domain/entities/dashboard.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dashboard.g.dart';

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

@Riverpod(keepAlive: true)
Future<RecordDashboard> recordDashboard(Ref ref) async {
  // Watch cross-feature data change topics.
  ref.watch(dataChangeVersionProvider(DataChangeTopic.dailyRecords));

  final selectedDate = ref.watch(selectedRecordDateProvider);
  final selectedFilter = ref.watch(selectedRecordFilterProvider);

  // The record repository degrades the timeline/summary on known upstream
  // failures (empty degrade is product behaviour); a Left here means an
  // unexpected error and is projected to AsyncValue.error.
  return authGuarded(
    ref: ref,
    fetch: () async {
      final result = await ref
          .watch(recordRepositoryProvider)
          .fetchDashboard(selectedDate, filterType: selectedFilter)
          .run()
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () =>
                throw TimeoutException('Record dashboard fetch timed out'),
          );
      return result.fold((failure) => throw failure, (dashboard) => dashboard);
    },
    signedOutFallback: () => ref
        .watch(recordRepositoryProvider)
        .signedOutDashboard(selectedDate, filterType: selectedFilter),
  );
}

DateTime _dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);
