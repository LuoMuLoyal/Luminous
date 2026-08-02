import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:intl/intl.dart';
import 'package:luminous/core/database/connection_providers.dart';
import 'package:luminous/core/database/daos/pending_sync_dao.dart';
import 'package:luminous/core/database/sync/worker.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/dialog_shell.dart';
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
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isRetrying = false;
        _retryError = AppLocalizations.of(
          context,
        )!.mineSyncFailedDetailsRetryFailed;
      });
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
          style: TypographyToken.level6.body(context),
        ),
        const SizedBox(height: Spacing.level2),
        Text(
          l10n.mineSyncFailedDetailsDescription,
          style: TypographyToken.level3
              .body(context)
              .copyWith(color: context.theme.colors.mutedForeground),
        ),
        const SizedBox(height: Spacing.level4),
        if (widget.entries.isEmpty)
          Text(
            l10n.mineSyncFailedDetailsEmpty,
            style: TypographyToken.level4.body(context),
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
            style: TypographyToken.level3
                .body(context)
                .copyWith(color: SemanticColor.destructive.solid(context)),
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

class _SyncFailedEntryCard extends StatelessWidget {
  const _SyncFailedEntryCard({required this.entry});

  final PendingSyncEntry entry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.theme.colors;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final queuedAt = DateFormat.yMMMd(
      locale,
    ).add_Hm().format(entry.createdAt.toLocal());

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Spacing.level4),
      decoration: BoxDecoration(
        color: colors.muted,
        borderRadius: BorderRadius.circular(RadiusTokens.level3),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DetailRow(
            label: l10n.mineSyncFailedDetailsEntity,
            value: entry.entityType,
          ),
          _DetailRow(
            label: l10n.mineSyncFailedDetailsOperation,
            value: entry.operation,
          ),
          if (entry.entityId != null)
            _DetailRow(
              label: l10n.mineSyncFailedDetailsRecord,
              value: entry.entityId!,
            ),
          _DetailRow(
            label: l10n.mineSyncFailedDetailsAttempts,
            value: '${entry.retryCount}/${entry.maxRetry}',
          ),
          _DetailRow(
            label: l10n.mineSyncFailedDetailsQueuedAt,
            value: queuedAt,
          ),
          if (entry.lastError != null && entry.lastError!.isNotEmpty) ...[
            const SizedBox(height: Spacing.level2),
            Text(
              l10n.mineSyncFailedDetailsLastError,
              style: TypographyToken.level2
                  .body(context)
                  .copyWith(color: colors.mutedForeground),
            ),
            const SizedBox(height: Spacing.level1),
            SelectableText(
              entry.lastError!,
              style: TypographyToken.level3.body(context),
            ),
          ],
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
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.level1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Text(
              label,
              style: TypographyToken.level2
                  .body(context)
                  .copyWith(color: context.theme.colors.mutedForeground),
            ),
          ),
          Expanded(
            child: Text(value, style: TypographyToken.level3.body(context)),
          ),
        ],
      ),
    );
  }
}
