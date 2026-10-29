import 'package:flutter/widgets.dart';
import 'package:luminous/core/utils/hour_minute.dart';
import 'package:luminous/features/record/domain/entities/dashboard.dart';
import 'package:luminous/features/record/domain/entities/quick_entry_intent.dart';

/// Everything a quick-entry surface needs from the page it was tapped on.
class QuickEntryExecutionContext {
  const QuickEntryExecutionContext({
    required this.buildContext,
    required this.action,
    required this.selectedDate,
    required this.now,
    required this.canAccessProtectedData,
    required this.isAuthLoading,
  });

  final BuildContext buildContext;
  final RecordQuickAction action;
  final DateTime selectedDate;
  final DateTime now;
  final bool canAccessProtectedData;
  final bool isAuthLoading;

  /// The record's day in `yyyy-MM-dd` (selected date).
  String get occurredAt => formatCalendarDateKey(selectedDate);

  /// The record's time in `HH:mm` (now).
  String get occurredTime => formatClockHourMinute(now);

  /// Which surface the tap should open (decided by the domain intent).
  RecordQuickEntryIntent get intent => quickEntryTapIntentFor(action.type);
}
