import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/widgets/app_section_surface.dart';
import 'package:luminous/core/widgets/app_status_pill.dart';
import 'package:luminous/core/widgets/app_icon_badge.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/feedback/app_toast.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/core/widgets/app_state_views.dart';
import 'package:luminous/core/widgets/page_scaffold_shell.dart';
import 'package:luminous/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:luminous/features/auth/presentation/widgets/auth_required_dialog.dart';
import 'package:luminous/features/medicine/presentation/providers/medicine_reminder_providers.dart';
import 'package:luminous/features/medicine/presentation/utils/medicine_reminder_formatters.dart';
import 'package:luminous/features/medicine/presentation/widgets/reminder/medicine_reminder_delete_dialog.dart';
import 'package:luminous/features/medicine/presentation/widgets/reminder/reminder_loading.dart';
import 'package:luminous/features/medicine/presentation/widgets/reminder/reminder_log_panels.dart';
import 'package:luminous/features/medicine/presentation/widgets/reminder/reminder_rows.dart';
import 'package:luminous/features/settings/presentation/widgets/settings_components.dart';
import 'package:luminous/l10n/app_localizations.dart';

class MedicineReminderDetailPage extends ConsumerWidget {
  const MedicineReminderDetailPage({
    super.key,
    required this.currentMedicineId,
  });

  final String currentMedicineId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final session = ref.watch(authSessionProvider);

    if (!session.canAccessProtectedData) {
      return PageScaffoldShell(
        title: l10n.medicineReminderDetailTitle,
        centerTitle: true,
        leading: const SettingsBackButton(),
        children: [
          session.isLoading
              ? const ReminderLoading()
              : AuthRequiredDialogGate(
                  onLogin: () =>
                      context.push(loginRouteForCurrentLocation(context)),
                ),
        ],
      );
    }

    final detail = ref.watch(medicineReminderDetailProvider(currentMedicineId));

