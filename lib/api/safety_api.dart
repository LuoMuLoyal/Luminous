import 'package:luminous/constants/constants.dart';
import 'package:luminous/utils/DioRequest.dart';
import 'package:luminous/viewmodels/safety.dart';

class SafetyApi {
  SafetyApi._();

  static Future<ApiResult<MedicineAiSafetyResult>> query({
    String? userId,
    required String mode,
    required List<Map<String, String>> medicines,
  }) {
    return dioRequest.post<MedicineAiSafetyResult>(
      HttpConstants.MEDICINE_AI_SAFETY,
      data: <String, dynamic>{
        if (userId != null && userId.trim().isNotEmpty) 'userId': userId.trim(),
        'mode': mode,
        'medicines': medicines,
      },
      decoder: (json) => MedicineAiSafetyResult.fromJson(_asMap(json)),
      showLoading: true,
      loadingText: '查询中...',
    );
  }

  static Map<String, dynamic> _asMap(dynamic json) {
    if (json is Map<String, dynamic>) return json;
    if (json is Map) return json.map((k, v) => MapEntry(k.toString(), v));
    return <String, dynamic>{};
  }
}

