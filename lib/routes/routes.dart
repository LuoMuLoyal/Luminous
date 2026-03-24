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
  const secondary = Color(0xFFC8A7F2);
  const tertiary = Color(0xFFE7C767);
  final colorScheme =
      ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
      ).copyWith(
        primary: primary,
        secondary: secondary,
        tertiary: tertiary,
        surface: Colors.white,
        onSurfaceVariant: const Color(0xFF64748B),
        outline: const Color(0xFFDDE5F0),
        shadow: const Color(0xFF0F172A),
      );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppUiConstants.PAGE_BACKGROUND,
    canvasColor: AppUiConstants.PAGE_BACKGROUND,
    dividerColor: const Color(0xFFE2E8F0),
    shadowColor: const Color(0xFF0F172A),
    dialogTheme: const DialogThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(24)),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: Color(0xFF0F172A),
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: const CardThemeData(
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        side: BorderSide(color: Color(0xFFE4EAF2)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF7F9FC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      hintStyle: const TextStyle(
        color: Color(0xFF94A3B8),
        fontWeight: FontWeight.w500,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(0, 46),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      side: const BorderSide(color: Color(0xFFCBD5E1)),
      fillColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.selected)) {
          return primary;
        }
        return Colors.white;
      }),
      checkColor: const WidgetStatePropertyAll<Color>(Colors.white),
    ),
    switchTheme: const SwitchThemeData(
      trackOutlineColor: WidgetStatePropertyAll<Color>(Colors.transparent),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.transparent,
      indicatorColor: primary.withValues(alpha: 0.12),
      labelTextStyle: WidgetStateProperty.resolveWith<TextStyle?>((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          fontSize: 12.5,
          fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
          color: selected ? primary : AppUiConstants.TAB_INACTIVE,
        );
      }),
    ),
  );
}

ThemeData _buildDarkTheme() {
  const primary = Color(0xFF7DD3FC);
  const secondary = Color(0xFFE0D2FF);
  const tertiary = Color(0xFFF7E3A5);
  const background = Color(0xFF0C1424);
  const surface = Color(0xFF131E30);
  const surfaceAlt = Color(0xFF1C2A41);
  final colorScheme =
      ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.dark,
      ).copyWith(
        primary: primary,
        surface: surface,
        secondary: secondary,
        tertiary: tertiary,
        onSurfaceVariant: const Color(0xFF97A6BA),
        outline: const Color(0xFF334155),
      );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: background,
    canvasColor: background,
    dividerColor: const Color(0xFF334155),
    shadowColor: Colors.black,
    dialogTheme: const DialogThemeData(
      backgroundColor: surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(24)),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: const CardThemeData(
      color: surface,
      surfaceTintColor: Colors.transparent,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        side: BorderSide(color: Color(0xFF334155)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceAlt,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      hintStyle: const TextStyle(
        color: Color(0xFF94A3B8),
        fontWeight: FontWeight.w500,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: const Color(0xFF082F49),
        minimumSize: const Size(0, 46),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      side: const BorderSide(color: Color(0xFF475569)),
      fillColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.selected)) {
          return primary;
        }
        return surfaceAlt;
      }),
      checkColor: const WidgetStatePropertyAll<Color>(Color(0xFF082F49)),
    ),
    switchTheme: const SwitchThemeData(
      trackOutlineColor: WidgetStatePropertyAll<Color>(Colors.transparent),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.transparent,
      indicatorColor: primary.withValues(alpha: 0.18),
      labelTextStyle: WidgetStateProperty.resolveWith<TextStyle?>((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          fontSize: 12.5,
          fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
          color: selected ? primary : const Color(0xFF94A3B8),
        );
      }),
    ),
  );
}
