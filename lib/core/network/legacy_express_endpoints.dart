/// 旧 Express 后端接口路径常量。
///
/// 从 `HttpConstants` 中分离 legacy 端点，与 Lucent `/api/v1` 端点区分管理。
/// 迁往 Lucent 后，此文件中的路径将被逐步标记为 deprecated。
class LegacyExpressEndpoints {
  LegacyExpressEndpoints._();

  /// API 前缀。
  static const String prefix = '/api';

  /// 获取验证码接口。
  static const String sendCode = '/api/auth/codes';

  /// 用户注册接口。
  static const String registerUser = '/api/auth/register';

  /// 用户登录接口。
  static const String loginUser = '/api/auth/login';

  /// 刷新鉴权 Token 接口。
  static const String refreshToken = '/api/auth/refresh';

  /// 个人资料读取接口。
  static const String userProfile = '/api/user/profile';

  /// 个人资料更新接口。
  static const String userProfileUpdate = '/api/user/profile-update';

  /// 注销账户接口。
  static const String userDelete = '/api/user/delete';

  /// 我的药品新增/更新接口。
  static const String myMedicineUpsert = '/api/medicines/my-upsert';

  /// 我的药品删除接口。
  static const String myMedicineDelete = '/api/medicines/my-delete';

  /// 我的药品列表接口。
  static const String myMedicineList = '/api/medicines/my-list';

  /// 首页今日提醒接口。
  static const String todayReminders = '/api/reminders/today';

  /// 药品搜索接口。
  static const String medicineSearch = '/api/medicines/search';

  /// 药品详情接口。
  static const String medicineDetail = '/api/medicines/detail';

  /// 药品 AI 详情解读接口。
  static const String medicineAiDetail = '/api/medicines/ai-detail';

  /// 药品识别接口。
  static const String medicineScan = '/api/medicines/scan';

  /// 识别记录创建接口。
  static const String scanRecordCreate = '/api/medicines/scan-record-create';

  /// 提醒计划新增/更新接口。
  static const String reminderUpsert = '/api/reminders/upsert';

  /// 提醒计划删除接口。
  static const String reminderDelete = '/api/reminders/delete';

  /// 提醒计划列表接口。
  static const String reminderList = '/api/reminders/list';

  /// 安全辅助 AI 查询接口。
  static const String medicineAiSafety = '/api/medicines/ai-safety';
}
