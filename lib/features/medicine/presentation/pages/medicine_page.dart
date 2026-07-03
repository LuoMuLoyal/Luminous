import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/design/app_breakpoints.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/feedback/app_toast.dart';
import 'package:luminous/features/auth/presentation/providers/session/auth_session_provider.dart';
import 'package:luminous/features/auth/presentation/widgets/auth_required_dialog.dart';
import 'package:luminous/features/medicine/data/datasources/dose_log_remote_data_source.dart';
import 'package:luminous/features/medicine/presentation/providers/medicine_workspace_provider.dart';
import 'package:luminous/features/medicine/presentation/widgets/views/medicine_mobile_dashboard_view.dart';
import 'package:luminous/features/medicine/presentation/widgets/views/medicine_skeleton_view.dart';
import 'package:luminous/features/medicine/presentation/widgets/shared/medicine_workspace_parts.dart';
import 'package:luminous/features/medicine/presentation/widgets/views/medicine_workspace_view.dart';
import 'package:luminous/features/shell/presentation/shell_deferred_content.dart';
import 'package:luminous/features/today/presentation/providers/today_dashboard_provider.dart';
import 'package:luminous/l10n/app_localizations.dart';

class MedicinePage extends ConsumerWidget {
  const MedicinePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspaceAsync = ref.watch(medicineWorkspaceProvider);
    final colors = context.theme.colors;
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= AppBreakpoints.desktop;

    return ShellDeferredContent(
      child: workspaceAsync.when(
        data: (workspace) => isDesktop
            ? _MedicineDesktopShell(
                child: MedicineMobileDashboardView(
                  workspace: workspace,
                  onMarkDose: (currentMedicineId, action) =>
                      _markDose(context, ref, currentMedicineId, action),
                  onOpenReminder: (currentMedicineId) =>
                      _openReminder(context, ref, currentMedicineId),
                  onCreateReminder: () => _openReminder(context, ref, null),
                ),
              )
            : _MedicineMobileShell(
                child: MedicineMobileDashboardView(
                  workspace: workspace,
                  onMarkDose: (currentMedicineId, action) =>
                      _markDose(context, ref, currentMedicineId, action),
                  onOpenReminder: (currentMedicineId) =>
                      _openReminder(context, ref, currentMedicineId),
                  onCreateReminder: () => _openReminder(context, ref, null),
                ),
              ),
        loading: () => isDesktop
            ? const _MedicineDesktopShell(child: MedicineSkeletonView())
            : const _MedicineMobileShell(child: MedicineSkeletonView()),
        error: (_, __) => DecoratedBox(
          decoration: BoxDecoration(color: colors.background),
          child: SafeArea(
            bottom: false,
            child: MedicineErrorView(
              onRetry: () => ref.invalidate(medicineWorkspaceProvider),
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> _markDose(
  BuildContext context,
  WidgetRef ref,
  String currentMedicineId,
  MedicineDoseAction action,
) async {
  final session = ref.read(authSessionProvider);
  if (!session.canAccessProtectedData) {
    if (session.isLoading) {
      return;
    }
    if (context.mounted) {
      await showAuthRequiredDialog(
        context,
        onLogin: () => context.push(loginRouteForCurrentLocation(context)),
      );
    }
    return;
  }

  final l10n = AppLocalizations.of(context)!;
  final today = DateTime.now();
  final dateStr =
      '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

  try {
    await ref
        .read(doseLogRemoteDataSourceProvider)
        .markForDate(currentMedicineId, action.name, dateStr);
    ref.invalidate(medicineWorkspaceProvider);
    ref.invalidate(todayDashboardProvider);
    if (context.mounted) {
      unawaited(AppToast.show(context, l10n.medicineDoseActionSavedToast));
    }
  } catch (error) {
    if (context.mounted) {
      unawaited(AppToast.show(context, l10n.medicineDoseActionFailedToast));
    }
  }
}

Future<void> _openReminder(
  BuildContext context,
  WidgetRef ref,
  String? currentMedicineId,
) async {
  final session = ref.read(authSessionProvider);
  if (!session.canAccessProtectedData) {
    if (session.isLoading) {
      return;
    }
    if (context.mounted) {
      await showAuthRequiredDialog(
        context,
        onLogin: () => context.push(loginRouteForCurrentLocation(context)),
      );
    }
    return;
  }

  if (!context.mounted) return;
  if (currentMedicineId == null) {
    unawaited(context.push('/medicine/reminders/new'));
    return;
  }
  unawaited(
    context.push(
      '/medicine/reminders/${Uri.encodeComponent(currentMedicineId)}',
    ),
  );
}

class _MedicineMobileShell extends StatelessWidget {
  const _MedicineMobileShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return DecoratedBox(
      decoration: BoxDecoration(color: colors.background),
      child: SafeArea(
        bottom: false,
        child: ListView(
          key: const PageStorageKey<String>('medicine-mobile-scroll'),
          padding: const EdgeInsets.fromLTRB(
            AppSpacingTokens.level4,
            AppSpacingTokens.level4,
            AppSpacingTokens.level4,
            AppSpacingTokens.level10,
          ),
          children: [
            const _MedicineMobileTopBar(),
            const SizedBox(height: AppSpacingTokens.level4),
            const _MedicineMobileSearchBar(),
            const SizedBox(height: AppSpacingTokens.level4),
            child,
          ],
        ),
      ),
    );
  }
}

class _MedicineDesktopShell extends StatelessWidget {
  const _MedicineDesktopShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return DecoratedBox(
      decoration: BoxDecoration(color: colors.background),
      child: SafeArea(
        bottom: false,
        child: ListView(
          key: const PageStorageKey<String>('medicine-desktop-scroll'),
          padding: const EdgeInsets.fromLTRB(
            AppSpacingTokens.level6,
            AppSpacingTokens.level6,
            AppSpacingTokens.level6,
            AppSpacingTokens.level6,
          ),
          children: [child],
        ),
      ),
    );
  }
}

class _MedicineMobileTopBar extends StatelessWidget {
  const _MedicineMobileTopBar();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            l10n.tabMedicine,
            style: textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: AppSpacingTokens.level3),
        const _MedicineSafeGuardPill(),
        const SizedBox(width: AppSpacingTokens.level2),
        const _MedicineNotificationButton(),
      ],
    );
  }
}

