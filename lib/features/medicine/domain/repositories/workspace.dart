import 'package:fpdart/fpdart.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/features/medicine/domain/entities/workspace.dart';

/// Domain interface for the medicine workspace dashboard.
///
/// Repository boundary: every expected recoverable failure (network, server
/// business failure) is a `TaskEither` Left produced via
/// `LucentErrorMapper.fromObject`.
abstract interface class MedicineWorkspaceRepository {
  TaskEither<LucentFailure, MedicineWorkspace> fetchWorkspace();

  /// Pure local preview value — no network boundary, stays a plain Future
  /// (today `signedOutDashboard` precedent).
  Future<MedicineWorkspace> get signedOutWorkspace;
}
