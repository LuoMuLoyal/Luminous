import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/logger/logger.dart';
import 'package:luminous/core/network/api_exception.dart';
import 'package:luminous/core/network/client_providers.dart';
import 'package:luminous/core/network/envelope.dart';
import 'package:luminous/core/network/security_elevation_token_holder.dart';

/// State of the security elevation flow.
sealed class SecurityElevationState {
  const SecurityElevationState();

  /// No valid elevation token is available.
  bool get needsVerification => this is SecurityElevationUnverified;

  /// A valid elevation token is available.
  bool get isVerified => this is SecurityElevationVerified;
}

/// No elevation token has been obtained (or it has expired / been cleared).
class SecurityElevationUnverified extends SecurityElevationState {
  const SecurityElevationUnverified();
}

/// A valid elevation token is currently held.
class SecurityElevationVerified extends SecurityElevationState {
  const SecurityElevationVerified({required this.expiresAt});

  final DateTime expiresAt;
}

/// Controller for the security elevation lifecycle.
///
/// - [verify] calls `POST /settings/security-pin/verify` with the user's
///   6-digit PIN and stores the returned elevation token in the
///   [SecurityElevationTokenHolder] so the Dio interceptor can inject it.
/// - [clear] invalidates the token (e.g. on logout, PIN change, PIN disable).
/// - The state reflects whether a valid token is currently held.
class SecurityElevationController extends Notifier<SecurityElevationState> {
  @override
  SecurityElevationState build() {
    // Clear elevation when the auth session changes (logout / user switch).
    ref.listen(authSessionProvider, (_, session) {
      if (session.isConfirmedSignedOut) {
        _holder.clear();
        state = const SecurityElevationUnverified();
      }
    });

    return const SecurityElevationUnverified();
  }

  SecurityElevationTokenHolder get _holder =>
      ref.read(securityElevationTokenHolderProvider);

  /// Verifies the PIN and stores the elevation token.
  ///
  /// Returns `true` on success, `false` on failure (wrong PIN, network
  /// error, PIN not enabled, etc.).
  Future<bool> verify(String pin) async {
    try {
      final api = ref.read(lucentClientProvider).userSettings;
      final response = await api.userSettingsControllerVerifySecurityPinV1(
        verifySecurityPinDto: VerifySecurityPinDto(pin: pin),
      );
      final dto = requireData(response.data, operation: 'verifySecurityPin');
      // 生成客户端切换到资源响应前，保留 DTO 内部状态校验；错误 HTTP
      // 响应已经由 Problem Details 错误链处理。
      ensureEnvelopeSuccess(code: dto.code, message: dto.message);
      final data = dto.data;
      final expiresAtStr = data.expiresAt;
      final expiresAt = DateTime.tryParse(expiresAtStr);
      if (expiresAt == null) {
        // 服务端过期时间无法解析:视为验证失败,拒绝设置提升令牌。绝不使用
        // 客户端时间兜底延长有效期——否则服务端异常或被篡改的响应会人为
        // 延长安全提升状态。
        appTalker.warning(
          'SecurityElevation: verify 返回非法 expiresAt($expiresAtStr),'
          '拒绝设置提升令牌',
        );
        return false;
      }

      _holder.set(data.elevationToken, expiresAt);
      state = SecurityElevationVerified(expiresAt: expiresAt);
      return true;
    } on DioException {
      // 可预期失败:Problem Details 与网络/HTTP 层错误均属正常用户可见
      // 失败,直接返回 false。
      return false;
    } on LucentApiException {
      // 旧 DTO 直连或本地手工错误仍可能抛出此异常；资源客户端迁移后删除。
      return false;
    } catch (e, st) {
      // 意外异常(TypeError、空响应、解析错误等):记录日志与堆栈后返回
      // false,避免生产环境"验证莫名失败"却无迹可查。
      appTalker.error('SecurityElevation: verify 意外异常: $e', st);
      return false;
    }
  }

  /// Clears the elevation token.
  void clear() {
    _holder.clear();
    state = const SecurityElevationUnverified();
  }

  /// Whether a valid (non-expired) elevation token is currently held.
  bool get hasValidToken => _holder.hasValidToken;
}

final securityElevationControllerProvider =
    NotifierProvider<SecurityElevationController, SecurityElevationState>(
      SecurityElevationController.new,
    );
