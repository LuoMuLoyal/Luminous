/// 本地持久化存储 key 常量。
///
/// 从 `GlobalConstants` 迁出，只包含与本地存储直接相关的 key。
/// Token、用户、主题、语言、装饰透明度等 key 集中在此管理。
class StorageKeys {
  StorageKeys._();

  /// 本地存储 AT 时使用的 key。
  static const String token = 'luminous_access_token';

  /// 本地存储 RT 时使用的 key。
  static const String refreshToken = 'luminous_refresh_token';

  /// 本地存储用户信息时使用的 key。
  static const String user = 'luminous_user';

  /// 本地存储主题模式偏好时使用的 key。
  static const String themeMode = 'luminous_theme_mode';

  /// 本地存储主题风格偏好时使用的 key。
  static const String themeStyle = 'luminous_theme_style';

  /// 本地存储语言偏好时使用的 key。
  static const String locale = 'luminous_locale';

  /// 本地存储氛围装饰透明度偏好时使用的 key。
  static const String ornamentTransparency = 'luminous_ornament_transparency';
}
