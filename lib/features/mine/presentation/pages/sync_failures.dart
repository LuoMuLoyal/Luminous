import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/logger/log_level.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/core/widgets/layout/page_scaffold.dart';
import 'package:luminous/core/widgets/layout/responsive_content_frame.dart';
import 'package:luminous/features/mine/presentation/providers/sync_failures.dart';
import 'package:luminous/features/mine/presentation/widgets/sections/sync/sync_failed_entry.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Full-page view of permanently failed local sync items.
///
/// Replaces the former details dialog: the queue is a list the user may need
/// to read at length (and copy diagnostics out of), so it gets a real page
/// with its own loading, error and empty states instead of a scrollable
/// dialog body.
///
/// Structure, in reading order: what the page is (header line + count), the
/// entries themselves, and the one action that applies to all of them —
/// pinned in the footer so it stays reachable however long the list gets.
class SyncFailuresPage extends ConsumerStatefulWidget {
  const SyncFailuresPage({super.key});

  @override
  ConsumerState<SyncFailuresPage> createState() => _SyncFailuresPageState();
}

class _SyncFailuresPageState extends ConsumerState<SyncFailuresPage> {
  bool _isRetrying = false;
  String? _retryError;

  Future<void> _retryAll(List<MineSyncEntry> entries) async {
    if (_isRetrying) return;

    setState(() {
      _isRetrying = true;
      _retryError = null;
    });

    try {
      await ref.read(mineSyncQueueActionsProvider).retryAll(entries);
      // Reload the list: retried items either leave the queue or come back
      // with a fresh error, so the page must not keep the stale snapshot.
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

  /// Removes one entry from the local queue.
  ///
  /// Retry cannot clear a payload the server keeps rejecting, so the user
  /// needs a terminal action; the card owns the button and states that the
  /// removal is permanent. Failures surface through the same footer error
  /// slot as a failed retry so the two paths report in one place.
  Future<void> _discard(MineSyncEntry entry) async {
    try {
      await ref.read(mineSyncQueueActionsProvider).discard(entry);
    } catch (e, st) {
      ref.read(talkerProvider).error('SyncFailuresPage._discard: $e', st);
      if (!mounted) return;
      setState(() {
        _retryError = AppLocalizations.of(
          context,
        )!.mineSyncFailedDetailsDiscardFailed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final entriesAsync = ref.watch(mineSyncFailedEntriesProvider);

    // The state switch wraps body *and* footer so the primary action is
    // driven by the same snapshot as the list.
    return PageScaffold(
      title: l10n.mineSyncFailedDetailsTitle,
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
                onRefresh: _isRetrying
                    ? null
                    : () => ref.invalidate(mineSyncFailedEntriesProvider),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(AppLocalizations l10n, List<MineSyncEntry> entries) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (entries.isEmpty)
          StateMessageView(
            title: l10n.mineSyncFailedDetailsEmpty,
            icon: SemanticIcons.statusSuccess,
            tone: StateTone.success,
          )
        else ...[
          _PageSummary(
            count: entries.length,
            description: l10n.mineSyncFailedDetailsDescription,
          ),
          const SizedBox(height: Spacing.lg),
          for (final entry in entries) ...[
            SyncFailedEntryCard(entry: entry, onDiscard: () => _discard(entry)),
            if (entry != entries.last) const SizedBox(height: Spacing.lg),
          ],
        ],
      ],
    );
  }
}

/// What the page holds, stated once.
///
/// Replaces the old stacked description + "待处理项（3）" heading: both said
/// "three things are stuck", so the count now carries the page and the
/// description explains it at a glance.
class _PageSummary extends StatelessWidget {
  const _PageSummary({required this.count, required this.description});

  final int count;
  final String description;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final typography = context.theme.typography;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$count',
          style: typography.display.md.copyWith(
            color: context.theme.colors.foreground,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: Spacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.mineSyncFailedDetailsCount,
                style: typography.body.sm.copyWith(
                  color: context.theme.colors.foreground,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: Spacing.xs),
              Text(
                description,
                style: typography.body.xs.copyWith(
                  color: context.theme.colors.mutedForeground,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Scrollable, width-constrained body region shared by the three states.
///
/// The scroll view is the outer widget, matching the rest of the app's
/// sub-pages. Inverted, the content sinks to the middle of the screen:
/// [ResponsiveContentFrame] is a `Center`, so it hands the scroll view loose
/// vertical constraints, the scroll view shrink-wraps to its content height,
/// and the `Center` then centres that block vertically instead of starting it
/// under the header.
class _ScrollArea extends StatelessWidget {
  const _ScrollArea({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: Spacing.xl),
      child: ResponsiveContentFrame(child: child),
    );
  }
}

/// Persistent action bar holding the page's primary action, so "retry all"
/// stays reachable however long the failure list is.
///
/// The refresh control sits beside it: reloading the queue is the secondary
/// action when the network just came back but a retry is not wanted.
class _RetryAllFooter extends StatelessWidget {
  const _RetryAllFooter({
    required this.isRetrying,
    required this.errorMessage,
    required this.onRetryAll,
    required this.onRefresh,
  });

  final bool isRetrying;
  final String? errorMessage;
  final VoidCallback onRetryAll;
  final VoidCallback? onRefresh;

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
          top: BorderSide(
            color: SurfaceTokens.containerBorder(context.theme.colors),
          ),
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
            Row(
              children: [
                if (onRefresh != null) ...[
                  FButton.icon(
                    key: const Key('sync-failures-refresh'),
                    variant: FButtonVariant.ghost,
                    size: FButtonSizeVariant.md,
                    onPress: isRetrying ? null : onRefresh,
                    semanticsLabel: l10n.mineSyncFailedDetailsReload,
                    semanticsTooltip: l10n.mineSyncFailedDetailsReload,
                    child: const Icon(
                      SemanticIcons.actionRefresh,
                      size: IconSizeTokens.md,
                    ),
                  ),
                  const SizedBox(width: Spacing.sm),
                ],
                Expanded(
                  child: FButton(
                    key: const Key('sync-failures-retry-all'),
                    onPress: isRetrying ? null : onRetryAll,
                    child: isRetrying
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(
                                width: IconSizeTokens.sm,
                                height: IconSizeTokens.sm,
                                child: FCircularProgress(),
                              ),
                              const SizedBox(width: Spacing.sm),
                              Text(l10n.mineSyncFailedDetailsRetrying),
                            ],
                          )
                        : Text(l10n.mineSyncFailedDetailsRetryAll),
                  ),
                ),
              ],
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
