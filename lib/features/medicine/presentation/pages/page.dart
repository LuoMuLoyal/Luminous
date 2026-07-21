import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/providers/data_change_bus.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/logger/logger.dart';
import 'package:luminous/features/auth/presentation/providers/session.dart';
import 'package:luminous/features/auth/presentation/widgets/shared/required_dialog.dart';
import 'package:luminous/features/medicine/data/datasources/dose_log_cached.dart';
import 'package:luminous/features/medicine/presentation/routes.dart';
import 'package:luminous/features/medicine/presentation/providers/workspace.dart';
import 'package:luminous/features/medicine/presentation/widgets/views/mobile_dashboard_view.dart';
import 'package:luminous/features/medicine/presentation/widgets/views/skeleton_view.dart';
import 'package:luminous/features/medicine/presentation/widgets/shared/workspace_parts.dart';
import 'package:luminous/features/medicine/presentation/widgets/views/workspace_view.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/core/widgets/common/top_bar.dart';
import 'package:luminous/features/medicine/domain/entities/workspace.dart';
import 'package:luminous/features/notification/presentation/providers/notification.dart';
import 'package:luminous/features/shell/presentation/deferred_content.dart';
import 'package:luminous/features/shell/presentation/desktop_tab_shell.dart';
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
      isInsufficient: (workspace) =>
          session.isAuthenticated && workspace.plan.items.isEmpty,
    );

    return ShellDeferredContent(
      child: PageStateSwitch<MedicineWorkspace>(
        state: pageState,
        loadingBuilder: () => isDesktop
            ? DesktopTabShell(
                title: l10n.tabMedicine,
                trailing: const [
                  _MedicineSafeGuardPill(),
                  _MedicineNotificationButton(),
                ],
                scrollable: false,
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _MedicineMobileSearchBar(),
                    SizedBox(height: Spacing.level4),
                    Expanded(child: MedicineSkeletonView()),
                  ],
                ),
              )
            : const _MedicineMobileShell(child: MedicineSkeletonView()),
        fatalErrorBuilder: (error) => isDesktop
            ? DesktopTabShell(
                title: l10n.tabMedicine,
                trailing: const [
                  _MedicineSafeGuardPill(),
                  _MedicineNotificationButton(),
                ],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _MedicineMobileSearchBar(),
                    const SizedBox(height: Spacing.level4),
                    Expanded(
                      child: MedicineErrorView(
                        onRetry: () =>
                            ref.invalidate(medicineWorkspaceProvider),
                      ),
                    ),
                  ],
                ),
              )
            : DecoratedBox(
                decoration: BoxDecoration(color: colors.background),
                child: SafeArea(
                  bottom: false,
                  child: MedicineErrorView(
                    onRetry: () => ref.invalidate(medicineWorkspaceProvider),
                  ),
                ),
              ),
        emptyInsufficientBuilder: (empty) => isDesktop
            ? DesktopTabShell(
                title: l10n.tabMedicine,
                trailing: const [
                  _MedicineSafeGuardPill(),
                  _MedicineNotificationButton(),
                ],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _MedicineMobileSearchBar(),
                    const SizedBox(height: Spacing.level4),
                    Expanded(
                      child: AppStateMessageView(
                        title: l10n.medicineEmptyAddFirstTitle,
                        description: l10n.medicineEmptyAddFirstDescription,
                        icon: FLucideIcons.pillBottle,
                        actionLabel: l10n.medicineQuickAddTitle,
                        onAction: () => pushAuthRequiredRoute(
                          context,
                          AppRoutes.medicineSearch,
                        ),
                      ),
                    ),
                  ],
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
          final dashboardContent = isPreview
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SignInHintBanner(onSignIn: onSignIn),
                    const SizedBox(height: Spacing.level4),
                    content,
                  ],
                )
              : content;
          return isDesktop
              ? DesktopTabShell(
                  title: l10n.tabMedicine,
                  trailing: const [
                    _MedicineSafeGuardPill(),
                    _MedicineNotificationButton(),
                  ],
                  scrollStorageKey: 'medicine-desktop-scroll',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _MedicineMobileSearchBar(),
                      const SizedBox(height: Spacing.level4),
                      dashboardContent,
                    ],
                  ),
                )
              : _MedicineMobileShell(child: dashboardContent);
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
    ref.read(dataChangeBusProvider.notifier).emit(DataChangeTopic.doseLogs);
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

class _MedicineSafeGuardPill extends StatelessWidget {
  const _MedicineSafeGuardPill();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.theme.colors;
    final isNarrow = MediaQuery.sizeOf(context).width < Breakpoints.tablet;

    final shieldIcon = Icon(
      FLucideIcons.shieldCheck,
      color: colors.primary,
      size: Spacing.level5,
    );

    return FTooltip(
      tipBuilder: (context, controller) => Text(l10n.medicineSafetyGuardLabel),
      child: isNarrow
          ? FButton.icon(
              onPress: () => context.push(AppRoutes.medicineRiskCheck),
              variant: FButtonVariant.ghost,
              child: shieldIcon,
            )
          : FButton(
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
              prefix: shieldIcon,
              child: Text(
                l10n.medicineSafetyGuardLabel,
                style: TypographyToken.level4
                    .body(context)
                    .copyWith(
                      color: colors.foreground,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
    );
  }
}

class _MedicineNotificationButton extends ConsumerWidget {
  const _MedicineNotificationButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.theme.colors;
    final unreadAsync = ref.watch(notificationUnreadCountProvider);
    final unreadCount = unreadAsync.value ?? 0;
    final showBadge = unreadCount > 0;

    return FTooltip(
      tipBuilder: (context, controller) =>
          Text(l10n.medicineNotificationsTooltip),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          FButton.icon(
            onPress: () =>
                pushAuthRequiredRoute(context, AppRoutes.notifications),
            variant: FButtonVariant.ghost,
            child: Icon(FLucideIcons.bell, color: colors.foreground),
          ),
          if (showBadge)
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

    return ConstrainedBox(
      key: const Key('medicine-home-search-bar'),
      constraints: const BoxConstraints(minHeight: 56),
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
            const SizedBox(width: Spacing.level2),
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
