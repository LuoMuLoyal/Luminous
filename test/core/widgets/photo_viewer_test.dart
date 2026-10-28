import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/photo_viewer.dart';
import 'package:photo_view/photo_view.dart';

import '../../helpers/kv_test_store.dart';
import '../../helpers/test_forui_app.dart';

void main() {
  setUp(() {
    KvTestStore.install();
  });

  Future<void> pump(WidgetTester tester, Widget child) {
    return tester.pumpWidget(TestForuiApp(home: Scaffold(body: child)));
  }

  group('PhotoViewer', () {
    testWidgets('renders a zoomable PhotoView for a remote URL', (
      tester,
    ) async {
      await pump(
        tester,
        const PhotoViewer(imageUrl: 'https://example.com/a.png'),
      );

      final provider = tester
          .widget<PhotoView>(find.byType(PhotoView))
          .imageProvider;
      expect(provider, isA<CachedNetworkImageProvider>());
    });

    testWidgets('reuses the shared image cache instead of a second loader', (
      tester,
    ) async {
      await pump(
        tester,
        const PhotoViewer(imageUrl: 'https://example.com/a.png'),
      );

      final provider = tester
          .widget<PhotoView>(find.byType(PhotoView))
          .imageProvider;
      expect(
        (provider! as CachedNetworkImageProvider).url,
        'https://example.com/a.png',
      );
    });

    testWidgets('keeps zoom gestures enabled and bounded', (tester) async {
      await pump(
        tester,
        const PhotoViewer(imageUrl: 'https://example.com/a.png'),
      );

      final photoView = tester.widget<PhotoView>(find.byType(PhotoView));
      expect(photoView.disableGestures, isNot(true));
      expect(photoView.maxScale, isNotNull);
      expect(photoView.minScale, isNotNull);
      expect(photoView.initialScale, isNotNull);
    });

    testWidgets('renders the error state instead of a blank surface', (
      tester,
    ) async {
      await pump(
        tester,
        const PhotoViewer(imageUrl: 'https://example.com/missing.png'),
      );

      final errorBuilder = tester
          .widget<PhotoView>(find.byType(PhotoView))
          .errorBuilder;
      expect(errorBuilder, isNotNull);

      // Drive the error builder directly: a real network failure would need a
      // live HTTP client, and tests must not hit the network.
      final rendered = errorBuilder!(
        tester.element(find.byType(PhotoView)),
        Exception('boom'),
        StackTrace.empty,
      );
      await tester.pumpWidget(TestForuiApp(home: Scaffold(body: rendered)));

      expect(find.text('加载失败'), findsOneWidget);
      expect(find.text('页面数据未能加载，请重试'), findsOneWidget);
    });

    testWidgets('shows a close affordance only when onClose is provided', (
      tester,
    ) async {
      await pump(
        tester,
        const PhotoViewer(imageUrl: 'https://example.com/a.png'),
      );
      expect(find.byIcon(SemanticIcons.actionClose), findsNothing);

      await pump(
        tester,
        PhotoViewer(imageUrl: 'https://example.com/a.png', onClose: () {}),
      );
      expect(find.byIcon(SemanticIcons.actionClose), findsOneWidget);
    });
  });
}
