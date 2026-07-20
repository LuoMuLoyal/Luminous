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
class AppInfo {
  const AppInfo({
    required this.name,
    required this.version,
    required this.description,
    required this.buildDate,
    this.minClientVersion,
    this.supportEmail,
    this.privacyPolicyUrl,
    this.termsOfServiceUrl,
  });

  final String name;
  final String version;
  final String description;

  /// ISO-8601 build/publish timestamp.
  final String buildDate;
  final String? minClientVersion;
  final String? supportEmail;
  final String? privacyPolicyUrl;
  final String? termsOfServiceUrl;
}

/// Fallback support URL used when no support email is configured in [AppInfo].
/// Only used as a last-resort link in the About page.
const kFallbackSupportUrl = 'https://luminous.app/support';
