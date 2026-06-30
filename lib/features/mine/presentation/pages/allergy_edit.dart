import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/feedback/app_toast.dart';
import 'package:luminous/core/widgets/common/app_state_views.dart';
import 'package:luminous/core/widgets/layout/page_scaffold_shell.dart';
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
      return PageScaffoldShell(
        title: isNew ? l10n.mineEditAllergyNewTitle : l10n.mineEditAllergyTitle,
        centerTitle: true,
        leading: const AppBackButton(),
        children: [
          session.isLoading
              ? const _MineEditFormLoading()
              : AuthRequiredDialogGate(
                  onLogin: () =>
                      context.push(loginRouteForCurrentLocation(context)),
                ),
        ],
      );
    }

    final snapshot = ref.watch(healthContextSnapshotProvider);
    snapshot.whenOrNull(data: (_) => tryPrefill());

    if (notFound.value) {
      return PageScaffoldShell(
        title: l10n.mineEditAllergyTitle,
        centerTitle: true,
        leading: const AppBackButton(),
        children: [
          AppStateErrorView(
            title: l10n.mineErrorDescription,
            description: '',
            icon: Icons.error_outline_rounded,
            actionLabel: l10n.todayRetryAction,
            onAction: () => context.pop(),
          ),
        ],
      );
    }

    if (isEdit && !prefilled.value && !snapshot.hasError) {
      return PageScaffoldShell(
        title: l10n.mineEditAllergyTitle,
        centerTitle: true,
        leading: const AppBackButton(),
        children: const [_MineEditFormLoading()],
      );
    }

    return PageScaffoldShell(
      title: isNew ? l10n.mineEditAllergyNewTitle : l10n.mineEditAllergyTitle,
      centerTitle: true,
      leading: const AppBackButton(),
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacingTokens.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _enumDropdown<HealthAllergyKind>(
                label: l10n.mineEditFieldKind,
                value: kind.value,
                values: HealthAllergyKind.values,
                onChanged: (v) => kind.value = v,
              ),
              const SizedBox(height: AppSpacingTokens.sm),
              TextField(
                key: const Key('allergy-label-field'),
                controller: labelController,
                decoration: InputDecoration(labelText: l10n.mineEditFieldLabel),
              ),
              const SizedBox(height: AppSpacingTokens.sm),
              TextField(
                controller: reactionController,
                decoration: InputDecoration(
                  labelText: l10n.mineEditFieldReaction,
                ),
              ),
              const SizedBox(height: AppSpacingTokens.sm),
              DropdownButtonFormField<HealthAllergySeverity>(
                initialValue: severity.value,
                decoration: InputDecoration(
                  labelText: l10n.mineEditFieldSeverity,
                ),
                items: HealthAllergySeverity.values
                    .map(
                      (v) => DropdownMenuItem(value: v, child: Text(v.value)),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) severity.value = v;
                },
              ),
              const SizedBox(height: AppSpacingTokens.sm),
              TextField(
                controller: noteController,
                decoration: InputDecoration(labelText: l10n.mineEditFieldNote),
                maxLines: 3,
              ),
              const SizedBox(height: AppSpacingTokens.lg),
              ElevatedButton(
                key: const Key('allergy-save-button'),
                onPressed: onSave,
                child: Text(l10n.mineEditSaveAction),
              ),
              if (!isNew) ...[
                const SizedBox(height: AppSpacingTokens.sm),
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
