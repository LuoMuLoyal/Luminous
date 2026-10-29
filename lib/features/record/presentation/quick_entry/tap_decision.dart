import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/utils/hour_minute.dart';
import 'package:luminous/features/record/presentation/providers/dashboard.dart';
import 'package:luminous/features/record/presentation/providers/time.dart';

/// The non-UI decision a quick-entry tap starts from: who is signed in, which
/// date the record belongs to, what time it is.
///
/// Reading all four from one place keeps the "tap" entry points short and keeps
/// the auth gate at a single call site.
class RecordQuickEntryDecision {
  const RecordQuickEntryDecision({
    required this.selectedDate,
    required this.now,
    required this.canAccessProtectedData,
    required this.isAuthLoading,
  });

  factory RecordQuickEntryDecision.read(WidgetRef ref) {
    final session = ref.read(authSessionProvider);
    return RecordQuickEntryDecision(
      selectedDate: ref.read(selectedRecordDateProvider),
      now: ref.read(currentRecordDateTimeProvider),
      canAccessProtectedData: session.canAccessProtectedData,
      isAuthLoading: session.isLoading,
    );
  }

  final DateTime selectedDate;
  final DateTime now;
  final bool canAccessProtectedData;
  final bool isAuthLoading;

  /// The record's day in `yyyy-MM-dd`.
  String get occurredAt => formatCalendarDateKey(selectedDate);

  /// The record's time in `HH:mm`.
  String get occurredTime => formatClockHourMinute(now);
}
