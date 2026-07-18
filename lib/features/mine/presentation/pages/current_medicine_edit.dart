import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/forms/validators.dart';
import 'package:luminous/core/widgets/common/dialog_shell.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/core/widgets/layout/responsive_content_frame.dart';
import 'package:luminous/features/auth/presentation/providers/session.dart';
import 'package:luminous/features/auth/presentation/widgets/shared/required_dialog.dart';
import 'package:luminous/features/health_context/data/providers/health_context.dart';
import 'package:luminous/features/health_context/domain/entities/write_inputs.dart';
import 'package:luminous/features/mine/presentation/providers/health_edit_forms.dart';
import 'package:luminous/features/mine/presentation/utils/health_enum_l10n.dart';
import 'package:luminous/core/widgets/layout/page_scaffold.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/core/widgets/common/shared_widgets.dart';

class CurrentMedicineEditPage extends HookConsumerWidget {
  const CurrentMedicineEditPage({super.key, this.medicineId});

  final String? medicineId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isNew = medicineId == null;
    final isEdit = !isNew;

    final sourceRefIdController = useTextEditingController();
    final displayNameController = useTextEditingController();
    final strengthTextController = useTextEditingController();
    final doseTextController = useTextEditingController();
    final routeController = useTextEditingController();
    final startedAtController = useTextEditingController();
    final noteController = useTextEditingController();
    final source = useState(HealthMedicineSource.manual);
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
      sourceRefIdController.text = item.sourceRefId ?? '';
      strengthTextController.text = item.strengthText ?? '';
      doseTextController.text = item.doseText ?? '';
      routeController.text = item.route ?? '';
      startedAtController.text = item.startedAt ?? '';
      noteController.text = item.note ?? '';
      source.value =
          HealthMedicineSource.fromValue(item.source) ??
          HealthMedicineSource.manual;
    }

    void onSave() {
      final displayNameError = RequiredInput.validate(
        displayNameController.text,
        AppLocalizations.of(context)!.mineEditFieldDisplayNameRequired,
      );
      if (displayNameError != null) {
        AppToast.show(context, displayNameError);
        return;
      }

      if (medicineId != null) {
        ref
            .read(currentMedicineFormProvider.notifier)
            .save(
              create: const CurrentMedicineWriteInput(
                source: HealthMedicineSource.manual,
                displayName: '',
              ),
              id: medicineId,
              update: CurrentMedicineUpdateInput(
                source: source.value,
                sourceRefId: sourceRefIdController.text.isEmpty
                    ? null
                    : sourceRefIdController.text,
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
                startedAt: startedAtController.text.isEmpty
                    ? null
                    : startedAtController.text,
                note: noteController.text.isEmpty ? null : noteController.text,
              ),
            );
      } else {
        ref
            .read(currentMedicineFormProvider.notifier)
            .save(
              create: CurrentMedicineWriteInput(
                source: source.value,
                sourceRefId: sourceRefIdController.text.isEmpty
                    ? null
                    : sourceRefIdController.text,
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
                startedAt: startedAtController.text.isEmpty
                    ? null
                    : startedAtController.text,
                note: noteController.text.isEmpty ? null : noteController.text,
              ),
            );
      }
    }

    void onDelete() {
      if (medicineId != null) {
        ref.read(currentMedicineFormProvider.notifier).delete(medicineId!);
      }
    }

    final session = ref.watch(authSessionProvider);

    ref.listen<CurrentMedicineFormState>(currentMedicineFormProvider, (
      _,
      next,
    ) {
      if (next.saved) {
        AppToast.show(context, l10n.mineEditSavedToast);
        if (context.mounted) context.pop();
      }
    });

    final Widget content;

    if (!session.canAccessProtectedData) {
      final width = MediaQuery.sizeOf(context).width;
      content = ResponsiveContentFrame(
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: width < Breakpoints.mobile ? 24 : 32,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              session.isLoading
                  ? const MineEditFormLoading()
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
              vertical: width < Breakpoints.mobile ? 24 : 32,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppStateErrorView(
                  title: l10n.mineErrorDescription,
                  description: '',
                  icon: FLucideIcons.circleAlert,
                  actionLabel: l10n.todayRetryAction,
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
              vertical: width < Breakpoints.mobile ? 24 : 32,
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [MineEditFormLoading()],
            ),
          ),
        );
      } else {
        final width = MediaQuery.sizeOf(context).width;
        content = ResponsiveContentFrame(
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: width < Breakpoints.mobile ? 24 : 32,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(Spacing.level4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _enumDropdown<HealthMedicineSource>(
                        label: l10n.mineEditFieldSource,
                        value: source.value,
                        values: HealthMedicineSource.values,
                        onChanged: (v) => source.value = v,
                        labelBuilder: (v) => medicineSourceLabel(l10n, v),
                      ),
                      const SizedBox(height: Spacing.level3),
                      FTextField(
                        control: FTextFieldControl.managed(
                          controller: sourceRefIdController,
                        ),
                        label: Text(l10n.mineEditFieldSourceRefId),
                      ),
                      const SizedBox(height: Spacing.level3),
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
                      ),
                      const SizedBox(height: Spacing.level3),
                      FTextField(
                        control: FTextFieldControl.managed(
                          controller: doseTextController,
                        ),
                        label: Text(l10n.mineEditFieldDoseText),
                      ),
                      const SizedBox(height: Spacing.level3),
                      FTextField(
                        control: FTextFieldControl.managed(
                          controller: routeController,
                        ),
                        label: Text(l10n.mineEditFieldRoute),
                      ),
                      const SizedBox(height: Spacing.level3),
                      FTextField(
                        control: FTextFieldControl.managed(
                          controller: startedAtController,
                        ),
                        label: Text(l10n.mineEditFieldStartedAt),
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

Widget _enumDropdown<T extends HealthContextWireEnum>({
  required String label,
  required T value,
  required List<T> values,
  required ValueChanged<T> onChanged,
  required String Function(T) labelBuilder,
}) {
  return FSelect<T>.rich(
    label: Text(label),
    hint: label,
    format: labelBuilder,
    control: FSelectControl.lifted(
      value: value,
      onChange: (v) {
        if (v != null) onChanged(v);
      },
    ),
    children: values
        .map((v) => FSelectItem.item(title: Text(labelBuilder(v)), value: v))
        .toList(),
  );
}
