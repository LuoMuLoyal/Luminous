import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/logger/logger.dart';
import 'package:luminous/core/utils/date_format_utils.dart';
import 'package:luminous/core/widgets/common/dialog_shell.dart';
import 'package:luminous/core/widgets/common/sheet_drag_handle.dart';
import 'package:luminous/features/review/presentation/providers/clinic_summary.dart';
import 'package:luminous/features/review/presentation/widgets/shared/components.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Shows the current user's clinic summary shares (desktop dialog / mobile
/// bottom sheet).
///
/// Lists `GET /api/v1/user/reports/clinic-summary/shares` — each row shows
/// created / expires / access count / last accessed (or "not accessed yet")
/// and a revoke action for active shares. Revoked shares stay listed with
/// their revocation time. The API never exposes visitor identity (no names,
/// no IPs), and this sheet never infers or displays any.
Future<void> showShareManagementSheet(BuildContext context) {
  final isDesktop = MediaQuery.sizeOf(context).width >= Breakpoints.desktop;

  if (isDesktop) {
    return showFDialog<void>(
      context: context,
      builder: (dialogContext, _, __) => DialogShell(
        maxWidth: LayoutScaleResolver.dialogStandardMaxWidth,
        builder: (_) => const ShareManagementSheet(),
      ),
    );
  }

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: context.theme.style.borderRadius.md.topLeft,
      ),
    ),
    builder: (_) => SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: const ShareManagementSheet(),
      ),
    ),
  );
}

/// Share management content; can be rendered directly (tests) or popped via
/// [showShareManagementSheet].
class ShareManagementSheet extends ConsumerStatefulWidget {
  const ShareManagementSheet({super.key});

  @override
  ConsumerState<ShareManagementSheet> createState() =>
      _ShareManagementSheetState();
}

class _ShareManagementSheetState extends ConsumerState<ShareManagementSheet> {
  /// Share ids whose revoke request is in flight. A Set so independent rows
  /// can be revoked concurrently; only the in-flight row's button spins.
  final Set<String> _revokingShareIds = {};

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(clinicSummaryShareListProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(Spacing.level5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (MediaQuery.sizeOf(context).width < Breakpoints.desktop)
            const Center(child: SheetDragHandle()),
          Text(
            l10n.reviewShareManagementTitle,
            style: context.theme.typography.body.lg.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: Spacing.level4),
          ...switch (async) {
            // Value-first: while a revoke refreshes the list the previous
            // rows stay visible instead of flashing the spinner.
            AsyncValue(:final hasValue) when hasValue => _shareList(
              l10n,
              async.value ?? const [],
            ),
            AsyncValue(:final isLoading) when isLoading => [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: Spacing.level6),
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: FCircularProgress(),
                  ),
                ),
              ),
            ],
            _ => [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: Spacing.level4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      SemanticIcons.statusWarning,
                      size: 28,
                      color: SemanticColor.warning.solid(context),
                    ),
                    const SizedBox(height: Spacing.level3),
                    Text(
                      l10n.reviewShareManagementLoadFailed,
                      style: context.theme.typography.body.xs,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: Spacing.level4),
                    FButton(
                      variant: FButtonVariant.outline,
                      onPress: () =>
                          ref.invalidate(clinicSummaryShareListProvider),
                      child: Text(l10n.todayRetryAction),
                    ),
                  ],
                ),
              ),
            ],
          },
          const SizedBox(height: Spacing.level4),
        ],
      ),
    );
  }

  List<Widget> _shareList(
    AppLocalizations l10n,
    List<ClinicSummaryShareListItemDto> shares,
  ) {
    if (shares.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: Spacing.level5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                SemanticIcons.safetyNeutral,
                size: 28,
                color: SemanticColor.neutral.solid(context),
              ),
              const SizedBox(height: Spacing.level3),
              Text(
                l10n.reviewShareManagementEmpty,
                style: context.theme.typography.body.sm,
              ),
              const SizedBox(height: Spacing.level1),
              Text(
                l10n.reviewShareManagementEmptyHint,
                style: context.theme.typography.body.xs.copyWith(
                  color: SemanticColor.neutral.solid(context),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ];
    }

    return [
      for (var i = 0; i < shares.length; i++) ...[
        _ShareRow(
          share: shares[i],
          isRevoking: _revokingShareIds.contains(shares[i].id),
          onRevoke: () => _revoke(context, shares[i].id),
        ),
        if (i < shares.length - 1) const SizedBox(height: Spacing.level3),
      ],
    ];
  }

  Future<void> _revoke(BuildContext context, String shareId) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _revokingShareIds.add(shareId));
    try {
      // 撤销失败（网络 / 服务端业务失败 / 协议异常逃逸）统一提示失败，
      // 行保留可重试（widget 不读 code/status）。
      await ref.read(clinicSummaryShareListProvider.notifier).revoke(shareId);
    } catch (error) {
      // 撤销失败（网络 / 服务端业务失败 / 协议异常逃逸）统一提示失败，
      // 行保留可重试（widget 不读 code/status）。
      ref
          .read(talkerProvider)
          .error('ShareManagementSheet._revoke: failed: $error');
      if (context.mounted) {
        await Toast.show(context, l10n.reviewShareRevokeFailed);
      }
    } finally {
      if (mounted) {
        setState(() => _revokingShareIds.remove(shareId));
      }
    }
  }
}

