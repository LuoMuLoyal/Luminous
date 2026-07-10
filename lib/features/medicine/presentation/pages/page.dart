import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/feedback/app_toast.dart';
import 'package:luminous/core/logger/app_logger.dart';
import 'package:luminous/features/auth/presentation/providers/session/session_provider.dart';
import 'package:luminous/features/auth/presentation/widgets/shared/required_dialog.dart';
import 'package:luminous/features/medicine/data/datasources/cached_dose_log_data_source.dart';
import 'package:luminous/features/medicine/presentation/routes.dart';
import 'package:luminous/features/medicine/presentation/providers/workspace_provider.dart';
import 'package:luminous/features/medicine/presentation/widgets/views/mobile_dashboard_view.dart';
import 'package:luminous/features/medicine/presentation/widgets/views/skeleton_view.dart';
import 'package:luminous/features/medicine/presentation/widgets/shared/workspace_parts.dart';
import 'package:luminous/features/medicine/presentation/widgets/views/workspace_view.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/core/widgets/common/top_bar.dart';
import 'package:luminous/features/medicine/domain/entities/workspace.dart';
import 'package:luminous/features/shell/presentation/deferred_content.dart';
import 'package:luminous/features/today/presentation/providers/dashboard_provider.dart';
import 'package:luminous/l10n/app_localizations.dart';

class MedicinePage extends ConsumerWidget {
  const MedicinePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authSessionProvider);
    final l10n = AppLocalizations.of(context)!;
    final colors = context.theme.colors;
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= Breakpoints.desktop;

    // Always watch the provider — when signed out it returns preview data.
    final workspaceAsync = ref.watch(medicineWorkspaceProvider);

    final pageState = resolvePageViewState<MedicineWorkspace>(
      session: session,
      data: workspaceAsync,
      isInsufficient: (workspace) => workspace.plan.items.isEmpty,
    );

    return ShellDeferredContent(
      child: PageStateSwitch<MedicineWorkspace>(
        state: pageState,
        loadingBuilder: () => isDesktop
            ? const _MedicineDesktopShell(child: MedicineSkeletonView())
            : const _MedicineMobileShell(child: MedicineSkeletonView()),
        fatalErrorBuilder: (error) => DecoratedBox(
          decoration: BoxDecoration(color: colors.background),
          child: SafeArea(
            bottom: false,
            child: MedicineErrorView(
              onRetry: () => ref.invalidate(medicineWorkspaceProvider),
            ),
          ),
        ),
        emptyInsufficientBuilder: (empty) => isDesktop
            ? _MedicineDesktopShell(
                child: AppStateMessageView(
                  title: l10n.medicineEmptyAddFirstTitle,
                  description: l10n.medicineEmptyAddFirstDescription,
                  icon: FLucideIcons.pillBottle,
                  actionLabel: l10n.medicineQuickAddTitle,
                  onAction: () =>
                      pushAuthRequiredRoute(context, AppRoutes.medicineSearch),
                ),
              )
            : _MedicineMobileShell(
                child: AppStateMessageView(
                  title: l10n.medicineEmptyAddFirstTitle,
                  description: l10n.medicineEmptyAddFirstDescription,
                  icon: FLucideIcons.pillBottle,
                  actionLabel: l10n.medicineQuickAddTitle,
                  onAction: () =>
                      pushAuthRequiredRoute(context, AppRoutes.medicineSearch),
                ),
              ),
        readyBuilder: (workspace, isPreview) {
          final onSignIn = isPreview
              ? () => context.push(loginRouteForCurrentLocation(context))
              : null;
          final content = MedicineMobileDashboardView(
            workspace: workspace,
            onMarkDose: (request) => _markDose(context, ref, request),
            onOpenReminder: (currentMedicineId) =>
                _openReminder(context, ref, currentMedicineId),
            onCreateReminder: () => _openReminder(context, ref, null),
          );
          return isDesktop
              ? _MedicineDesktopShell(
                  child: isPreview
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SignInHintBanner(onSignIn: onSignIn),
                            const SizedBox(height: Spacing.level4),
                            content,
                          ],
                        )
                      : content,
                )
              : isPreview
              ? _MedicineMobileShell(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SignInHintBanner(onSignIn: onSignIn),
                      const SizedBox(height: Spacing.level4),
                      content,
                    ],
                  ),
                )
              : _MedicineMobileShell(child: content);
        },
      ),
    );
  }
}

