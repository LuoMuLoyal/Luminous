import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/router/login/path.dart';
import 'package:luminous/features/auth/presentation/routes.dart';

void main() {
  // Drift guard: core may not import feature code, so `loginPath` mirrors the
  // auth feature's typed `LoginRoute`. Tests may cross layers, which is what
  // keeps the two from drifting apart.
  test('loginPath mirrors LoginRoute', () {
    expect(loginPath, const LoginRoute().location);
  });
}
