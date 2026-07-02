import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/feedback/app_toast.dart';
import 'package:luminous/core/widgets/common/app_state_views.dart';
import 'package:luminous/core/design/app_breakpoints.dart';
import 'package:luminous/core/widgets/layout/responsive_content_frame.dart';
import 'package:luminous/features/auth/presentation/providers/session/auth_session_provider.dart';
import 'package:luminous/features/auth/presentation/widgets/auth_required_dialog.dart';
import 'package:luminous/features/health_context/data/providers/health_context_data_providers.dart';
import 'package:luminous/features/health_context/domain/entities/health_context_write_inputs.dart';
import 'package:luminous/features/mine/presentation/providers/health_edit_forms.dart';
import 'package:luminous/core/widgets/common/app_back_button.dart';
import 'package:luminous/l10n/app_localizations.dart';

class AllergyEditPage extends HookConsumerWidget {
  const AllergyEditPage({super.key, this.allergyId});

  final String? allergyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isNew = allergyId == null;
    final isEdit = !isNew;

    final labelController = useTextEditingController();
    final reactionController = useTextEditingController();
    final noteController = useTextEditingController();
    final kind = useState(HealthAllergyKind.drug);
    final severity = useState(HealthAllergySeverity.unknown);
    final prefilled = useState(false);
    final notFound = useState(false);

    void tryPrefill() {
      if (prefilled.value) return;
      final snapshot = ref.read(healthContextSnapshotProvider).asData?.value;
      if (snapshot == null) return;

      final id = allergyId;
      if (id == null) {
        prefilled.value = true;
        return;
      }

      final item = snapshot.allergies.firstWhereOrNull((a) => a.id == id);
      if (item == null) {
        notFound.value = true;
        prefilled.value = true;
        return;
      }

      prefilled.value = true;
      labelController.text = item.label;
      reactionController.text = item.reaction ?? '';
      noteController.text = item.note ?? '';
      kind.value =
          HealthAllergyKind.fromValue(item.kind) ?? HealthAllergyKind.drug;
      severity.value =
          HealthAllergySeverity.fromValue(item.severity) ??
          HealthAllergySeverity.unknown;
    }

    void onSave() {
      if (labelController.text.trim().isEmpty) {
        AppToast.show(
          context,
          AppLocalizations.of(context)!.authCodeRequiredToast,
        );
        return;
      }

      if (allergyId != null) {
        ref
            .read(allergyFormProvider.notifier)
            .save(
              create: HealthAllergyWriteInput(kind: kind.value, label: ''),
              id: allergyId,
              update: HealthAllergyUpdateInput(
                kind: kind.value,
                label: labelController.text,
                reaction: reactionController.text.isEmpty
                    ? null
                    : reactionController.text,
                severity: severity.value,
                note: noteController.text.isEmpty ? null : noteController.text,
              ),
            );
      } else {
        ref
            .read(allergyFormProvider.notifier)
            .save(
              create: HealthAllergyWriteInput(
                kind: kind.value,
                label: labelController.text,
                reaction: reactionController.text.isEmpty
                    ? null
                    : reactionController.text,
                severity: severity.value,
                note: noteController.text.isEmpty ? null : noteController.text,
              ),
            );
      }
    }

    void onDelete() {
      if (allergyId != null) {
        ref.read(allergyFormProvider.notifier).delete(allergyId!);
      }
    }

    final session = ref.watch(authSessionProvider);

    ref.listen<AllergyFormState>(allergyFormProvider, (_, next) {
      if (next.saved) {
        AppToast.show(context, l10n.mineEditSavedToast);
        if (context.mounted) context.pop();
      }
    });

