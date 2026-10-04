/// Failure codes for errors the **client** detects itself.
///
/// The failing layer (data service, platform client, interceptor) carries this
/// enum instead of user-visible copy; the presentation layer maps it to a
/// localized string through `ClientErrorL10n.map`, normally via
/// `userMessageFromError`.
///
/// [NetworkErrorCode] stays the vocabulary for transport failures, and
/// `LucentFailure.code` for codes the server sent. Client codes fill the third
/// gap: "the client refused before/without a server answer".
enum ClientErrorCode {
  /// The action needs a signed-in user, but the session has none.
  notSignedIn,

  /// WeChat mobile SDK login is unavailable in this build (no app id).
  wechatSdkNotConfigured,

  /// WeChat mobile SDK login is not available on this platform.
  wechatMobileUnsupported,

  /// WeChat desktop OAuth callback listener is not available on this platform.
  wechatDesktopUnsupported,

  /// `Fluwx.registerApi` returned false.
  wechatSdkRegistrationFailed,

  /// The WeChat app is not installed on the device.
  wechatNotInstalled,

  /// WeChat authorization was cancelled or reported failure.
  wechatAuthFailed,

  /// WeChat authorization could not be started.
  wechatAuthStartFailed,

  /// WeChat authorization did not complete before the deadline.
  wechatAuthTimeout,

  /// No refresh token in the store, so the session cannot be renewed.
  refreshTokenUnavailable,

  /// Avatar upload refused: the picked file is empty.
  avatarFileEmpty,

  /// Avatar upload refused: the content type is not allowed.
  avatarFileTypeUnsupported,

  /// Avatar upload refused: the file exceeds the client size limit.
  avatarFileTooLarge,
}
