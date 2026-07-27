import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/core/network/api_exception.dart';
import 'package:luminous/core/network/error_code.dart';
import 'package:luminous/features/medicine/domain/entities/safety_tip.dart';

class SafetyTipsRemoteDataSource {
  const SafetyTipsRemoteDataSource({required this.api});

  final MedicinesApi api;

  Future<List<MedicineSafetyTip>> fetchTips({List<String>? excludeIds}) async {
    final response = await api.medicinesControllerGetSafetyTipsV1(
      exclude: excludeIds,
    );
    final dto = response.data;
    if (dto == null) {
      throw const LucentApiException(
        message: '用药安全提示响应体为空',
        networkErrorCode: NetworkErrorCode.emptyResponse,
      );
    }
    final dtos = dto.data;
    return dtos
        .map(
          (d) =>
              MedicineSafetyTip(id: d.id, text: d.text, category: d.category),
        )
        .toList(growable: false);
  }
}
