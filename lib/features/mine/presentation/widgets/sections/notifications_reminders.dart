import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/utils/date_format_utils.dart';
import 'package:luminous/core/widgets/common/soft_icon.dart';
import 'package:luminous/features/auth/presentation/providers/session.dart';
import 'package:luminous/features/auth/presentation/widgets/shared/required_dialog.dart';
import 'package:luminous/features/mine/presentation/widgets/shared/shared.dart';
import 'package:luminous/features/notification/data/providers/unread_count.dart';
import 'package:luminous/features/settings/presentation/providers/notification.dart';
import 'package:luminous/l10n/app_localizations.dart';

class MineNotificationsReminderSection extends ConsumerWidget {
  const MineNotificationsReminderSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final session = ref.watch(authSessionProvider);
    final settingsAsync = ref.watch(notificationSettingsControllerProvider);
    final settings =
        settingsAsync.asData?.value ?? const NotificationSettingsState();
    final unreadCountAsync = session.canAccessProtectedData
        ? ref.watch(notificationUnreadCountProvider)
        : const AsyncData<int>(0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MineSectionTitle(title: l10n.mineNotificationReminderSectionTitle),
        const SizedBox(height: Spacing.level3),
        FTileGroup(
          key: const Key('mine-notifications-reminder-section'),
          divider: FItemDivider.full,
          children: [
            FTile(
              key: const Key('mine-notification-settings-tile'),
              prefix: const SoftIcon(
                icon: SemanticIcons.notificationBellRing,
                color: SemanticColor.primary,
              ),
              title: Text(l10n.mineReminderSectionTitle),
              subtitle: Text(
                _reminderSummary(l10n, settings),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              suffix: const Icon(SemanticIcons.actionNext),
              onPress: () => context.push(Routes.settingsNotifications),
            ),
            FTile(
              key: const Key('mine-dnd-settings-tile'),
              prefix: const SoftIcon(
                icon: SemanticIcons.recordSleep,
                color: SemanticColor.primary,
              ),
              title: Text(l10n.settingsNotificationsDndTitle),
              subtitle: Text(
                _dndSummary(l10n, settings, Localizations.localeOf(context)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              suffix: const Icon(SemanticIcons.actionNext),
              onPress: () => context.push(Routes.settingsNotificationsDnd),
            ),
            FTile(
              key: const Key('mine-notification-inbox-tile'),
              prefix: const SoftIcon(
                icon: SemanticIcons.actionMessage,
                color: SemanticColor.primary,
              ),
              title: Text(l10n.mineNotificationInboxTitle),
              subtitle: Text(
                _inboxSummary(l10n, session, unreadCountAsync),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              suffix: const Icon(SemanticIcons.actionNext),
              onPress: () =>
                  pushAuthRequiredRoute(context, Routes.notifications),
            ),
          ],
        ),
      ],
    );
  }

  String _reminderSummary(
    AppLocalizations l10n,
    NotificationSettingsState settings,
  ) {
    final enabledCount = _enabledReminderCount(settings);
    final enabledSummary = l10n.settingsNotificationsSummary(enabledCount);
    final advanceSummary = settings.reminderAdvanceMinutes <= 0
        ? l10n.settingsNotificationsAdvanceOff
        : l10n.settingsNotificationsAdvanceMinutes(
            settings.reminderAdvanceMinutes,
          );
    return '$enabledSummary · $advanceSummary';
  }

  int _enabledReminderCount(NotificationSettingsState settings) {
    var count = 0;
    if (settings.medicationReminders) count += 1;
    if (settings.waterReminders) count += 1;
    if (settings.sleepReminderEnabled) count += 1;
    return count;
  }

  String _dndSummary(
    AppLocalizations l10n,
    NotificationSettingsState settings,
    Locale locale,
  ) {
    if (!settings.dndEnabled) {
      return l10n.settingsNotificationsTimeUnset;
    }
    final start = _formatTimeOfDay(settings.dndStartTime, locale);
    final end = _formatTimeOfDay(settings.dndEndTime, locale);
    return '$start - $end';
  }

  String _inboxSummary(
    AppLocalizations l10n,
    AuthSessionState session,
    AsyncValue<int> unreadCountAsync,
  ) {
    if (!session.canAccessProtectedData) {
      return l10n.mineNotificationInboxSignedOutSummary;
    }
    return unreadCountAsync.maybeWhen(
      data: l10n.mineNotificationInboxUnreadSummary,
      orElse: () => l10n.mineNotificationInboxLoadingSummary,
    );
  }

  String _formatTimeOfDay(TimeOfDay? time, Locale locale) {
    if (time == null) return '—';
    return formatTimeOfDay(time, locale);
  }
}
