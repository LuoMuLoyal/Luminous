import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:intl/intl.dart';
import 'package:luminous/core/database/daos/pending_sync.dart';
import 'package:luminous/core/database/models/pending_sync_error_details.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/dialog/dialog_shell.dart';
import 'package:luminous/features/mine/presentation/mappers/sync_error_user_message.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// One permanently failed sync item, rendered as a self-contained panel.
///
/// The user-facing message is shown first; the raw exception and the
/// structured trace fields stay behind the collapsed diagnostics section.
///
/// [onDiscard] removes the item from the local queue. It is offered because a
/// permanent failure is not necessarily retryable: when the server keeps
/// rejecting the payload's identity, replaying it byte-identically will never
/// succeed, so the user needs a way to clear the entry rather than watch it
/// sit in the queue forever.
class SyncFailedEntryCard extends StatefulWidget {
  const SyncFailedEntryCard({super.key, required this.entry, this.onDiscard});

  final PendingSyncEntry entry;

  /// Called after the user confirms discarding this entry. When null, no
  /// discard action is rendered.
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

  /// Confirms and performs the discard. Discarding destroys the only copy of
  /// an unsynced local change, so it is gated behind an explicit confirmation
  /// and reports failures inline rather than pretending the entry is gone.
  Future<void> _discard() async {
    final onDiscard = widget.onDiscard;
    if (onDiscard == null || _isDiscarding) return;

    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDangerConfirmationDialog(
      context: context,
      title: l10n.mineSyncFailedDetailsDiscardTitle,
      message: l10n.mineSyncFailedDetailsDiscardDescription,
      confirmLabel: l10n.mineSyncFailedDetailsDiscardConfirm,
    );
    if (!confirmed || !mounted) return;

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
    final colors = context.theme.colors;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final queuedAt = DateFormat.yMMMd(
      locale,
    ).add_Hm().format(widget.entry.createdAt.toLocal());
    final userMessage = mapSyncErrorToUserMessage(widget.entry, l10n);
    final details = widget.entry.errorDetails;
    final hasDiagnostics =
        details != null ||
        (widget.entry.lastError != null && widget.entry.lastError!.isNotEmpty);
    final typography = context.theme.typography;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Spacing.lg),
      decoration: BoxDecoration(
        color: colors.muted,
        borderRadius: context.theme.style.borderRadius.sm,
        border: Border.all(color: SemanticColor.neutral.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DetailRow(
            label: l10n.mineSyncFailedDetailsEntity,
            value: widget.entry.entityType,
          ),
          _DetailRow(
            label: l10n.mineSyncFailedDetailsOperation,
            value: widget.entry.operation,
          ),
          if (widget.entry.entityId != null)
            _DetailRow(
              label: l10n.mineSyncFailedDetailsRecord,
              value: widget.entry.entityId!,
            ),
          _DetailRow(
            label: l10n.mineSyncFailedDetailsAttempts,
            value: '${widget.entry.retryCount}/${widget.entry.maxRetry}',
          ),
          _DetailRow(
            label: l10n.mineSyncFailedDetailsQueuedAt,
            value: queuedAt,
          ),
          const SizedBox(height: Spacing.sm),
          Text(
            l10n.mineSyncFailedDetailsLastError,
            style: typography.body.xs2.copyWith(
              color: SemanticColor.neutral.solid(context),
            ),
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            userMessage,
            style: typography.body.xs.copyWith(
              color: SemanticColor.destructive.solid(context),
            ),
          ),
          if (hasDiagnostics) ...[
            const SizedBox(height: Spacing.sm),
            _DiagnosticsPanel(
              expanded: _diagnosticsExpanded,
              copied: _copied,
              onToggle: () {
                setState(() {
                  _diagnosticsExpanded = !_diagnosticsExpanded;
                });
              },
              onCopy: () => _copyDiagnostics(l10n),
              details: details,
              raw: widget.entry.lastError,
            ),
          ],
          if (widget.onDiscard != null) ...[
            const SizedBox(height: Spacing.md),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: FButton(
                key: const Key('sync-failed-entry-discard'),
                variant: FButtonVariant.outline,
                size: FButtonSizeVariant.sm,
                onPress: _isDiscarding ? null : _discard,
                child: _isDiscarding
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: FCircularProgress(),
                      )
                    : Text(l10n.mineSyncFailedDetailsDiscard),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DiagnosticsPanel extends StatelessWidget {
  const _DiagnosticsPanel({
    required this.expanded,
    required this.copied,
    required this.onToggle,
    required this.onCopy,
    this.details,
    this.raw,
  });

  final bool expanded;
  final bool copied;
  final VoidCallback onToggle;
  final VoidCallback onCopy;
  final PendingSyncErrorDetails? details;
  final String? raw;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.theme.colors;
    final typography = context.theme.typography;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onToggle,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
            child: Row(
              children: [
                Icon(
                  expanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 18,
                  color: SemanticColor.neutral.solid(context),
                ),
                const SizedBox(width: Spacing.xs),
                Text(
                  l10n.mineSyncFailedDetailsDiagnostics,
                  style: typography.body.xs.copyWith(
                    color: SemanticColor.neutral.solid(context),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (expanded) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(Spacing.md),
            decoration: BoxDecoration(
              color: colors.background,
              borderRadius: context.theme.style.borderRadius.xs,
              border: Border.all(color: SemanticColor.neutral.border(context)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (details?.traceId != null &&
                    details!.traceId!.isNotEmpty) ...[
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
                  SelectableText(raw!, style: typography.body.xs2),
                ],
              ],
            ),
          ),
          const SizedBox(height: Spacing.sm),
          FButton(
            variant: FButtonVariant.outline,
            size: FButtonSizeVariant.sm,
            onPress: onCopy,
            child: Text(
              copied
                  ? l10n.mineSyncFailedDetailsDiagnosticsCopied
                  : l10n.mineSyncFailedDetailsCopyDiagnostics,
            ),
          ),
        ],
      ],
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
            width: 92,
            child: Text(
              label,
              style: typography.body.xs2.copyWith(
                color: SemanticColor.neutral.solid(context),
              ),
            ),
          ),
          Expanded(child: Text(value, style: typography.body.xs)),
        ],
      ),
    );
  }
}
