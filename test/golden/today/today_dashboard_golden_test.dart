import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/theme/app_theme.dart';
import 'package:luminous/features/today/data/repositories/mock_today_repository.dart';
import 'package:luminous/features/today/presentation/widgets/today_dashboard_view.dart';

void main() {
  testWidgets('Today dashboard mobile golden', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: TodayDashboardView(
              dashboard: MockTodayRepository.previewDashboard,
              onRefresh: () async {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(TodayDashboardView),
      matchesGoldenFile('golden/today/today_dashboard_mobile.png'),
    );
  });

  testWidgets('Today dashboard loading golden', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: TodayDashboardView(
              dashboard: MockTodayRepository.previewDashboard,
              isLoading: true,
              onRefresh: () async {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(TodayDashboardView),
      matchesGoldenFile('golden/today/today_dashboard_loading.png'),
    );
  });
}
