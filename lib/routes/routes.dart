import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luminous/constants/constants.dart';
import 'package:luminous/pages/CheckIn/checkin.dart';
import 'package:luminous/pages/Legal/legal_documents.dart';
import 'package:luminous/pages/Login/login.dart';
import 'package:luminous/pages/Main/main.dart';
import 'package:luminous/pages/Register/register.dart';
import 'package:luminous/pages/Reminders/reminder_list.dart';
import 'package:luminous/pages/Safety/safety_assist.dart';
import 'package:luminous/pages/Scan/medicine_scan.dart';
import 'package:luminous/pages/Search/search.dart';
import 'package:luminous/pages/Settings/settings.dart';
import 'package:luminous/stores/theme_controller.dart';
import 'package:luminous/utils/loading_utils.dart';

/// 构建应用根组件。
///
/// 当前项目使用原生 `MaterialApp` 路由表，不依赖 `GetMaterialApp`。
Widget getRootWidget() {
  final themeController = Get.find<ThemeController>();
  return Obx(
    () => MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: LoadingUtils.navigatorKey,
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: themeController.themeMode,
      initialRoute: '/',
      routes: getRootRoutes(),
    ),
  );
}

/// 返回整个应用的命名路由表。
///
/// 所有 `Navigator.pushNamed` 都会通过这里注册的页面进行匹配。
Map<String, Widget Function(BuildContext)> getRootRoutes() {
  return {
    '/': (context) => const MainPage(),
    '/login': (context) => const LoginPage(),
    '/register': (context) => const RegisterView(),
    '/search': (context) => const SearchView(),
    '/scan': (context) => const MedicineScanPage(
      mode: ScanEntryMode.result,
      promptSourceOnStart: true,
    ),
    '/reminders': (context) => const ReminderListPage(),
    '/checkin': (context) => const CheckInPage(),
    '/safety': (context) => const SafetyAssistPage(),
    '/settings': (context) => const SettingsPage(),
    '/user-agreement': (context) => const UserAgreementPage(),
    '/privacy-policy': (context) => const PrivacyPolicyPage(),
  };
}

ThemeData _buildLightTheme() {
  const primary = Color(0xFF0EA5E9);
  final colorScheme = ColorScheme.fromSeed(
    seedColor: primary,
    brightness: Brightness.light,
  ).copyWith(primary: primary, surface: Colors.white);

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppUiConstants.PAGE_BACKGROUND,
    dialogTheme: const DialogThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: Color(0xFF0F172A),
      elevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: const CardThemeData(
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppUiConstants.TAB_BAR_BACKGROUND,
      elevation: 0,
    ),
  );
}

ThemeData _buildDarkTheme() {
  const primary = Color(0xFF7DD3FC);
  const background = Color(0xFF0F172A);
  const surface = Color(0xFF162033);
  const surfaceAlt = Color(0xFF1E293B);
  final colorScheme =
      ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.dark,
      ).copyWith(
        primary: primary,
        surface: surface,
        secondary: const Color(0xFF99F6E4),
      );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: background,
    canvasColor: background,
    dialogTheme: const DialogThemeData(
      backgroundColor: surface,
      surfaceTintColor: Colors.transparent,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: const CardThemeData(
      color: surface,
      surfaceTintColor: Colors.transparent,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceAlt,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF111C2E),
      elevation: 0,
    ),
  );
}
