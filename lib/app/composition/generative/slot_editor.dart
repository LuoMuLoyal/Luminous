import 'package:flutter/widgets.dart';
import 'package:luminous/features/generative/presentation/widgets/slot_sheet.dart';
import 'package:luminous/shared/domain/composition/surface.dart';

/// 打开某个 surface 的生成式区块编辑面板。
///
/// 实现留在 `generative`，需要它的编排页（`customizer`）从组合根拿这个函数，
/// 因此两个 feature 之间没有 `presentation` 依赖。
Future<void> showSlotEditor(BuildContext context, SurfaceId surface) =>
    showGenerativeSlotSheet(context, surface);
