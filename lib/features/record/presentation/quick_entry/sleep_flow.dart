import 'package:luminous/core/providers/data_change_bus.dart';
import 'package:luminous/features/record/domain/entities/inputs.dart';
import 'package:luminous/features/record/domain/entities/record.dart';
import 'package:luminous/features/record/presentation/quick_entry/water_flow.dart';
import 'package:luminous/features/record/presentation/services/quick_entry_undo.dart';

typedef DeleteSleepRecord = Future<void> Function(String recordId);

class SleepQuickEntryContext extends QuickEntryRecordContext {
  const SleepQuickEntryContext({
    required super.occurredAt,
    required super.occurredTime,
    required this.now,
  });

  final DateTime now;
}

enum SleepQuickEntryOutcomeType {
  started,
  wakeRecorded,
  needsStartSelection,
  invalidDuration,
}

class SleepQuickEntryOutcome {
  const SleepQuickEntryOutcome._({
    required this.type,
    this.record,
    this.merge,
    this.openStarts = const <DailyRecordItem>[],
  });

  const SleepQuickEntryOutcome.started(DailyRecordItem record)
    : this._(type: SleepQuickEntryOutcomeType.started, record: record);

  const SleepQuickEntryOutcome.wakeRecorded({
    required DailyRecordItem record,
    required SleepQuickEntryMerge merge,
  }) : this._(
         type: SleepQuickEntryOutcomeType.wakeRecorded,
         record: record,
         merge: merge,
       );

  const SleepQuickEntryOutcome.needsStartSelection(
    List<DailyRecordItem> openStarts,
  ) : this._(
        type: SleepQuickEntryOutcomeType.needsStartSelection,
        openStarts: openStarts,
      );

  const SleepQuickEntryOutcome.invalidDuration()
    : this._(type: SleepQuickEntryOutcomeType.invalidDuration);

  final SleepQuickEntryOutcomeType type;
  final DailyRecordItem? record;
  final SleepQuickEntryMerge? merge;
  final List<DailyRecordItem> openStarts;
}

class SleepQuickEntryMerge {
  const SleepQuickEntryMerge({
    required this.startRecord,
    required this.wakeRecord,
    required this.durationMinutes,
    required this.mergedInput,
  });

  final DailyRecordItem startRecord;
  final DailyRecordItem wakeRecord;
  final int durationMinutes;
  final DailyRecordCreateInput mergedInput;
}

class SleepQuickEntryFlow {
  const SleepQuickEntryFlow({
    required this.createRecord,
    required this.deleteRecord,
    required this.emitDataChange,
    required this.registerUndo,
  });

  final CreateDailyRecord createRecord;
  final DeleteSleepRecord deleteRecord;
  final EmitDataChange emitDataChange;
  final RegisterQuickEntryUndo registerUndo;

  Future<SleepQuickEntryOutcome> handleTap({
    required SleepQuickEntryContext context,
    required List<DailyRecordItem> candidateRecords,
  }) async {
    final openStarts = findOpenStarts(candidateRecords);
    if (openStarts.isEmpty) {
      final record = await _recordStart(context);
      return SleepQuickEntryOutcome.started(record);
    }
    if (openStarts.length > 1) {
      return SleepQuickEntryOutcome.needsStartSelection(openStarts);
    }
    return recordWakeForStart(context: context, startRecord: openStarts.single);
  }

  Future<SleepQuickEntryOutcome> recordWakeForStart({
    required SleepQuickEntryContext context,
    required DailyRecordItem startRecord,
  }) async {
    if (!_isWakeAfterStart(startRecord, context.now)) {
      return const SleepQuickEntryOutcome.invalidDuration();
    }

    final wakeRecord = await createRecord(_wakeInput(context, startRecord.id));
    emitDataChange(DataChangeTopic.dailyRecords);
    registerUndo(
      QuickEntryUndoAction.deleteDailyRecord(recordId: wakeRecord.id),
    );

    final merge = buildMerge(
      context: context,
      startRecord: startRecord,
      wakeRecord: wakeRecord,
    );
    return SleepQuickEntryOutcome.wakeRecorded(
      record: wakeRecord,
      merge: merge,
    );
  }

