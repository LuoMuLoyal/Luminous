import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/app_spacing_tokens.dart';
import 'package:luminous/core/router/external_url_launcher.dart';
import 'package:luminous/core/widgets/common/app_state_views.dart';
import 'package:luminous/core/design/app_breakpoints.dart';
import 'package:luminous/core/widgets/layout/responsive_content_frame.dart';
import 'package:luminous/features/auth/presentation/widgets/auth_required_dialog.dart';
import 'package:luminous/core/widgets/common/app_back_button.dart';
import 'package:luminous/features/support/data/providers/support_resources_providers.dart';
import 'package:luminous/features/settings/presentation/widgets/settings_subpage_tile_group_style.dart';
import 'package:lucent_openapi/lucent_openapi.dart';
import 'package:luminous/l10n/app_localizations.dart';

class HelpSettingsPage extends ConsumerWidget {
  const HelpSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final resourcesAsync = ref.watch(supportResourcesProvider('help'));

    final width = MediaQuery.sizeOf(context).width;
    final content = ResponsiveContentFrame(
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: width < AppBreakpoints.mobile ? 24 : 32,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            resourcesAsync.when(
              data: (resources) {
                final actionable = resources.where(_isActionable).toList();
                if (actionable.isEmpty) {
                  return _EmptyState(message: l10n.settingsHelpEmpty);
                }
                return FTileGroup(
                  style: settingsSubpageTileGroupStyle(context.theme),
                  children: [
                    for (final resource in actionable)
                      FTile(
                        title: Text(resource.title),
                        subtitle:
                            resource.subtitle == null ||
                                resource.subtitle!.isEmpty
                            ? null
                            : Text(resource.subtitle!),
                        suffix: const Icon(FLucideIcons.chevronRight),
                        onPress: () => _openResource(context, resource),
                      ),
                  ],
                );
              },
              loading: () => const AppInlineSkeleton(
                children: [
                  AppInlineSkeletonBlock(height: 56),
                  AppInlineSkeletonBlock(height: 56),
                  AppInlineSkeletonBlock(height: 56),
                ],
              ),
              error: (error, _) => _EmptyState(message: l10n.settingsHelpError),
            ),
          ],
        ),
      ),
    );

    return FScaffold(
      header: SafeArea(
        bottom: false,
        child: FHeader.nested(
          title: Text(l10n.mineSettingHelpTitle),
          titleAlignment: Alignment.center,
          prefixes: [const AppBackButton()],
        ),
      ),
      child: SafeArea(
        top: false,
        child: Material(
          color: Colors.transparent,
          child: SingleChildScrollView(child: content),
        ),
      ),
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
      unawaited(pushAuthRequiredRoute(context, resource.actionUrl!));
    }
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(AppSpacingTokens.level5),
      child: Text(
        message,
        style: textTheme.bodyMedium?.copyWith(color: colors.mutedForeground),
        textAlign: TextAlign.center,
      ),
    );
  }
}
