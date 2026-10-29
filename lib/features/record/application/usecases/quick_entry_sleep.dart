import 'package:flutter/material.dart' show TimeOfDay;
import 'package:luminous/features/record/domain/entities/inputs.dart';
import 'package:luminous/features/record/domain/entities/record.dart';
import 'package:luminous/features/record/domain/services/hour_minute.dart';
import 'package:luminous/features/record/domain/services/sleep_entry.dart';
import 'package:luminous/features/record/domain/undo/quick_entry_undo.dart';

/// Fallback bedtime/wake-time when there is no sleep history to prefill from
/// (the nap window is supplied by the sheet when the user switches type).
const TimeOfDay kDefaultSleepBedtime = TimeOfDay(hour: 23, minute: 0);
const TimeOfDay kDefaultSleepWakeTime = TimeOfDay(hour: 7, minute: 0);

/// The sheet's initial state for a sleep quick entry.
class SleepQuickEntryPrefill {
  const SleepQuickEntryPrefill({
    required this.kind,
    required this.bedtime,
    required this.wakeTime,
  });

  const SleepQuickEntryPrefill.fallback()
    : kind = SleepEntryKind.nightSleep,
      bedtime = kDefaultSleepBedtime,
      wakeTime = kDefaultSleepWakeTime;

  final SleepEntryKind kind;
  final TimeOfDay bedtime;
  final TimeOfDay wakeTime;
}

/// What the sleep sheet collected; enough to build the record it writes.
class SleepQuickEntryDraft {
  const SleepQuickEntryDraft({
    required this.kind,
    required this.bedtime,
    required this.wakeTime,
    this.quality,
    this.note,
  });

  final SleepEntryKind kind;
  final TimeOfDay bedtime;
  final TimeOfDay wakeTime;
  final String? quality;
  final String? note;
}

/// Outcome of a sleep quick entry write.
sealed class SleepQuickEntryOutcome {
  const SleepQuickEntryOutcome();
}

/// The record was created; [recordId] is what the undo command deletes.
final class SleepQuickEntrySaved extends SleepQuickEntryOutcome {
  const SleepQuickEntrySaved(this.recordId);

  final String recordId;
}

/// The write failed; the caller surfaces a "create failed" toast.
final class SleepQuickEntryWriteFailed extends SleepQuickEntryOutcome {
  const SleepQuickEntryWriteFailed(this.error);

  final Object error;
}

/// The draft was invalid (no times / zero duration) — nothing was written and
/// the sheet's own validation is expected to have caught it first.
final class SleepQuickEntryInvalidDraft extends SleepQuickEntryOutcome {
  const SleepQuickEntryInvalidDraft();
}

/// One-time sleep quick entry: prefill the sheet from history, then write
/// exactly one sleep record.
///
/// The record's day (`occurredAt`) is the selected date and its time is the
/// wake time (wake-date convention); the duration comes from the bedtime/wake
/// pair and rides along in the payload.
///
/// UI is not this class's business: [resolvePrefill] feeds the sheet,
/// [saveDraft] persists what the sheet returned, and the caller (presentation)
/// decides what to toast and whether to offer undo.
class SleepQuickEntryFlow {
  const SleepQuickEntryFlow({
    required this.repository,
    required this.emitDataChange,
  });

  /// Read/write access to daily records (the sleep write + the prefill read).
  final SleepQuickEntryRepository repository;
  final EmitDataChangeTopic emitDataChange;

  /// Prefill from the most recent sleep record on [selectedDate] or the day
  /// before; falls back to a night-sleep 23:00–07:00 window when there is no
  /// usable history or the read fails (a failed read never blocks entry).
  Future<SleepQuickEntryPrefill> resolvePrefill(DateTime selectedDate) async {
    final List<DailyRecordItem> records;
    try {
      records = await _fetchRecentSleepRecords(selectedDate);
    } catch (_) {
      return const SleepQuickEntryPrefill.fallback();
    }

    for (final record in records) {
      final bedtime = _clockOf(record.payload?['startedAt']);
      final wakeTime = _clockOf(record.payload?['endedAt']);
      if (bedtime != null && wakeTime != null) {
        return SleepQuickEntryPrefill(
          kind: SleepEntryKind.fromPayload(record.payload?['sleepType']),
          bedtime: bedtime,
          wakeTime: wakeTime,
        );
      }
    }
    return const SleepQuickEntryPrefill.fallback();
  }

