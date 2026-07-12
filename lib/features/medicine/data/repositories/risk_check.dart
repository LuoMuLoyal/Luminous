import 'package:luminous/core/logger/logger.dart';
import 'package:luminous/features/health_context/domain/entities/snapshot.dart';
import 'package:luminous/features/medicine/domain/entities/risk_check.dart';
import 'package:luminous/features/medicine/domain/services/risk_checker.dart';
import 'package:luminous/features/search/data/datasources/medicine_search.dart';
import 'package:luminous/features/search/data/repositories/lucent.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'risk_check.g.dart';

class MedicineRiskCheckRepository {
  MedicineRiskCheckRepository({
    required this.remoteDataSource,
    this.checker = const MedicineRiskChecker(),
  });

  final MedicineSearchRemoteDataSource remoteDataSource;
  final MedicineRiskChecker checker;

  Future<MedicineRiskCheckResult> fetchForSnapshot(
    HealthContextSnapshot snapshot,
  ) async {
    final currentMedicines = snapshot.currentMedicines
        .where((item) => item.isCurrent)
        .toList(growable: false);
    final details = <MedicineRiskMedicineDetail>[];

    for (final item in currentMedicines) {
      final source = item.source;
      final sourceRefId = item.sourceRefId?.trim();
      if ((source != 'cn' && source != 'drugbank') ||
          sourceRefId == null ||
          sourceRefId.isEmpty) {
        continue;
      }

      try {
        final response = await remoteDataSource.getDetail(
          id: sourceRefId,
          source: source,
        );
        if (response.code != 0) {
          continue;
        }
        details.add(
          MedicineRiskMedicineDetail(item: item, detail: response.data),
        );
      } catch (e) {
        appTalker.error(
          'MedicineRiskCheckRepository: risk detail fetch failed: $e',
        );
      }
    }

    return checker.evaluate(snapshot: snapshot, medicines: details);
  }
}

@riverpod
MedicineRiskCheckRepository medicineRiskCheckRepository(Ref ref) {
  final remoteDataSource = ref.watch(medicineSearchRemoteDataSourceProvider);
  return MedicineRiskCheckRepository(remoteDataSource: remoteDataSource);
}
