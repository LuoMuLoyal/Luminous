import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/mine/domain/entities/dashboard.dart';

void main() {
  group('MineDashboard.signedOut', () {
    test('creates a dashboard with unauthenticated account', () {
      final dashboard = MineDashboard.signedOut();

      expect(dashboard.account.isAuthenticated, isFalse);
      expect(
        dashboard.account.displayNameKey,
        MineCopyKey.accountGuestDisplayName,
      );
      expect(dashboard.account.email, '');
      expect(dashboard.account.statusKey, MineCopyKey.accountSignedOut);
      expect(dashboard.account.roleKey, MineCopyKey.accountStudentRole);
    });

    test('creates a dashboard with zero completion', () {
      final dashboard = MineDashboard.signedOut();

      expect(dashboard.completion.progress, 0);
      expect(dashboard.completion.percentLabel, '0%');
      expect(dashboard.completion.titleKey, MineCopyKey.completionTitle);
    });

    test('creates a dashboard with empty profile snapshot', () {
      final dashboard = MineDashboard.signedOut();

      expect(dashboard.profile.age, isNull);
      expect(dashboard.profile.heightCm, isNull);
      expect(dashboard.profile.weightKg, isNull);
      expect(dashboard.profile.unitSystem, isNull);
      expect(dashboard.profile.allergyCount, 0);
      expect(dashboard.profile.conditionCount, 0);
      expect(dashboard.profile.currentMedicineCount, 0);
      expect(dashboard.profile.basicInfoCompleted, isFalse);
    });

    test('creates a dashboard with no alerts', () {
      final dashboard = MineDashboard.signedOut();

      expect(dashboard.alerts, isEmpty);
    });

    test('creates a dashboard with no archive entries', () {
      final dashboard = MineDashboard.signedOut();

      expect(dashboard.archiveEntries, isEmpty);
    });

    test('creates a dashboard with privacy notice', () {
      final dashboard = MineDashboard.signedOut();

      expect(dashboard.privacyNotice.icon, SemanticIcons.safetyNeutral);
      expect(dashboard.privacyNotice.titleKey, MineCopyKey.privacyNoticeTitle);
      expect(
        dashboard.privacyNotice.actionKey,
        MineCopyKey.privacyNoticeAction,
      );
    });
  });

  group('MineAccount', () {
    test('default values for optional fields', () {
      const account = MineAccount(
        isAuthenticated: true,
        displayNameKey: MineCopyKey.accountDisplayName,
        email: 'test@example.com',
        statusKey: MineCopyKey.accountSignedIn,
        roleKey: MineCopyKey.accountStudentRole,
      );

      expect(account.emailVerified, isFalse);
      expect(account.hasPassword, isFalse);
      expect(account.linkedIdentityCount, 0);
      expect(account.lastLoginAt, isNull);
      expect(account.displayName, isNull);
    });
  });

  group('MineCopyKey enum', () {
    test('has all expected values', () {
      expect(MineCopyKey.values, contains(MineCopyKey.accountGuestDisplayName));
      expect(MineCopyKey.values, contains(MineCopyKey.completionTitle));
      expect(MineCopyKey.values, contains(MineCopyKey.privacyNoticeTitle));
      expect(MineCopyKey.values, contains(MineCopyKey.archiveEmergencyTitle));
    });
  });
}
