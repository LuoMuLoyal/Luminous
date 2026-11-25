import 'package:fpdart/fpdart.dart';
import 'package:luminous/core/network/api.dart';
import 'package:luminous/core/network/contract/failure.dart';
import 'package:luminous/features/medicine/data/datasources/adverse_reaction_remote.dart';
import 'package:luminous/features/medicine/domain/entities/adverse_reaction.dart';
import 'package:luminous/features/medicine/domain/repositories/adverse_reaction.dart';
import 'package:luminous/shared/domain/failure.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'adverse_reaction.g.dart';

/// OnSIDES-backed adverse-reaction repository.
///
/// The boundary does one thing: turn transport failures into `Left`. A `null`
/// report stays `Right(null)` — that is the backend's answer "this drug has no
/// RxCUI bridge", which retrying cannot change.
class LucentAdverseReactionRepository implements AdverseReactionRepository {
  const LucentAdverseReactionRepository({required this.remote});

  final AdverseReactionRemoteDataSource remote;

  @override
  Future<Either<LucentFailure, AdverseReactionReport?>> forDrugbankId(
    String drugbankId,
  ) => _guard(() => remote.forDrugbankId(drugbankId));

  @override
  Future<Either<LucentFailure, AdverseReactionReport?>> forIngredient(
    String rxnormCui,
  ) => _guard(() => remote.forIngredient(rxnormCui));

  @override
  Future<Either<LucentFailure, ReactionDrugList?>> drugsForReaction(
    String meddraId, {
    int limit = defaultReactionDrugLimit,
  }) => _guard(() => remote.drugsForReaction(meddraId, limit: limit));

  Future<Either<LucentFailure, T>> _guard<T>(Future<T> Function() run) async {
    try {
      return Right(await run());
    } catch (error) {
      return Left(LucentErrorMapper.fromObject(error));
    }
  }
}

/// Page size for the reverse lookup.
///
/// Matches the backend's `limit` default; keeping the number in one place means
/// the UI never has to reason about the cap.
const defaultReactionDrugLimit = 50;

@riverpod
AdverseReactionRepository adverseReactionRepository(Ref ref) {
  final client = ref.watch(lucentClientProvider);
  return LucentAdverseReactionRepository(
    remote: AdverseReactionRemoteDataSource(api: client.medicines),
  );
}
