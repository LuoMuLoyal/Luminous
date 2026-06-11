import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/constants/app_breakpoints.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/core/widgets/app_state_views.dart';
import 'package:luminous/core/widgets/page_scaffold_shell.dart';
import 'package:luminous/features/auth/presentation/widgets/auth_required_dialog.dart';
import 'package:luminous/features/record/data/repositories/mock_record_repository.dart';
import 'package:luminous/features/record/domain/entities/record_dashboard.dart';
import 'package:luminous/features/record/domain/entities/record_type_mapping.dart';
import 'package:luminous/features/record/presentation/providers/record_dashboard_provider.dart';
import 'package:luminous/features/record/presentation/widgets/record_copy.dart';
import 'package:luminous/features/record/presentation/widgets/record_components.dart';
import 'package:luminous/features/record/presentation/widgets/record_dashboard_view.dart';
import 'package:luminous/l10n/app_localizations.dart';

class RecordPage extends ConsumerWidget {
  const RecordPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(recordDashboardProvider);
    final selectedDate = ref.watch(selectedRecordDateProvider);
    final selectedFilter = ref.watch(selectedRecordFilterProvider);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final width = MediaQuery.sizeOf(context).width;
    final isCompact = width < AppBreakpoints.mobile;
    final isMobileLayout = width < AppBreakpoints.desktop;
    final typography = isCompact
        ? AppTypographyTokens.mobile(theme.colorScheme.onSurface)
        : AppTypographyTokens.desktop(theme.colorScheme.onSurface);

    return PageScaffoldShell(
      title: l10n.tabRecord,
      actions: isMobileLayout
          ? [
              RecordHeaderActionChip(
                key: const Key('record-add-action'),
                label: isCompact
                    ? l10n.recordAddCompactAction
                    : l10n.recordAddAction,
                icon: Icons.add_rounded,
                emphasized: true,
                typography: typography,
                surface: surface,
                onTap: () => pushAuthRequiredRoute(
                  context,
                  '/record/create?date=${_formatDate(selectedDate)}',
                ),
                iconOnly: true,
              ),
            ]
          : [
              RecordHeaderActionChip(
                key: const Key('record-date-today-action'),
                label: l10n.recordTodayAction,
                icon: Icons.today_outlined,
                typography: typography,
                surface: surface,
                onTap: () => _setSelectedDate(ref, DateTime.now()),
                iconOnly: isCompact,
              ),
              RecordHeaderActionChip(
                key: const Key('record-date-previous-action'),
                label: l10n.recordPreviousDayAction,
                icon: Icons.chevron_left_rounded,
                typography: typography,
                surface: surface,
                onTap: () => _setSelectedDate(
                  ref,
                  selectedDate.subtract(const Duration(days: 1)),
                ),
                iconOnly: true,
              ),
              RecordHeaderActionChip(
                key: const Key('record-date-next-action'),
                label: l10n.recordNextDayAction,
                icon: Icons.chevron_right_rounded,
                typography: typography,
                surface: surface,
                onTap: () => _setSelectedDate(
                  ref,
                  selectedDate.add(const Duration(days: 1)),
                ),
                iconOnly: true,
              ),
              RecordHeaderActionChip(
                label: l10n.recordPickDateAction,
                icon: Icons.calendar_month_outlined,
                typography: typography,
                surface: surface,
                onTap: () => _pickSelectedDate(context, ref, selectedDate),
                iconOnly: true,
              ),
              RecordHeaderActionChip(
                key: const Key('record-add-action'),
                label: isCompact
                    ? l10n.recordAddCompactAction
                    : l10n.recordAddAction,
                icon: Icons.add_rounded,
                emphasized: true,
                typography: typography,
                surface: surface,
                onTap: () => pushAuthRequiredRoute(
                  context,
                  '/record/create?date=${_formatDate(selectedDate)}',
                ),
              ),
            ],
      children: [
        dashboardAsync.when(
          data: (dashboard) => RecordDashboardView(
            dashboard: dashboard,
            onFilterSelected: (type) =>
                ref.read(selectedRecordFilterProvider.notifier).setFilter(type),
            onDateSelected: (date) => _setSelectedDate(ref, date),
            onPickDate: () => _pickSelectedDate(context, ref, selectedDate),
            onQuickAction: (action) => _handleQuickAction(context, ref, action),
          ),
          loading: () => RecordDashboardView(
            dashboard: MockRecordRepository.loadingDashboard(
              selectedDate,
              filterType: selectedFilter,
            ),
            isLoading: true,
            onFilterSelected: (type) =>
                ref.read(selectedRecordFilterProvider.notifier).setFilter(type),
            onDateSelected: (date) => _setSelectedDate(ref, date),
            onPickDate: () => _pickSelectedDate(context, ref, selectedDate),
            onQuickAction: (action) => _handleQuickAction(context, ref, action),
          ),
          error: (_, __) => AppStateErrorView(
            title: l10n.recordErrorTitle,
            description: l10n.recordErrorDescription,
            icon: Icons.edit_calendar_outlined,
            actionLabel: l10n.todayRetryAction,
            onAction: () => ref.invalidate(recordDashboardProvider),
            tone: AppStateTone.warning,
          ),
        ),
      ],
    );
  }

  void _setSelectedDate(WidgetRef ref, DateTime date) {
    ref.read(selectedRecordDateProvider.notifier).setDate(date);
  }

  void _handleQuickAction(
    BuildContext context,
    WidgetRef ref,
    RecordQuickAction action,
  ) {
    final kind = dailyRecordKindForEntryType(action.type);
    if (kind == null) {
      showRecordToast(context, _quickActionLabel(context, action));
      return;
    }

    final selectedDate = ref.read(selectedRecordDateProvider);
    pushAuthRequiredRoute(
      context,
      '/record/create?kind=${Uri.encodeComponent(kind.name)}'
      '&date=${Uri.encodeComponent(_formatDate(selectedDate))}',
    );
  }

  Future<void> _pickSelectedDate(
    BuildContext context,
    WidgetRef ref,
    DateTime selectedDate,
  ) async {
    final today = _dateOnly(DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: today.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    _setSelectedDate(ref, picked);
  }

  DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  String _quickActionLabel(BuildContext context, RecordQuickAction action) {
    final l10n = AppLocalizations.of(context)!;
    return l10n.recordQuickActionLabel(recordCopy(l10n, action.titleKey));
  }

  String _formatDate(DateTime value) {
    return '${value.year.toString().padLeft(4, '0')}-'
        '${value.month.toString().padLeft(2, '0')}-'
        '${value.day.toString().padLeft(2, '0')}';
  }
}