    if (!session.canAccessProtectedData) {
      final width = MediaQuery.sizeOf(context).width;
      final content = ResponsiveContentFrame(
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: width < AppBreakpoints.mobile ? 24 : 32,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              session.isLoading
                  ? const _MineEditFormLoading()
                  : AuthRequiredDialogGate(
                      onLogin: () =>
                          context.push(loginRouteForCurrentLocation(context)),
                    ),
            ],
          ),
        ),
      );

      return FScaffold(
        header: SafeArea(
          bottom: false,
          child: FHeader.nested(
            title: Text(
              isNew ? l10n.mineEditAllergyNewTitle : l10n.mineEditAllergyTitle,
            ),
            titleAlignment: Alignment.center,
            prefixes: [const AppBackButton()],
          ),
        ),
        child: SafeArea(
          top: false,
          child: Material(
            color: Colors.transparent,
            child: SingleChildScrollView(child: content),
          ),
        ),
      );
    }

    final snapshot = ref.watch(healthContextSnapshotProvider);
    snapshot.whenOrNull(data: (_) => tryPrefill());

    if (notFound.value) {
      final width = MediaQuery.sizeOf(context).width;
      final content = ResponsiveContentFrame(
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: width < AppBreakpoints.mobile ? 24 : 32,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppStateErrorView(
                title: l10n.mineErrorDescription,
                description: '',
                icon: Icons.error_outline_rounded,
                actionLabel: l10n.todayRetryAction,
                onAction: () => context.pop(),
              ),
            ],
          ),
        ),
      );

      return FScaffold(
        header: SafeArea(
          bottom: false,
          child: FHeader.nested(
            title: Text(l10n.mineEditAllergyTitle),
            titleAlignment: Alignment.center,
            prefixes: [const AppBackButton()],
          ),
        ),
        child: SafeArea(
          top: false,
          child: Material(
            color: Colors.transparent,
            child: SingleChildScrollView(child: content),
          ),
        ),
      );
    }

    if (isEdit && !prefilled.value && !snapshot.hasError) {
      final width = MediaQuery.sizeOf(context).width;
      final content = ResponsiveContentFrame(
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: width < AppBreakpoints.mobile ? 24 : 32,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [_MineEditFormLoading()],
          ),
        ),
      );

      return FScaffold(
        header: SafeArea(
          bottom: false,
          child: FHeader.nested(
            title: Text(l10n.mineEditAllergyTitle),
            titleAlignment: Alignment.center,
            prefixes: [const AppBackButton()],
          ),
        ),
        child: SafeArea(
          top: false,
          child: Material(
            color: Colors.transparent,
            child: SingleChildScrollView(child: content),
          ),
        ),
      );
    }

    final width = MediaQuery.sizeOf(context).width;
    final content = ResponsiveContentFrame(
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: width < AppBreakpoints.mobile ? 24 : 32,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacingTokens.level4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _enumDropdown<HealthAllergyKind>(
                    label: l10n.mineEditFieldKind,
                    value: kind.value,
                    values: HealthAllergyKind.values,
                    onChanged: (v) => kind.value = v,
                  ),
                  const SizedBox(height: AppSpacingTokens.level3),
                  TextField(
                    key: const Key('allergy-label-field'),
                    controller: labelController,
                    decoration: InputDecoration(
                      labelText: l10n.mineEditFieldLabel,
                    ),
                  ),
                  const SizedBox(height: AppSpacingTokens.level3),
                  TextField(
                    controller: reactionController,
                    decoration: InputDecoration(
                      labelText: l10n.mineEditFieldReaction,
                    ),
                  ),
                  const SizedBox(height: AppSpacingTokens.level3),
                  DropdownButtonFormField<HealthAllergySeverity>(
                    initialValue: severity.value,
                    decoration: InputDecoration(
                      labelText: l10n.mineEditFieldSeverity,
                    ),
                    items: HealthAllergySeverity.values
                        .map(
                          (v) =>
                              DropdownMenuItem(value: v, child: Text(v.value)),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v != null) severity.value = v;
                    },
                  ),
                  const SizedBox(height: AppSpacingTokens.level3),
                  TextField(
                    controller: noteController,
                    decoration: InputDecoration(
                      labelText: l10n.mineEditFieldNote,
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: AppSpacingTokens.level5),
                  ElevatedButton(
                    key: const Key('allergy-save-button'),
                    onPressed: onSave,
                    child: Text(l10n.mineEditSaveAction),
                  ),
                  if (!isNew) ...[
                    const SizedBox(height: AppSpacingTokens.level3),
                    OutlinedButton(
                      key: const Key('allergy-delete-button'),
                      onPressed: onDelete,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.error,
                      ),
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

    return FScaffold(
      header: SafeArea(
        bottom: false,
        child: FHeader.nested(
          title: Text(
            isNew ? l10n.mineEditAllergyNewTitle : l10n.mineEditAllergyTitle,
          ),
          titleAlignment: Alignment.center,
          prefixes: [const AppBackButton()],
        ),
      ),
      child: SafeArea(
        top: false,
        child: Material(
          color: Colors.transparent,
          child: SingleChildScrollView(child: content),
        ),
      ),
    );
  }
}

class _MineEditFormLoading extends StatelessWidget {
  const _MineEditFormLoading();

  @override
  Widget build(BuildContext context) {
    return const AppInlineSkeletonSection(
      children: [
        AppInlineSkeletonBlock(height: 56),
        AppInlineSkeletonBlock(height: 56),
        AppInlineSkeletonBlock(height: 56),
        AppInlineSkeletonBlock(height: 96),
        AppInlineSkeletonBlock(height: 56),
      ],
    );
  }
}

Widget _enumDropdown<T extends HealthContextWireEnum>({
  required String label,
  required T value,
  required List<T> values,
  required ValueChanged<T> onChanged,
}) {
  return DropdownButtonFormField<T>(
    initialValue: value,
    decoration: InputDecoration(labelText: label),
    items: values
        .map((v) => DropdownMenuItem(value: v, child: Text(v.value)))
        .toList(),
    onChanged: (v) {
      if (v != null) onChanged(v);
    },
  );
}
