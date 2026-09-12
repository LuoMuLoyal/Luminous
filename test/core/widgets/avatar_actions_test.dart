import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/widgets/common/avatar/avatar_actions.dart';
import 'package:luminous/core/widgets/common/avatar/avatar_viewer.dart';

import '../../helpers/test_forui_app.dart';

void main() {
  testWidgets('avatar actions sheet exposes the management actions', (
    tester,
  ) async {
    await tester.pumpWidget(
      TestForuiApp(
        home: Builder(
          builder: (context) => FButton(
            onPress: () => showAvatarActionsSheet(
              context,
              avatarUrl: 'https://example.com/avatar.png',
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('头像设置'), findsOneWidget);
    expect(find.text('拍照'), findsOneWidget);
    expect(find.text('从相册选择'), findsOneWidget);
    expect(find.text('移除头像'), findsOneWidget);

    await tester.tap(find.text('移除头像'));
    await tester.pumpAndSettle();
  });

  testWidgets('avatar viewer supports interactive viewing and closing', (
    tester,
  ) async {
    await tester.pumpWidget(
      const TestForuiApp(
        home: AvatarViewer(avatarUrl: 'https://example.com/avatar.png'),
      ),
    );

    expect(find.byType(InteractiveViewer), findsOneWidget);
    expect(find.byTooltip('关闭'), findsOneWidget);
  });
}
