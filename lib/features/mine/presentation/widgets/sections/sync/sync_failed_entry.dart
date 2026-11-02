import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:intl/intl.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/mine/presentation/mappers/sync_entry_caption.dart';
import 'package:luminous/features/mine/presentation/mappers/sync_error_user_message.dart';
import 'package:luminous/features/mine/presentation/providers/sync_failures.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// One permanently failed sync item, rendered as a white card on the page
/// canvas.
///
/// The card is read in one pass, top to bottom: *why* it failed (the only
/// thing the user can act on) leads, *what* it was follows as a quiet caption,
/// and the terminal action sits at the end of the row without a confirmation
/// dialog of its own. Everything the user cannot act on — entity type,
/// operation, record id, attempt counts, trace id, raw exception — lives in
/// the collapsed [_DiagnosticsPanel] and can be copied out in one tap.
///
/// [onDiscard] removes the item from the local queue. It is offered because a
/// permanent failure is not necessarily retryable: when the server keeps
/// rejecting the payload's identity, replaying it byte-identically will never
/// succeed, so the user needs a way to clear the entry rather than watch it
/// sit in the queue forever.
class SyncFailedEntryCard extends StatefulWidget {
  const SyncFailedEntryCard({super.key, required this.entry, this.onDiscard});

  final MineSyncEntry entry;

  /// Called to discard this entry. When null, no discard action is rendered.
  final Future<void> Function()? onDiscard;

  @override
  State<SyncFailedEntryCard> createState() => _SyncFailedEntryCardState();
}

class _SyncFailedEntryCardState extends State<SyncFailedEntryCard> {
  bool _diagnosticsExpanded = false;
  bool _copied = false;
  bool _isDiscarding = false;

  String _buildDiagnosticsText(AppLocalizations l10n) {
    final details = widget.entry.errorDetails;
    final raw = widget.entry.lastError;
    final lines = <String>[
      '${l10n.mineSyncFailedDetailsEntity}: ${widget.entry.entityType}',
      '${l10n.mineSyncFailedDetailsOperation}: ${widget.entry.operation}',
      if (widget.entry.entityId != null)
        '${l10n.mineSyncFailedDetailsRecord}: ${widget.entry.entityId}',
      '${l10n.mineSyncFailedDetailsAttempts}: ${widget.entry.retryCount}/${widget.entry.maxRetry}',
      '${l10n.mineSyncFailedDetailsQueuedAt}: ${DateFormat.yMMMd(Localizations.localeOf(context).toLanguageTag()).add_Hm().format(widget.entry.createdAt.toLocal())}',
      if (details?.traceId != null && details!.traceId!.isNotEmpty)
        '${l10n.mineSyncFailedDetailsTraceId}: ${details.traceId}',
      if (details?.code != null)
        '${l10n.mineSyncFailedDetailsErrorCode}: ${details!.code}',
      if (details?.statusCode != null)
        '${l10n.mineSyncFailedDetailsHttpStatus}: ${details!.statusCode}',
      if (raw != null && raw.isNotEmpty) '\n$raw',
    ];
    return lines.join('\n');
  }

