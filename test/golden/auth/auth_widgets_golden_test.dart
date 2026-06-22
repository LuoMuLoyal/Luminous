import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/theme/app_theme.dart';
import 'package:luminous/features/auth/presentation/widgets/auth_shell.dart';

void main() {
  group('AuthTextField golden', () {
    testWidgets('default state', (tester) async {
      await tester.pumpWidget(_wrap(AuthTextField(
        controller: TextEditingController(),
        label: 'Email',
      )));
      await expectLater(
        find.byType(AuthTextField),
        matchesGoldenFile('golden/auth/auth_textfield_default.png'),
      );
    });

    testWidgets('with text', (tester) async {
      final controller = TextEditingController(text: 'user@example.com');
      await tester.pumpWidget(_wrap(AuthTextField(
        controller: controller,
        label: 'Email',
      )));
      await expectLater(
        find.byType(AuthTextField),
        matchesGoldenFile('golden/auth/auth_textfield_with_text.png'),
      );
    });

    testWidgets('obscured password', (tester) async {
      await tester.pumpWidget(_wrap(AuthTextField(
        controller: TextEditingController(text: 'secret'),
        label: 'Password',
        obscureText: true,
      )));
      await expectLater(
        find.byType(AuthTextField),
        matchesGoldenFile('golden/auth/auth_textfield_obscured.png'),
      );
    });
  });

  group('AuthPrimaryButton golden', () {
    testWidgets('enabled', (tester) async {
      await tester.pumpWidget(_wrap(AuthPrimaryButton(
        label: 'Sign in',
        onPressed: () {},
      )));
      await expectLater(
        find.byType(AuthPrimaryButton),
        matchesGoldenFile('golden/auth/auth_primary_button_enabled.png'),
      );
    });

    testWidgets('disabled', (tester) async {
      await tester.pumpWidget(_wrap(const AuthPrimaryButton(
        label: 'Sign in',
        onPressed: null,
      )));
      await expectLater(
        find.byType(AuthPrimaryButton),
        matchesGoldenFile('golden/auth/auth_primary_button_disabled.png'),
      );
    });
  });

  group('AuthSectionCard golden', () {
    testWidgets('renders with child', (tester) async {
      await tester.pumpWidget(_wrap(const AuthSectionCard(
        child: Text('Card content'),
      )));
      await expectLater(
        find.byType(AuthSectionCard),
        matchesGoldenFile('golden/auth/auth_section_card.png'),
      );
    });
  });

  group('AuthStatusMessage golden', () {
    testWidgets('error message', (tester) async {
      await tester.pumpWidget(_wrap(const AuthStatusMessage(
        error: 'Invalid credentials',
      )));
      await expectLater(
        find.byType(AuthStatusMessage),
        matchesGoldenFile('golden/auth/auth_status_error.png'),
      );
    });

    testWidgets('success message', (tester) async {
      await tester.pumpWidget(_wrap(const AuthStatusMessage(
        success: 'Code sent',
      )));
      await expectLater(
        find.byType(AuthStatusMessage),
        matchesGoldenFile('golden/auth/auth_status_success.png'),
      );
    });
  });
}

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(body: Center(child: Padding(
      padding: const EdgeInsets.all(24),
      child: child,
    ))),
  );
}
