import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/widgets/common/avatar/avatar_view.dart';

import '../../helpers/test_forui_app.dart';

void main() {
  group('AvatarView', () {
    testWidgets('uses the account fallback when no URL is provided', (
      tester,
    ) async {
      await tester.pumpWidget(
        const TestForuiApp(
          home: AvatarView(semanticLabel: '头像', size: 64, iconSize: 32),
        ),
      );

      expect(find.bySemanticsLabel('头像'), findsOneWidget);
    });

    testWidgets('uses a cached network image when a URL is provided', (
      tester,
    ) async {
      await tester.pumpWidget(
        const TestForuiApp(
          home: AvatarView(
            avatarUrl: 'https://example.com/avatar.png',
            semanticLabel: '头像',
          ),
        ),
      );

      expect(find.byType(CachedNetworkImage), findsOneWidget);
      expect(find.bySemanticsLabel('头像'), findsOneWidget);
    });
  });
}
