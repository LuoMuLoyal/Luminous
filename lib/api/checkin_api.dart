import 'package:luminous/constants/constants.dart';
import 'package:luminous/utils/DioRequest.dart';
import 'package:luminous/viewmodels/checkin.dart';

class CheckinApi {
  CheckinApi._();

  static Future<ApiResult<CheckinCreateResult>> create({
    required String userId,
    required String reminderId,
    int? takenAt,
  }) {
    return dioRequest.post<CheckinCreateResult>(
      HttpConstants.CHECKIN_CREATE,
      data: <String, dynamic>{
        'userId': userId.trim(),
        'reminderId': reminderId.trim(),
        ...?(takenAt == null ? null : <String, dynamic>{'takenAt': takenAt}),
      },
      decoder: (json) => CheckinCreateResult.fromJson(_asMap(json)),
      showLoading: true,
      loadingText: '打卡中...',
    );
  }

  static Map<String, dynamic> _asMap(dynamic json) {
    if (json is Map<String, dynamic>) return json;
    if (json is Map) return json.map((k, v) => MapEntry(k.toString(), v));
    return <String, dynamic>{};
  }
}
