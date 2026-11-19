import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/features/record/presentation/providers/dashboard.dart';
import 'package:luminous/features/record/presentation/providers/surface.dart';
import 'package:luminous/features/record/presentation/widgets/sections/dashboard/filter/mobile.dart';
import 'package:luminous/features/record/presentation/widgets/shared/dashboard_tokens.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

/// 移动端记录类型过滤条区块。
class RecordFilterSection extends ConsumerWidget {
  const RecordFilterSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(recordSurfaceStateProvider).dataOrNull;
    if (dashboard == null) return const SizedBox.shrink();
    return RecordMobileFilter(
      filters: buildMobileFilters(dashboard.filters),
      l10n: AppLocalizations.of(context)!,
      onFilterSelected: (type) =>
          ref.read(selectedRecordFilterProvider.notifier).setFilter(type),
    );
  }
}
