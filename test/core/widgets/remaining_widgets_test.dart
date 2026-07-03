import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';

import '../../helpers/test_forui_app.dart';

Widget _appShell(Widget child) {
  return TestForuiApp(home: Scaffold(body: child));
}

void main() {
  // ── Header Action Chip → FButton.icon ───────────────────────

  group('FButton.icon — 操作按钮', () {
    testWidgets('渲染标签和前缀图标', (tester) async {
      await tester.pumpWidget(
        _appShell(
          FButton(
            prefix: const Icon(FLucideIcons.search),
            child: const Text('Search'),
            onPress: () {},
            mainAxisSize: MainAxisSize.min,
          ),
        ),
      );

      expect(find.text('Search'), findsOneWidget);
      expect(find.byIcon(FLucideIcons.search), findsOneWidget);
    });

    testWidgets('点击触发回调', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        _appShell(
          FButton(
            child: const Text('Tap me'),
            onPress: () => tapped = true,
            mainAxisSize: MainAxisSize.min,
          ),
        ),
      );

      await tester.tap(find.text('Tap me'));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);
    });
  });

  // ── Image Placeholder → Container + Icon + Text ────────────

  group('图片占位符', () {
    testWidgets('渲染标签和默认图标', (tester) async {
      await tester.pumpWidget(
        _appShell(
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(FLucideIcons.image, size: 32),
                SizedBox(height: 8),
                Text('No image'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('No image'), findsOneWidget);
      expect(find.byIcon(FLucideIcons.image), findsOneWidget);
    });

    testWidgets('支持自定义图标', (tester) async {
      await tester.pumpWidget(
        _appShell(
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(FLucideIcons.camera, size: 32),
                SizedBox(height: 8),
                Text('Photo'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Photo'), findsOneWidget);
      expect(find.byIcon(FLucideIcons.camera), findsOneWidget);
    });

    testWidgets('支持指定宽高', (tester) async {
      await tester.pumpWidget(
        _appShell(
          const SizedBox(
            width: 200,
            height: 150,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(FLucideIcons.image, size: 32),
                SizedBox(height: 8),
                Text('Sized'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Sized'), findsOneWidget);
    });
  });

  // ── Settings Switch Row → FTile + FSwitch ─────────────────

  group('FTile + FSwitch — 设置开关行', () {
    testWidgets('渲染标题和开关', (tester) async {
      await tester.pumpWidget(
        _appShell(
          FTile(
            title: const Text('Enable feature'),
            suffix: FSwitch(value: true, onChange: (_) {}),
          ),
        ),
      );

      expect(find.text('Enable feature'), findsOneWidget);
      expect(find.byType(FSwitch), findsOneWidget);
    });

    testWidgets('带副标题', (tester) async {
      await tester.pumpWidget(
        _appShell(
          FTile(
            title: const Text('Notifications'),
            subtitle: const Text('Get push alerts'),
            suffix: FSwitch(value: false, onChange: (_) {}),
          ),
        ),
      );

      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Get push alerts'), findsOneWidget);
    });

    testWidgets('点击 FSwitch 切换开关', (tester) async {
      bool toggled = false;
      await tester.pumpWidget(
        _appShell(
          FTile(
            title: const Text('Toggle me'),
            suffix: FSwitch(value: false, onChange: (v) => toggled = v),
          ),
        ),
      );

      await tester.tap(find.byType(FSwitch));
      await tester.pumpAndSettle();
      expect(toggled, isTrue);
    });
  });

  // ── Setting Row → FTile ──────────────────────────────────

  group('FTile — 设置行', () {
    testWidgets('渲染标题并响应点击', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        _appShell(
          FTile(
            title: const Text('Open settings'),
            onPress: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.text('Open settings'));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);
    });

    testWidgets('带头部箭头图标', (tester) async {
      await tester.pumpWidget(
        _appShell(
          FTile(
            title: const Text('With chevron'),
            suffix: const Icon(FLucideIcons.chevronRight),
          ),
        ),
      );

      expect(find.byIcon(FLucideIcons.chevronRight), findsOneWidget);
    });

    testWidgets('带副标题和值', (tester) async {
      await tester.pumpWidget(
        _appShell(
          FTile(
            title: const Text('Profile'),
            subtitle: const Text('Manage your data'),
            details: const Text('View'),
          ),
        ),
      );

      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('Manage your data'), findsOneWidget);
      expect(find.text('View'), findsOneWidget);
    });

    testWidgets('支持自定义后缀组件', (tester) async {
      await tester.pumpWidget(
        _appShell(
          FTile(
            title: const Text('With trailing'),
            suffix: const Icon(Icons.star),
          ),
        ),
      );

      expect(find.byIcon(Icons.star), findsOneWidget);
    });
  });

  // ── Settings Navigation Row → FTile + chevron ────────────

  group('FTile — 导航行', () {
    testWidgets('渲染标题和箭头', (tester) async {
      await tester.pumpWidget(
        _appShell(
          FTile(
            title: const Text('Go to page'),
            suffix: const Icon(FLucideIcons.chevronRight),
          ),
        ),
      );

      expect(find.text('Go to page'), findsOneWidget);
      expect(find.byIcon(FLucideIcons.chevronRight), findsOneWidget);
    });

    testWidgets('带副标题和值', (tester) async {
      await tester.pumpWidget(
        _appShell(
          FTile(
            title: const Text('Language'),
            subtitle: const Text('App locale'),
            details: const Text('English'),
            suffix: const Icon(FLucideIcons.chevronRight),
          ),
        ),
      );

      expect(find.text('Language'), findsOneWidget);
      expect(find.text('App locale'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
    });

    testWidgets('点击触发导航', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        _appShell(
          FTile(
            title: const Text('Navigate'),
            onPress: () => tapped = true,
            suffix: const Icon(FLucideIcons.chevronRight),
          ),
        ),
      );

      await tester.tap(find.text('Navigate'));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);
    });
  });

  // ── Settings Section → Text section label ────────────────

  group('FTileGroup — 段落标签', () {
    testWidgets('渲染段落标题', (tester) async {
      await tester.pumpWidget(
        _appShell(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 16, bottom: 4),
                child: Text(
                  'General',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              FTileGroup(
                children: [
                  FTile(title: const Text('Item 1')),
                  FTile(title: const Text('Item 2')),
                ],
              ),
            ],
          ),
        ),
      );

      expect(find.text('General'), findsOneWidget);
      expect(find.byType(FTileGroup), findsOneWidget);
    });
  });
}
