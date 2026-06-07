import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/feedback/app_toast.dart';
import 'package:luminous/core/widgets/app_state_views.dart';
import 'package:luminous/core/widgets/page_scaffold_shell.dart';
import 'package:luminous/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:luminous/features/health_context/data/providers/health_context_data_providers.dart';
import 'package:luminous/features/health_context/domain/entities/health_context_write_inputs.dart';
import 'package:luminous/features/mine/presentation/providers/health_edit_forms.dart';
import 'package:luminous/features/settings/presentation/widgets/settings_components.dart';
import 'package:luminous/l10n/app_localizations.dart';

class AllergyEditPage extends ConsumerStatefulWidget {
  const AllergyEditPage({super.key, this.allergyId});

  final String? allergyId;

  @override
  ConsumerState<AllergyEditPage> createState() => _AllergyEditPageState();
}

class _AllergyEditPageState extends ConsumerState<AllergyEditPage> {
  final _labelController = TextEditingController();
  final _reactionController = TextEditingController();
  final _noteController = TextEditingController();

  HealthAllergyKind _kind = HealthAllergyKind.drug;
  HealthAllergySeverity _severity = HealthAllergySeverity.unknown;

  bool _prefilled = false;
  bool _notFound = false;

  @override
  void dispose() {
    _labelController.dispose();
    _reactionController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _tryPrefill() {
    if (_prefilled) return;
    final snapshot = ref.read(healthContextSnapshotProvider).asData?.value;
    if (snapshot == null) return;

    final id = widget.allergyId;
    if (id == null) {
      _prefilled = true;
      return;
    }

    final item = snapshot.allergies.cast<dynamic>().firstWhere(
      (a) => a.id == id,
      orElse: () => null,
    );
    if (item == null) {
      _notFound = true;
      _prefilled = true;
      return;
    }

    _prefilled = true;
    _labelController.text = item.label ?? '';
    _reactionController.text = item.reaction ?? '';
    _noteController.text = item.note ?? '';
    setState(() {
      _kind = HealthAllergyKind.fromValue(item.kind) ?? HealthAllergyKind.drug;
      _severity =
          HealthAllergySeverity.fromValue(item.severity) ??
          HealthAllergySeverity.unknown;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isNew = widget.allergyId == null;
    final isEdit = !isNew;
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
        leading: const SettingsBackButton(),
        children: [
          session.isLoading
              ? const _MineEditFormLoading()
              : _MineAuthRequiredPrompt(onLogin: () => context.push('/login')),
        ],
      );
    }

    // Watch snapshot for prefill
    final snapshot = ref.watch(healthContextSnapshotProvider);
    snapshot.whenOrNull(data: (_) => _tryPrefill());

    if (_notFound) {
      return PageScaffoldShell(
        title: l10n.mineEditAllergyTitle,
        centerTitle: true,
        leading: const SettingsBackButton(),
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

    // Show loading while fetching for edit mode
    if (isEdit && !_prefilled && !snapshot.hasError) {
      return PageScaffoldShell(
        title: l10n.mineEditAllergyTitle,
        centerTitle: true,
        leading: const SettingsBackButton(),
        children: const [_MineEditFormLoading()],
      );
    }

    return PageScaffoldShell(
      title: isNew ? l10n.mineEditAllergyNewTitle : l10n.mineEditAllergyTitle,
      centerTitle: true,
      leading: const SettingsBackButton(),
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacingTokens.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _enumDropdown<HealthAllergyKind>(
                label: l10n.mineEditFieldKind,
                value: _kind,
                values: HealthAllergyKind.values,
                onChanged: (v) => setState(() => _kind = v),
              ),
              const SizedBox(height: 12),
              TextField(
                key: const Key('allergy-label-field'),
                controller: _labelController,
                decoration: InputDecoration(labelText: l10n.mineEditFieldLabel),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _reactionController,
                decoration: InputDecoration(
                  labelText: l10n.mineEditFieldReaction,
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<HealthAllergySeverity>(
                initialValue: _severity,
                decoration: InputDecoration(
                  labelText: l10n.mineEditFieldSeverity,
                ),
                items: HealthAllergySeverity.values
                    .map(
                      (v) => DropdownMenuItem(value: v, child: Text(v.value)),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _severity = v);
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _noteController,
                decoration: InputDecoration(labelText: l10n.mineEditFieldNote),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                key: const Key('allergy-save-button'),
                onPressed: _onSave,
                child: Text(l10n.mineEditSaveAction),
              ),
              if (!isNew) ...[
                const SizedBox(height: 12),
                OutlinedButton(
                  key: const Key('allergy-delete-button'),
                  onPressed: _onDelete,
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

  void _onSave() {
    if (_labelController.text.trim().isEmpty) {
      AppToast.show(
        context,
        AppLocalizations.of(context)!.authCodeRequiredToast,
      );
      return;
    }

    if (widget.allergyId != null) {
      ref
          .read(allergyFormProvider.notifier)
          .save(
            create: HealthAllergyWriteInput(kind: _kind, label: ''),
            id: widget.allergyId,
            update: HealthAllergyUpdateInput(
              kind: _kind,
              label: _labelController.text,
              reaction: _reactionController.text.isEmpty
                  ? null
                  : _reactionController.text,
              severity: _severity,
              note: _noteController.text.isEmpty ? null : _noteController.text,
            ),
          );
    } else {
      ref
          .read(allergyFormProvider.notifier)
          .save(
            create: HealthAllergyWriteInput(
              kind: _kind,
              label: _labelController.text,
              reaction: _reactionController.text.isEmpty
                  ? null
                  : _reactionController.text,
              severity: _severity,
              note: _noteController.text.isEmpty ? null : _noteController.text,
            ),
          );
    }
  }

  void _onDelete() {
    if (widget.allergyId != null) {
      ref.read(allergyFormProvider.notifier).delete(widget.allergyId!);
    }
  }
}

class _MineAuthRequiredPrompt extends StatelessWidget {
  const _MineAuthRequiredPrompt({required this.onLogin});

  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacingTokens.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.authNotSignedIn),
            const SizedBox(height: AppSpacingTokens.md),
            ElevatedButton(onPressed: onLogin, child: Text(l10n.authGoLogin)),
          ],
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
