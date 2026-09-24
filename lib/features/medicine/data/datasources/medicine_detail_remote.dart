import 'package:dio/dio.dart';
import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/network/api.dart';
import 'package:luminous/core/network/contract/error_code.dart';
import 'package:luminous/core/network/map_utils.dart';
import 'package:luminous/features/medicine/data/mappers/medicine_detail.dart';
import 'package:luminous/features/medicine/data/mappers/medicine_sequences.dart';
import 'package:luminous/features/medicine/domain/entities/medicine_detail.dart';

/// Remote data source for the medication knowledge detail.
///
/// Reads `GET /api/v1/medicines/{id}?source=` and `GET /api/v1/medicines/{id}/sequences`,
/// mapping the direct response resources to [MedicineDetail] /
/// [MedicineSequences] via the mappers. The detail read issues its own request
/// rather than going through the generated typed call — see [fetchDetail].
///
/// Transport only: returns a plain `Future` and throws — an empty success
/// body is a [LucentFailure.network] (auth `_requireBody` precedent); the
/// consuming provider surfaces it as an `AsyncValue.error`.
class MedicineDetailRemoteDataSource {
  const MedicineDetailRemoteDataSource({
    required this.api,
    required this.dio,
    this.mapper = const MedicineDetailMapper(),
    this.sequencesMapper = const MedicineSequencesMapper(),
  });

  /// Generated API surface, used for the endpoints whose response models
  /// deserialize correctly (the sequences read).
  final MedicinesApi api;

  /// The same Dio instance backing [api], used to issue the detail request
  /// without the generated union decoding (see [fetchDetail]).
  final Dio dio;

  final MedicineDetailMapper mapper;
  final MedicineSequencesMapper sequencesMapper;

  /// Fetches the detail for [id] from the given [source] (`cn` | `drugbank`).
  ///
  /// Deliberately bypasses the generated [MedicinesApi.getDetail] typed
  /// deserialization. The OpenAPI `detail` property is a `oneOf` union of the
  /// `cnProduct` and `drugbank` variants, and the generator emits the two
  /// variant classes (`MedicineDetailResponseDetailOneOf` /
  /// `...OneOf1`) correctly — but it also emits a `MedicineDetailResponseDetail`
  /// wrapper that the response model actually declares for `detail`, and that
  /// wrapper is generated with `checked: true` and *every* field of *both*
  /// variants marked required. Real payloads only ever carry one family, so the
  /// wrapper's `fromJson` throws `CheckedFromJsonException` for every medicine
  /// (`drugbank` misses the 21 CN keys, `cnProduct` misses the 26 DrugBank
  /// ones). Because that throw happens inside the generated call, it surfaces
  /// as `DioExceptionType.unknown` and the page can only ever offer a generic
  /// error.
  ///
  /// So the raw JSON is parsed here instead and dispatched on the `kind`
  /// discriminator to the matching variant class, exactly as the OpenAPI
  /// contract describes. `_detailFromJson` rebuilds the wrapper in memory (no
  /// JSON decoding) so the mapper keeps its existing DTO-based signature.
  Future<MedicineDetail> fetchDetail({
    required String id,
    required String source,
  }) async {
    final response = await _getDetailRaw(id: id, source: source);
    final body = coerceToStringMap(response.data);
    if (body == null) {
      throw LucentFailure.network(
        message: 'Empty medicine detail response body',
        networkErrorCode: NetworkErrorCode.emptyResponse,
      );
    }
    return mapper.dataDtoToEntity(_detailFromJson(body));
  }

  /// Issues the detail request directly through [dio], skipping the generated
  /// response decoding that would throw on the union.
  Future<Response<dynamic>> _getDetailRaw({
    required String id,
    required String source,
  }) {
    return dio.request<dynamic>(
      '/api/v1/medicines/${Uri.encodeComponent(id)}',
      options: Options(method: 'GET', responseType: ResponseType.json),
      queryParameters: <String, dynamic>{'source': source},
    );
  }

