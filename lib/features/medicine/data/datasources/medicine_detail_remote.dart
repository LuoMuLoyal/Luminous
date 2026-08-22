import 'package:luminous/core/network/api.dart';
import 'package:luminous/core/network/error_code.dart';
import 'package:luminous/features/medicine/data/mappers/medicine_detail.dart';
import 'package:luminous/features/medicine/domain/entities/medicine_detail.dart';

/// Remote data source for the medication knowledge detail.
///
/// Calls the generated [MedicinesApi] `GET /api/v1/medicines/{id}?source=`
/// and maps the direct response resource to [MedicineDetail] via
/// [MedicineDetailMapper].
class MedicineDetailRemoteDataSource {
  const MedicineDetailRemoteDataSource({
    required this.api,
    this.mapper = const MedicineDetailMapper(),
  });

  final MedicinesApi api;
  final MedicineDetailMapper mapper;

  /// Fetches the detail for [id] from the given [source] (`cn` | `drugbank`).
  Future<MedicineDetail> fetchDetail({
    required String id,
    required String source,
  }) async {
    final response = await api.medicinesControllerGetDetailV1(
      id: id,
      source_: source,
    );
    final dto = response.data;
    if (dto == null) {
      throw const LucentApiException(
        message: '药品详情响应体为空',
        networkErrorCode: NetworkErrorCode.emptyResponse,
      );
    }
    return mapper.dataDtoToEntity(dto);
  }
}
