import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/feedback/app_toast.dart';
import 'package:luminous/core/widgets/page_scaffold_shell.dart';
import 'package:luminous/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:luminous/features/record/data/providers/daily_record_providers.dart';
import 'package:luminous/features/record/domain/entities/daily_record.dart';
import 'package:luminous/features/record/domain/entities/daily_record_inputs.dart' show DailyRecordUpdateInput, dailyRecordNoChange;
import 'package:luminous/features/record/presentation/providers/record_dashboard_provider.dart';
import 'package:luminous/features/settings/presentation/widgets/settings_components.dart';
import 'package:luminous/features/today/presentation/providers/today_dashboard_provider.dart';
import 'package:luminous/l10n/app_localizations.dart';

class RecordEditPage extends ConsumerStatefulWidget {
  const RecordEditPage({super.key, required this.recordId});

  final String recordId;

  @override
  ConsumerState<RecordEditPage> createState() => _RecordEditPageState();
}

class _RecordEditPageState extends ConsumerState<RecordEditPage> {
  DailyRecordKind _kind = DailyRecordKind.water;
  final _valueController = TextEditingController();
  final _unitController = TextEditingController();
  final _noteController = TextEditingController();
  final _titleController = TextEditingController();

  bool _saving = false;
  bool _deleting = false;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final session = ref.read(authSessionProvider);
      if (!session.isAuthenticated) return;
      _loadRecord();
    });
  }

  @override
  void dispose() {
    _valueController.dispose();
    _unitController.dispose();
    _noteController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _loadRecord() async {
    try {
      final repo = ref.read(dailyRecordRepositoryProvider);
      final dateStr = _todayString();
      final result = await repo.fetchRecords(dateStr, pageSize: 100);
      final record = result.items.where((r) => r.id == widget.recordId).firstOrNull;
      if (!mounted) return;
      if (record == null) {
        AppToast.show(context, AppLocalizations.of(context)!.recordCreateFailedToast);
        context.pop();
        return;
      }
      setState(() {
        _kind = record.kind;
        _valueController.text = record.value ?? '';
        _unitController.text = record.unit ?? '';
        _noteController.text = record.note ?? '';
        _titleController.text = record.title ?? '';
        _loaded = true;
      });
    } catch (_) {
      if (mounted) {
        AppToast.show(context, AppLocalizations.of(context)!.recordCreateFailedToast);
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final session = ref.watch(authSessionProvider);

    if (!session.isAuthenticated) {
      return PageScaffoldShell(
        title: l10n.recordEditAction,
        centerTitle: true,
        leading: const SettingsBackButton(),
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacingTokens.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.authNotSignedIn),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.push('/login'),
                    child: Text(l10n.authGoLogin),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    if (!_loaded) {
      return PageScaffoldShell(
        title: l10n.recordEditAction,
        centerTitle: true,
        leading: const SettingsBackButton(),
        children: [
          const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacingTokens.xl),
              child: CircularProgressIndicator(),
            ),
          ),
        ],
      );
    }

    return PageScaffoldShell(
      title: l10n.recordEditAction,
      centerTitle: true,
      leading: const SettingsBackButton(),
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacingTokens.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<DailyRecordKind>(
                initialValue: _kind,
                decoration: InputDecoration(
                  labelText: l10n.recordCreateFieldKind,
                ),
                items: DailyRecordKind.values
                    .map(
                      (k) => DropdownMenuItem(
                        value: k,
                        child: Text(_kindLabel(l10n, k)),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _kind = v);
                },
              ),
              const SizedBox(height: 12),
              if (_kind != DailyRecordKind.mood) ...[
                TextField(
                  controller: _valueController,
                  decoration: InputDecoration(
                    labelText: _valueLabel(l10n, _kind),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (_kind == DailyRecordKind.vital ||
                  _kind == DailyRecordKind.water) ...[
                TextField(
                  controller: _unitController,
                  decoration: InputDecoration(
                    labelText: l10n.recordCreateFieldUnit,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (_kind != DailyRecordKind.water) ...[
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: l10n.recordCreateFieldTitleOptional,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              TextField(
                controller: _noteController,
                decoration: InputDecoration(
                  labelText: l10n.recordCreateFieldNote,
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saving ? null : _onSave,
                child: Text(_saving ? '...' : l10n.mineEditSaveAction),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _deleting || _saving ? null : _onDelete,
                icon: _deleting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.delete_outline_rounded, size: 18),
                label: Text(_deleting ? '...' : l10n.authDeleteAccountAction),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _kindLabel(AppLocalizations l10n, DailyRecordKind kind) {
    return switch (kind) {
      DailyRecordKind.water => l10n.recordTypeWater,
      DailyRecordKind.meal => l10n.recordTypeMeal,
      DailyRecordKind.vital => l10n.recordTypeVitals,
      DailyRecordKind.mood => l10n.recordTypeMood,
      DailyRecordKind.symptom => l10n.recordTypeSymptom,
      DailyRecordKind.activity => l10n.recordTypeActivity,
      DailyRecordKind.note => l10n.recordCreateKindNote,
    };
  }

  String _valueLabel(AppLocalizations l10n, DailyRecordKind kind) {
    return switch (kind) {
      DailyRecordKind.water => l10n.recordCreateValueWater,
      DailyRecordKind.meal => l10n.recordCreateValueMeal,
      DailyRecordKind.vital => l10n.recordCreateValueVital,
      DailyRecordKind.mood => l10n.recordTypeMood,
      DailyRecordKind.symptom => l10n.recordTypeSymptom,
      DailyRecordKind.activity => l10n.recordTypeActivity,
      DailyRecordKind.note => l10n.recordCreateFieldNote,
    };
  }

  Future<void> _onSave() async {
    setState(() => _saving = true);
    try {
      final repo = ref.read(dailyRecordRepositoryProvider);
      await repo.update(
        widget.recordId,
        DailyRecordUpdateInput(
          kind: _kind,
          title: _titleController.text.isEmpty ? dailyRecordNoChange : _titleController.text,
          value: _valueController.text.isEmpty ? dailyRecordNoChange : _valueController.text,
          unit: _unitController.text.isEmpty ? dailyRecordNoChange : _unitController.text,
          note: _noteController.text.isEmpty ? dailyRecordNoChange : _noteController.text,
        ),
      );
      _invalidateProviders();
      if (mounted) {
        await AppToast.show(context, AppLocalizations.of(context)!.mineEditSavedToast);
        if (!mounted) return;
        context.pop();
      }
    } catch (_) {
      if (mounted) {
        await AppToast.show(context, AppLocalizations.of(context)!.recordCreateFailedToast);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _onDelete() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.authIdentityUnlinkConfirmTitle),
        content: Text(l10n.recordDeleteConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.authCancelAction),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.authDeleteAccountAction),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _deleting = true);
    try {
      final repo = ref.read(dailyRecordRepositoryProvider);
      await repo.delete(widget.recordId);
      _invalidateProviders();
      if (mounted) {
        await AppToast.show(context, l10n.mineEditSavedToast);
        if (!mounted) return;
        context.pop();
      }
    } catch (_) {
      if (mounted) {
        await AppToast.show(context, l10n.recordCreateFailedToast);
      }
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  void _invalidateProviders() {
    ref.invalidate(recordDashboardProvider);
    ref.invalidate(todayDashboardProvider);
  }

  String _todayString() {
    final today = DateTime.now();
    return '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
  }
}
