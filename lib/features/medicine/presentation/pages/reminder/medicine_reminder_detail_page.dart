import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/widgets/common/app_status_pill.dart';
import 'package:luminous/core/widgets/common/app_icon_badge.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/feedback/app_toast.dart';
import 'package:luminous/core/widgets/common/app_state_views.dart';
import 'package:luminous/core/design/app_breakpoints.dart';
import 'package:luminous/core/widgets/layout/responsive_content_frame.dart';
import 'package:luminous/features/auth/presentation/providers/session/auth_session_provider.dart';
import 'package:luminous/features/auth/presentation/widgets/auth_required_dialog.dart';
import 'package:luminous/features/medicine/presentation/providers/medicine_reminder_providers.dart';
import 'package:luminous/features/medicine/presentation/utils/medicine_reminder_formatters.dart';
import 'package:luminous/features/medicine/presentation/widgets/reminder/medicine_reminder_delete_dialog.dart';
import 'package:luminous/features/medicine/presentation/widgets/reminder/reminder_loading.dart';
import 'package:luminous/features/medicine/presentation/widgets/reminder/reminder_log_panels.dart';
import 'package:luminous/features/medicine/presentation/widgets/reminder/reminder_rows.dart';
import 'package:luminous/core/widgets/common/app_back_button.dart';
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
      final width = MediaQuery.sizeOf(context).width;
      final content = ResponsiveContentFrame(
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: width < AppBreakpoints.mobile ? 24 : 32,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              session.isLoading
                  ? const ReminderLoading()
                  : AuthRequiredDialogGate(
                      onLogin: () =>
                          context.push(loginRouteForCurrentLocation(context)),
                    ),
            ],
          ),
        ),
      );

      return FScaffold(
        header: SafeArea(
          bottom: false,
          child: FHeader.nested(
            title: Text(l10n.medicineReminderDetailTitle),
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

    final detail = ref.watch(medicineReminderDetailProvider(currentMedicineId));

    final width = MediaQuery.sizeOf(context).width;
    final content = ResponsiveContentFrame(
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: width < AppBreakpoints.mobile ? 24 : 32,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            detail.when(
              data: (data) => _ReminderDetailBody(data: data),
              loading: () => const ReminderLoading(),
              error: (error, _) {
                final isNotFound =
                    error is StateError &&
                    error.message == 'Medicine not found.';
                return AppStateErrorView(
                  title: isNotFound
                      ? l10n.medicineReminderNotFoundTitle
                      : l10n.medicineReminderGenericErrorTitle,
                  description: isNotFound
                      ? l10n.medicineReminderNotFoundDescription
                      : l10n.medicineReminderGenericErrorDescription,
                  icon: FLucideIcons.circleAlert,
                  actionLabel: l10n.todayRetryAction,
                  onAction: () => ref.invalidate(
                    medicineReminderDetailProvider(currentMedicineId),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );

    return FScaffold(
      header: SafeArea(
        bottom: false,
        child: FHeader.nested(
          title: Text(l10n.medicineReminderDetailTitle),
          titleAlignment: Alignment.center,
          prefixes: [const AppBackButton()],
          suffixes: [
            TextButton(
              onPressed: () => context.push(
                '/medicine/reminders/${Uri.encodeComponent(currentMedicineId)}/edit',
              ),
              child: Text(l10n.recordEditAction),
            ),
          ],
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
}

class _ReminderDetailBody extends ConsumerWidget {
  const _ReminderDetailBody({required this.data});

  final MedicineReminderDetailData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.theme.colors;
    final textTheme = Theme.of(context).textTheme;
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
      padding: const EdgeInsets.symmetric(horizontal: AppSpacingTokens.level4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FCard.raw(
            child: Row(
              children: [
                const AppIconBadge(
                  icon: FLucideIcons.pillBottle,
                  color: Color(0xFFB45309),
                  backgroundColor: Color(0xFFFEF3C7),
                  shape: BoxShape.circle,
                  size: AppSpacingTokens.level9,
                  iconSize: AppSpacingTokens.level6,
                ),
                const SizedBox(width: AppSpacingTokens.level4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.medicine.displayName,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacingTokens.level1),
                      Text(
                        medicineDoseText(l10n, data.medicine),
                        style: textTheme.bodySmall?.copyWith(
                          color: colors.mutedForeground,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacingTokens.level3),
                AppStatusPill(
                  label: isActive
                      ? l10n.medicineReminderEnabledStatus
                      : l10n.medicineReminderDisabledStatus,
                  color: isActive ? Color(0xFF0F766E) : colors.mutedForeground,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacingTokens.level4),
          FCard.raw(
            child: Column(
              children: [
                ReminderInfoRow(
                  icon: FLucideIcons.repeat2,
                  label: l10n.medicineReminderFrequencyLabel,
                  value: frequencyLabel(l10n, reminders),
                  showDivider: true,
                ),
                ReminderInfoRow(
                  icon: FLucideIcons.clock3,
                  label: l10n.medicineReminderTimesLabel,
                  value: reminders.isEmpty
                      ? l10n.medicineScheduleNotSet
                      : reminders.map((item) => item.timeLabel).join(' · '),
                  showDivider: true,
                ),
                ReminderInfoRow(
                  icon: FLucideIcons.pillBottle,
                  label: l10n.medicineReminderDoseLabel,
                  value: medicineDoseText(l10n, data.medicine),
                  showDivider: true,
                ),
                ReminderInfoRow(
                  icon: FLucideIcons.calendar,
                  label: l10n.medicineReminderStartDateLabel,
                  value:
                      firstReminder?.startDate ??
                      l10n.medicineReminderDateNotSet,
                  showDivider: true,
                ),
                ReminderInfoRow(
                  icon: FLucideIcons.calendarX2,
                  label: l10n.medicineReminderEndDateLabel,
                  value:
                      firstReminder?.endDate ?? l10n.medicineReminderDateNotSet,
                  showDivider: true,
                ),
                ReminderInfoRow(
                  icon: FLucideIcons.bell,
                  label: l10n.medicineReminderMethodLabel,
                  value: methodValue,
                  showDivider: hasNote,
                ),
                if (hasNote)
                  ReminderInfoRow(
                    icon: FLucideIcons.notebookPen,
                    label: l10n.medicineReminderNoteLabel,
                    value: data.reminders
                        .map((item) => item.note?.trim())
                        .whereType<String>()
                        .where((item) => item.isNotEmpty)
                        .first,
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacingTokens.level4),
          ReminderTodayLogPanel(logs: data.todayLogs),
          const SizedBox(height: AppSpacingTokens.level4),
          ReminderDeliveryLogPanel(logs: data.deliveryLogs),
          if (reminders.isNotEmpty) ...[
            const SizedBox(height: AppSpacingTokens.level5),
            FilledButton.icon(
              key: const Key('medicine-reminder-delete-button'),
              style: FilledButton.styleFrom(
                backgroundColor: colors.destructive,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadiusTokens.level3),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacingTokens.level4,
                ),
              ),
              onPressed: () async {
                final confirmed = await showMedicineReminderDeleteDialog(
                  context,
                );
                if (confirmed != true) return;
                final deleted = await ref
                    .read(medicineReminderFormProvider.notifier)
                    .deleteGroup(reminders);
                if (deleted && context.mounted) {
                  unawaited(
                    AppToast.show(context, l10n.medicineReminderDeletedToast),
                  );
                  context.pop();
                } else if (context.mounted) {
                  unawaited(AppToast.show(context, l10n.settingsSyncFailed));
                }
              },
              icon: const Icon(FLucideIcons.trash2),
              label: Text(l10n.medicineReminderDeleteAction),
            ),
          ],
        ],
      ),
    );
  }
}
