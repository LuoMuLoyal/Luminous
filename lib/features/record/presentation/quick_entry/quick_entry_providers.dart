import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/providers/instrumentation/data_change_bus.dart';
import 'package:luminous/features/record/application/usecases/quick_entry_sleep.dart';
import 'package:luminous/app/composition/record/record_access.dart';
import 'package:luminous/features/record/domain/entities/inputs.dart';
import 'package:luminous/features/record/domain/entities/record.dart';
import 'package:luminous/features/record/domain/repositories/daily.dart';
import 'package:luminous/features/record/domain/services/quick_entry.dart';
import 'package:luminous/features/record/domain/services/water_quick_entry.dart';
import 'package:luminous/features/record/domain/undo/quick_entry_undo.dart';

/// Adapts the feature's `DailyRecordRepository` onto the application layer's
/// [DailyRecordWriter]: `TaskEither` → thrown exception at the seam.
class RepositoryDailyRecordWriter implements DailyRecordWriter {
  RepositoryDailyRecordWriter(this._repository);

  final DailyRecordRepository _repository;

  @override
  Future<DailyRecordItem> create(DailyRecordCreateInput input) async {
    final result = await _repository.create(input).run();
    return result.fold((failure) => throw failure, (item) => item);
  }

  @override
  Future<DailyRecordItem> update(
    String id,
    DailyRecordUpdateInput input,
  ) async {
    final result = await _repository.update(id, input).run();
    return result.fold((failure) => throw failure, (item) => item);
  }

  @override
  Future<void> delete(String id) async {
    final result = await _repository.delete(id).run();
    result.fold((failure) => throw failure, (_) {});
  }

  @override
  Future<DailyRecordAttachmentInput> uploadImage(
    DailyRecordImageUploadInput input,
  ) async {
    final result = await _repository.uploadImage(input).run();
    return result.fold((failure) => throw failure, (attachment) => attachment);
  }
}

/// Adapts the daily-record repository onto the sleep use case's read/write
/// surface (which also needs the history read for its prefill).
class RepositorySleepQuickEntryRepository implements SleepQuickEntryRepository {
  RepositorySleepQuickEntryRepository(this._repository);

  final DailyRecordRepository _repository;

  @override
  Future<DailyRecordItem> create(DailyRecordCreateInput input) async {
    final result = await _repository.create(input).run();
    return result.fold((failure) => throw failure, (item) => item);
  }

  @override
  Future<DailyRecordListData> fetchRecords(
    String date, {
    String? kind,
    int pageSize = 20,
  }) async {
    final result = await _repository
        .fetchRecords(date, kind: kind, pageSize: pageSize)
        .run();
    return result.fold((failure) => throw failure, (page) => page);
  }
}

/// The writer use cases receive (see `application/usecases/quick_entry_contract.dart`).
final quickEntryDailyRecordWriterProvider = Provider<DailyRecordWriter>((ref) {
  return RepositoryDailyRecordWriter(ref.watch(dailyRecordRepositoryProvider));
});

/// Emits application-layer data-change topics onto the shared bus.
final emitQuickEntryDataChangeProvider = Provider<EmitDataChangeTopic>((ref) {
  return (topic) => ref.read(dataChangeBusProvider.notifier).emit(topic);
});

final createDailyRecordProvider = Provider<CreateDailyRecord>((ref) {
  final writer = ref.watch(quickEntryDailyRecordWriterProvider);
  return writer.create;
});

final deleteDailyRecordProvider = Provider<DeleteDailyRecord>((ref) {
  final writer = ref.watch(quickEntryDailyRecordWriterProvider);
  return writer.delete;
});

final sleepQuickEntryFlowProvider = Provider<SleepQuickEntryFlow>((ref) {
  return SleepQuickEntryFlow(
    repository: RepositorySleepQuickEntryRepository(
      ref.watch(dailyRecordRepositoryProvider),
    ),
    emitDataChange: ref.watch(emitQuickEntryDataChangeProvider),
  );
});
