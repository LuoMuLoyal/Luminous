import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/features/health_context/domain/entities/health_context_snapshot.dart';
import 'package:luminous/features/medicine/domain/entities/medicine_risk_check.dart';
import 'package:luminous/features/medicine/domain/services/medicine_risk_checker.dart';
import 'package:luminous/features/search/data/datasources/remote_data_source.dart';
import 'package:luminous/features/search/data/repositories/lucent_repository.dart';

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
      } catch (_) {
        // The page and workspace surface missing coverage explicitly later.
      }
    }

    return checker.evaluate(snapshot: snapshot, medicines: details);
  }
}

final medicineRiskCheckRepositoryProvider =
    Provider<MedicineRiskCheckRepository>((ref) {
      final remoteDataSource = ref.watch(
        medicineSearchRemoteDataSourceProvider,
      );
      return MedicineRiskCheckRepository(remoteDataSource: remoteDataSource);
    });
