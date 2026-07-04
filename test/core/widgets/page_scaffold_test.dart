import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/widgets/common/app_back_button.dart';
import 'package:luminous/core/widgets/layout/page_scaffold.dart';

import '../../helpers/test_forui_app.dart';

Widget _appShell(Widget child) {
  return TestForuiApp(home: child);
}

void main() {
  group('PageScaffold', () {
    testWidgets('renders title and body', (tester) async {
      await tester.pumpWidget(
        _appShell(
          const PageScaffold(title: 'Settings', child: Text('Body content')),
        ),
      );

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Body content'), findsOneWidget);
      expect(find.byType(FScaffold), findsOneWidget);
    });

    testWidgets('uses AppBackButton as default leading', (tester) async {
      await tester.pumpWidget(
        _appShell(const PageScaffold(title: 'Page', child: SizedBox.shrink())),
      );

      expect(find.byType(AppBackButton), findsOneWidget);
    });

    testWidgets('can hide leading', (tester) async {
      await tester.pumpWidget(
        _appShell(
          const PageScaffold(
            title: 'Page',
            leading: null,
            child: SizedBox.shrink(),
          ),
        ),
      );

      expect(find.byType(AppBackButton), findsNothing);
    });

    testWidgets('renders actions', (tester) async {
      await tester.pumpWidget(
        _appShell(
          PageScaffold(
            title: 'Page',
            actions: [
              IconButton(icon: const Icon(Icons.share), onPressed: () {}),
            ],
            child: const SizedBox.shrink(),
          ),
        ),
      );

      expect(find.byIcon(Icons.share), findsOneWidget);
    });

    testWidgets('renders custom title widget', (tester) async {
      await tester.pumpWidget(
        _appShell(
          const PageScaffold(
            titleWidget: Text('Custom Title'),
            child: SizedBox.shrink(),
          ),
        ),
      );

      expect(find.text('Custom Title'), findsOneWidget);
    });

    testWidgets('renders when centerTitle is false', (tester) async {
      await tester.pumpWidget(
        _appShell(
          const PageScaffold(
            title: 'Left',
            centerTitle: false,
            child: SizedBox.shrink(),
          ),
        ),
      );

      expect(find.text('Left'), findsOneWidget);
    });

    testWidgets('wraps body in SafeArea by default', (tester) async {
      await tester.pumpWidget(
        _appShell(const PageScaffold(title: 'Page', child: Text('Body'))),
      );

      final scaffold = tester.widget<FScaffold>(find.byType(FScaffold));
      expect(scaffold.child, isA<SafeArea>());
    });

    testWidgets('can disable SafeArea', (tester) async {
      await tester.pumpWidget(
        _appShell(
          const PageScaffold(
            title: 'Page',
            useSafeArea: false,
            child: Text('Body'),
          ),
        ),
      );

      final scaffold = tester.widget<FScaffold>(find.byType(FScaffold));
      expect(scaffold.child, isA<Text>());
    });
  });
}
