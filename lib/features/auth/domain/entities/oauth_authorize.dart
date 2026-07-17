/// Domain entity for an OAuth authorize URL response.
class OAuthAuthorizeData {
  const OAuthAuthorizeData({
    required this.authorizeUrl,
    required this.state,
    required this.expiresInSeconds,
  });

  final String authorizeUrl;
  final String state;
  final int expiresInSeconds;
}
