import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/widgets/common/avatar/avatar_actions.dart';
import 'package:luminous/core/widgets/common/control/divider.dart';
import 'package:luminous/core/widgets/common/dialog/sheet_drag_handle.dart';

import '../../helpers/test_forui_app.dart';

void main() {
  testWidgets('avatar actions dialog lists the management actions', (
    tester,
  ) async {
    await tester.pumpWidget(
      TestForuiApp(
        home: Builder(
          builder: (context) => FButtonProbe(
            onPress: () => showAvatarActionsDialog(
              context,
              avatarUrl: 'https://example.com/avatar.png',
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('probe'));
    await tester.pumpAndSettle();

    expect(find.text('头像设置'), findsOneWidget);
    // A centered dialog, not a bottom sheet: no drag handle, and the options sit
    // on one flat surface separated by dividers instead of card framing.
    expect(find.byType(SheetDragHandle), findsNothing);
    expect(find.byType(SheetSurface), findsNothing);
    expect(find.byType(AppDivider), findsNWidgets(3));

    expect(find.byKey(const Key('avatar-action-view')), findsOneWidget);
    expect(find.text('查看头像'), findsOneWidget);
    expect(find.byKey(const Key('avatar-action-camera')), findsOneWidget);
    expect(find.text('拍照'), findsOneWidget);
    expect(find.text('从相册选择'), findsOneWidget);
    expect(find.text('移除头像'), findsOneWidget);

    await tester.tap(find.text('从相册选择'));
    await tester.pumpAndSettle();
    expect(find.text('头像设置'), findsNothing);
  });

  testWidgets('avatar actions dialog hides viewing when there is no avatar', (
    tester,
  ) async {
    await tester.pumpWidget(
      TestForuiApp(
        home: Builder(
          builder: (context) => FButtonProbe(
            onPress: () => showAvatarActionsDialog(context, avatarUrl: '   '),
          ),
        ),
      ),
    );

    await tester.tap(find.text('probe'));
    await tester.pumpAndSettle();

    expect(find.text('头像设置'), findsOneWidget);
    expect(find.byKey(const Key('avatar-action-view')), findsNothing);
    expect(find.text('查看头像'), findsNothing);
    expect(find.byKey(const Key('avatar-action-camera')), findsOneWidget);
    expect(find.byKey(const Key('avatar-action-gallery')), findsOneWidget);
    expect(find.byKey(const Key('avatar-action-remove')), findsOneWidget);
    expect(find.byType(AppDivider), findsNWidgets(2));

    await tester.tapAt(const Offset(8, 8));
    await tester.pumpAndSettle();
    expect(find.text('头像设置'), findsNothing);
  });
}

class FButtonProbe extends StatelessWidget {
  const FButtonProbe({super.key, required this.onPress});

  final Future<void> Function() onPress;

  @override
  Widget build(BuildContext context) {
    return TextButton(onPressed: () => onPress(), child: const Text('probe'));
  }
}
