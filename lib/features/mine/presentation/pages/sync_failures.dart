import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/database/connection_providers.dart';
import 'package:luminous/core/database/daos/pending_sync.dart';
import 'package:luminous/core/database/sync/worker.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/logger/log_level.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/core/widgets/layout/page_scaffold.dart';
import 'package:luminous/core/widgets/layout/responsive_content_frame.dart';
import 'package:luminous/features/mine/presentation/providers/sync_failures.dart';
import 'package:luminous/features/mine/presentation/widgets/sections/sync_failed_entry.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Full-page view of permanently failed local sync items.
///
/// Replaces the former details dialog: the queue is a list the user may need
/// to read at length (and copy diagnostics out of), so it gets a real page
/// with its own loading, error and empty states instead of a scrollable
/// dialog body.
class SyncFailuresPage extends ConsumerStatefulWidget {
  const SyncFailuresPage({super.key});

  @override
  ConsumerState<SyncFailuresPage> createState() => _SyncFailuresPageState();
}

class _SyncFailuresPageState extends ConsumerState<SyncFailuresPage> {
  bool _isRetrying = false;
  String? _retryError;

  Future<void> _retryAll(List<PendingSyncEntry> entries) async {
    if (_isRetrying) return;

    setState(() {
      _isRetrying = true;
      _retryError = null;
    });

    try {
      final dao = ref.read(pendingSyncDaoProvider);
      await Future.wait(entries.map((entry) => dao.resetForRetry(entry.id)));
      await ref.read(syncWorkerProvider).flush();
      ref.invalidate(syncFailedCountProvider);
      // Reload the list: retried items either leave the queue or come back
      // with a fresh error, so the page must not keep the stale snapshot.
      ref.invalidate(mineSyncFailedEntriesProvider);
    } catch (e, st) {
      // Log the real failure (DB corruption, disk full, ...) so it is not
      // silently swallowed — talker forwards it to Sentry in release builds.
      ref.read(talkerProvider).error('SyncFailuresPage._retryAll: $e', st);
      if (!mounted) return;
      setState(() {
        _retryError = AppLocalizations.of(
          context,
        )!.mineSyncFailedDetailsRetryFailed;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isRetrying = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final entriesAsync = ref.watch(mineSyncFailedEntriesProvider);

    return PageScaffold(
      title: l10n.mineSyncFailedDetailsTitle,
      // The state switch wraps body *and* footer so the primary action is
      // driven by the same snapshot as the list.
      child: entriesAsync.when(
        // Keep the current list (and its action) on screen while a retry
        // reloads it — the queue only changes after flush() settles.
        skipLoadingOnReload: true,
        loading: () => const _ScrollArea(child: _SyncFailuresLoading()),
        error: (_, _) => _ScrollArea(
          child: StateErrorView(
            title: l10n.stateFatalErrorTitle,
            description: l10n.stateFatalErrorDescription,
            icon: SemanticIcons.statusError,
            actionLabel: l10n.commonRetry,
            onAction: () => ref.invalidate(mineSyncFailedEntriesProvider),
          ),
        ),
        data: (entries) => Column(
          children: [
            Expanded(child: _ScrollArea(child: _buildContent(l10n, entries))),
            if (entries.isNotEmpty)
              _RetryAllFooter(
                isRetrying: _isRetrying,
                errorMessage: _retryError,
                onRetryAll: () => _retryAll(entries),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(AppLocalizations l10n, List<PendingSyncEntry> entries) {
    final typography = context.theme.typography;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.mineSyncFailedDetailsDescription,
          style: typography.body.sm.copyWith(
            color: SemanticColor.neutral.solid(context),
          ),
        ),
        const SizedBox(height: Spacing.xl),
        if (entries.isEmpty)
          StateMessageView(
            title: l10n.mineSyncFailedDetailsEmpty,
            icon: SemanticIcons.statusSuccess,
            tone: StateTone.success,
          )
        else ...[
          Text(
            l10n.mineSyncFailedDetailsListTitle(entries.length),
            style: typography.body.sm.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: Spacing.md),
          for (final entry in entries) ...[
            SyncFailedEntryCard(entry: entry),
            if (entry != entries.last) const SizedBox(height: Spacing.md),
          ],
        ],
      ],
    );
  }
}

/// Scrollable, width-constrained body region shared by the three states.
class _ScrollArea extends StatelessWidget {
  const _ScrollArea({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ResponsiveContentFrame(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: Spacing.xl),
        child: child,
      ),
    );
  }
}

/// Persistent action bar holding the page's primary action, so "retry all"
/// stays reachable however long the failure list is.
class _RetryAllFooter extends StatelessWidget {
  const _RetryAllFooter({
    required this.isRetrying,
    required this.errorMessage,
    required this.onRetryAll,
  });

  final bool isRetrying;
  final String? errorMessage;
  final VoidCallback onRetryAll;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final typography = context.theme.typography;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        Spacing.lg,
        Spacing.md,
        Spacing.lg,
        Spacing.lg,
      ),
      decoration: BoxDecoration(
        color: context.theme.colors.background,
        border: Border(
          top: BorderSide(color: SemanticColor.neutral.border(context)),
        ),
      ),
      child: ResponsiveContentFrame(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (errorMessage != null) ...[
              Text(
                errorMessage!,
                style: typography.body.xs.copyWith(
                  color: SemanticColor.destructive.solid(context),
                ),
              ),
              const SizedBox(height: Spacing.md),
            ],
            FButton(
              key: const Key('sync-failures-retry-all'),
              onPress: isRetrying ? null : onRetryAll,
              child: isRetrying
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: FCircularProgress(),
                        ),
                        const SizedBox(width: Spacing.sm),
                        Text(l10n.mineSyncFailedDetailsRetrying),
                      ],
                    )
                  : Text(l10n.mineSyncFailedDetailsRetryAll),
            ),
          ],
        ),
      ),
    );
  }
}

class _SyncFailuresLoading extends StatelessWidget {
  const _SyncFailuresLoading();

  @override
  Widget build(BuildContext context) {
    return const InlineSkeletonSection(
      children: [
        InlineSkeletonBlock(height: 148),
        InlineSkeletonBlock(height: 148),
        InlineSkeletonBlock(height: 148),
      ],
    );
  }
}
