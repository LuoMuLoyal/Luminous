// TODO(archive): 无 UI 消费方（死代码保留）；若未来做随机安全贴士，
// 应在移动端药品详情页内以经过审核的内容卡片形式重做，勿直接复用本链路。
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
