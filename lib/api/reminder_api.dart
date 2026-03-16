import 'package:luminous/constants/constants.dart';
import 'package:luminous/utils/DioRequest.dart';
import 'package:luminous/viewmodels/reminder.dart';

class ReminderApi {
  ReminderApi._();

  static Future<ApiResult<ReminderListResult>> list({required String userId}) {
    return dioRequest.post<ReminderListResult>(
      HttpConstants.REMINDER_LIST,
      data: <String, dynamic>{'userId': userId.trim()},
      decoder: (json) {
        if (json is Map<String, dynamic>) return ReminderListResult.fromJson(json);
        if (json is Map) return ReminderListResult.fromJson(json.cast<String, dynamic>());
        return const ReminderListResult(items: []);
      },
      showLoading: false,
    );
  }

  static Future<ApiResult<ReminderPlan>> upsert({
    required String userId,
    String? id,
    required String time,
    String? drugCode,
    String? approvalNo,
    required String productName,
    String? subtitle,
    bool enabled = true,
    String repeatRule = 'daily',
    String method = 'notification',
  }) {
    return dioRequest.post<ReminderPlan>(
      HttpConstants.REMINDER_UPSERT,
      data: <String, dynamic>{
        'userId': userId.trim(),
        if (id != null && id.trim().isNotEmpty) 'id': id.trim(),
        'time': time.trim(),
        if (drugCode != null && drugCode.trim().isNotEmpty) 'drugCode': drugCode.trim(),
        if (approvalNo != null && approvalNo.trim().isNotEmpty) 'approvalNo': approvalNo.trim(),
        'productName': productName.trim(),
        'subtitle': (subtitle ?? '').trim(),
        'enabled': enabled,
        'repeatRule': repeatRule,
        'method': method,
      },
      decoder: (json) => ReminderPlan.fromJson(_asMap(json)),
      showLoading: true,
      loadingText: '保存中...',
    );
  }

  static Future<ApiResult<bool>> delete({
    required String userId,
    required String id,
  }) {
    return dioRequest.post<bool>(
      HttpConstants.REMINDER_DELETE,
      data: <String, dynamic>{'userId': userId.trim(), 'id': id.trim()},
      decoder: (json) {
        if (json is bool) return json;
        if (json is num) return json != 0;
        final s = (json ?? '').toString().trim().toLowerCase();
        return s == 'true' || s == '1' || s == 'ok';
      },
      showLoading: false,
    );
  }

  static Map<String, dynamic> _asMap(dynamic json) {
    if (json is Map<String, dynamic>) return json;
    if (json is Map) return json.map((k, v) => MapEntry(k.toString(), v));
    return <String, dynamic>{};
  }
}

