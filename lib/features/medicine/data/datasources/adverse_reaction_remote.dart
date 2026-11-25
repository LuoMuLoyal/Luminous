import 'package:dio/dio.dart';
import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/core/network/contract/failure.dart';
import 'package:luminous/features/medicine/data/mappers/adverse_reaction.dart';
import 'package:luminous/features/medicine/domain/entities/adverse_reaction.dart';
import 'package:luminous/features/medicine/domain/repositories/adverse_reaction.dart';
import 'package:luminous/shared/domain/failure.dart';

/// Remote data source for OnSIDES adverse reactions.
///
/// Transport only: returns bare futures and throws on failure; the repository
/// boundary collapses that into a `LucentFailure`.
///
/// ## The 404 is not an error here
///
/// `GET /medicines/drugs/{id}/reactions` answers 404 when the drug has no RxCUI
/// cross-reference — true for 91.8% of DrugBank rows. That is a factual answer
/// ("we cannot bridge this drug"), so it becomes `null`, not a thrown failure.
/// Everything else still throws.
class AdverseReactionRemoteDataSource {
  const AdverseReactionRemoteDataSource({
    required this.api,
    this.mapper = const AdverseReactionMapper(),
  });

  final MedicinesApi api;
  final AdverseReactionMapper mapper;

  Future<AdverseReactionReport?> forDrugbankId(String drugbankId) async {
    return _orNullOnMissing(
      () => api.listDrugReactions(drugbankId: drugbankId),
      'drug adverse reactions',
      (dto) => mapper.reportDtoToEntity(dto),
    );
  }

  Future<AdverseReactionReport?> forIngredient(String rxnormCui) async {
    return _orNullOnMissing(
      () => api.listIngredientReactions(rxnormCui: rxnormCui),
      'ingredient adverse reactions',
      (dto) => mapper.reportDtoToEntity(dto),
    );
  }

  Future<ReactionDrugList?> drugsForReaction(
    String meddraId, {
    int limit = 50,
  }) async {
    return _orNullOnMissing(
      () => api.listReactionDrugs(meddraId: meddraId, limit: limit),
      'reaction drug list',
      (dto) => mapper.reactionDrugsDtoToEntity(dto),
    );
  }

  /// Runs a request, mapping "backend says this key has no data" to `null`.
  ///
  /// Only a 404 on a *read* becomes `null`. A 404 on anything else (and any
  /// other status) keeps its failure path, so a genuinely broken route is not
  /// silently reported as "no data for this drug".
  Future<T?> _orNullOnMissing<D, T>(
    Future<Response<D?>> Function() request,
    String what,
    T Function(D dto) map,
  ) async {
    try {
      final response = await request();
      final body = response.data;
      if (body == null) {
        throw LucentFailure.network(
          message: 'Empty $what response body',
          networkErrorCode: NetworkErrorCode.emptyResponse,
        );
      }
      return map(body);
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        return null;
      }
      rethrow;
    }
  }
}
