import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/semantic_color.dart';
import 'package:luminous/features/mine/domain/entities/dashboard.dart';
import 'package:luminous/features/mine/presentation/widgets/sections/status_overview.dart';
import 'package:luminous/l10n/app_localizations.dart';

import '../../helpers/test_forui_app.dart';

MineDashboard _buildDashboard({List<MineStatusCard>? alerts}) {
  return MineDashboard(
    account: const MineAccount(
      isAuthenticated: true,
      displayNameKey: MineCopyKey.accountDisplayName,
      email: 'test@example.com',
      statusKey: MineCopyKey.accountSignedIn,
      roleKey: MineCopyKey.accountStudentRole,
    ),
    completion: const MineCompletion(
      progress: 0.5,
      percentLabel: '50%',
      titleKey: MineCopyKey.completionTitle,
    ),
    profile: const MineProfileSnapshot(
      age: 30,
      heightCm: 170.0,
      allergyCount: 1,
      conditionCount: 0,
      currentMedicineCount: 2,
      basicInfoCompleted: true,
    ),
    alerts:
        alerts ??
        [
          const MineStatusCard(
            icon: FLucideIcons.alertTriangle,
            accent: SemanticColor.warning,
            titleKey: MineCopyKey.alertAllergyTitle,
            subtitleKey: MineCopyKey.alertAllergySubtitle,
            badgeKey: MineCopyKey.alertAllergyBadge,
          ),
          const MineStatusCard(
            icon: FLucideIcons.pill,
            accent: SemanticColor.primary,
            titleKey: MineCopyKey.alertMedicineTitle,
            subtitleKey: MineCopyKey.alertMedicineSubtitle,
            badgeKey: MineCopyKey.alertMedicineBadge,
          ),
          const MineStatusCard(
            icon: FLucideIcons.shield,
            accent: SemanticColor.success,
            titleKey: MineCopyKey.alertPrivacyTitle,
            subtitleKey: MineCopyKey.alertPrivacySubtitle,
            badgeKey: MineCopyKey.alertPrivacyBadge,
          ),
        ],
    archiveEntries: [],
    privacyNotice: const MinePrivacyNotice(
      icon: FLucideIcons.shield,
      titleKey: MineCopyKey.privacyNoticeTitle,
      actionKey: MineCopyKey.privacyNoticeAction,
    ),
  );
}

void main() {
  testWidgets('renders card with key mine-status-overview', (tester) async {
    await tester.pumpWidget(
      TestForuiApp(
        home: Scaffold(body: MineStatusOverview(dashboard: _buildDashboard())),
      ),
    );

    expect(find.byKey(const Key('mine-status-overview')), findsOneWidget);
  });

  testWidgets('renders all alert titles', (tester) async {
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

    await tester.pumpWidget(
      TestForuiApp(
        home: Scaffold(body: MineStatusOverview(dashboard: _buildDashboard())),
      ),
    );

    expect(find.text(l10n.mineAlertAllergyTitle), findsOneWidget);
    expect(find.text(l10n.mineAlertMedicineTitle), findsOneWidget);
    expect(find.text(l10n.mineAlertPrivacyTitle), findsOneWidget);
  });

  testWidgets('renders alert subtitles', (tester) async {
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

    await tester.pumpWidget(
      TestForuiApp(
        home: Scaffold(body: MineStatusOverview(dashboard: _buildDashboard())),
      ),
    );

    expect(find.text(l10n.mineAlertAllergySubtitle), findsOneWidget);
    expect(find.text(l10n.mineAlertMedicineSubtitle), findsOneWidget);
    expect(find.text(l10n.mineAlertPrivacySubtitle), findsOneWidget);
  });

  testWidgets('renders alert badges', (tester) async {
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

    await tester.pumpWidget(
      TestForuiApp(
        home: Scaffold(body: MineStatusOverview(dashboard: _buildDashboard())),
      ),
    );

    expect(find.text(l10n.mineAlertAllergyBadge), findsOneWidget);
    expect(find.text(l10n.mineAlertMedicineBadge), findsOneWidget);
    expect(find.text(l10n.mineAlertPrivacyBadge), findsOneWidget);
  });

  testWidgets('renders with two alerts and divider', (tester) async {
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

    await tester.pumpWidget(
      TestForuiApp(
        home: Scaffold(
          body: MineStatusOverview(
            dashboard: _buildDashboard(
              alerts: [
                const MineStatusCard(
                  icon: FLucideIcons.alertTriangle,
                  accent: SemanticColor.warning,
                  titleKey: MineCopyKey.alertAllergyTitle,
                  subtitleKey: MineCopyKey.alertAllergySubtitle,
                  badgeKey: MineCopyKey.alertAllergyBadge,
                ),
                const MineStatusCard(
                  icon: FLucideIcons.pill,
                  accent: SemanticColor.primary,
                  titleKey: MineCopyKey.alertMedicineTitle,
                  subtitleKey: MineCopyKey.alertMedicineSubtitle,
                  badgeKey: MineCopyKey.alertMedicineBadge,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.text(l10n.mineAlertAllergyTitle), findsOneWidget);
    expect(find.text(l10n.mineAlertMedicineTitle), findsOneWidget);
  });

  testWidgets('renders with single alert', (tester) async {
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

    await tester.pumpWidget(
      TestForuiApp(
        home: Scaffold(
          body: MineStatusOverview(
            dashboard: _buildDashboard(
              alerts: [
                const MineStatusCard(
                  icon: FLucideIcons.shield,
                  accent: SemanticColor.success,
                  titleKey: MineCopyKey.alertPrivacyTitle,
                  subtitleKey: MineCopyKey.alertPrivacySubtitle,
                  badgeKey: MineCopyKey.alertPrivacyBadge,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.text(l10n.mineAlertPrivacyTitle), findsOneWidget);
    expect(find.byType(MineStatusOverview), findsOneWidget);
  });

  testWidgets('renders with empty alerts list', (tester) async {
    await tester.pumpWidget(
      TestForuiApp(
        home: Scaffold(
          body: MineStatusOverview(dashboard: _buildDashboard(alerts: [])),
        ),
      ),
    );

    expect(find.byKey(const Key('mine-status-overview')), findsOneWidget);
  });
}
