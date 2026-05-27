import 'dart:ui' as ui;

import 'package:luminous/core/providers/locale_provider.dart';

/// 轻量文本本地化助手。
///
/// 适用于没有 BuildContext 的底层模块（如 utils/store/viewmodel）。
class AppI18nText {
  AppI18nText._();

  /// 注入一个读取当前 [AppLocalePreference] 的函数。
  ///
  /// 在 `main()` 创建 [ProviderContainer] 后调用一次，替换默认的
  /// 系统语言回退逻辑。
  static void init({
    required AppLocalePreference Function() readLocalePreference,
  }) {
    _readLocalePreference = readLocalePreference;
  }

  /// 在单元测试中重置，避免跨测试污染。
  static void resetForTest() {
    _readLocalePreference = null;
  }

  static AppLocalePreference Function()? _readLocalePreference;

  static bool get isChinese {
    final languageCode = _currentLanguageCode.toLowerCase();
    return languageCode.startsWith('zh');
  }

  static String pick({required String zh, required String en}) {
    return isChinese ? zh : en;
  }

  static String get _currentLanguageCode {
    try {
      final preference = _readLocalePreference?.call();
      switch (preference) {
        case AppLocalePreference.zh:
          return 'zh';
        case AppLocalePreference.en:
          return 'en';
        case AppLocalePreference.system:
          break;
        case null:
          break;
      }
    } catch (_) {
      // Tests and early startup can call this before the app container exists.
    }

    return ui.PlatformDispatcher.instance.locale.languageCode;
  }
}
