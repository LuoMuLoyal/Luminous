import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/forms/validators.dart';
import 'package:luminous/core/widgets/auth/required_dialog.dart';
import 'package:luminous/core/widgets/common/dialog/dialog_shell.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/core/widgets/layout/page_scaffold.dart';
import 'package:luminous/core/widgets/layout/responsive_content_frame.dart';
import 'package:luminous/features/health_context/data/providers/health_context.dart';
import 'package:luminous/features/health_context/domain/entities/write_inputs.dart';
import 'package:luminous/features/mine/presentation/providers/health_edit_forms.dart';
import 'package:luminous/features/mine/presentation/widgets/shared/edit_form_loading.dart';
import 'package:luminous/features/settings/presentation/widgets/shared/section_label.dart';
import 'package:luminous/l10n/app_localizations.dart';

class CurrentMedicineEditPage extends HookConsumerWidget {
  const CurrentMedicineEditPage({super.key, this.medicineId});

  final String? medicineId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isNew = medicineId == null;
    final isEdit = !isNew;

    final displayNameController = useTextEditingController();
    final strengthTextController = useTextEditingController();
    final doseTextController = useTextEditingController();
    final routeController = useTextEditingController();
    final startedAt = useState<DateTime?>(null);
    final noteController = useTextEditingController();
    final prefilled = useState(false);
    final notFound = useState(false);

    void tryPrefill() {
      if (prefilled.value) return;
      final snapshot = ref.read(healthContextSnapshotProvider).asData?.value;
      if (snapshot == null) return;

      final id = medicineId;
      if (id == null) {
        prefilled.value = true;
        return;
      }

      final item = snapshot.currentMedicines.firstWhereOrNull(
        (m) => m.id == id,
      );
      if (item == null) {
        notFound.value = true;
        prefilled.value = true;
        return;
      }

      prefilled.value = true;
      displayNameController.text = item.displayName;
      strengthTextController.text = item.strengthText ?? '';
      doseTextController.text = item.doseText ?? '';
      routeController.text = item.route ?? '';
      startedAt.value = _tryParseDate(item.startedAt);
      noteController.text = item.note ?? '';
    }

    void onSave() {
      final displayNameError = RequiredInput.validate(
        displayNameController.text,
        AppLocalizations.of(context)!.mineEditFieldDisplayNameRequired,
      );
      if (displayNameError != null) {
        unawaited(Toast.show(context, displayNameError));
        return;
      }

      // Source is always manual when created/edited from the UI — the
      // drugbank/cn sources are reserved for imported data and should not
      // be exposed as a user-facing concept.
      const source = HealthMedicineSource.manual;

      if (medicineId != null) {
        unawaited(
          ref
              .read(currentMedicineFormProvider.notifier)
              .save(
                create: const CurrentMedicineWriteInput(
                  source: source,
                  displayName: '',
                ),
                id: medicineId,
                update: CurrentMedicineUpdateInput(
                  source: source,
                  displayName: displayNameController.text,
                  strengthText: strengthTextController.text.isEmpty
                      ? null
                      : strengthTextController.text,
                  doseText: doseTextController.text.isEmpty
                      ? null
                      : doseTextController.text,
                  route: routeController.text.isEmpty
                      ? null
                      : routeController.text,
                  startedAt: startedAt.value != null
                      ? _formatDate(startedAt.value!)
                      : null,
                  note: noteController.text.isEmpty
                      ? null
                      : noteController.text,
                ),
              ),
        );
      } else {
        unawaited(
          ref
              .read(currentMedicineFormProvider.notifier)
              .save(
                create: CurrentMedicineWriteInput(
                  source: source,
                  displayName: displayNameController.text,
                  strengthText: strengthTextController.text.isEmpty
                      ? null
                      : strengthTextController.text,
                  doseText: doseTextController.text.isEmpty
                      ? null
                      : doseTextController.text,
                  route: routeController.text.isEmpty
                      ? null
                      : routeController.text,
                  startedAt: startedAt.value != null
                      ? _formatDate(startedAt.value!)
                      : null,
                  note: noteController.text.isEmpty
                      ? null
                      : noteController.text,
                ),
              ),
        );
      }
    }

