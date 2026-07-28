/// Action type for a support resource.
enum SupportResourceAction {
  url,
  phone,
  internal,
  unknown;

  static SupportResourceAction fromJson(String? json) {
    return switch (json) {
      'url' => SupportResourceAction.url,
      'phone' => SupportResourceAction.phone,
      'internal' => SupportResourceAction.internal,
      _ => SupportResourceAction.unknown,
    };
  }
}

/// A support resource shown in help or about pages.
class SupportResource {
  const SupportResource({
    required this.id,
    required this.title,
    required this.available,
    this.titleKey,
    this.subtitle,
    this.subtitleKey,
    this.icon,
    this.actionUrl,
    this.actionType,
  });

  final String id;
  final String title;
  final String? titleKey;
  final String? subtitle;
  final String? subtitleKey;
  final String? icon;
  final String? actionUrl;
  final SupportResourceAction? actionType;

  /// Whether the resource is currently available.
  final bool available;
}

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
