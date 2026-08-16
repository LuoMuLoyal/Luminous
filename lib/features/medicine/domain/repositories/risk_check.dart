import 'package:luminous/features/medicine/domain/entities/risk_check.dart';

abstract interface class MedicineRiskCheckRepository {
  /// Fetches the latest risk check records (static + llm) from the API.
  Future<MedicineRiskCheckRecords> getRecords();

  /// Runs a risk check of the given [type] and returns the new record.
  Future<MedicineRiskCheckRecord> runCheck(MedicineRiskCheckType type);

  /// Runs an immediate pre-check for a candidate medicine before it is added
  /// to the box. [source] is the trusted drug-library source ('cn' /
  /// 'drugbank') and [sourceRefId] the candidate id within that source.
  ///
  /// The server checks the current medicine box plus the candidate on the fly
  /// without persisting a record, so this returns the preview result directly
  /// (not a record).
  Future<MedicineRiskCheckResult> runPrecheck({
    required String source,
    required String sourceRefId,
  });
}