class _MedicineSafeGuardPill extends StatelessWidget {
  const _MedicineSafeGuardPill();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.theme.colors;
    final textTheme = Theme.of(context).textTheme;

    return Tooltip(
      message: l10n.medicineSafetyGuardLabel,
      child: FButton(
        onPress: () => context.push('/medicine/risk-check'),
        variant: FButtonVariant.ghost,
        mainAxisSize: MainAxisSize.min,
        style: .delta(
          contentStyle: .delta(
            padding: .value(
              const EdgeInsets.symmetric(
                horizontal: AppSpacingTokens.level2,
                vertical: AppSpacingTokens.level2,
              ),
            ),
            spacing: AppSpacingTokens.level2,
          ),
        ),
        prefix: Icon(
          FLucideIcons.shieldCheck,
          color: colors.primary,
          size: AppSpacingTokens.level5,
        ),
        child: Text(
          l10n.medicineSafetyGuardLabel,
          style: textTheme.labelMedium?.copyWith(
            color: colors.foreground,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _MedicineNotificationButton extends StatelessWidget {
  const _MedicineNotificationButton();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.theme.colors;

    return Tooltip(
      message: l10n.medicineNotificationsTooltip,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          FButton.icon(
            onPress: () =>
                pushAuthRequiredRoute(context, '/medicine/reminders/new'),
            variant: FButtonVariant.ghost,
            child: Icon(FLucideIcons.bell, color: colors.foreground),
          ),
          Positioned(
            right: AppSpacingTokens.level3,
            top: AppSpacingTokens.level2,
            child: FBadge.raw(
              style: .delta(
                decoration: .shapeDelta(
                  color: colors.destructive,
                  shape: const CircleBorder(),
                ),
              ),
              builder: (context, style) =>
                  SizedBox.square(dimension: AppSpacingTokens.level2),
            ),
          ),
        ],
      ),
    );
  }
}

class _MedicineMobileSearchBar extends StatelessWidget {
  const _MedicineMobileSearchBar();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.theme.colors;
    final textTheme = Theme.of(context).textTheme;

    return FButton.raw(
      onPress: () => context.push('/medicine/search'),
      variant: FButtonVariant.ghost,
      style: .delta(
        decoration: .delta([
          .all(
            .shapeDelta(
              color: colors.background,
              shape: RoundedSuperellipseBorder(
                side: BorderSide(color: colors.border),
                borderRadius: context.theme.style.borderRadius.lg,
              ),
            ),
          ),
        ]),
        contentStyle: .delta(
          padding: .value(
            const EdgeInsets.symmetric(
              horizontal: AppSpacingTokens.level4,
              vertical: AppSpacingTokens.level3,
            ),
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            FLucideIcons.search,
            color: colors.mutedForeground,
            size: AppSpacingTokens.level5,
          ),
          const SizedBox(width: AppSpacingTokens.level3),
          Expanded(
            child: Text(
              l10n.medicineHomeSearchHint,
              style: textTheme.bodyMedium?.copyWith(
                color: colors.mutedForeground,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
