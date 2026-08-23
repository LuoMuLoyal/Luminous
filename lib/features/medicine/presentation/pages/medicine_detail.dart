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
import 'package:luminous/core/logger/logger.dart';
import 'package:luminous/core/providers/data_change_bus.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/core/widgets/layout/page_scaffold.dart';
import 'package:luminous/core/widgets/layout/responsive_content_frame.dart';
import 'package:luminous/features/auth/presentation/widgets/shared/required_dialog.dart';
import 'package:luminous/features/health_context/data/providers/health_context.dart';
import 'package:luminous/features/health_context/domain/entities/write_inputs.dart';
import 'package:luminous/features/medicine/domain/entities/medicine_detail.dart';
import 'package:luminous/features/medicine/presentation/providers/medicine_detail.dart';
import 'package:luminous/features/medicine/presentation/routes.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Mobile medication knowledge detail page (F-14).
///
/// Renders the package-insert / DrugBank sections for a medicine identified by
/// [source] (`cn` | `drugbank`) and [id], plus an "add to drugbox" action and
/// a risk-check entry.
class MedicineDetailPage extends ConsumerWidget {
  const MedicineDetailPage({super.key, required this.source, required this.id});

  final String source;
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    if (source != 'cn' && source != 'drugbank') {
      return PageScaffold(
        title: l10n.medicineDetailPageTitle,
        child: StateErrorView(
          title: l10n.medicineDetailUnknownSourceTitle,
          description: '',
          icon: SemanticIcons.statusError,
        ),
      );
    }

    final detailAsync = ref.watch(medicineDetailProvider(source, id));

    return PageScaffold(
      title: l10n.medicineDetailPageTitle,
      child: detailAsync.when(
        data: (detail) =>
            _MedicineDetailContent(detail: detail, source: source),
        loading: () => const _MedicineDetailLoading(),
        error: (_, __) => StateErrorView(
          title: l10n.medicineDetailErrorTitle,
          description: l10n.medicineDetailErrorDescription,
          icon: SemanticIcons.statusError,
          actionLabel: l10n.todayRetryAction,
          onAction: () => ref.invalidate(medicineDetailProvider(source, id)),
        ),
      ),
    );
  }
}

class _MedicineDetailLoading extends StatelessWidget {
  const _MedicineDetailLoading();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.level4,
        vertical: Spacing.level4,
      ),
      child: InlineSkeletonSection(
        children: [
          InlineSkeletonBlock(height: 96),
          InlineSkeletonBlock(height: 40),
          InlineSkeletonBlock(height: 160),
          InlineSkeletonBlock(height: 52),
        ],
      ),
    );
  }
}

class _MedicineDetailContent extends ConsumerWidget {
  const _MedicineDetailContent({required this.detail, required this.source});

  final MedicineDetail detail;
  final String source;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    final snapshotAsync = ref.watch(healthContextSnapshotProvider);
    final isAdded = snapshotAsync.maybeWhen(
      data: (snapshot) => snapshot.currentMedicines.any(
        (m) => m.isCurrent && m.sourceRefId == detail.id && m.source == source,
      ),
      orElse: () => false,
    );

    final sections = source == 'drugbank'
        ? _drugbankSections(l10n)
        : _cnSections(l10n);

