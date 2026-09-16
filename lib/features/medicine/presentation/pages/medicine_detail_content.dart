import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/errors/user_message.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/logger/log_level.dart';
import 'package:luminous/core/providers/data_change_bus.dart';
import 'package:luminous/core/widgets/auth/required_dialog.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/core/widgets/layout/responsive_content_frame.dart';
import 'package:luminous/features/health_context/data/providers/health_context.dart';
import 'package:luminous/features/health_context/domain/entities/write_inputs.dart';
import 'package:luminous/features/medicine/domain/entities/medicine_detail.dart';
import 'package:luminous/features/medicine/presentation/pages/detail_section_view.dart';
import 'package:luminous/features/medicine/presentation/pages/detail_sections.dart';
import 'package:luminous/features/medicine/presentation/pages/medicine_detail_shared.dart';
import 'package:luminous/features/medicine/presentation/routes.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Core content widget for medicine detail page.
class MedicineDetailContent extends ConsumerStatefulWidget {
  const MedicineDetailContent({
    super.key,
    required this.detail,
    required this.source,
  });

  final MedicineDetail detail;
  final String source;

  @override
  ConsumerState<MedicineDetailContent> createState() =>
      _MedicineDetailContentState();
}

class _MedicineDetailContentState extends ConsumerState<MedicineDetailContent> {
  /// Accordion items the user has opened.
  ///
  /// Lifted out of the accordion because a collapsed item's child is still
  /// built — without this, the sequence section would fire its request on page
  /// load instead of on demand.
  ///
  /// Held in a notifier rather than widget state on purpose: rebuilding the
  /// accordion on every toggle makes Forui re-run each item's
  /// `didChangeDependencies`, which resets the item to `initiallyExpanded` and
  /// collapses the section the user just opened. Only the sequence child
  /// listens, so the accordion itself is never rebuilt.
  final ValueNotifier<Set<int>> _expandedSections = ValueNotifier(const {});

  late final FAccordionControl _accordionControl;

  @override
  void initState() {
    super.initState();
    // Created once (not per build) so the accordion keeps its expanded state
    // across rebuilds.
    _accordionControl = FAccordionManagedControl(
      onChange: (expanded) => _expandedSections.value = expanded,
    );
  }

