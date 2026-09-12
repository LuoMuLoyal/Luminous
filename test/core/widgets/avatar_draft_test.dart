import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/widgets/common/avatar/avatar_draft.dart';

import '../../helpers/test_forui_app.dart';

void main() {
  test('AvatarDraft keeps bytes and upload metadata together', () {
    final bytes = Uint8List.fromList(const [1, 2, 3]);
    final draft = AvatarDraft(
      bytes: bytes,
      fileName: 'avatar.png',
      contentType: 'image/png',
    );

    expect(draft.bytes, same(bytes));
    expect(draft.fileName, 'avatar.png');
    expect(draft.contentType, 'image/png');
  });

  testWidgets('AvatarCropper renders a fixed-square crop surface', (
    tester,
  ) async {
    final bytes = Uint8List.fromList(<int>[
      0x89,
      0x50,
      0x4e,
      0x47,
      0x0d,
      0x0a,
      0x1a,
      0x0a,
    ]);

    await tester.pumpWidget(TestForuiApp(home: AvatarCropper(bytes: bytes)));
    await tester.pump();

    expect(find.text('裁剪头像'), findsOneWidget);
  });
}
