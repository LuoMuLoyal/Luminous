import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/design/app_breakpoints.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/feedback/app_toast.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/core/widgets/common/app_ink_well.dart';
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
    final surface = Theme.of(context).extension<AppThemeSurface>()!;
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
          decoration: BoxDecoration(color: surface.canvasSoft),
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
    final surface = Theme.of(context).extension<AppThemeSurface>()!;

    return DecoratedBox(
      decoration: BoxDecoration(color: surface.canvasSoft),
      child: SafeArea(
        bottom: false,
        child: ListView(
          key: const PageStorageKey<String>('medicine-mobile-scroll'),
          padding: const EdgeInsets.fromLTRB(
            AppSpacingTokens.md,
            AppSpacingTokens.md,
            AppSpacingTokens.md,
            AppSpacingTokens.x5l,
          ),
          children: [
            const _MedicineMobileTopBar(),
            const SizedBox(height: AppSpacingTokens.md),
            const _MedicineMobileSearchBar(),
            const SizedBox(height: AppSpacingTokens.md),
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
    final surface = Theme.of(context).extension<AppThemeSurface>()!;

    return DecoratedBox(
      decoration: BoxDecoration(color: surface.canvasSoft),
      child: SafeArea(
        bottom: false,
        child: ListView(
          key: const PageStorageKey<String>('medicine-desktop-scroll'),
          padding: const EdgeInsets.fromLTRB(
            AppSpacingTokens.xl,
            AppSpacingTokens.xl,
            AppSpacingTokens.xl,
            AppSpacingTokens.xl,
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
    final theme = Theme.of(context);
    final typography = AppTypographyTokens.mobile(theme.colorScheme.onSurface);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            l10n.tabMedicine,
            style: typography.displayXl.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
        ),
        const SizedBox(width: AppSpacingTokens.sm),
        const _MedicineSafeGuardPill(),
        const SizedBox(width: AppSpacingTokens.xs),
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
    final theme = Theme.of(context);
    final typography = AppTypographyTokens.mobile(theme.colorScheme.onSurface);

    return Tooltip(
      message: l10n.medicineSafetyGuardLabel,
      child: AppInkWell(
        onTap: () => context.push('/medicine/risk-check'),
        borderRadius: BorderRadius.circular(AppRadiusTokens.pill),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacingTokens.xs,
          vertical: AppSpacingTokens.xs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.gpp_good_outlined,
              color: AppColorTokens.cyanDeep,
              size: AppSpacingTokens.lg,
            ),
            const SizedBox(width: AppSpacingTokens.xs),
            Text(
              l10n.medicineSafetyGuardLabel,
              style: typography.bodySmStrong.copyWith(
                color: Theme.of(context).extension<AppThemeSurface>()!.body,
                letterSpacing: 0,
              ),
            ),
          ],
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
    final theme = Theme.of(context);

    return Tooltip(
      message: l10n.medicineNotificationsTooltip,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          IconButton(
            onPressed: () =>
                pushAuthRequiredRoute(context, '/medicine/reminders/new'),
            icon: const Icon(Icons.notifications_none_rounded),
            color: theme.colorScheme.onSurface,
            visualDensity: VisualDensity.compact,
            style: const ButtonStyle(
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          Positioned(
            right: AppSpacingTokens.sm,
            top: AppSpacingTokens.xs,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colorScheme.error,
                shape: BoxShape.circle,
              ),
              child: const SizedBox.square(dimension: AppSpacingTokens.xs),
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
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final typography = AppTypographyTokens.mobile(theme.colorScheme.onSurface);

    return AppInkWell(
      onTap: () => context.push('/medicine/search'),
      borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: surface.canvas,
          borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
          border: Border.all(color: surface.hairline),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacingTokens.md,
            vertical: AppSpacingTokens.sm,
          ),
          child: Row(
            children: [
              Icon(
                Icons.search_rounded,
                color: surface.mute,
                size: AppSpacingTokens.lg,
              ),
              const SizedBox(width: AppSpacingTokens.sm),
              Expanded(
                child: Text(
                  l10n.medicineHomeSearchHint,
                  style: typography.bodyMd.copyWith(
                    color: surface.mute,
                    letterSpacing: 0,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
