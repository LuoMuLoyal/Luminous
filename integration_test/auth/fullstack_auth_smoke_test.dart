import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:luminous/features/auth/presentation/providers/auth_session_provider.dart';

import '../support/fullstack_e2e_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('full-stack auth can sign in against Lucent test runtime', (
    tester,
  ) async {
    final config = FullstackE2eConfig.fromEnvironment();

    await prepareFullstackRecordLane(config);
    final container = await pumpFullstackApp(tester, config: config);

    await signInThroughUi(tester, config: config);
    await waitForAuthenticatedSession(tester, container);

    final state = container.read(authSessionProvider);
    expect(state.isAuthenticated, isTrue);
    expect(state.user?.email, config.email);
  });
}
