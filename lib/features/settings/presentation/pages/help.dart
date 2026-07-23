import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/router/external_url_launcher.dart';
import 'package:luminous/core/widgets/common/skeleton.dart';
import 'package:luminous/core/widgets/common/state_message.dart';
import 'package:luminous/core/widgets/layout/page_scaffold.dart';
import 'package:luminous/core/widgets/layout/responsive_content_frame.dart';
import 'package:luminous/features/auth/presentation/widgets/shared/required_dialog.dart';
import 'package:luminous/features/settings/presentation/widgets/shared/subpage_tile_group_style.dart';
import 'package:luminous/features/support/data/providers/resources.dart';
import 'package:luminous/features/support/domain/entities/support_resource.dart';
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
          vertical: width < Breakpoints.mobile
              ? Spacing.level6
              : Spacing.level7,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            resourcesAsync.when(
              data: (resources) {
                final actionable = resources.where(_isActionable).toList();
                if (actionable.isEmpty) {
                  return StateMessageView(
                    title: l10n.settingsHelpEmpty,
                    icon: FLucideIcons.circleHelp,
                  );
                }
                return FTileGroup(
                  style: settingsSubpageTileGroupStyle(context.theme),
                  children: [
                    for (final resource in actionable)
                      FTile(
                        title: Text(resource.title),
                        subtitle: () {
                          final sub = resource.subtitle;
                          return sub == null || sub.isEmpty ? null : Text(sub);
                        }(),
                        suffix: const Icon(FLucideIcons.chevronRight),
                        onPress: () => _openResource(context, resource),
                      ),
                  ],
                );
              },
              loading: () => const InlineSkeleton(
                children: [
                  InlineSkeletonBlock(height: 56),
                  InlineSkeletonBlock(height: 56),
                  InlineSkeletonBlock(height: 56),
                ],
              ),
              error: (error, _) => StateMessageView(
                title: l10n.settingsHelpError,
                icon: FLucideIcons.circleAlert,
                tone: StateTone.danger,
                actionLabel: l10n.settingsHelpRetryAction,
                onAction: () =>
                    ref.invalidate(supportResourcesProvider('help')),
              ),
            ),
          ],
        ),
      ),
    );

    return PageScaffold(
      title: l10n.mineSettingHelpTitle,
      child: SingleChildScrollView(child: content),
    );
  }

  bool _isActionable(SupportResource resource) {
    return resource.available &&
        resource.actionUrl != null &&
        (resource.actionUrl?.isNotEmpty ?? false) &&
        resource.actionType != null;
  }

  Future<void> _openResource(
    BuildContext context,
    SupportResource resource,
  ) async {
    final actionUrl = resource.actionUrl;
    if (actionUrl == null || actionUrl.isEmpty) return;
    if (resource.actionType == SupportResourceAction.url ||
        resource.actionType == SupportResourceAction.phone) {
      final uri = Uri.tryParse(actionUrl);
      if (uri != null) {
        await const ExternalUrlLauncher().open(uri);
      }
    } else {
      unawaited(pushAuthRequiredRoute(context, actionUrl));
    }
  }
}