  Future<void> _copyDiagnostics(AppLocalizations l10n) async {
    final text = _buildDiagnosticsText(l10n);
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    setState(() {
      _copied = true;
    });
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() {
      _copied = false;
    });
  }

  /// Discards the entry.
  ///
  /// Discarding destroys the only copy of an unsynced local change, so the
  /// tap is not undoable. It is stated on the card's action row — next to the
  /// button, where the decision is actually made — instead of behind a
  /// confirmation dialog that every queue cleanup would have to clear.
  Future<void> _discard() async {
    final onDiscard = widget.onDiscard;
    if (onDiscard == null || _isDiscarding) return;

    setState(() {
      _isDiscarding = true;
    });
    try {
      await onDiscard();
    } finally {
      if (mounted) {
        setState(() {
          _isDiscarding = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final entry = widget.entry;
    final typography = context.theme.typography;
    final userMessage = mapSyncErrorToUserMessage(entry, l10n);
    final caption = syncEntryCaption(
      entry,
      l10n,
      Localizations.localeOf(context).toLanguageTag(),
    );
    final details = entry.errorDetails;
    final hasDiagnostics =
        details != null ||
        (entry.lastError != null && entry.lastError!.isNotEmpty);
    // Exhausted attempts are the reason nothing happens on its own anymore;
    // before that, the card is a plain failure and a count would be noise.
    final attemptsExhausted = entry.retryCount >= entry.maxRetry;

    return FCard(
      builder: (context, _, child) => Padding(
        padding: const EdgeInsets.fromLTRB(
          Spacing.xl,
          Spacing.lg,
          Spacing.lg,
          Spacing.sm,
        ),
        child: child,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                SemanticIcons.statusError,
                size: IconSizeTokens.md,
                color: SemanticColor.destructive.solid(context),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userMessage,
                      style: typography.body.sm.copyWith(
                        color: context.theme.colors.foreground,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: Spacing.xs),
                    Text(
                      l10n.mineSyncFailedDetailsRecordSummary(
                        caption.title,
                        caption.subtitle,
                      ),
                      style: typography.body.xs2.copyWith(
                        color: context.theme.colors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (attemptsExhausted || hasDiagnostics || widget.onDiscard != null)
            const SizedBox(height: Spacing.md),
          if (attemptsExhausted || hasDiagnostics || widget.onDiscard != null)
            _ActionRow(
              attemptsExhausted: attemptsExhausted,
              attemptLabel: l10n.mineSyncFailedDetailsAttemptsUsed(
                entry.retryCount,
                entry.maxRetry,
              ),
              hasDiagnostics: hasDiagnostics,
              diagnosticsExpanded: _diagnosticsExpanded,
              onToggleDiagnostics: () {
                setState(() {
                  _diagnosticsExpanded = !_diagnosticsExpanded;
                });
              },
              onDiscard: widget.onDiscard == null ? null : _discard,
              isDiscarding: _isDiscarding,
              discardLabel: l10n.mineSyncFailedDetailsDiscard,
            ),
          if (hasDiagnostics && _diagnosticsExpanded) ...[
            const SizedBox(height: Spacing.md),
            _DiagnosticsPanel(
              copied: _copied,
              onCopy: () => _copyDiagnostics(l10n),
              details: details,
              raw: entry.lastError,
              entityType: entry.entityType,
              operation: entry.operation,
              entityId: entry.entityId,
              attempts: '${entry.retryCount}/${entry.maxRetry}',
              queuedAt: DateFormat.yMMMd(
                Localizations.localeOf(context).toLanguageTag(),
              ).add_Hm().format(entry.createdAt.toLocal()),
            ),
          ],
        ],
      ),
    );
  }
}

/// The card's footer: the quiet advisory on the left, the actions on the
/// right.
///
/// Kept as one row so the two controls that act on a single entry sit at its
/// end, and so the primary-looking affordance stays the page's "retry all" —
/// neither per-entry action is a candidate for the strongest emphasis.
class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.attemptsExhausted,
    required this.attemptLabel,
    required this.hasDiagnostics,
    required this.diagnosticsExpanded,
    required this.onToggleDiagnostics,
    required this.onDiscard,
    required this.isDiscarding,
    required this.discardLabel,
  });

  final bool attemptsExhausted;
  final String attemptLabel;
  final bool hasDiagnostics;
  final bool diagnosticsExpanded;
  final VoidCallback onToggleDiagnostics;
  final Future<void> Function()? onDiscard;
  final bool isDiscarding;
  final String discardLabel;

  @override
  Widget build(BuildContext context) {
    final typography = context.theme.typography;
    final muted = typography.body.xs2.copyWith(
      color: context.theme.colors.mutedForeground,
    );

    return Row(
      children: [
        Expanded(
          child: attemptsExhausted
              ? Text(attemptLabel, style: muted)
              : const SizedBox.shrink(),
        ),
        if (hasDiagnostics)
          FButton.icon(
            key: const Key('sync-failed-entry-diagnostics'),
            variant: FButtonVariant.ghost,
            size: FButtonSizeVariant.xs,
            onPress: onToggleDiagnostics,
            child: AnimatedRotation(
              turns: diagnosticsExpanded ? 0.5 : 0,
              duration: DurationTokens.widgetQuick,
              curve: MotionTokens.standard,
              child: const Icon(
                SemanticIcons.actionExpand,
                size: IconSizeTokens.sm,
              ),
            ),
          ),
        if (onDiscard != null) ...[
          const SizedBox(width: Spacing.xs),
          FButton(
            key: const Key('sync-failed-entry-discard'),
            variant: FButtonVariant.ghost,
            size: FButtonSizeVariant.sm,
            onPress: isDiscarding ? null : onDiscard,
            child: isDiscarding
                ? const SizedBox(
                    width: IconSizeTokens.sm,
                    height: IconSizeTokens.sm,
                    child: FCircularProgress(),
                  )
                : Text(
                    discardLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
          ),
        ],
      ],
    );
  }
}

/// Everything the user cannot act on, behind one disclosure: wire identity,
/// attempt history, trace fields and the raw exception.
class _DiagnosticsPanel extends StatelessWidget {
  const _DiagnosticsPanel({
    required this.copied,
    required this.onCopy,
    required this.entityType,
    required this.operation,
    required this.entityId,
    required this.attempts,
    required this.queuedAt,
    this.details,
    this.raw,
  });

  final bool copied;
  final VoidCallback onCopy;
  final String entityType;
  final String operation;
  final String? entityId;
  final String attempts;
  final String queuedAt;
  final MineSyncErrorDetails? details;
  final String? raw;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.theme.colors;
    final typography = context.theme.typography;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Spacing.lg),
      decoration: BoxDecoration(
        color: colors.secondary,
        borderRadius: context.theme.style.borderRadius.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DetailRow(
            label: l10n.mineSyncFailedDetailsEntity,
            value: entityType,
          ),
          _DetailRow(
            label: l10n.mineSyncFailedDetailsOperation,
            value: operation,
          ),
          if (entityId != null)
            _DetailRow(
              label: l10n.mineSyncFailedDetailsRecord,
              value: entityId!,
            ),
          _DetailRow(
            label: l10n.mineSyncFailedDetailsAttempts,
            value: attempts,
          ),
          _DetailRow(
            label: l10n.mineSyncFailedDetailsQueuedAt,
            value: queuedAt,
          ),
          if (details?.traceId != null && details!.traceId!.isNotEmpty) ...[
            _DetailRow(
              label: l10n.mineSyncFailedDetailsTraceId,
              value: details!.traceId!,
            ),
          ],
          if (details?.code != null) ...[
            _DetailRow(
              label: l10n.mineSyncFailedDetailsErrorCode,
              value: details!.code!.toString(),
            ),
          ],
          if (details?.statusCode != null) ...[
            _DetailRow(
              label: l10n.mineSyncFailedDetailsHttpStatus,
              value: details!.statusCode!.toString(),
            ),
          ],
          if (raw != null && raw!.isNotEmpty) ...[
            const SizedBox(height: Spacing.sm),
            SelectableText(
              raw!,
              style: typography.body.xs2.copyWith(
                color: colors.mutedForeground,
              ),
            ),
          ],
          const SizedBox(height: Spacing.md),
          FButton(
            variant: FButtonVariant.ghost,
            size: FButtonSizeVariant.xs,
            onPress: onCopy,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(SemanticIcons.actionCopy, size: IconSizeTokens.sm),
                const SizedBox(width: Spacing.sm),
                Text(
                  copied
                      ? l10n.mineSyncFailedDetailsDiagnosticsCopied
                      : l10n.mineSyncFailedDetailsCopyDiagnostics,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final typography = context.theme.typography;
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 88,
            child: Text(
              label,
              style: typography.body.xs2.copyWith(
                color: context.theme.colors.mutedForeground,
              ),
            ),
          ),
          Expanded(child: Text(value, style: typography.body.xs)),
        ],
      ),
    );
  }
}
