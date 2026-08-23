import 'package:fpdart/fpdart.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/features/medicine/domain/entities/risk_check.dart';

/// Domain interface for medicine risk check records.
///
/// Repository boundary: every expected recoverable failure (network, server
/// business failure) is a `TaskEither` Left produced via
/// `LucentErrorMapper.fromObject`; a legal empty records set stays a Right.
abstract interface class MedicineRiskCheckRepository {
  /// Fetches the latest risk check records (static + llm) from the API.
  TaskEither<LucentFailure, MedicineRiskCheckRecords> getRecords();

  /// Runs a risk check of the given [type] and returns the new record.
  TaskEither<LucentFailure, MedicineRiskCheckRecord> runCheck(
    MedicineRiskCheckType type,
  );

  /// Runs an immediate pre-check for a candidate medicine before it is added
  /// to the box. [source] is the trusted drug-library source ('cn' /
  /// 'drugbank') and [sourceRefId] the candidate id within that source.
  ///
  /// The server checks the current medicine box plus the candidate on the fly
  /// without persisting a record, so this returns the preview result directly
  /// (not a record).
  TaskEither<LucentFailure, MedicineRiskCheckResult> runPrecheck({
    required String source,
    required String sourceRefId,
  });
}
