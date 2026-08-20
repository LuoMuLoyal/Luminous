import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/network/client_providers.dart';
import 'package:luminous/core/network/security_elevation_token_holder.dart';
import 'package:luminous/core/providers/security_elevation.dart';
import 'package:luminous/core/widgets/common/security_elevation_dialog.dart';
import 'package:luminous/features/settings/domain/entities/user_settings.dart';
import 'package:luminous/features/settings/presentation/providers/user_settings.dart';
import 'package:luminous/l10n/app_localizations.dart';

import '../../helpers/test_forui_app.dart';

void main() {
  testWidgets(
    'expired verified state clears elevation and opens PIN dialog again',
    (tester) async {
      final holder = SecurityElevationTokenHolder();
      final expiresAt = DateTime.now().subtract(const Duration(minutes: 1));
      holder.set('expired-elevation-token', expiresAt);
      final container = ProviderContainer(
        overrides: [
          securityElevationTokenHolderProvider.overrideWithValue(holder),
          securityElevationControllerProvider.overrideWith(
            _ExpiredSecurityElevationController.new,
          ),
          userSettingsControllerProvider.overrideWith(
            _EnabledSecurityPinSettingsController.new,
          ),
        ],
      );
      addTearDown(container.dispose);
      await container.read(userSettingsControllerProvider.future);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: TestForuiApp(
            home: Consumer(
              builder: (context, ref, _) => FButton(
                onPress: () async {
                  await showSecurityElevationDialog(context, ref);
                },
                child: const Text('verify'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('verify'));
      await tester.pumpAndSettle();

      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      expect(find.text(l10n.securityElevationDialogTitle), findsOneWidget);
      expect(
        container.read(securityElevationControllerProvider),
        isA<SecurityElevationUnverified>(),
      );
      expect(holder.token, isNull);
    },
  );
}

class _ExpiredSecurityElevationController extends SecurityElevationController {
  @override
  SecurityElevationState build() {
    return SecurityElevationVerified(
      expiresAt: DateTime.now().subtract(const Duration(minutes: 1)),
    );
  }
}

class _EnabledSecurityPinSettingsController extends UserSettingsController {
  @override
  Future<UserSettings> build() async {
    return const UserSettings(
      aiSummariesEnabled: false,
      dataSharingConsent: false,
      assistantEnabled: false,
      assistantMemoryEnabled: false,
      waterTargetCount: 8,
      assistantContext: AssistantContextSettings(
        healthProfile: false,
        dailyRecords: false,
        sleepRecords: false,
        currentMedicines: false,
      ),
      securityPin: SecurityPinSettings(enabled: true),
    );
  }
}
