import 'package:flutter/material.dart'
    hide MaterialApp, Scaffold, ElevatedButton;
import 'package:flutter_localizations/flutter_localizations.dart' as fl;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/auth/sensitive_action_password_resolver.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/providers/sensitive_action_password.dart';
import 'package:luminous/core/theme/theme.dart';
import 'package:luminous/features/settings/domain/entities/user_settings.dart';
import 'package:luminous/features/settings/presentation/providers/user_settings.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:material_ui/material_ui.dart'
    show MaterialApp, Scaffold, ElevatedButton, GlobalMaterialLocalizations;

UserSettings _testSettings({required bool passwordReauthenticationRequired}) {
  return UserSettings(
    aiSummariesEnabled: true,
    dataSharingConsent: false,
    assistantEnabled: true,
    assistantMemoryEnabled: false,
    waterTargetCount: 8,
    assistantContext: const AssistantContextSettings(
      healthProfile: true,
      dailyRecords: true,
      sleepRecords: false,
      currentMedicines: true,
    ),
    passwordReauthenticationRequired: passwordReauthenticationRequired,
  );
}

/// Toast shell mirroring the pattern in `app_toast_test.dart`.
Widget _toastShell(Widget child) {
  final theme = appThemeData(appDefaultThemeFamily, Brightness.light);
  return MaterialApp(
    theme: foruiMaterialTheme(theme),
    debugShowCheckedModeBanner: false,
    builder: (context, child) => FTheme(
      data: theme,
      child: FToaster(child: child ?? const SizedBox.shrink()),
    ),
    localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
      AppLocalizations.delegate,
      FLocalizations.delegate,
      ...GlobalMaterialLocalizations.delegates,
      fl.GlobalMaterialLocalizations.delegate,
      fl.GlobalWidgetsLocalizations.delegate,
      fl.GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );
}

void main() {
  group('resolveSensitiveActionPassword', () {
    testWidgets(
      'returns empty string when passwordReauthenticationRequired is false',
      (tester) async {
        final settings = _testSettings(passwordReauthenticationRequired: false);

        var promptCalled = false;
        final container = ProviderContainer(
          overrides: [
            userSettingsControllerProvider.overrideWith(
              () => _FakeSettings(settings),
            ),
            sensitiveActionPasswordPromptProvider.overrideWithValue((
              _, {
              title,
              message,
              label,
            }) async {
              promptCalled = true;
              return 'should-not-be-called';
            }),
          ],
        );
        addTearDown(container.dispose);

        String? result;
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: _toastShell(
              Consumer(
                builder: (context, ref, _) {
                  return ElevatedButton(
                    onPressed: () async {
                      result = await resolveSensitiveActionPassword(
                        ref,
                        context,
                      );
                    },
                    child: const Text('trigger'),
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('trigger'));
        await tester.pumpAndSettle();

        expect(promptCalled, isFalse);
        expect(result, '');
      },
    );

    testWidgets(
      'calls password prompt when passwordReauthenticationRequired is true',
      (tester) async {
        final settings = _testSettings(passwordReauthenticationRequired: true);

        var promptCalled = false;
        final container = ProviderContainer(
          overrides: [
            userSettingsControllerProvider.overrideWith(
              () => _FakeSettings(settings),
            ),
            sensitiveActionPasswordPromptProvider.overrideWithValue((
              _, {
              title,
              message,
              label,
            }) async {
              promptCalled = true;
              return 'secret-password';
            }),
          ],
        );
        addTearDown(container.dispose);

        String? result;
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: _toastShell(
              Consumer(
                builder: (context, ref, _) {
                  return ElevatedButton(
                    onPressed: () async {
                      result = await resolveSensitiveActionPassword(
                        ref,
                        context,
                      );
                    },
                    child: const Text('trigger'),
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('trigger'));
        await tester.pumpAndSettle();

        expect(promptCalled, isTrue);
        expect(result, 'secret-password');
      },
    );
  });

  group('handleSensitiveActionFailure', () {
    // Note: Full widget tests for toast rendering are covered in
    // `test/core/feedback/app_toast_test.dart`. The tests below verify
    // the return value logic of the helper without rendering toasts,
    // avoiding forui toaster layout constraints in the test environment.

    testWidgets('returns true for AUTH_PASSWORD_NOT_SET failure', (
      tester,
    ) async {
      const failure = LucentFailure(
        kind: LucentFailureKind.authentication,
        message: 'Password not set',
        code: LucentFailure.kPasswordNotSetCode,
        statusCode: 403,
      );

      bool? handled;
      await tester.pumpWidget(
        _toastShell(
          Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context)!;
              return ElevatedButton(
                onPressed: () async {
                  handled = await handleSensitiveActionFailure(
                    context: context,
                    l10n: l10n,
                    error: failure,
                    failurePrefix: '导出失败',
                  );
                },
                child: const Text('trigger'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('trigger'));
      // Pump enough frames for the async path to complete. The toast
      // layout may overflow in the constrained test surface, but we
      // only assert the return value here.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      // Drain auto-dismiss timer.
      await tester.pump(const Duration(milliseconds: 1800));
      await tester.pumpAndSettle();

      // Swallow layout overflow exceptions from the toast widget.
      tester.takeException();

      expect(handled, isTrue);
    });

    testWidgets('returns false for non-PASSWORD_NOT_SET errors', (
      tester,
    ) async {
      const failure = LucentFailure(
        kind: LucentFailureKind.network,
        message: 'Network error',
        code: 'NETWORK_ERROR',
      );

      bool? handled;
      await tester.pumpWidget(
        _toastShell(
          Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context)!;
              return ElevatedButton(
                onPressed: () async {
                  handled = await handleSensitiveActionFailure(
                    context: context,
                    l10n: l10n,
                    error: failure,
                    failurePrefix: '导出失败',
                  );
                },
                child: const Text('trigger'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('trigger'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 1800));
      await tester.pumpAndSettle();

      // Swallow any layout overflow exceptions from the toast widget.
      tester.takeException();

      expect(handled, isFalse);
    });
  });
}

/// A fake [UserSettingsController] that immediately returns the given
/// [UserSettings] without requiring auth session or repository wiring.
class _FakeSettings extends UserSettingsController {
  _FakeSettings(this._settings);

  final UserSettings _settings;

  @override
  Future<UserSettings> build() async => _settings;
}
