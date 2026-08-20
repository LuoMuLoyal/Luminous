/// Application metadata shown in the about page.
///
/// Only contains fields that come from the backend (runtime config).
/// App name, version, and build number are obtained locally via
/// `package_info_plus`.
class AppInfo {
  const AppInfo({
    this.minClientVersion,
    this.latestVersion,
    this.downloadUrl,
    this.supportEmail,
  });

  final String? minClientVersion;
  final String? latestVersion;
  final String? downloadUrl;
  final String? supportEmail;
}

/// Fallback support URL used when no support email is configured in [AppInfo].
/// Only used as a last-resort link in the About page.
const kFallbackSupportUrl = 'https://github.com/LuoMuLoyal/Luminous';
