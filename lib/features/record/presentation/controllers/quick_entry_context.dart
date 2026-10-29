import 'package:flutter/widgets.dart';
import 'package:luminous/features/record/domain/entities/dashboard.dart';

class QuickEntryExecutionContext {
  const QuickEntryExecutionContext({
    required this.buildContext,
    required this.action,
    required this.selectedDate,
    required this.now,
    required this.occurredAt,
    required this.occurredTime,
    required this.canAccessProtectedData,
    required this.isAuthLoading,
  });

  final BuildContext buildContext;
  final RecordQuickAction action;
  final DateTime selectedDate;
  final DateTime now;
  final String occurredAt;
  final String occurredTime;
  final bool canAccessProtectedData;
  final bool isAuthLoading;
}
