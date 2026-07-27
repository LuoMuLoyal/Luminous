import 'package:luminous/features/medicine/domain/entities/risk_check.dart';

abstract interface class MedicineRiskCheckRepository {
  /// Fetches the latest risk check records (static + llm) from the API.
  Future<MedicineRiskCheckRecords> getRecords();

  /// Runs a risk check of the given [type] and returns the new record.
  Future<MedicineRiskCheckRecord> runCheck(MedicineRiskCheckType type);
}