    return ResponsiveContentFrame(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.level4,
            vertical: Spacing.level4,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _HeaderCard(detail: detail, source: source),
              const SizedBox(height: Spacing.level4),
              _ReferenceNotice(l10n: l10n),
              const SizedBox(height: Spacing.level1),
              _RiskCheckEntry(
                l10n: l10n,
                onTap: () => const MedicineRiskCheckRoute().push(context),
              ),
              const SizedBox(height: Spacing.level4),
              if (sections.isNotEmpty)
                FAccordion(
                  children: [
                    for (var index = 0; index < sections.length; index += 1)
                      FAccordionItem(
                        title: Text(sections[index].title),
                        initiallyExpanded: index == 0,
                        child: Text(sections[index].body),
                      ),
                  ],
                )
              else
                StateMessageView(
                  title: l10n.medicineDetailNoContentTitle,
                  icon: SemanticIcons.statusInfo,
                ),
              const SizedBox(height: Spacing.level4),
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
            ],
          ),
        ),
      ),
    );
  }

  List<_DetailSection> _cnSections(AppLocalizations l10n) {
    return [
      _section(l10n.medicineDetailSectionIndications, detail.indications),
      _section(l10n.medicineDetailSectionIngredients, detail.ingredients),
      _section(l10n.medicineDetailSectionProperties, detail.properties),
      _section(
        l10n.medicineDetailSectionContraindications,
        detail.contraindications,
      ),
      _section(l10n.medicineDetailSectionPrecautions, detail.precautions),
      _section(l10n.medicineDetailSectionDosage, detail.dosage),
      _section(
        l10n.medicineDetailSectionAdverseReactions,
        detail.adverseReactions,
      ),
      _section(l10n.medicineDetailSectionStorage, detail.storage),
      _section(
        l10n.medicineDetailSectionPharmacology,
        detail.pharmacologyToxicology,
      ),
      _section(
        l10n.medicineDetailSectionPharmacokinetics,
        detail.pharmacokinetics,
      ),
      _section(l10n.medicineDetailSectionOverdose, detail.overdose),
      _section(l10n.medicineDetailSectionValidity, detail.validityPeriod),
    ].whereType<_DetailSection>().toList(growable: false);
  }

  List<_DetailSection> _drugbankSections(AppLocalizations l10n) {
    return [
      _section(l10n.medicineDetailSectionDescription, detail.description),
      _section(l10n.medicineDetailSectionIndications, detail.indication),
      _section(l10n.medicineDetailSectionMechanism, detail.mechanismOfAction),
      _section(
        l10n.medicineDetailSectionPharmacodynamics,
        detail.pharmacodynamics,
      ),
      _section(l10n.medicineDetailSectionToxicity, detail.toxicity),
      _section(l10n.medicineDetailSectionDrugType, detail.drugType),
      _section(l10n.medicineDetailSectionState, detail.state),
      _section(l10n.medicineDetailSectionMetabolism, detail.metabolism),
      _section(l10n.medicineDetailSectionAbsorption, detail.absorption),
      _section(l10n.medicineDetailSectionHalfLife, detail.halfLife),
      _section(l10n.medicineDetailSectionProteinBinding, detail.proteinBinding),
      _section(
        l10n.medicineDetailSectionElimination,
        detail.routeOfElimination,
      ),
      _section(
        l10n.medicineDetailSectionDistribution,
        detail.volumeOfDistribution,
      ),
      _section(l10n.medicineDetailSectionClearance, detail.clearance),
      _listSection(l10n.medicineDetailSectionCategories, detail.categories),
      _listSection(l10n.medicineDetailSectionGroups, detail.groups),
      _listSection(l10n.medicineDetailSectionAtc, detail.atcCodes),
      _listSection(l10n.medicineDetailSectionSynonyms, detail.synonyms),
      _listSection(
        l10n.medicineDetailSectionFoodInteractions,
        detail.foodInteractions,
      ),
      _interactionsSection(
        l10n.medicineDetailSectionDrugInteractions,
        detail.drugInteractions,
      ),
    ].whereType<_DetailSection>().toList(growable: false);
  }

  _DetailSection? _section(String title, String? body) {
    if (body == null || body.trim().isEmpty) return null;
    return _DetailSection(title: title, body: body);
  }

  _DetailSection? _listSection(String title, List<String> items) {
    if (items.isEmpty) return null;
    final body = items.join(', ');
    if (body.trim().isEmpty) return null;
    return _DetailSection(title: title, body: body);
  }

  _DetailSection? _interactionsSection(
    String title,
    List<MedicineDetailInteraction> items,
  ) {
    if (items.isEmpty) return null;
    final body = items
        .map((item) => '${item.drugbankId}: ${item.description}')
        .join('\n\n');
    return _DetailSection(title: title, body: body);
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
    final medicineSource = source == 'drugbank'
        ? HealthMedicineSource.drugbank
        : HealthMedicineSource.cn;

    final input = CurrentMedicineWriteInput(
      source: medicineSource,
      sourceRefId: detail.id,
      displayName: detail.name,
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
          (m) => m.sourceRefId == detail.id && m.source == medicineSource.name,
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
          .error('MedicineDetailPage._addToCurrentMedicines: failed: $e');
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

class _DetailSection {
  const _DetailSection({required this.title, required this.body});

  final String title;
  final String body;
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.detail, required this.source});

  final MedicineDetail detail;
  final String source;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.theme.colors;

    return FCard(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.level4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    detail.name,
                    style: TypographyToken.level6
                        .body(context)
                        .copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(width: Spacing.level2),
                _SourceBadge(source: source, l10n: l10n),
              ],
            ),
            if (detail.subtitle != null) ...[
              const SizedBox(height: Spacing.level2),
              Text(
                detail.subtitle!,
                style: TypographyToken.level3
                    .body(context)
                    .copyWith(color: colors.mutedForeground),
              ),
            ],
            if (source == 'cn') ...[
              const SizedBox(height: Spacing.level2),
              if (detail.approvalNumber != null)
                _MetaRow(
                  label: l10n.medicineDetailApprovalNumber,
                  value: detail.approvalNumber!,
                ),
              if (detail.manufacturer != null)
                _MetaRow(
                  label: l10n.medicineDetailManufacturer,
                  value: detail.manufacturer!,
                ),
              if (detail.packageSpec != null)
                _MetaRow(
                  label: l10n.medicineDetailPackageSpec,
                  value: detail.packageSpec!,
                ),
              if (detail.brandName != null)
                _MetaRow(
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

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return Padding(
      padding: const EdgeInsets.only(top: Spacing.level2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: Spacing.level8,
            child: Text(
              label,
              style: TypographyToken.level3
                  .body(context)
                  .copyWith(color: colors.mutedForeground),
            ),
          ),
          const SizedBox(width: Spacing.level3),
          Expanded(
            child: Text(value, style: TypographyToken.level3.body(context)),
          ),
        ],
      ),
    );
  }
}

