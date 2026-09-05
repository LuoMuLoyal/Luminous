// TODO(archive): 无 UI 消费方（死代码保留）；若未来做随机安全贴士，
// 应在移动端药品详情页内以经过审核的内容卡片形式重做，勿直接复用本链路。
import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/network/contract/error_code.dart';
import 'package:luminous/features/medicine/domain/entities/safety_tip.dart';

/// Remote data source for medicine safety tips.
///
/// Transport only: returns a plain `Future` and throws — an empty success
/// body is a [LucentFailure.network] (auth `_requireBody` precedent).
class SafetyTipsRemoteDataSource {
  const SafetyTipsRemoteDataSource({required this.api});

  final MedicinesApi api;

  Future<List<MedicineSafetyTip>> fetchTips({List<String>? excludeIds}) async {
    final response = await api.getSafetyTips(
      exclude: excludeIds,
    );
    final dto = response.data;
    if (dto == null) {
      throw LucentFailure.network(
        message: 'Empty safety tips response body',
        networkErrorCode: NetworkErrorCode.emptyResponse,
      );
    }
    final dtos = dto;
    return dtos
        .map(
          (d) =>
              MedicineSafetyTip(id: d.id, text: d.text, category: d.category),
        )
        .toList(growable: false);
  }
}
