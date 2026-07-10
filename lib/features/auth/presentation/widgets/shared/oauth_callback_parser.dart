/// Parsed OAuth callback containing the authorization code and state.
class OAuthCallback {
  const OAuthCallback({required this.code, required this.state});

  final String code;
  final String state;
}

/// Parses a raw user-pasted OAuth callback string into an [OAuthCallback].
///
/// The input may be:
/// 1. A full URL with `code` and `state` query parameters
///    (e.g. `https://app.example.com/oauth/wechat/callback?code=abc&state=xyz`)
/// 2. A query string starting with `?`
///    (e.g. `?code=abc&state=xyz`)
/// 3. A bare code token (only when [fallbackState] is provided)
///
/// Returns `null` when the input is empty or cannot be parsed.
class OAuthCallbackParser {
  OAuthCallbackParser._();

  /// Parses [raw] into an [OAuthCallback], using [fallbackState] when the
  /// input itself doesn't contain a `state` parameter.
  ///
  /// This is used for WeChat, QQ, and any other OAuth provider that returns
  /// `code` + `state` pairs.
  static OAuthCallback? parse(String raw, String? fallbackState) {
    final input = raw.trim();
    if (input.isEmpty) return null;

    // 1. Try parsing as a full URL.
    final uri = Uri.tryParse(input);
    final uriCode = uri?.queryParameters['code']?.trim();
    final uriState = uri?.queryParameters['state']?.trim();
    if (uriCode?.isNotEmpty == true &&
        (uriState?.isNotEmpty == true || fallbackState?.isNotEmpty == true)) {
      return OAuthCallback(
        code: uriCode!,
        state: uriState?.isNotEmpty == true ? uriState! : fallbackState!,
      );
    }

    // 2. Try parsing as a bare query string (with or without leading '?').
    final query = input.startsWith('?') ? input.substring(1) : input;
    if (query.contains('=')) {
      try {
        final values = Uri.splitQueryString(query);
        final code = values['code']?.trim();
        final state = values['state']?.trim();
        if (code?.isNotEmpty == true &&
            (state?.isNotEmpty == true || fallbackState?.isNotEmpty == true)) {
          return OAuthCallback(
            code: code!,
            state: state?.isNotEmpty == true ? state! : fallbackState!,
          );
        }
      } on FormatException {
        return null;
      }
    }

    // 3. Treat as a bare code if we have a fallback state and the input
    //    looks like a single token (no whitespace).
    if (!input.contains(RegExp(r'\s')) && fallbackState?.isNotEmpty == true) {
      return OAuthCallback(code: input, state: fallbackState!);
    }

    return null;
  }
}
