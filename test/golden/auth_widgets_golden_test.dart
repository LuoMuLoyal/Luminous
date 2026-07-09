import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/design/design.dart';
import '../helpers/test_forui_app.dart';

/// Golden tests for auth-related widgets.
///
/// Run `flutter test --update-goldens test/golden/` to generate or
/// update baseline images. Golden files are stored in
/// `test/golden/goldens/`.
void main() {
  group('Auth widgets golden', () {
    goldenTest(
      'AuthShell renders correctly in light and dark themes',
      fileName: 'auth_shell',
      builder: () => GoldenTestGroup(
        columns: 2,
        children: [
          GoldenTestScenario(
            name: 'light',
            child: const _AuthShellPreview(themeMode: ThemeMode.light),
          ),
          GoldenTestScenario(
            name: 'dark',
            child: const _AuthShellPreview(themeMode: ThemeMode.dark),
          ),
        ],
      ),
    );

    goldenTest(
      'FButton variants',
      fileName: 'fbutton_variants',
      builder: () => GoldenTestGroup(
        columns: 2,
        children: [
          GoldenTestScenario(
            name: 'primary',
            child: const _ButtonPreview(
              variant: FButtonVariant.primary,
              label: 'Sign in',
            ),
          ),
          GoldenTestScenario(
            name: 'secondary',
            child: const _ButtonPreview(
              variant: FButtonVariant.secondary,
              label: 'Register',
            ),
          ),
          GoldenTestScenario(
            name: 'destructive',
            child: const _ButtonPreview(
              variant: FButtonVariant.destructive,
              label: 'Delete',
            ),
          ),
          GoldenTestScenario(
            name: 'outline',
            child: const _ButtonPreview(
              variant: FButtonVariant.outline,
              label: 'Cancel',
            ),
          ),
        ],
      ),
    );

    goldenTest(
      'FTextField states',
      fileName: 'ftextfield_states',
      builder: () => GoldenTestGroup(
        columns: 2,
        children: [
          GoldenTestScenario(
            name: 'email',
            child: const _TextFieldPreview(
              label: 'Email',
              hint: 'name@example.com',
            ),
          ),
          GoldenTestScenario(
            name: 'password',
            child: const _TextFieldPreview(
              label: 'Password',
              hint: '••••••••',
              password: true,
            ),
          ),
        ],
      ),
    );
  });
}

// ── Preview Widgets ───────────────────────────────────────────

/// Fixed size for golden test previews.
const _previewSize = Size(400, 600);
const _buttonPreviewSize = Size(200, 80);
const _textFieldPreviewSize = Size(320, 100);

class _AuthShellPreview extends StatelessWidget {
  const _AuthShellPreview({required this.themeMode});

  final ThemeMode themeMode;

  @override
  Widget build(BuildContext context) {
    return TestForuiApp(
      themeMode: themeMode,
      home: SizedBox.fromSize(
        size: _previewSize,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(Spacing.level6),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Welcome back',
                      textAlign: TextAlign.center,
                      style: context.theme.typography.body.xl.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: Spacing.level2),
                    Text(
                      'Sign in to continue',
                      textAlign: TextAlign.center,
                      style: context.theme.typography.body.sm.copyWith(
                        color: context.theme.colors.mutedForeground,
                      ),
                    ),
                    const SizedBox(height: Spacing.level6),
                    FCard.raw(
                      child: Padding(
                        padding: const EdgeInsets.all(Spacing.level6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const FTextField(
                              label: Text('Email'),
                              hint: 'name@example.com',
                            ),
                            const SizedBox(height: Spacing.level4),
                            FTextField.password(label: const Text('Password')),
                            const SizedBox(height: Spacing.level4),
                            FButton(
                              onPress: () {},
                              child: const Text('Sign in'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ButtonPreview extends StatelessWidget {
  const _ButtonPreview({required this.variant, required this.label});

  final FButtonVariant variant;
  final String label;

  @override
  Widget build(BuildContext context) {
    return TestForuiApp(
      home: SizedBox.fromSize(
        size: _buttonPreviewSize,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(Spacing.level4),
            child: FButton(
              variant: variant,
              onPress: () {},
              child: Text(label),
            ),
          ),
        ),
      ),
    );
  }
}

class _TextFieldPreview extends StatelessWidget {
  const _TextFieldPreview({
    required this.label,
    required this.hint,
    this.password = false,
  });

  final String label;
  final String hint;
  final bool password;

  @override
  Widget build(BuildContext context) {
    return TestForuiApp(
      home: SizedBox.fromSize(
        size: _textFieldPreviewSize,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(Spacing.level4),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 300),
              child: password
                  ? FTextField.password(label: Text(label), hint: hint)
                  : FTextField(label: Text(label), hint: hint),
            ),
          ),
        ),
      ),
    );
  }
}
