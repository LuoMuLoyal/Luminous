import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/auth/presentation/widgets/auth_branding.dart';

import '../helpers/test_forui_app.dart';

void main() {
  testWidgets('AuthBrandLogo renders', (tester) async {
    await tester.pumpWidget(TestForuiApp(home: const AuthBrandLogo()));
    expect(find.byType(AuthBrandLogo), findsOneWidget);
  });

  testWidgets('AuthBrandLogo with custom size', (tester) async {
    await tester.pumpWidget(
      const TestForuiApp(home: AuthBrandLogo(size: 80)),
    );
    expect(find.byType(AuthBrandLogo), findsOneWidget);
  });
}
