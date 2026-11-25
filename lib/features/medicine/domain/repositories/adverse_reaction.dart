import 'package:fpdart/fpdart.dart';
import 'package:luminous/features/medicine/domain/entities/adverse_reaction.dart';
import 'package:luminous/shared/domain/failure.dart';

/// Reads label-stated adverse reactions for a medicine.
///
/// ## Why "no bridge" is a `Right(null)`, not a `Left`
///
/// Only 8.2% of DrugBank rows carry an RxCUI cross-reference, so "this drug has
/// no adverse-reaction data" is the common answer, not a failure — the backend
/// says so with a 404 on purpose, to keep it distinguishable from "bridged, but
/// nothing found". Mapping that 404 to a `Left` would put a retry button in
/// front of a condition retrying cannot fix.
///
/// Genuine transport failures are still `Left`.
abstract interface class AdverseReactionRepository {
  /// Reactions for a DrugBank id, or `null` when the drug has no RxCUI bridge.
  Future<Either<LucentFailure, AdverseReactionReport?>> forDrugbankId(
    String drugbankId,
  );

  /// Reactions for a known RxNorm ingredient CUI.
  Future<Either<LucentFailure, AdverseReactionReport?>> forIngredient(
    String rxnormCui,
  );

  /// Which drugs could cause one MedDRA reaction — the reverse direction.
  ///
  /// This answers a question the prose leaflets never could, so it is exposed
  /// rather than kept internal.
  Future<Either<LucentFailure, ReactionDrugList?>> drugsForReaction(
    String meddraId, {
    int limit,
  });
}

/// One drug named as a possible cause of a reaction.
class ReactionDrug {
  const ReactionDrug({
    required this.drugbankId,
    required this.name,
    required this.labelCount,
    required this.confidence,
  });

  final String drugbankId;
  final String name;
  final int labelCount;
  final ReactionConfidence confidence;
}

/// The reverse lookup result.
class ReactionDrugList {
  const ReactionDrugList({
    required this.meddraId,
    required this.meddraName,
    required this.drugs,
  });

  final String meddraId;
  final String? meddraName;
  final List<ReactionDrug> drugs;
}
