import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luminous/constants/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 全局主题控制器。
///
/// 只负责一件事：
/// - 持久化并恢复“是否启用暗黑模式”。
class ThemeController extends GetxController {
  final RxBool isDarkMode = false.obs;
  Future<SharedPreferences>? _prefsFuture;

  Future<SharedPreferences> get _prefs async {
    return _prefsFuture ??= SharedPreferences.getInstance();
  }

  /// 当前应用真正使用的 ThemeMode。
  ThemeMode get themeMode => isDarkMode.value ? ThemeMode.dark : ThemeMode.light;

  /// 启动时恢复上一次保存的主题选择。
  Future<void> init() async {
    final prefs = await _prefs;
    isDarkMode.value = prefs.getBool(GlobalConstants.DARK_MODE_KEY) ?? false;
  }

  /// 更新暗黑模式开关，并写入本地持久化。
  Future<void> setDarkMode(bool enabled) async {
    if (isDarkMode.value == enabled) {
      return;
    }
    isDarkMode.value = enabled;
    final prefs = await _prefs;
    await prefs.setBool(GlobalConstants.DARK_MODE_KEY, enabled);
  }
}
