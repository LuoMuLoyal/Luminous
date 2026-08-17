import 'package:luminous/core/providers/data_change_bus.dart';
import 'package:luminous/features/record/application/usecases/quick_entry_undo.dart';
import 'package:luminous/features/record/application/usecases/water_quick_entry.dart';
import 'package:luminous/features/record/domain/entities/inputs.dart';
import 'package:luminous/features/record/domain/entities/record.dart';
import 'package:luminous/features/record/presentation/utils/date_time_formatters.dart';

typedef DeleteSleepRecord = Future<void> Function(String recordId);

class SleepQuickEntryContext extends QuickEntryRecordContext {
  const SleepQuickEntryContext({
    required super.occurredAt,
    required super.occurredTime,
    required this.now,
    this.sleepType = 'nightSleep',
    this.approximateDurationMinutes,
    this.quality,
  });

  final DateTime now;
  final String sleepType;
  final int? approximateDurationMinutes;
  final String? quality;
}

class SleepQuickEntryStartOptions {
  const SleepQuickEntryStartOptions({
    required this.sleepType,
    this.approximateDurationMinutes,
    this.quality,
  });

  final String sleepType;
  final int? approximateDurationMinutes;
  final String? quality;
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
          'sleepType': startRecord.payload?['sleepType'] == 'nap'
              ? 'nap'
              : 'nightSleep',
          'startedAt': startAt.toUtc().toIso8601String(),
          'endedAt': endAt.toUtc().toIso8601String(),
          'durationMinutes': durationMinutes,
          if (startRecord.payload?['quality'] is String)
            'quality': startRecord.payload?['quality'],
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
    final time = parseRecordTime(record.occurredTime);
    if (time == null) return date;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<DailyRecordItem> _recordStart(SleepQuickEntryContext context) async {
    final payload = <String, dynamic>{
      'sleepEvent': 'start',
      'eventAt': context.now.toUtc().toIso8601String(),
      'sleepType': context.sleepType == 'nap' ? 'nap' : 'nightSleep',
    };
    final approximateDurationMinutes = context.approximateDurationMinutes;
    if (approximateDurationMinutes != null && approximateDurationMinutes > 0) {
      payload['approximateDurationMinutes'] = approximateDurationMinutes;
    }
    final quality = context.quality;
    if (quality != null && quality.isNotEmpty) payload['quality'] = quality;

    final record = await createRecord(
      DailyRecordCreateInput(
        kind: DailyRecordKind.sleep,
        occurredAt: context.occurredAt,
        occurredTime: context.occurredTime,
        payload: payload,
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
}
