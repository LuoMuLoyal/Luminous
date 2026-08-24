import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/dialog_shell.dart';
import 'package:luminous/core/widgets/layout/page_scaffold.dart';
import 'package:luminous/core/widgets/layout/responsive_content_frame.dart';
import 'package:luminous/features/auth/presentation/widgets/shared/required_dialog.dart';
import 'package:luminous/features/settings/presentation/utils/page_padding.dart';
import 'package:luminous/features/settings/presentation/widgets/about_section.dart';
import 'package:luminous/features/settings/presentation/widgets/account_header.dart';
import 'package:luminous/features/settings/presentation/widgets/general_section.dart';
import 'package:luminous/features/settings/presentation/widgets/master_detail.dart';
import 'package:luminous/features/settings/presentation/widgets/navigation_tile.dart';
import 'package:luminous/features/settings/presentation/widgets/privacy_section.dart';
import 'package:luminous/features/settings/presentation/widgets/quick_entry_section.dart';
import 'package:luminous/features/settings/presentation/widgets/shared/section_label.dart';
import 'package:luminous/features/settings/presentation/widgets/sign_out_tile.dart';
import 'package:luminous/l10n/app_localizations.dart';

const _kGroupSpacing = 20.0;

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final session = ref.watch(authSessionProvider);
    final signedIn = session.canAccessProtectedData;
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= Breakpoints.desktop;

    // Sign-out callback shared by both mobile and desktop layouts.
    Future<void> handleSignOut() async {
      if (!session.canAccessProtectedData) {
        context.go(loginRouteForCurrentLocation(context));
        return;
      }
      final confirmed = await showDangerConfirmationDialog(
        context: context,
        title: l10n.authSignOutConfirmTitle,
        message: l10n.authSignOutConfirmMessage,
        confirmLabel: l10n.authSignOutConfirmAction,
      );
      if (!confirmed || !context.mounted) return;
      await ref.read(authSessionProvider.notifier).logout();
      if (!context.mounted) return;
      context.go(Routes.login);
    }

    // Account security tile group — used in both mobile sections list and
    // desktop master-detail groups.
    Widget buildAccountSecurityGroup() => FTileGroup(
      physics: const NeverScrollableScrollPhysics(),
      divider: FItemDivider.full,
      children: [
        SettingsNavigationTile(
          tileKey: const Key('settings-row-account-security'),
          icon: SemanticIcons.safetySafe,
          title: l10n.mineSettingsAccountTitle,
          onTap: () => pushAuthRequiredRoute(context, Routes.account),
        ),
        SettingsNavigationTile(
          tileKey: const Key('settings-row-health-profile'),
          icon: SemanticIcons.profileCondition,
          title: l10n.settingsHealthProfileTitle,
          subtitle: l10n.settingsHealthProfileSubtitle,
          onTap: () {
            if (!signedIn) {
              unawaited(pushAuthRequiredRoute(context, Routes.settings));
              return;
            }
            context.go(Routes.mine);
          },
        ),
      ],
    );

    final accountHeader = AccountHeader(
      session: session,
      signedIn: signedIn,
      onTap: () => pushAuthRequiredRoute(context, Routes.account),
    );

    final signOutTile = SignOutTile(
      signedIn: signedIn,
      isLoading: session.isLoading,
      onTap: () => handleSignOut(),
    );

    if (isDesktop) {
      return PageScaffold(
        title: l10n.desktopSidebarSettings,
        child: SettingsMasterDetail(
          accountHeader: accountHeader,
          signOutTile: signOutTile,
          groups: [
            SettingsGroup(
              label: l10n.settingsAccountSecuritySectionTitle,
              icon: SemanticIcons.safetySafe,
              body: buildAccountSecurityGroup(),
            ),
            SettingsGroup(
              label: l10n.settingsGeneralSectionTitle,
              icon: SemanticIcons.actionSettings,
              body: const GeneralSection(),
            ),
            SettingsGroup(
              label: l10n.settingsQuickEntrySection,
              icon: SemanticIcons.safetyAllergy,
              body: const QuickEntrySection(),
            ),
            SettingsGroup(
              label: l10n.settingsPrivacySectionTitle,
              icon: SemanticIcons.statusBlocked,
              body: PrivacySection(signedIn: signedIn),
            ),
            SettingsGroup(
              label: l10n.settingsAboutSectionTitle,
              icon: SemanticIcons.statusInfo,
              body: AboutSection(signedIn: signedIn),
            ),
          ],
        ),
      );
    }

    // Mobile layout
    final sections = <Widget>[
      accountHeader,
      const SizedBox(height: _kGroupSpacing),
      // -- 账号与安全 --
      SettingsSectionLabel(label: l10n.settingsAccountSecuritySectionTitle),
      const SizedBox(height: Spacing.level3),
      buildAccountSecurityGroup(),
      const SizedBox(height: _kGroupSpacing),
      const GeneralSection(),
      const SizedBox(height: _kGroupSpacing),
      const QuickEntrySection(),
      const SizedBox(height: _kGroupSpacing),
      PrivacySection(signedIn: signedIn),
      const SizedBox(height: _kGroupSpacing),
      AboutSection(signedIn: signedIn),
      const SizedBox(height: _kGroupSpacing),
      signOutTile,
    ];

    return PageScaffold(
      title: l10n.desktopSidebarSettings,
      child: SingleChildScrollView(
        child: ResponsiveContentFrame(
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: settingsPageVerticalPadding(context),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: sections,
            ),
          ),
        ),
      ),
    );
  }
}
