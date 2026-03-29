import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:luminous/pages/Settings/settings.dart';
import 'package:luminous/stores/theme_controller.dart';
import 'package:luminous/stores/user_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues(<String, Object>{});
    Get.testMode = true;
    Get.reset();
    final userController = Get.put(UserController(), permanent: true);
    await userController.init();
    final themeController = Get.put(ThemeController(), permanent: true);
    await themeController.init();
  });

  testWidgets('settings page builds without exceptions', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SettingsPage()));

    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('设置'), findsOneWidget);
    expect(find.text('主题设置'), findsOneWidget);
    expect(find.text('语言设置'), findsOneWidget);
  });

  testWidgets('theme settings entry navigates to theme detail page', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SettingsPage()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('主题设置'));
    await tester.pumpAndSettle();

    expect(find.text('主题设置'), findsWidgets);
    expect(find.text('主题模式'), findsOneWidget);
    expect(find.text('主题风格'), findsOneWidget);
  });

  testWidgets('language settings entry navigates to placeholder page', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SettingsPage()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('语言设置'));
    await tester.pumpAndSettle();

    expect(find.text('语言设置'), findsWidgets);
    expect(find.text('简体中文'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('即将支持'), findsOneWidget);
  });
}