    void onDelete() {
      if (medicineId != null) {
        unawaited(
          ref.read(currentMedicineFormProvider.notifier).delete(medicineId!),
        );
      }
    }

    final session = ref.watch(authSessionProvider);

    ref.listen<CurrentMedicineFormState>(currentMedicineFormProvider, (
      prev,
      next,
    ) {
      if (next.saved && prev?.saved != true) {
        unawaited(
          Toast.show(
            context,
            next.deleted ? l10n.mineEditDeletedToast : l10n.mineEditSavedToast,
          ),
        );
        if (context.mounted) context.pop();
      }
      final error = next.errorMessage;
      if (error != null && error != prev?.errorMessage) {
        unawaited(Toast.show(context, error));
      }
    });

    final Widget content;

    if (!session.canAccessProtectedData) {
      final width = MediaQuery.sizeOf(context).width;
      content = ResponsiveContentFrame(
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: width < Breakpoints.mobile
                ? Spacing.level6
                : Spacing.level7,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              session.isLoading
                  ? const MineEditFormLoading(
                      blockHeights: [56, 56, 56, 56, 56, 56],
                    )
                  : AuthRequiredDialogGate(
                      onLogin: () =>
                          context.push(loginRouteForCurrentLocation(context)),
                    ),
            ],
          ),
        ),
      );
    } else {
      final snapshot = ref.watch(healthContextSnapshotProvider);
      snapshot.whenOrNull(data: (_) => tryPrefill());

      if (notFound.value) {
        final width = MediaQuery.sizeOf(context).width;
        content = ResponsiveContentFrame(
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: width < Breakpoints.mobile
                  ? Spacing.level6
                  : Spacing.level7,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StateErrorView(
                  title: l10n.mineEditRecordNotFoundTitle,
                  description: l10n.mineEditRecordNotFoundDescription,
                  icon: SemanticIcons.statusError,
                  actionLabel: l10n.mineEditBackAction,
                  onAction: () => context.pop(),
                ),
              ],
            ),
          ),
        );
      } else if (isEdit && !prefilled.value && !snapshot.hasError) {
        final width = MediaQuery.sizeOf(context).width;
        content = ResponsiveContentFrame(
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: width < Breakpoints.mobile
                  ? Spacing.level6
                  : Spacing.level7,
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MineEditFormLoading(blockHeights: [56, 56, 56, 56, 56, 56]),
              ],
            ),
          ),
        );
      } else {
        final width = MediaQuery.sizeOf(context).width;
        content = ResponsiveContentFrame(
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: width < Breakpoints.mobile
                  ? Spacing.level6
                  : Spacing.level7,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Group 1 — 药品信息
                SettingsSectionLabel(label: l10n.mineEditMedicineSectionInfo),
                FCard(
                  child: Padding(
                    padding: const EdgeInsets.all(Spacing.level4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        FTextField(
                          key: const Key('medicine-displayname-field'),
                          control: FTextFieldControl.managed(
                            controller: displayNameController,
                          ),
                          label: Text(l10n.mineEditFieldDisplayName),
                        ),
                        const SizedBox(height: Spacing.level3),
                        FTextField(
                          control: FTextFieldControl.managed(
                            controller: strengthTextController,
                          ),
                          label: Text(l10n.mineEditFieldStrengthText),
                          hint: l10n.mineEditFieldStrengthTextHint,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: Spacing.level5),

                // Group 2 — 用法用量
                SettingsSectionLabel(label: l10n.mineEditMedicineSectionDosage),
                FCard(
                  child: Padding(
                    padding: const EdgeInsets.all(Spacing.level4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        FTextField(
                          control: FTextFieldControl.managed(
                            controller: doseTextController,
                          ),
                          label: Text(l10n.mineEditFieldDoseText),
                          hint: l10n.mineEditFieldDoseTextHint,
                        ),
                        const SizedBox(height: Spacing.level2),
                        Wrap(
                          spacing: Spacing.level2,
                          runSpacing: Spacing.level2,
                          children: [
                            for (final v in [
                              l10n.mineEditDoseQuick1Tablet,
                              l10n.mineEditDoseQuick2Tablets,
                              l10n.mineEditDoseQuick5ml,
                              l10n.mineEditDoseQuick10ml,
                            ])
                              _QuickSelectChip(
                                label: v,
                                onTap: () => doseTextController.text = v,
                              ),
                          ],
                        ),
                        const SizedBox(height: Spacing.level3),
                        FTextField(
                          control: FTextFieldControl.managed(
                            controller: routeController,
                          ),
                          label: Text(l10n.mineEditFieldRoute),
                          hint: l10n.mineEditFieldRouteHint,
                        ),
                        const SizedBox(height: Spacing.level2),
                        Wrap(
                          spacing: Spacing.level2,
                          runSpacing: Spacing.level2,
                          children: [
                            for (final v in [
                              l10n.mineEditRouteQuickOral,
                              l10n.mineEditRouteQuickTopical,
                              l10n.mineEditRouteQuickInhaled,
                              l10n.mineEditRouteQuickInjection,
                            ])
                              _QuickSelectChip(
                                label: v,
                                onTap: () => routeController.text = v,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: Spacing.level5),

                // Group 3 — 时间与备注
                SettingsSectionLabel(
                  label: l10n.mineEditMedicineSectionTimeline,
                ),
                FCard(
                  child: Padding(
                    padding: const EdgeInsets.all(Spacing.level4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        FDateField.calendar(
                          key: const Key('medicine-started-at-field'),
                          label: Text(l10n.mineEditFieldStartedAt),
                          selectionControl: FDateSelectionControl.managedSingle(
                            initial: startedAt.value,
                            toggleable: true,
                            onChange: (value) => startedAt.value = value,
                          ),
                        ),
                        const SizedBox(height: Spacing.level3),
                        FTextField(
                          control: FTextFieldControl.managed(
                            controller: noteController,
                          ),
                          label: Text(l10n.mineEditFieldNote),
                          maxLines: 3,
                        ),
                        const SizedBox(height: Spacing.level5),
                        FButton(
                          key: const Key('medicine-save-button'),
                          onPress: onSave,
                          child: Text(l10n.mineEditSaveAction),
                        ),
                        if (!isNew) ...[
                          const SizedBox(height: Spacing.level3),
                          FButton(
                            key: const Key('medicine-delete-button'),
                            variant: FButtonVariant.destructive,
                            onPress: () async {
                              final confirmed =
                                  await showDangerConfirmationDialog(
                                    context: context,
                                    title: l10n.mineEditDeleteConfirmTitle,
                                    message: l10n.mineEditDeleteConfirmMessage,
                                    confirmLabel: l10n.mineEditDeleteAction,
                                  );
                              if (confirmed) onDelete();
                            },
                            child: Text(l10n.mineEditDeleteAction),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }

    final title = isNew
        ? l10n.mineEditMedicineNewTitle
        : l10n.mineEditMedicineTitle;

    return PageScaffold(
      title: title,
      child: SingleChildScrollView(child: content),
    );
  }
}

DateTime? _tryParseDate(String? value) {
  if (value == null || value.isEmpty) return null;
  return DateTime.tryParse(value);
}

String _formatDate(DateTime date) {
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

class _QuickSelectChip extends StatelessWidget {
  const _QuickSelectChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FTappable(
      onPress: onTap,
      builder: (context, data, child) => DecoratedBox(
        decoration: BoxDecoration(
          color: SemanticColor.neutral.subtle(context),
          borderRadius: context.theme.style.borderRadius.md,
          border: Border.all(color: SemanticColor.neutral.border(context)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.level3,
            vertical: Spacing.level1,
          ),
          child: Text(
            label,
            style: context.theme.typography.body.xs.copyWith(
              color: SemanticColor.neutral.solid(context),
            ),
          ),
        ),
      ),
    );
  }
}