Future<void> _markDose(
  BuildContext context,
  WidgetRef ref,
  MedicineDoseMarkRequest request,
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
  final today = clock.now();
  final dateStr =
      '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

  try {
    await ref
        .read(cachedDoseLogDataSourceProvider)
        .mark(
          currentMedicineId: request.currentMedicineId,
          reminderId: request.reminderId,
          scheduledTime: request.scheduledTime,
          status: request.action.name,
          date: dateStr,
        );
    ref.invalidate(medicineWorkspaceProvider);
    ref.invalidate(todayDashboardProvider);
    if (context.mounted) {
      unawaited(AppToast.show(context, l10n.medicineDoseActionSavedToast));
    }
  } catch (error) {
    ref.read(talkerProvider).error('_markDose: failed: $error');
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
    unawaited(const MedicineRemindersNewRoute().push(context));
    return;
  }
  unawaited(
    MedicineReminderDetailRoute(medicineId: currentMedicineId).push(context),
  );
}

class _MedicineMobileShell extends StatelessWidget {
  const _MedicineMobileShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.theme.colors;

    return DecoratedBox(
      decoration: BoxDecoration(color: colors.background),
      child: SafeArea(
        bottom: false,
        child: ListView(
          key: const PageStorageKey<String>('medicine-mobile-scroll'),
          padding: const EdgeInsets.fromLTRB(
            Spacing.level4,
            Spacing.level4,
            Spacing.level4,
            Spacing.level10,
          ),
          children: [
            AppTopBar(
              title: l10n.tabMedicine,
              trailing: const [
                _MedicineSafeGuardPill(),
                _MedicineNotificationButton(),
              ],
            ),
            const SizedBox(height: Spacing.level4),
            const _MedicineMobileSearchBar(),
            const SizedBox(height: Spacing.level4),
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
            Spacing.level6,
            Spacing.level6,
            Spacing.level6,
            Spacing.level6,
          ),
          children: [child],
        ),
      ),
    );
  }
}

class _MedicineSafeGuardPill extends StatelessWidget {
  const _MedicineSafeGuardPill();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.theme.colors;

    return FTooltip(
      tipBuilder: (context, controller) => Text(l10n.medicineSafetyGuardLabel),
      child: FButton(
        onPress: () => context.push(AppRoutes.medicineRiskCheck),
        variant: FButtonVariant.ghost,
        mainAxisSize: MainAxisSize.min,
        style: const .delta(
          contentStyle: .delta(
            padding: .value(
              EdgeInsets.symmetric(
                horizontal: Spacing.level2,
                vertical: Spacing.level2,
              ),
            ),
            spacing: Spacing.level2,
          ),
        ),
        prefix: Icon(
          FLucideIcons.shieldCheck,
          color: colors.primary,
          size: Spacing.level5,
        ),
        child: Text(
          l10n.medicineSafetyGuardLabel,
          style: TypographyToken.level4
              .body(context)
              .copyWith(color: colors.foreground, fontWeight: FontWeight.w700),
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

    return FTooltip(
      tipBuilder: (context, controller) =>
          Text(l10n.medicineNotificationsTooltip),
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
            right: Spacing.level3,
            top: Spacing.level2,
            child: FBadge.raw(
              style: .delta(
                decoration: .shapeDelta(
                  color: colors.destructive,
                  shape: const CircleBorder(),
                ),
              ),
              builder: (context, style) =>
                  const SizedBox.square(dimension: Spacing.level2),
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

    return SizedBox(
      key: const Key('medicine-home-search-bar'),
      height: 56,
      child: FButton.raw(
        onPress: () => context.push(AppRoutes.medicineSearch),
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
          contentStyle: const .delta(
            padding: .value(EdgeInsets.symmetric(horizontal: Spacing.level4)),
          ),
        ),
        child: Row(
          children: [
            Icon(
              FLucideIcons.search,
              color: colors.mutedForeground,
              size: Spacing.level5,
            ),
            const SizedBox(width: Spacing.level3),
            Expanded(
              child: Text(
                l10n.medicineHomeSearchHint,
                style: TypographyToken.level4
                    .body(context)
                    .copyWith(color: colors.mutedForeground),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
