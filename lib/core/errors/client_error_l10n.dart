import 'package:luminous/core/errors/client_error_code.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Maps a [ClientErrorCode] to a localized user-facing string.
///
/// Counterpart of `NetworkErrorL10n` for failures the client detects itself:
/// the failing layer carries the code, and only presentation sites with a
/// [AppLocalizations] handle turn it into copy.
abstract final class ClientErrorL10n {
  static String map(ClientErrorCode code, AppLocalizations l10n) {
    return switch (code) {
      ClientErrorCode.notSignedIn => l10n.authNotSignedIn,
      // 三种"当前环境不支持微信登录"共用一个用户可见结果：未配置 SDK、移动端
      // 平台不支持、桌面回调监听不支持。代码分开是为了运维侧能区分原因。
      ClientErrorCode.wechatSdkNotConfigured ||
      ClientErrorCode.wechatMobileUnsupported ||
      ClientErrorCode.wechatDesktopUnsupported =>
        l10n.authWechatLoginUnsupported,
      // 注册失败与启动失败对用户是同一件事：这次授权没能起来。
      ClientErrorCode.wechatSdkRegistrationFailed ||
      ClientErrorCode.wechatAuthStartFailed => l10n.authWechatStartFailed,
      ClientErrorCode.wechatNotInstalled => l10n.authWechatNotInstalled,
      ClientErrorCode.wechatAuthFailed => l10n.authWechatAuthFailed,
      ClientErrorCode.wechatAuthTimeout => l10n.authWechatAuthTimeout,
      ClientErrorCode.refreshTokenUnavailable =>
        l10n.authRefreshTokenUnavailable,
      // 头像预检（`profile.dart` / `avatar_draft.dart`）已用同一批键，上传失败
      // 复用它们，避免同一件事在两条路径上给出不同文案。
      ClientErrorCode.avatarFileEmpty => l10n.profileAvatarEmptyFile,
      ClientErrorCode.avatarFileTypeUnsupported =>
        l10n.profileAvatarUnsupportedType,
      ClientErrorCode.avatarFileTooLarge => l10n.profileAvatarTooLarge,
    };
  }
}
