import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/features/auth/presentation/widgets/auth_action_row.dart';
import 'package:luminous/features/auth/presentation/widgets/auth_branding.dart';
import 'package:luminous/features/auth/presentation/widgets/auth_field_error.dart';
import 'package:luminous/features/auth/presentation/widgets/auth_status_message.dart';
import 'package:luminous/l10n/app_localizations.dart';

Widget _shell(Widget child) {
  return MaterialApp(
    theme: ThemeData.light().copyWith(
      extensions: const <ThemeExtension<dynamic>>[AppThemeSurface.light],
    ),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );
}

void main() {
  testWidgets('AuthBrandLogo renders', (tester) async {
    await tester.pumpWidget(_shell(const AuthBrandLogo()));
    expect(find.byType(AuthBrandLogo), findsOneWidget);
  });

  testWidgets('AuthBrandLogo with custom size', (tester) async {
    await tester.pumpWidget(_shell(const AuthBrandLogo(size: 80)));
    expect(find.byType(AuthBrandLogo), findsOneWidget);
  });

  testWidgets('AuthFieldError renders error text', (tester) async {
    await tester.pumpWidget(_shell(const AuthFieldError('Invalid email')));
    expect(find.text('Invalid email'), findsOneWidget);
  });

  testWidgets('AuthFieldError renders nothing for null', (tester) async {
    await tester.pumpWidget(_shell(const AuthFieldError(null)));
    expect(find.byType(AuthFieldError), findsOneWidget);
  });

  testWidgets('AuthStatusMessage renders error', (tester) async {
    await tester.pumpWidget(
      _shell(const AuthStatusMessage(error: 'Login failed')),
    );
    expect(find.text('Login failed'), findsOneWidget);
  });

  testWidgets('AuthStatusMessage renders success', (tester) async {
    await tester.pumpWidget(
      _shell(const AuthStatusMessage(success: 'Email sent')),
    );
    expect(find.text('Email sent'), findsOneWidget);
  });

  testWidgets('AuthLoginActionRow renders', (tester) async {
    await tester.pumpWidget(
      _shell(
        AuthLoginActionRow(
          registerPrompt: 'No account?',
          registerLabel: 'Sign up',
          onRegister: () {},
          forgotPasswordLabel: 'Forgot?',
          onForgotPassword: () {},
        ),
      ),
    );
    expect(find.text('No account?'), findsOneWidget);
    expect(find.text('Sign up'), findsOneWidget);
  });
}
