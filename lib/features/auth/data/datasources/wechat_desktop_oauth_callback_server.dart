class WechatOAuthCallback {
  const WechatOAuthCallback({required this.code, required this.state});

  final String code;
  final String state;
}

class WechatDesktopOAuthCallbackServer {
  const WechatDesktopOAuthCallbackServer({
    required this.callbackUri,
    required this.callback,
    required this.close,
  });

  final Uri callbackUri;
  final Future<WechatOAuthCallback> callback;
  final Future<void> Function() close;
}