  Future<DailyRecordItem> confirmMerge(SleepQuickEntryMerge merge) async {
    final merged = await createRecord(merge.mergedInput);
    await deleteRecord(merge.startRecord.id);
    await deleteRecord(merge.wakeRecord.id);
    emitDataChange(DataChangeTopic.dailyRecords);
    return merged;
  }

  static List<DailyRecordItem> findOpenStarts(List<DailyRecordItem> records) {
    final wakeStartedIds = records
        .where(_isSleepWake)
        .map((record) => record.payload?['startedRecordId'])
        .whereType<String>()
        .toSet();
    final starts = records
        .where(_isSleepStart)
        .where((record) => !wakeStartedIds.contains(record.id))
        .toList();
    starts.sort((a, b) {
      final aAt = eventAtForRecord(a);
      final bAt = eventAtForRecord(b);
      if (aAt == null && bAt == null) return 0;
      if (aAt == null) return 1;
      if (bAt == null) return -1;
      return bAt.compareTo(aAt);
    });
    return starts;
  }

  static SleepQuickEntryMerge buildMerge({
    required SleepQuickEntryContext context,
    required DailyRecordItem startRecord,
    required DailyRecordItem wakeRecord,
  }) {
    final startAt = eventAtForRecord(startRecord);
    final endAt = eventAtForRecord(wakeRecord);
    if (startAt == null || endAt == null || !endAt.isAfter(startAt)) {
      throw StateError('Sleep wake time must be after start time.');
    }
    final durationMinutes = endAt.difference(startAt).inMinutes;
    if (durationMinutes <= 0) {
      throw StateError('Sleep duration must be positive.');
    }

    return SleepQuickEntryMerge(
      startRecord: startRecord,
      wakeRecord: wakeRecord,
      durationMinutes: durationMinutes,
      mergedInput: DailyRecordCreateInput(
        kind: DailyRecordKind.sleep,
        occurredAt: context.occurredAt,
        occurredTime: context.occurredTime,
        payload: {
          'durationMinutes': durationMinutes,
          'startAt': startAt.toUtc().toIso8601String(),
          'endAt': endAt.toUtc().toIso8601String(),
        },
      ),
    );
  }

  static DateTime? eventAtForRecord(DailyRecordItem record) {
    final eventAt = record.payload?['eventAt'];
    if (eventAt is String) {
      final parsed = DateTime.tryParse(eventAt);
      if (parsed != null) return parsed;
    }
    final date = DateTime.tryParse(record.occurredAt);
    if (date == null) return null;
    final time = _parseHourMinute(record.occurredTime);
    if (time == null) return date;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<DailyRecordItem> _recordStart(SleepQuickEntryContext context) async {
    final record = await createRecord(
      DailyRecordCreateInput(
        kind: DailyRecordKind.sleep,
        occurredAt: context.occurredAt,
        occurredTime: context.occurredTime,
        payload: {
          'sleepEvent': 'start',
          'eventAt': context.now.toUtc().toIso8601String(),
        },
      ),
    );
    emitDataChange(DataChangeTopic.dailyRecords);
    registerUndo(QuickEntryUndoAction.deleteDailyRecord(recordId: record.id));
    return record;
  }

  DailyRecordCreateInput _wakeInput(
    SleepQuickEntryContext context,
    String startedRecordId,
  ) {
    return DailyRecordCreateInput(
      kind: DailyRecordKind.sleep,
      occurredAt: context.occurredAt,
      occurredTime: context.occurredTime,
      payload: {
        'sleepEvent': 'wake',
        'eventAt': context.now.toUtc().toIso8601String(),
        'startedRecordId': startedRecordId,
      },
    );
  }

  bool _isWakeAfterStart(DailyRecordItem startRecord, DateTime wakeAt) {
    final startAt = eventAtForRecord(startRecord);
    if (startAt == null) return false;
    return wakeAt.isAfter(startAt);
  }

  static bool _isSleepStart(DailyRecordItem record) =>
      record.kind == DailyRecordKind.sleep &&
      record.payload?['sleepEvent'] == 'start';

  static bool _isSleepWake(DailyRecordItem record) =>
      record.kind == DailyRecordKind.sleep &&
      record.payload?['sleepEvent'] == 'wake';

  static ({int hour, int minute})? _parseHourMinute(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    final parts = trimmed.split(':');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;
    return (hour: hour, minute: minute);
  }
}