class _SourceBadge extends StatelessWidget {
  const _SourceBadge({required this.source, required this.l10n});

  final String source;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return FBadge(
      variant: FBadgeVariant.primary,
      style: .delta(
        decoration: .boxDelta(
          borderRadius: BorderRadius.circular(RadiusTokens.level2),
        ),
      ),
      child: Text(
        source == 'drugbank'
            ? l10n.medicineSearchSourceDrugbank
            : l10n.medicineSearchSourceCn,
      ),
    );
  }
}

class _ReferenceNotice extends StatelessWidget {
  const _ReferenceNotice({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.level3,
        vertical: Spacing.level2,
      ),
      decoration: BoxDecoration(
        color: SemanticColor.info.muted(context),
        borderRadius: BorderRadius.circular(RadiusTokens.level2),
      ),
      child: Row(
        children: [
          Icon(
            SemanticIcons.statusInfo,
            size: Spacing.level4,
            color: SemanticColor.info.solid(context),
          ),
          const SizedBox(width: Spacing.level2),
          Expanded(
            child: Text(
              l10n.medicineReferenceNoticeTitle,
              style: TypographyToken.level3
                  .body(context)
                  .copyWith(color: colors.foreground),
            ),
          ),
        ],
      ),
    );
  }
}

class _RiskCheckEntry extends StatelessWidget {
  const _RiskCheckEntry({required this.l10n, required this.onTap});

  final AppLocalizations l10n;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return FTappable(
      onPress: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Spacing.level2),
        child: Row(
          children: [
            Icon(
              SemanticIcons.safetyCaution,
              size: Spacing.level4,
              color: colors.primary,
            ),
            const SizedBox(width: Spacing.level2),
            Expanded(
              child: Text(
                l10n.medicineDetailRiskCheckEntry,
                style: TypographyToken.level3
                    .body(context)
                    .copyWith(color: colors.foreground),
              ),
            ),
            Icon(
              SemanticIcons.actionNext,
              size: Spacing.level4,
              color: colors.mutedForeground,
            ),
          ],
        ),
      ),
    );
  }
}
