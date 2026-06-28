import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/design/app_breakpoints.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/router/external_url_launcher.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/core/widgets/app_section_surface.dart';
import 'package:luminous/core/widgets/app_settings_navigation_row.dart';
import 'package:luminous/core/widgets/page_scaffold_shell.dart';
import 'package:luminous/features/auth/presentation/widgets/auth_required_dialog.dart';
import 'package:luminous/core/widgets/app_back_button.dart';
import 'package:luminous/features/support/data/providers/support_resources_providers.dart';
import 'package:lucent_openapi/lucent_openapi.dart';
import 'package:luminous/l10n/app_localizations.dart';

class HelpSettingsPage extends ConsumerWidget {
  const HelpSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final resourcesAsync = ref.watch(supportResourcesProvider('help'));

    return PageScaffoldShell(
      title: l10n.mineSettingHelpTitle,
      centerTitle: true,
      leading: const AppBackButton(),
      children: [
        resourcesAsync.when(
          data: (resources) {
            final actionable = resources.where(_isActionable).toList();
            if (actionable.isEmpty) {
              return _EmptyState(message: l10n.settingsHelpEmpty);
            }
            return AppSectionSurface(
              child: Column(
                children: [
                  for (var i = 0; i < actionable.length; i++) ...[
                    AppSettingsNavigationRow(
                      title: actionable[i].title,
                      subtitle: actionable[i].subtitle,
                      onTap: () => _openResource(context, actionable[i]),
                      showDivider: i < actionable.length - 1,
                    ),
                  ],
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _EmptyState(message: l10n.settingsHelpError),
        ),
      ],
    );
  }

  bool _isActionable(SupportResourceDto resource) {
    return resource.available &&
        resource.actionUrl != null &&
        resource.actionUrl!.isNotEmpty &&
        resource.actionType != null;
  }

  Future<void> _openResource(
    BuildContext context,
    SupportResourceDto resource,
  ) async {
    if (resource.actionType == SupportResourceActionType.url ||
        resource.actionType == SupportResourceActionType.phone) {
      final uri = Uri.tryParse(resource.actionUrl!);
      if (uri != null) {
        await const ExternalUrlLauncher().open(uri);
      }
    } else {
      pushAuthRequiredRoute(context, resource.actionUrl!);
    }
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final typography = _typography(context);

    return Padding(
      padding: const EdgeInsets.all(AppSpacingTokens.lg),
      child: Text(
        message,
        style: typography.bodyMd.copyWith(color: surface.mute),
        textAlign: TextAlign.center,
      ),
    );
  }

  AppTypographyScale _typography(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.sizeOf(context).width;
    return width < AppBreakpoints.mobile
        ? AppTypographyTokens.mobile(theme.colorScheme.onSurface)
        : AppTypographyTokens.desktop(theme.colorScheme.onSurface);
  }
}
