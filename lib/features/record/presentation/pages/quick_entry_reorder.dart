import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/layout/page_scaffold.dart';
import 'package:luminous/core/widgets/layout/responsive_content_frame.dart';
import 'package:luminous/features/record/data/quick_entry_preferences.dart';
import 'package:luminous/features/record/domain/entities/dashboard.dart';
import 'package:luminous/features/record/presentation/widgets/shared/copy.dart';
import 'package:luminous/features/record/presentation/widgets/shared/dashboard_tokens.dart';
import 'package:luminous/l10n/app_localizations.dart';

class QuickEntryReorderPage extends ConsumerStatefulWidget {
  const QuickEntryReorderPage({super.key});

  @override
  ConsumerState<QuickEntryReorderPage> createState() =>
      _QuickEntryReorderPageState();
}

class _QuickEntryReorderPageState extends ConsumerState<QuickEntryReorderPage> {
  List<RecordEntryType>? _order;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final prefs =
        ref.watch(quickEntryPreferencesProvider).asData?.value ??
        const QuickEntryPreferences();

    return PageScaffold(
      title: l10n.recordQuickSettingsManualOrder,
      child: ResponsiveContentFrame(
        child: prefs.dynamicSortEnabled
            ? _DisabledView(l10n: l10n)
            : _ReorderList(
                order: _resolvedOrder(prefs),
                l10n: l10n,
                onReorder: _handleReorder,
              ),
      ),
    );
  }

  List<RecordEntryType> _resolvedOrder(QuickEntryPreferences prefs) {
    final current = _order;
    if (current != null) return current;
    final parsed = [
      for (final name in prefs.customOrder)
        for (final type in RecordEntryType.values)
          if (type.name == name) type,
    ];
    final base = parsed.isEmpty ? defaultQuickActionOrder : parsed;
    _order = List<RecordEntryType>.from(base);
    return _order!;
  }

  void _handleReorder(int oldIndex, int newIndex) {
    final current = List<RecordEntryType>.from(
      _order ?? defaultQuickActionOrder,
    );
    final item = current.removeAt(oldIndex);
    current.insert(newIndex, item);
    setState(() => _order = current);
    ref
        .read(quickEntryPreferencesProvider.notifier)
        .setCustomOrder(current.map((type) => type.name).toList());
  }
}

class _DisabledView extends StatelessWidget {
  const _DisabledView({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.level4),
        child: Text(
          l10n.recordQuickSortDisableDynamicFirst,
          key: const Key('record-quick-reorder-disabled'),
          textAlign: TextAlign.center,
          style: context.theme.typography.body.md,
        ),
      ),
    );
  }
}

class _ReorderList extends StatelessWidget {
  const _ReorderList({
    required this.order,
    required this.l10n,
    required this.onReorder,
  });

  final List<RecordEntryType> order;
  final AppLocalizations l10n;
  final ReorderCallback onReorder;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Spacing.level4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.recordQuickReorderHint,
            key: const ValueKey('record-quick-reorder-hint'),
            style: context.theme.typography.body.sm.copyWith(
              color: context.theme.colors.mutedForeground,
            ),
          ),
          const SizedBox(height: Spacing.level3),
          Expanded(
            child: ReorderableListView.builder(
              key: const Key('record-quick-reorder-list'),
              itemCount: order.length,
              onReorderItem: onReorder,
              itemBuilder: (context, index) {
                final type = order[index];
                return _ReorderRow(
                  key: ValueKey('record-quick-reorder-${type.name}'),
                  type: type,
                  label: recordCopy(l10n, _copyKeyFor(type)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  RecordCopyKey _copyKeyFor(RecordEntryType type) {
    return switch (type) {
      RecordEntryType.symptom => RecordCopyKey.typeSymptom,
      RecordEntryType.medication => RecordCopyKey.typeMedication,
      RecordEntryType.water => RecordCopyKey.typeWater,
      RecordEntryType.meal => RecordCopyKey.typeMeal,
      RecordEntryType.sleep => RecordCopyKey.typeSleep,
      RecordEntryType.mood => RecordCopyKey.typeMood,
      RecordEntryType.note => RecordCopyKey.typeNote,
      RecordEntryType.vitals => RecordCopyKey.typeVitals,
      RecordEntryType.heartRate => RecordCopyKey.typeHeartRate,
      RecordEntryType.weight => RecordCopyKey.typeWeight,
      RecordEntryType.activity => RecordCopyKey.typeActivity,
    };
  }
}

class _ReorderRow extends StatelessWidget {
  const _ReorderRow({super.key, required this.type, required this.label});

  final RecordEntryType type;
  final String label;

  @override
  Widget build(BuildContext context) {
    return FTile(
      title: Text(label),
      prefix: const Icon(SemanticIcons.actionMore),
    );
  }
}
