import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/mine/domain/entities/dashboard.dart';
import 'package:luminous/features/mine/presentation/widgets/sections/archive_row.dart';
import 'package:luminous/features/mine/presentation/widgets/sections/archive_sections.dart';
import 'package:luminous/features/mine/presentation/widgets/shared/shared.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Mine「健康档案」区块入口：负责区块编排（标题 + 空态/条目列表），
/// 各条目交互与空态/元信息组件分别由 [ArchiveRow] 与
/// [ArchiveEmpty]/[buildArchiveProfileMeta] 承担。
class MineArchiveSection extends StatelessWidget {
  const MineArchiveSection({super.key, required this.dashboard});

  final MineDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final meta = buildArchiveProfileMeta(l10n, dashboard.profile);

    return Column(
      key: const Key('mine-archive-section'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MineSectionTitle(title: l10n.mineProfileTitle),
        SizedBox(height: context.titleContentGap),
        if (dashboard.archiveEntries.isEmpty)
          const ArchiveEmpty()
        else
          FTileGroup(
            divider: FItemDivider.full,
            children: [
              for (final entry in dashboard.archiveEntries)
                ArchiveRow(
                  entry: entry,
                  dashboard: dashboard,
                  subtitleOverride:
                      entry.titleKey == MineCopyKey.archiveBasicTitle
                      ? meta
                      : null,
                ),
            ],
          ),
      ],
    );
  }
}