  @override
  void dispose() {
    _expandedSections.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final detail = widget.detail;
    final source = widget.source;
    final l10n = AppLocalizations.of(context)!;

    final snapshotAsync = ref.watch(healthContextSnapshotProvider);
    // Extract the current-medicine record for this medicine (if any) so we
    // can both check membership and navigate to the reminder detail page.
    final currentMedicine = snapshotAsync.maybeWhen(
      data: (snapshot) {
        for (final m in snapshot.currentMedicines) {
          if (m.isCurrent && m.sourceRefId == detail.id && m.source == source) {
            return m;
          }
        }
        return null;
      },
      orElse: () => null,
    );
    final isAdded = currentMedicine != null;

    final sections = MedicineDetailSections(detail, l10n).build();

    return ResponsiveContentFrame(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.lg,
            vertical: Spacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              HeaderCard(detail: detail, source: source),
              const SizedBox(height: Spacing.lg),
              ReferenceNotice(l10n: l10n),
              const SizedBox(height: Spacing.xs),
              RiskCheckEntry(
                l10n: l10n,
                onTap: () => const MedicineRiskCheckRoute().push(context),
              ),
              const SizedBox(height: Spacing.lg),
              if (sections.isNotEmpty)
                FAccordion(
                  control: _accordionControl,
                  children: [
                    for (var index = 0; index < sections.length; index += 1)
                      FAccordionItem(
                        title: _SectionHeader(section: sections[index]),
                        // Only the highest-frequency section opens by default;
                        // everything below is opt-in so the page stays short.
                        initiallyExpanded: sections[index].tier == Tier.primary,
                        child: _SectionBody(
                          section: sections[index],
                          l10n: l10n,
                          index: index,
                          expandedSections: _expandedSections,
                          medicineId: detail.id,
                          source: source,
                        ),
                      ),
                  ],
                )
              else
                StateMessageView(
                  title: l10n.medicineDetailNoContentTitle,
                  icon: SemanticIcons.statusInfo,
                ),
              const SizedBox(height: Spacing.lg),
              FButton(
                onPress: isAdded
                    ? null
                    : () => _addToCurrentMedicines(ref, context, l10n),
                variant: isAdded
                    ? FButtonVariant.outline
                    : FButtonVariant.primary,
                child: Text(
                  isAdded
                      ? l10n.medicineSearchAlreadyAddedLabel
                      : l10n.medicineSearchAddToBoxAction,
                ),
              ),
              if (isAdded) ...[
                const SizedBox(height: Spacing.sm),
                FButton(
                  variant: FButtonVariant.outline,
                  onPress: () => MedicineReminderDetailRoute(
                    medicineId: currentMedicine.id,
                  ).push(context),
                  child: Text(l10n.medicineDetailOpenReminderAction),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addToCurrentMedicines(
    WidgetRef ref,
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    final authSession = ref.read(authSessionProvider);
    if (!authSession.canAccessProtectedData) {
      if (authSession.isLoading) return;
      if (context.mounted) {
        await showAuthRequiredDialog(
          context,
          onLogin: () => context.push(loginRouteForCurrentLocation(context)),
        );
      }
      return;
    }

    final repository = ref.read(healthContextRepositoryProvider);
    final medicineSource = widget.source == 'drugbank'
        ? HealthMedicineSource.drugbank
        : HealthMedicineSource.cn;

    final input = CurrentMedicineWriteInput(
      source: medicineSource,
      sourceRefId: widget.detail.id,
      displayName: widget.detail.name,
    );

    try {
      final result = await repository.createCurrentMedicine(input).run();
      final updatedSnapshot = result.fold(
        (failure) => throw failure,
        (snapshot) => snapshot,
      );
      ref
          .read(dataChangeBusProvider.notifier)
          .emit(DataChangeTopic.currentMedicines);

      if (context.mounted) {
        final newMedicine = updatedSnapshot.currentMedicines.firstWhereOrNull(
          (m) =>
              m.sourceRefId == widget.detail.id &&
              m.source == medicineSource.name,
        );
        if (newMedicine == null) return;
        unawaited(
          Toast.showWithAction(
            context,
            l10n.medicineSearchAddedToBoxToast,
            l10n.medicineSearchGoToReminderAction,
            // The toast action fires on a later user tap; the page may have
            // been popped in between, so guard the push (deactivated context
            // would trip the `_dependents.isEmpty` assertion).
            () {
              if (!context.mounted) return;
              unawaited(
                MedicineRemindersNewRoute(
                  medicineId: newMedicine.id,
                ).push(context),
              );
            },
          ),
        );
      }
    } catch (e) {
      ref
          .read(talkerProvider)
          .error('MedicineDetailContent._addToCurrentMedicines: failed: $e');
      if (context.mounted) {
        unawaited(
          Toast.show(
            context,
            userMessageFromError(
              e,
              fallback: l10n.medicineSearchPrecheckFailedToast,
              l10n: l10n,
            ),
          ),
        );
      }
    }
  }
}

/// Renders one accordion body.
///
/// Only sections that fetch their own data (sequences) subscribe to the
/// expanded-set notifier; every other section renders straight through so a
/// long page is not rebuilt on each toggle.
class _SectionBody extends StatelessWidget {
  const _SectionBody({
    required this.section,
    required this.l10n,
    required this.index,
    required this.expandedSections,
    required this.medicineId,
    required this.source,
  });

  final MedicineDetailSection section;
  final AppLocalizations l10n;
  final int index;
  final ValueNotifier<Set<int>> expandedSections;
  final String medicineId;
  final String source;

  @override
  Widget build(BuildContext context) {
    if (section.body is! SequencesSectionBody) {
      return DetailSectionView(section: section, l10n: l10n);
    }

    return ValueListenableBuilder<Set<int>>(
      valueListenable: expandedSections,
      builder: (context, expanded, _) => DetailSectionView(
        section: section,
        l10n: l10n,
        shouldLoad: expanded.contains(index),
        medicineId: medicineId,
        source: source,
      ),
    );
  }
}

/// Accordion header showing the section title plus, when the payload has more
/// than one entry, a count badge so the user can judge whether to expand.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.section});

  final MedicineDetailSection section;

  @override
  Widget build(BuildContext context) {
    final count = section.count;
    if (count == null) {
      return Text(section.title);
    }

    return Row(
      children: [
        Expanded(child: Text(section.title)),
        const SizedBox(width: Spacing.xs),
        FBadge(variant: FBadgeVariant.secondary, child: Text('$count')),
      ],
    );
  }
}

/// Header card widget displaying medicine name, source badge, and metadata rows.
class HeaderCard extends StatelessWidget {
  const HeaderCard({super.key, required this.detail, required this.source});

  final MedicineDetail detail;
  final String source;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final typography = context.theme.typography;

    return FCard(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    detail.name,
                    style: typography.body.lg.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: Spacing.sm),
                SourceBadge(source: source, l10n: l10n),
              ],
            ),
            if (detail.subtitle != null) ...[
              const SizedBox(height: Spacing.sm),
              Text(
                detail.subtitle!,
                style: typography.body.xs.copyWith(
                  color: SemanticColor.neutral.solid(context),
                ),
              ),
            ],
            if (source == 'cn') ...[
              const SizedBox(height: Spacing.sm),
              if (detail.approvalNumber != null)
                MetaRow(
                  label: l10n.medicineDetailApprovalNumber,
                  value: detail.approvalNumber!,
                ),
              if (detail.manufacturer != null)
                MetaRow(
                  label: l10n.medicineDetailManufacturer,
                  value: detail.manufacturer!,
                ),
              if (detail.packageSpec != null)
                MetaRow(
                  label: l10n.medicineDetailPackageSpec,
                  value: detail.packageSpec!,
                ),
              if (detail.brandName != null)
                MetaRow(
                  label: l10n.medicineDetailBrandName,
                  value: detail.brandName!,
                ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Metadata row widget displaying label and value.
class MetaRow extends StatelessWidget {
  const MetaRow({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final typography = context.theme.typography;
    return Padding(
      padding: const EdgeInsets.only(top: Spacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: Spacing.xl4,
            child: Text(
              label,
              style: typography.body.xs.copyWith(
                color: SemanticColor.neutral.solid(context),
              ),
            ),
          ),
          const SizedBox(width: Spacing.md),
          Expanded(child: Text(value, style: typography.body.xs)),
        ],
      ),
    );
  }
}