    return PageScaffoldShell(
      title: l10n.medicineReminderDetailTitle,
      centerTitle: true,
      leading: const SettingsBackButton(),
      actions: [
        TextButton(
          onPressed: () => context.push(
            '/medicine/reminders/${Uri.encodeComponent(currentMedicineId)}/edit',
          ),
          child: Text(l10n.recordEditAction),
        ),
      ],
      children: [
        detail.when(
          data: (data) => _ReminderDetailBody(data: data),
          loading: () => const ReminderLoading(),
          error: (error, _) {
            final isNotFound =
                error is StateError && error.message == 'Medicine not found.';
            return AppStateErrorView(
              title: isNotFound
                  ? l10n.medicineReminderNotFoundTitle
                  : l10n.medicineReminderGenericErrorTitle,
              description: isNotFound
                  ? l10n.medicineReminderNotFoundDescription
                  : l10n.medicineReminderGenericErrorDescription,
              icon: Icons.error_outline_rounded,
              actionLabel: l10n.todayRetryAction,
              onAction: () => ref.invalidate(
                medicineReminderDetailProvider(currentMedicineId),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _ReminderDetailBody extends ConsumerWidget {
  const _ReminderDetailBody({required this.data});

  final MedicineReminderDetailData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final typography = AppTypographyTokens.mobile(theme.colorScheme.onSurface);
    final reminders = [...data.reminders]..sort(compareReminderTime);
    final isActive = reminders.any((item) => item.isActive);
    final firstReminder = reminders.firstOrNull;
    final soundPreference =
        ref.watch(medicineReminderSoundProvider).asData?.value ??
        MedicineReminderSoundPreference.defaultTone;
    final methodValue =
        '${isActive ? l10n.medicineReminderNotificationOn : l10n.medicineReminderNotificationOff} · ${l10n.medicineReminderSmsOff} · ${soundPreferenceLabel(l10n, soundPreference)}';
    final hasNote = data.reminders.any(
      (item) => (item.note ?? '').trim().isNotEmpty,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacingTokens.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSectionSurface(
            color: Color.alphaBlend(
              surface.tealSoft.withValues(alpha: 0.38),
              surface.canvas,
            ),
            borderColor: surface.teal.withValues(alpha: 0.14),
            shadow: const <BoxShadow>[],
            child: Row(
              children: [
                AppIconBadge(
                  icon: Icons.medication_rounded,
                  color: surface.warningDeep,
                  backgroundColor: AppColorTokens.warningSoft,
                  shape: BoxShape.circle,
                  size: AppSpacingTokens.x4l,
                  iconSize: AppSpacingTokens.xl,
                ),
                const SizedBox(width: AppSpacingTokens.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.medicine.displayName,
                        style: typography.bodyLg.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacingTokens.xxs),
                      Text(
                        medicineDoseText(l10n, data.medicine),
                        style: typography.bodySm.copyWith(
                          color: surface.body,
                          letterSpacing: 0,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacingTokens.sm),
                AppStatusPill(
                  label: isActive
                      ? l10n.medicineReminderEnabledStatus
                      : l10n.medicineReminderDisabledStatus,
                  color: isActive ? surface.teal : surface.mute,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacingTokens.md),
          AppSectionSurface(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ReminderInfoRow(
                  icon: Icons.repeat_rounded,
                  label: l10n.medicineReminderFrequencyLabel,
                  value: frequencyLabel(l10n, reminders),
                  typography: typography,
                  surface: surface,
                  showDivider: true,
                ),
                ReminderInfoRow(
                  icon: Icons.schedule_rounded,
                  label: l10n.medicineReminderTimesLabel,
                  value: reminders.isEmpty
                      ? l10n.medicineScheduleNotSet
                      : reminders.map((item) => item.timeLabel).join(' · '),
                  typography: typography,
                  surface: surface,
                  showDivider: true,
                ),
                ReminderInfoRow(
                  icon: Icons.medication_liquid_outlined,
                  label: l10n.medicineReminderDoseLabel,
                  value: medicineDoseText(l10n, data.medicine),
                  typography: typography,
                  surface: surface,
                  showDivider: true,
                ),
                ReminderInfoRow(
                  icon: Icons.calendar_today_rounded,
                  label: l10n.medicineReminderStartDateLabel,
                  value:
                      firstReminder?.startDate ??
                      l10n.medicineReminderDateNotSet,
                  typography: typography,
                  surface: surface,
                  showDivider: true,
                ),
                ReminderInfoRow(
                  icon: Icons.event_busy_rounded,
                  label: l10n.medicineReminderEndDateLabel,
                  value:
                      firstReminder?.endDate ?? l10n.medicineReminderDateNotSet,
                  typography: typography,
                  surface: surface,
                  showDivider: true,
                ),
                ReminderInfoRow(
                  icon: Icons.notifications_none_rounded,
                  label: l10n.medicineReminderMethodLabel,
                  value: methodValue,
                  typography: typography,
                  surface: surface,
                  showDivider: hasNote,
                ),
                if (hasNote)
                  ReminderInfoRow(
                    icon: Icons.notes_rounded,
                    label: l10n.medicineReminderNoteLabel,
                    value: data.reminders
                        .map((item) => item.note?.trim())
                        .whereType<String>()
                        .where((item) => item.isNotEmpty)
                        .first,
                    typography: typography,
                    surface: surface,
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacingTokens.md),
          ReminderTodayLogPanel(
            logs: data.todayLogs,
            typography: typography,
            surface: surface,
          ),
          const SizedBox(height: AppSpacingTokens.md),
          ReminderDeliveryLogPanel(
            logs: data.deliveryLogs,
            typography: typography,
            surface: surface,
          ),
          const SizedBox(height: AppSpacingTokens.lg),
          FilledButton.icon(
            key: const Key('medicine-reminder-delete-button'),
            style: FilledButton.styleFrom(
              backgroundColor: surface.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadiusTokens.md),
              ),
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacingTokens.md,
              ),
            ),
            onPressed: reminders.isEmpty
                ? null
                : () async {
                    final confirmed = await showMedicineReminderDeleteDialog(
                      context,
                    );
                    if (confirmed != true) return;
                    final deleted = await ref
                        .read(medicineReminderFormProvider.notifier)
                        .deleteGroup(reminders);
                    if (deleted && context.mounted) {
                      AppToast.show(context, l10n.medicineReminderDeletedToast);
                      context.pop();
                    } else if (context.mounted) {
                      AppToast.show(context, l10n.settingsSyncFailed);
                    }
                  },
            icon: const Icon(Icons.delete_outline_rounded),
            label: Text(l10n.medicineReminderDeleteAction),
          ),
        ],
      ),
    );
  }
}
