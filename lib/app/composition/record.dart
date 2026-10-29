import 'package:luminous/app/composition/record/record_access.dart';
import 'package:luminous/features/record/application/mappers/dashboard_assembler.dart';
import 'package:luminous/features/record/data/repositories/lucent.dart';
import 'package:luminous/features/record/domain/repositories/daily.dart';
import 'package:luminous/features/record/domain/repositories/dashboard_view_assembler.dart';
import 'package:luminous/features/record/domain/repositories/record.dart';

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'record.g.dart';

/// Composition-root glue for the record feature.
///
/// The repository wiring lives here (not in `data/`) because it has to inject
/// an `application/` dependency — `data/` may only depend on its own feature's
/// `domain/` plus `core/network` / `core/database` / `core/storage`.

@riverpod
RecordDashboardViewAssembler recordDashboardViewAssembler(Ref ref) =>
    const RecordDashboardAssembler();

@riverpod
RecordRepository recordRepository(Ref ref) {
  final DailyRecordRepository dailyRecordRepo = ref.watch(
    dailyRecordRepositoryProvider,
  );
  return LucentRecordRepository(
    dailyRecordRepo: dailyRecordRepo,
    viewAssembler: ref.watch(recordDashboardViewAssemblerProvider),
  );
}
