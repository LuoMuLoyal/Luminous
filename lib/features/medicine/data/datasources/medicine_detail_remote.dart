import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/network/api.dart';
import 'package:luminous/core/network/contract/error_code.dart';
import 'package:luminous/features/medicine/data/mappers/medicine_detail.dart';
import 'package:luminous/features/medicine/data/mappers/medicine_sequences.dart';
import 'package:luminous/features/medicine/domain/entities/medicine_detail.dart';

/// Remote data source for the medication knowledge detail.
///
/// Calls the generated [MedicinesApi] `GET /api/v1/medicines/{id}?source=`
/// and maps the direct response resource to [MedicineDetail] via
/// [MedicineDetailMapper].
///
/// Transport only: returns a plain `Future` and throws — an empty success
/// body is a [LucentFailure.network] (auth `_requireBody` precedent); the
/// consuming provider surfaces it as an `AsyncValue.error`.
class MedicineDetailRemoteDataSource {
  const MedicineDetailRemoteDataSource({
    required this.api,
    this.mapper = const MedicineDetailMapper(),
    this.sequencesMapper = const MedicineSequencesMapper(),
  });

  final MedicinesApi api;
  final MedicineDetailMapper mapper;
  final MedicineSequencesMapper sequencesMapper;

  /// Fetches the detail for [id] from the given [source] (`cn` | `drugbank`).
  Future<MedicineDetail> fetchDetail({
    required String id,
    required String source,
  }) async {
    final response = await api.getDetail(id: id, source_: source);
    final dto = response.data;
    if (dto == null) {
      throw LucentFailure.network(
        message: 'Empty medicine detail response body',
        networkErrorCode: NetworkErrorCode.emptyResponse,
      );
    }
    return mapper.dataDtoToEntity(dto);
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
