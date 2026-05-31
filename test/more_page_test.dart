import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/theme/app_theme.dart';
import 'package:luminous/features/more/presentation/more_page.dart';
import 'package:luminous/l10n/app_localizations.dart';

void main() {
  testWidgets('More page renders mobile mock sections', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(393, 852);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    await _pumpMorePage(tester);

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    final scrollable = find.byType(Scrollable).first;
    final keys = <String>[
      'more-emergency-section',
      'more-family-section',
      'more-ai-section',
      'more-device-section',
      'more-knowledge-section',
      'more-environment-section',
    ];

    for (final key in keys) {
      final finder = find.byKey(Key(key));
      await tester.scrollUntilVisible(finder, 260, scrollable: scrollable);
      await tester.pump(const Duration(milliseconds: 200));
      expect(finder, findsOneWidget);
    }

    expect(find.text('紧急救助'), findsOneWidget);
    expect(find.text('家庭健康'), findsOneWidget);
    expect(find.text('AI 识别工具箱'), findsOneWidget);
    expect(find.text('智能设备管理'), findsOneWidget);
    expect(find.text('知识与服务'), findsOneWidget);
    expect(find.text('环境与健康提醒中心'), findsOneWidget);
    expect(find.text('SOS 紧急求助'), findsOneWidget);
    expect(find.text('我的设备'), findsOneWidget);
  });

  testWidgets('More page renders desktop side panels', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1440, 1000);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    await _pumpMorePage(tester);

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byKey(const Key('more-environment-panel')), findsOneWidget);
    expect(find.byKey(const Key('more-recent-panel')), findsOneWidget);
    expect(find.byKey(const Key('more-quick-panel')), findsOneWidget);
    expect(find.byKey(const Key('more-note-panel')), findsOneWidget);
    expect(find.text('环境与健康提醒中心'), findsOneWidget);
    expect(find.text('最近使用'), findsOneWidget);
    expect(find.text('快捷入口'), findsOneWidget);
    expect(find.text('温馨提示'), findsOneWidget);
    expect(find.text('过敏防护建议'), findsOneWidget);
  });
}

Future<void> _pumpMorePage(WidgetTester tester) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        locale: const Locale('zh'),
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: const MorePage(),
      ),
    ),
  );
}
