import '../support/e2e_test_helpers.dart';
import '../support/fullstack_e2e_helpers.dart';

void main() {
  patrolTest('full-stack auth can sign in against Lucent test runtime', (
    $,
  ) async {
    final config = FullstackE2eConfig.fromEnvironment();

    await prepareFullstackRecordLane(config);
    final container = await pumpFullstackApp($, config: config);

    await signInThroughUi($, config: config);
    await waitForAuthenticatedSession($, container);

    final state = container.read(authSessionProvider);
    expect(state.isAuthenticated, isTrue);
    expect(state.user?.email, config.email);
  });
}
