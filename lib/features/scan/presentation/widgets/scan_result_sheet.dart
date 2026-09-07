import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/control/divider.dart';
import 'package:luminous/features/health_context/data/providers/health_context.dart';
import 'package:luminous/features/health_context/domain/entities/snapshot.dart';
import 'package:luminous/features/scan/domain/entities/scan_result.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Bottom sheet content for a scanned medicine result (F-3).
///
/// The「已加入」state is derived **live** from [healthContextSnapshotProvider]
/// (matched by the `source:sourceRefId` key `cn:<产品id>`), not captured at
/// sheet open (F-3 P2-1): after a successful add the shared F-9 loop emits on
/// the DataChangeBus, the snapshot refreshes and this sheet rebuilds into the
/// added state — the add button cannot be tapped again to duplicate the
/// record. Loading / error states fall back to an empty map (default "not
/// added" exit); once the snapshot resolves the state is correct.
class BarcodeScanResultSheet extends ConsumerStatefulWidget {
  const BarcodeScanResultSheet({
    super.key,
    required this.item,
    required this.l10n,
    required this.onAddToBox,
    required this.onViewInstructions,
    required this.onOpenReminder,
  });

  final ScanSearchResult item;
  final AppLocalizations l10n;
  final Future<void> Function() onAddToBox;
  final VoidCallback onViewInstructions;

  /// Called with the matched drugbox record when the user opens the reminder
  /// detail from the added state (the sheet pops itself first).
  final ValueChanged<CurrentMedicineItem> onOpenReminder;

  @override
  ConsumerState<BarcodeScanResultSheet> createState() =>
      BarcodeScanResultSheetState();
}

class BarcodeScanResultSheetState
    extends ConsumerState<BarcodeScanResultSheet> {
  /// True while「加入药箱」is in flight. The button stays disabled from the
  /// tap until the awaited flow returns (and longer: while the snapshot is
  /// re-fetching, see the loading guard in [build]), so the sheet can never
  /// re-add a medicine that was just added (P2 复审 P2-1/P2-4).
  bool _addingBox = false;

  /// Drugbox lookup by `source:sourceRefId` (drugbox record id as value),
  /// derived from the live snapshot watched in [build].
  Map<String, CurrentMedicineItem> _boxByKeyFrom(
    AsyncValue<HealthContextSnapshot> snapshotAsync,
  ) => snapshotAsync.maybeWhen(
    data: (snapshot) => {
      for (final medicine in snapshot.currentMedicines)
        if (medicine.isCurrent && medicine.sourceRefId != null)
          '${medicine.source}:${medicine.sourceRefId}': medicine,
    },
    orElse: () => const <String, CurrentMedicineItem>{},
  );

  Future<void> _handleAddToBox() async {
    setState(() => _addingBox = true);
    try {
      await widget.onAddToBox();
    } finally {
      if (mounted) setState(() => _addingBox = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final typography = context.theme.typography;
    // While the snapshot is (re)fetching, `boxByKey` is empty; the loading
    // guard below keeps the add button disabled so the sheet cannot offer a
    // duplicate add for a medicine that was just added.
    final snapshotAsync = ref.watch(healthContextSnapshotProvider);
    final boxByKey = _boxByKeyFrom(snapshotAsync);
    // The loading guard applies to signed-in users only: signed-out
    // snapshots stay in a loading-with-error state (AuthRequiredException),
    // where the add button must stay tappable to reach the login prompt.
    final authSession = ref.watch(authSessionProvider);
    final snapshotLoading =
        snapshotAsync.isLoading && authSession.canAccessProtectedData;
    final boxItem = boxByKey['cn:${widget.item.id}'];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(Spacing.level4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.l10n.scanBarcodeResultTitle,
                  style: typography.body.lg.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              FButton.icon(
                variant: FButtonVariant.ghost,
                size: FButtonSizeVariant.sm,
                onPress: () => Navigator.pop(context),
                child: const Icon(
                  SemanticIcons.actionClose,
                  size: IconSizeTokens.level3,
                ),
              ),
            ],
          ),
        ),
        const AppDivider(),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.level5,
            vertical: Spacing.level4,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.item.name, style: typography.body.lg),
              if (widget.item.subtitle != null) ...[
                const SizedBox(height: Spacing.level2),
                Text(
                  widget.item.subtitle!,
                  style: typography.body.sm.copyWith(
                    color: SemanticColor.neutral.solid(context),
                  ),
                ),
              ],
            ],
          ),
        ),
        const AppDivider(),
        Padding(
          padding: EdgeInsets.fromLTRB(
            Spacing.level5,
            Spacing.level4,
            Spacing.level5,
            MediaQuery.paddingOf(context).bottom + Spacing.level4,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (boxItem != null) ...[
                // Reuses the search tile "already added" visual pattern
                // (disabled outline button + check icon).
                FButton(
                  onPress: null,
                  variant: FButtonVariant.outline,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        SemanticIcons.statusDone,
                        size: IconSizeTokens.level2,
                        color: SemanticColor.primary.solid(context),
                      ),
                      const SizedBox(width: Spacing.level2),
                      Text(widget.l10n.medicineSearchAlreadyAddedLabel),
                    ],
                  ),
                ),
                const SizedBox(height: Spacing.level3),
                FButton(
                  onPress: () => widget.onOpenReminder(boxItem),
                  child: Text(widget.l10n.scanViewReminderAction),
                ),
              ] else ...[
                FButton(
                  // Disabled while an add is in flight and while the snapshot
                  // is (re)fetching (P2 复审 P2-1/P2-4) — a rapid second tap
                  // cannot duplicate the record, and a just-added medicine is
                  // not re-addable in the refresh window.
                  onPress: _addingBox || snapshotLoading
                      ? null
                      : _handleAddToBox,
                  child: Text(widget.l10n.medicineSearchAddToBoxAction),
                ),
              ],
              const SizedBox(height: Spacing.level3),
              FButton(
                variant: FButtonVariant.secondary,
                onPress: widget.onViewInstructions,
                child: Text(widget.l10n.scanViewInstructionsAction),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