  /// Reconstructs the generated response wrapper from already-decoded JSON,
  /// dispatching the `oneOf` on `kind` and filling the unused variant's fields
  /// with `null` so the mapper's flat accessors keep working.
  MedicineDetailResponse _detailFromJson(Map<String, dynamic> body) {
    final rawDetail = coerceToStringMap(body['detail']);
    if (rawDetail == null) {
      throw LucentFailure.network(
        message: 'Medicine detail response is missing the detail object',
        networkErrorCode: NetworkErrorCode.emptyResponse,
      );
    }

    final kind = rawDetail['kind'];
    final MedicineDetailResponseDetail detail;
    switch (kind) {
      case 'cnProduct':
        final variant = MedicineDetailResponseDetailOneOf1.fromJson(rawDetail);
        detail = MedicineDetailResponseDetail(
          kind: variant.kind,
          // DrugBank family is not part of this variant.
          drugType: null,
          state: null,
          description: null,
          indication: null,
          mechanismOfAction: null,
          pharmacodynamics: null,
          toxicity: null,
          metabolism: null,
          absorption: null,
          halfLife: null,
          proteinBinding: null,
          routeOfElimination: null,
          volumeOfDistribution: null,
          clearance: null,
          groups: null,
          categories: null,
          atcCodes: null,
          synonyms: null,
          foodInteractions: null,
          drugInteractions: null,
          targets: null,
          externalIdentifiers: null,
          externalLinks: null,
          sequenceSummary: null,
          structure: null,
          approvalNumber: variant.approvalNumber,
          manufacturer: variant.manufacturer,
          packageSpec: variant.packageSpec,
          brandName: variant.brandName,
          ingredients: variant.ingredients,
          properties: variant.properties,
          indications: variant.indications,
          dosage: variant.dosage,
          adverseReactions: variant.adverseReactions,
          contraindications: variant.contraindications,
          precautions: variant.precautions,
          pharmacologyToxicology: variant.pharmacologyToxicology,
          pharmacokinetics: variant.pharmacokinetics,
          overdose: variant.overdose,
          storage: variant.storage,
          validityPeriod: variant.validityPeriod,
          barcode: variant.barcode,
          nationalDrugCode: variant.nationalDrugCode,
          sourceUrl: variant.sourceUrl,
          imageUrl: variant.imageUrl,
        );
      case 'drugbank':
        final variant = MedicineDetailResponseDetailOneOf.fromJson(rawDetail);
        detail = MedicineDetailResponseDetail(
          kind: variant.kind,
          drugType: variant.drugType,
          state: variant.state,
          description: variant.description,
          indication: variant.indication,
          mechanismOfAction: variant.mechanismOfAction,
          pharmacodynamics: variant.pharmacodynamics,
          toxicity: variant.toxicity,
          metabolism: variant.metabolism,
          absorption: variant.absorption,
          halfLife: variant.halfLife,
          proteinBinding: variant.proteinBinding,
          routeOfElimination: variant.routeOfElimination,
          volumeOfDistribution: variant.volumeOfDistribution,
          clearance: variant.clearance,
          groups: variant.groups,
          categories: variant.categories,
          atcCodes: variant.atcCodes,
          synonyms: variant.synonyms,
          foodInteractions: variant.foodInteractions,
          drugInteractions: variant.drugInteractions,
          targets: variant.targets,
          externalIdentifiers: variant.externalIdentifiers,
          externalLinks: variant.externalLinks,
          sequenceSummary: variant.sequenceSummary,
          structure: variant.structure,
          // CN package-insert family is not part of this variant.
          approvalNumber: null,
          manufacturer: null,
          packageSpec: null,
          brandName: null,
          ingredients: null,
          properties: null,
          indications: null,
          dosage: null,
          adverseReactions: null,
          contraindications: null,
          precautions: null,
          pharmacologyToxicology: null,
          pharmacokinetics: null,
          overdose: null,
          storage: null,
          validityPeriod: null,
          barcode: null,
          nationalDrugCode: null,
          sourceUrl: null,
          imageUrl: null,
        );
      default:
        throw LucentFailure.unknown(
          message: 'Unknown medicine detail kind: $kind',
        );
    }

    return MedicineDetailResponse(
      id: body['id'] as String,
      source_: MedicineDetailResponseSource_Enum.values.firstWhere(
        (value) => value.name == body['source'],
        orElse: () => MedicineDetailResponseSource_Enum.unknownDefaultOpenApi,
      ),
      name: body['name'] as String,
      subtitle: body['subtitle'] as String?,
      detail: detail,
    );
  }

  /// Fetches the sequence payload for [id].
  ///
  /// Separate from [fetchDetail] on purpose: the payload runs to tens of
  /// thousands of characters, so callers only invoke this when the user
  /// actually opens the sequence section.
  Future<MedicineSequences> fetchSequences({
    required String id,
    required String source,
  }) async {
    final response = await api.getSequences(id: id, source_: source);
    final dto = response.data;
    if (dto == null) {
      throw LucentFailure.network(
        message: 'Empty medicine sequence response body',
        networkErrorCode: NetworkErrorCode.emptyResponse,
      );
    }
    return sequencesMapper.dataDtoToEntity(dto);
  }
}
