import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:luminous/routes/routes.dart';
import 'package:luminous/stores/locale_controller.dart';
import 'package:luminous/startup/app_startup_warmup.dart';
import 'package:luminous/stores/ornament_controller.dart';
import 'package:luminous/stores/theme_controller.dart';
import 'package:luminous/stores/user_controller.dart';

/// 应用入口函数。
///
/// 启动阶段只保留真正必须在首帧前完成的轻量注入，
/// 其余 I/O / SDK / 网络预热统一延后到首帧之后。
Future<void> main() async {
  /// 初始化 Flutter 绑定，确保插件调用可用。
  WidgetsFlutterBinding.ensureInitialized();

  // 只保留真正必须在 runApp 前完成的轻量依赖注入。
  final userController = Get.put(UserController(), permanent: true);
  userController.markSessionPending();
  final themeController = Get.put(ThemeController(), permanent: true);
  final localeController = Get.put(LocaleController(), permanent: true);
  final ornamentController = Get.put(OrnamentController(), permanent: true);

  // 偏好恢复与预热统一延后到首帧后，避免阻塞冷启动首帧。
  runApp(
    LuminousApp(
      userController: userController,
      themeController: themeController,
      localeController: localeController,
      ornamentController: ornamentController,
    ),
  );
}

/// 根应用包装器。
///
/// 负责：
/// - 尽快渲染首帧；
/// - 在首帧后启动所有异步 warm-up 任务。
class LuminousApp extends StatefulWidget {
  const LuminousApp({
    super.key,
    required this.userController,
    required this.themeController,
    required this.localeController,
    required this.ornamentController,
  });

  final UserController userController;
  final ThemeController themeController;
  final LocaleController localeController;
  final OrnamentController ornamentController;

  @override
  State<LuminousApp> createState() => _LuminousAppState();
}

class _LuminousAppState extends State<LuminousApp> {
  late final AppStartupWarmup _startupWarmup;

  @override
  void initState() {
    super.initState();
    _startupWarmup = AppStartupWarmup(
      userController: widget.userController,
      themeController: widget.themeController,
      localeController: widget.localeController,
      ornamentController: widget.ornamentController,
    );
    _startupWarmup.start();
  }

  @override
  Widget build(BuildContext context) {
    return getRootWidget();
  }
}
