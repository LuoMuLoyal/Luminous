import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/forms/validators.dart';
import 'package:luminous/core/widgets/auth/required_dialog.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/core/widgets/layout/page_scaffold.dart';
import 'package:luminous/core/widgets/layout/responsive_content_frame.dart';
import 'package:luminous/features/health_context/data/providers/health_context.dart';
import 'package:luminous/features/mine/presentation/providers/health_edit_forms.dart';
import 'package:luminous/features/mine/presentation/utils/current_medicine_handlers.dart';
import 'package:luminous/features/mine/presentation/widgets/current_medicine_form.dart';
import 'package:luminous/features/mine/presentation/widgets/shared/edit_form_loading.dart';
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
      startedAt.value = tryParseMedicineDate(item.startedAt);
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
      if (medicineId != null) {
        unawaited(
          ref
              .read(currentMedicineFormProvider.notifier)
              .save(
                create: buildMedicineCreateInput(displayName: ''),
                id: medicineId,
                update: buildMedicineUpdateInput(
                  displayName: displayNameController.text,
                  strengthText: strengthTextController.text,
                  doseText: doseTextController.text,
                  route: routeController.text,
                  startedAt: startedAt.value,
                  note: noteController.text,
                ),
              ),
        );
      } else {
        unawaited(
          ref
              .read(currentMedicineFormProvider.notifier)
              .save(
                create: buildMedicineCreateInput(
                  displayName: displayNameController.text,
                  strengthText: strengthTextController.text,
                  doseText: doseTextController.text,
                  route: routeController.text,
                  startedAt: startedAt.value,
                  note: noteController.text,
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
            vertical: width < Breakpoints.mobile ? Spacing.xl2 : Spacing.xl3,
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
              vertical: width < Breakpoints.mobile ? Spacing.xl2 : Spacing.xl3,
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
              vertical: width < Breakpoints.mobile ? Spacing.xl2 : Spacing.xl3,
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
              vertical: width < Breakpoints.mobile ? Spacing.xl2 : Spacing.xl3,
            ),
            child: CurrentMedicineForm(
              l10n: l10n,
              displayNameController: displayNameController,
              strengthTextController: strengthTextController,
              doseTextController: doseTextController,
              routeController: routeController,
              startedAt: startedAt.value,
              onStartedAtChanged: (value) => startedAt.value = value,
              noteController: noteController,
              onSave: onSave,
              onDelete: onDelete,
              showDelete: !isNew,
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
