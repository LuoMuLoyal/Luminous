/// 快捷记录对外的接缝：别的表面（today 的快捷条）在这里拿到「写一条记录」
/// 所需的全部能力，不必 import `record` 的 `presentation/widgets/` 与
/// `presentation/quick_entry/`。
///
/// 只做 re-export + 一层薄封装，不改变任何行为：
/// - `WaterQuickEntryFlow` / `QuickEntryRecordContext`：水量快捷记录的编排流；
/// - `createDailyRecordProvider` / `emitQuickEntryDataChangeProvider`：流需要的
///   写入口与变更广播；
/// - `showWaterQuickEntrySheet`：让用户选量的面板。
library;

import 'package:luminous/features/record/presentation/widgets/dialogs/water_quick_entry_sheet.dart'
    as sheet;
import 'package:luminous/features/record/presentation/widgets/dialogs/water_quick_entry_sheet.dart'
    show WaterQuickEntryResult;
import 'package:material_ui/material_ui.dart';

export 'package:luminous/features/record/presentation/quick_entry/core/quick_entry_providers.dart'
    show createDailyRecordProvider, emitQuickEntryDataChangeProvider;
export 'package:luminous/features/record/presentation/quick_entry/flows/water_quick_entry.dart'
    show QuickEntryRecordContext, WaterQuickEntryFlow;
export 'package:luminous/features/record/presentation/widgets/dialogs/water_quick_entry_sheet.dart'
    show WaterQuickEntryResult;

/// 打开水量选择面板；返回 `null` 表示用户没有确认（什么也不记）。
Future<WaterQuickEntryResult?> showWaterQuickEntrySheet(BuildContext context) =>
    sheet.showWaterQuickEntrySheet(context);