/// One share row: created / expires / access count / last accessed (or
/// 暂无访问) / revocation state. No visitor identity is shown anywhere.
class _ShareRow extends ConsumerWidget {
  const _ShareRow({
    required this.share,
    required this.isRevoking,
    required this.onRevoke,
  });

  final ClinicSummaryShareListItemDto share;
  final bool isRevoking;
  final VoidCallback onRevoke;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final revoked = share.revokedAt != null;

    return FCard(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.level4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (revoked) ...[
              Row(
                children: [
                  FBadge.raw(
                    style: .delta(
                      decoration: .shapeDelta(
                        color: SemanticColor.neutral.muted(context),
                        shape: RoundedRectangleBorder(
                          borderRadius: context.theme.style.borderRadius.pill,
                        ),
                      ),
                    ),
                    builder: (context, style) => Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.level3,
                        vertical: Spacing.level1,
                      ),
                      child: Text(
                        l10n.reviewShareRevokedBadge,
                        style: context.theme.typography.body.xs.copyWith(
                          color: SemanticColor.neutral.solid(context),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: Spacing.level2),
                  Expanded(
                    child: Text(
                      formatDateTimeFull(share.revokedAt!, locale),
                      style: context.theme.typography.body.xs.copyWith(
                        color: SemanticColor.neutral.solid(context),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.level3),
            ],
            MetaRow(
              label: l10n.reviewShareCreatedAt,
              value: formatDateTimeFull(share.createdAt, locale),
            ),
            MetaRow(
              label: l10n.reviewShareExpiresAt,
              value: formatDateTimeFull(share.expiresAt, locale),
            ),
            MetaRow(
              label: l10n.reviewShareAccessCountLabel,
              value: l10n.reviewShareAccessCount(share.accessCount.toInt()),
            ),
            MetaRow(
              label: l10n.reviewShareLastAccessed,
              value: share.lastAccessedAt != null
                  ? formatDateTimeFull(share.lastAccessedAt!, locale)
                  : l10n.reviewShareLastAccessedNever,
            ),
            if (!revoked) ...[
              const SizedBox(height: Spacing.level3),
              FButton(
                variant: FButtonVariant.outline,
                onPress: isRevoking ? null : onRevoke,
                child: isRevoking
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: FCircularProgress(),
                      )
                    : Text(l10n.reviewShareRevokeAction),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
