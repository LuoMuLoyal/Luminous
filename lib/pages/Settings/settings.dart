import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luminous/stores/theme_controller.dart';
import 'package:luminous/stores/user_controller.dart';
import 'package:luminous/utils/toast_utils.dart';

/// 设置页。
///
/// 当前先放两项：
/// - 暗黑模式；
/// - 退出登录。
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final userController = Get.find<UserController>();
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            _SettingsSectionCard(
              title: '显示',
              children: [
                Obx(
                  () => SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    secondary: Icon(
                      themeController.isDarkMode.value
                          ? Icons.dark_mode_rounded
                          : Icons.light_mode_rounded,
                      color: scheme.primary,
                    ),
                    title: const Text(
                      '暗黑模式',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: Text(
                      themeController.isDarkMode.value
                          ? '当前为暗黑模式'
                          : '当前为明亮模式',
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    value: themeController.isDarkMode.value,
                    onChanged: themeController.setDarkMode,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _SettingsSectionCard(
              title: '账号',
              children: [
                Obx(() {
                  final loggedIn = userController.isLoggedIn;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    enabled: loggedIn,
                    leading: Icon(
                      Icons.logout_rounded,
                      color: loggedIn
                          ? scheme.error
                          : scheme.onSurfaceVariant.withValues(alpha: 0.7),
                    ),
                    title: const Text(
                      '退出登录',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: Text(
                      loggedIn ? '清除当前设备上的登录状态' : '当前还没有登录账号',
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    trailing: loggedIn
                        ? Icon(
                            Icons.chevron_right_rounded,
                            color: scheme.onSurfaceVariant,
                          )
                        : null,
                    onTap: loggedIn
                        ? () => _confirmLogout(context, userController)
                        : () {
                            ToastUtils.instance.show(context, '当前未登录');
                          },
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmLogout(
    BuildContext context,
    UserController userController,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('退出登录'),
          content: const Text('确定要退出当前账号吗？本地登录状态会被清除。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('退出'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    await userController.logout();
    if (context.mounted) {
      ToastUtils.instance.show(context, '已退出登录');
      Navigator.maybePop(context);
    }
  }
}

class _SettingsSectionCard extends StatelessWidget {
  const _SettingsSectionCard({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(
              alpha: theme.brightness == Brightness.dark ? 0.16 : 0.08,
            ),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: scheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }
}
