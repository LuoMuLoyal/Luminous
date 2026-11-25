import 'package:luminous/core/providers/channel.dart';
import 'package:luminous/features/medicine/domain/entities/adverse_reaction.dart';
import 'package:luminous/features/medicine/domain/repositories/adverse_reaction.dart';
import 'package:luminous/features/medicine/presentation/providers/data_access.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'adverse_reaction.g.dart';

/// Label-stated adverse reactions for one DrugBank drug.
///
/// Resolves to `null` when the drug has no RxCUI cross-reference — the common
/// case (91.8% of DrugBank rows). The section renders a quiet "no data" line for
/// `null`; it does **not** show an error, because nothing failed.
///
/// Deliberately separate from `medicineDetail`: a drug can have a detail page
/// and no reactions at all, and folding the two together would make the detail
/// response's shape depend on RxCUI coverage.
@riverpod
Future<AdverseReactionReport?> drugAdverseReactions(
  Ref ref,
  String drugbankId,
) {
  return unwrapFailure(
    ref.watch(adverseReactionRepositoryProvider).forDrugbankId(drugbankId),
  );
}

/// Which drugs could cause one MedDRA reaction — the reverse lookup.
///
/// Kept lazy: the page only asks for this when the user opens a reaction.
@riverpod
Future<ReactionDrugList?> reactionDrugs(Ref ref, String meddraId) {
  return unwrapFailure(
    ref.watch(adverseReactionRepositoryProvider).drugsForReaction(meddraId),
  );
}
