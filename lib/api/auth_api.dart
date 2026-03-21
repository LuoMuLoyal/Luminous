import 'package:luminous/constants/constants.dart';
import 'package:luminous/utils/DioRequest.dart';
import 'package:luminous/viewmodels/auth.dart';

/// 认证相关接口封装。
///
/// 页面不会直接拼接认证接口路径或业务字段，而是统一通过这个类调用。
class AuthApi {
  const AuthApi();

  /// 请求 SVG 验证码。
  Future<ApiResult<SvgCodeResult>> fetchSvgCode({
    AuthCodeScene scene = AuthCodeScene.register,
  }) {
    return dioRequest.post<SvgCodeResult>(
      HttpConstants.SEND_CODE,
      data: {'channel': 'svg', 'scene': scene.backendValue},
      decoder: (json) => SvgCodeResult.fromJson(_asMap(json)),
    );
  }

  /// 向指定邮箱发送验证码。
  Future<ApiResult<CodeTicketResult>> sendEmailCode({
    required String email,
    required AuthCodeScene scene,
  }) {
    return dioRequest.post<CodeTicketResult>(
      HttpConstants.SEND_CODE,
      data: {
        'channel': 'email',
        'scene': scene.backendValue,
        'target': email.trim(),
      },
      decoder: (json) => CodeTicketResult.fromJson(_asMap(json)),
    );
  }

  /// 向指定手机号发送验证码。
  Future<ApiResult<CodeTicketResult>> sendPhoneCode({
    required String phone,
    required AuthCodeScene scene,
  }) {
    return dioRequest.post<CodeTicketResult>(
      HttpConstants.SEND_CODE,
      data: {
        'channel': 'phone',
        'scene': scene.backendValue,
        'target': phone.trim(),
      },
      decoder: (json) => CodeTicketResult.fromJson(_asMap(json)),
    );
  }

  /// 使用邮箱完成注册。
  Future<ApiResult<RegisterResult>> registerWithEmail({
    required String email,
    required String code,
    required String codeId,
    required String svgCode,
    required String svgId,
    required String password,
  }) {
    return _register(
      identifierType: AuthIdentifierType.email,
      identifier: email,
      code: code,
      codeId: codeId,
      svgCode: svgCode,
      svgId: svgId,
      password: password,
    );
  }

  /// 使用手机号完成注册。
  Future<ApiResult<RegisterResult>> registerWithPhone({
    required String phone,
    required String code,
    required String codeId,
    required String svgCode,
    required String svgId,
    required String password,
  }) {
    return _register(
      identifierType: AuthIdentifierType.phone,
      identifier: phone,
      code: code,
      codeId: codeId,
      svgCode: svgCode,
      svgId: svgId,
      password: password,
    );
  }

  /// 使用密码登录。
  Future<ApiResult<LoginResult>> loginWithPassword({
    required AuthIdentifierType identifierType,
    required String identifier,
    required String password,
  }) {
    return dioRequest.post<LoginResult>(
      HttpConstants.LOGIN_USER,
      data: {
        'identifierType': identifierType.backendValue,
        'loginMode': AuthLoginMode.password.backendValue,
        'identifier': identifier.trim(),
        'password': password,
      },
      showLoading: true,
      loadingText: '登录中...',
      decoder: (json) => LoginResult.fromJson(_asMap(json)),
    );
  }

  /// 使用验证码登录。
  Future<ApiResult<LoginResult>> loginWithCode({
    required AuthIdentifierType identifierType,
    required String identifier,
    required String code,
    required String codeId,
  }) {
    return dioRequest.post<LoginResult>(
      HttpConstants.LOGIN_USER,
      data: {
        'identifierType': identifierType.backendValue,
        'loginMode': AuthLoginMode.code.backendValue,
        'identifier': identifier.trim(),
        'code': code.trim(),
        'codeId': codeId.trim(),
      },
      showLoading: true,
      loadingText: '登录中...',
      decoder: (json) => LoginResult.fromJson(_asMap(json)),
    );
  }

  Future<ApiResult<RegisterResult>> _register({
    required AuthIdentifierType identifierType,
    required String identifier,
    required String code,
    required String codeId,
    required String svgCode,
    required String svgId,
    required String password,
  }) {
    final trimmedIdentifier = identifier.trim();

    return dioRequest.post<RegisterResult>(
      HttpConstants.REGISTER_USER,
      data: {
        'identifierType': identifierType.backendValue,
        'email': identifierType == AuthIdentifierType.email
            ? trimmedIdentifier
            : '',
        'phone': identifierType == AuthIdentifierType.phone
            ? trimmedIdentifier
            : '',
        'code': code.trim(),
        'codeId': codeId.trim(),
        'svgCode': svgCode.trim(),
        'svgId': svgId.trim(),
        'password': password,
      },
      showLoading: true,
      loadingText: '注册中...',
      decoder: (json) => RegisterResult.fromJson(_asMap(json)),
    );
  }

  /// 把不稳定的动态 JSON 数据安全转换为 `Map<String, dynamic>`。
  static Map<String, dynamic> _asMap(dynamic json) {
    if (json is Map<String, dynamic>) {
      return json;
    }
    if (json is Map) {
      return json.map((key, value) => MapEntry(key.toString(), value));
    }
    return <String, dynamic>{};
  }
}

const authApi = AuthApi();