  /// Writes the sheet's draft as a single `sleep` daily record.
  Future<SleepQuickEntryOutcome> saveDraft({
    required DateTime recordDate,
    required SleepQuickEntryDraft draft,
  }) async {
    final payload = buildSleepPayload(
      recordDate: recordDate,
      bedtime: draft.bedtime,
      wakeTime: draft.wakeTime,
      kind: draft.kind,
      quality: draft.quality,
    );
    if (payload == null) return const SleepQuickEntryInvalidDraft();

    try {
      final item = await repository.create(
        DailyRecordCreateInput(
          kind: DailyRecordKind.sleep,
          occurredAt: formatCalendarDateKey(recordDate),
          occurredTime: formatHourMinuteOfDay(
            draft.wakeTime.hour,
            draft.wakeTime.minute,
          ),
          note: draft.note,
          payload: payload,
        ),
      );
      emitDataChange(QuickEntryDataChange.dailyRecords);
      return SleepQuickEntrySaved(item.id);
    } catch (error) {
      return SleepQuickEntryWriteFailed(error);
    }
  }

  /// The selected date and the day before it, newest event first.
  Future<List<DailyRecordItem>> _fetchRecentSleepRecords(
    DateTime selectedDate,
  ) async {
    final dates = [
      selectedDate.subtract(const Duration(days: 1)),
      selectedDate,
    ];
    final items = <DailyRecordItem>[];
    for (final date in dates) {
      final page = await repository.fetchRecords(
        formatCalendarDateKey(date),
        kind: DailyRecordKind.sleep.name,
        pageSize: 20,
      );
      items.addAll(page.items);
    }
    items.sort((a, b) => _eventAt(b).compareTo(_eventAt(a)));
    return items;
  }

  static DateTime _eventAt(DailyRecordItem record) {
    for (final key in const ['endedAt', 'startedAt']) {
      // The payload is locally written JSON, but its types can still be
      // corrupted by older versions or bad data; a non-String value is treated
      // as "key absent" so the loop falls through to the next candidate.
      final raw = record.payload?[key];
      final parsed = DateTime.tryParse(raw is String ? raw : '');
      if (parsed != null) return parsed;
    }
    return parseRecordDateTime(
          record.occurredAt,
          occurredTime: record.occurredTime,
        ) ??
        DateTime.fromMillisecondsSinceEpoch(0);
  }

  static TimeOfDay? _clockOf(Object? value) {
    if (value is! String) return null;
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return null;
    final local = parsed.toLocal();
    return TimeOfDay(hour: local.hour, minute: local.minute);
  }
}

/// The read/write surface a sleep quick entry needs.
abstract interface class SleepQuickEntryRepository {
  /// Creates a daily record (throws on failure).
  Future<DailyRecordItem> create(DailyRecordCreateInput input);

  /// Fetches one page of records for a `yyyy-MM-dd` date, optionally by kind.
  Future<DailyRecordListData> fetchRecords(
    String date, {
    String? kind,
    int pageSize,
  });
}

/// Parses a record's `occurredAt` (+ optional `occurredTime`) into a local
/// `DateTime`, returning null when the date is unparseable.
DateTime? parseRecordDateTime(String occurredAt, {String? occurredTime}) {
  final date = DateTime.tryParse(occurredAt);
  if (date == null) return null;
  final day = DateTime(date.year, date.month, date.day);
  final clock = parseHourMinuteOfDay(occurredTime);
  if (clock == null) return day;
  return DateTime(day.year, day.month, day.day, clock.hour, clock.minute);
}
