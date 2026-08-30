import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:intl/intl.dart';
import 'package:luminous/core/database/connection_providers.dart';
import 'package:luminous/core/database/daos/pending_sync_dao.dart';
import 'package:luminous/core/database/models/pending_sync_error_details.dart';
import 'package:luminous/core/database/sync/worker.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/logger/logger.dart';
import 'package:luminous/core/widgets/common/dialog_shell.dart';
import 'package:luminous/features/mine/presentation/mappers/sync_error_user_message.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Opens the user-facing details for permanently failed local sync items.
Future<void> showMineSyncFailedDetailsDialog({
  required BuildContext context,
  required List<PendingSyncEntry> entries,
}) async {
  await showAppDialog<void>(
    context: context,
    maxHeight: MediaQuery.sizeOf(context).height - Spacing.level8,
    scrollable: true,
    builder: (_) => _SyncFailedDetailsContent(entries: entries),
  );
}

class _SyncFailedDetailsContent extends ConsumerStatefulWidget {
  const _SyncFailedDetailsContent({required this.entries});

  final List<PendingSyncEntry> entries;

  @override
  ConsumerState<_SyncFailedDetailsContent> createState() =>
      _SyncFailedDetailsContentState();
}

class _SyncFailedDetailsContentState
    extends ConsumerState<_SyncFailedDetailsContent> {
  bool _isRetrying = false;
  String? _retryError;

  Future<void> _retryAll() async {
    if (_isRetrying) return;

    setState(() {
      _isRetrying = true;
      _retryError = null;
    });

    try {
      final dao = ref.read(pendingSyncDaoProvider);
      await Future.wait(
        widget.entries.map((entry) => dao.resetForRetry(entry.id)),
      );
      await ref.read(syncWorkerProvider).flush();
      ref.invalidate(syncFailedCountProvider);
      if (mounted) Navigator.of(context).pop();
    } catch (e, st) {
      // Log the real failure (DB corruption, disk full, ...) so it is not
      // silently swallowed — talker forwards it to Sentry in release builds.
      ref.read(talkerProvider).error('MineSyncFailedDetails._retryAll: $e', st);
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

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.mineSyncFailedDetailsTitle,
          style: context.theme.typography.body.lg,
        ),
        const SizedBox(height: Spacing.level2),
        Text(
          l10n.mineSyncFailedDetailsDescription,
          style: context.theme.typography.body.xs.copyWith(
            color: context.theme.colors.mutedForeground,
          ),
        ),
        const SizedBox(height: Spacing.level4),
        if (widget.entries.isEmpty)
          Text(
            l10n.mineSyncFailedDetailsEmpty,
            style: context.theme.typography.body.sm,
          )
        else
          for (final entry in widget.entries) ...[
            _SyncFailedEntryCard(entry: entry),
            if (entry != widget.entries.last)
              const SizedBox(height: Spacing.level3),
          ],
        if (_retryError != null) ...[
          const SizedBox(height: Spacing.level3),
          Text(
            _retryError!,
            style: context.theme.typography.body.xs.copyWith(
              color: SemanticColor.destructive.solid(context),
            ),
          ),
        ],
        const SizedBox(height: Spacing.level5),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FButton(
              variant: FButtonVariant.ghost,
              onPress: _isRetrying ? null : () => Navigator.of(context).pop(),
              child: Text(l10n.commonCancel),
            ),
            if (widget.entries.isNotEmpty) ...[
              const SizedBox(width: Spacing.level3),
              FButton(
                onPress: _isRetrying ? null : _retryAll,
                child: _isRetrying
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: FCircularProgress(),
                          ),
                          const SizedBox(width: Spacing.level2),
                          Text(l10n.mineSyncFailedDetailsRetrying),
                        ],
                      )
                    : Text(l10n.mineSyncFailedDetailsRetryAll),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _SyncFailedEntryCard extends StatefulWidget {
  const _SyncFailedEntryCard({required this.entry});

  final PendingSyncEntry entry;

  @override
  State<_SyncFailedEntryCard> createState() => _SyncFailedEntryCardState();
}

class _SyncFailedEntryCardState extends State<_SyncFailedEntryCard> {
  bool _diagnosticsExpanded = false;
  bool _copied = false;

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

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Spacing.level4),
      decoration: BoxDecoration(
        color: colors.muted,
        borderRadius: context.theme.style.borderRadius.sm,
        border: Border.all(color: colors.border),
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
          const SizedBox(height: Spacing.level2),
          Text(
            l10n.mineSyncFailedDetailsLastError,
            style: context.theme.typography.body.xs2.copyWith(
              color: colors.mutedForeground,
            ),
          ),
          const SizedBox(height: Spacing.level1),
          Text(
            userMessage,
            style: context.theme.typography.body.xs.copyWith(
              color: SemanticColor.destructive.solid(context),
            ),
          ),
          if (hasDiagnostics) ...[
            const SizedBox(height: Spacing.level2),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onToggle,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: Spacing.level2),
            child: Row(
              children: [
                Icon(
                  expanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 18,
                  color: colors.mutedForeground,
                ),
                const SizedBox(width: Spacing.level1),
                Text(
                  l10n.mineSyncFailedDetailsDiagnostics,
                  style: context.theme.typography.body.xs.copyWith(
                    color: colors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (expanded) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(Spacing.level3),
            decoration: BoxDecoration(
              color: colors.background,
              borderRadius: context.theme.style.borderRadius.xs,
              border: Border.all(color: colors.border),
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
                  const SizedBox(height: Spacing.level2),
                  SelectableText(
                    raw!,
                    style: context.theme.typography.body.xs2,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: Spacing.level2),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.level1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Text(
              label,
              style: context.theme.typography.body.xs2.copyWith(
                color: context.theme.colors.mutedForeground,
              ),
            ),
          ),
          Expanded(child: Text(value, style: context.theme.typography.body.xs)),
        ],
      ),
    );
  }
}
