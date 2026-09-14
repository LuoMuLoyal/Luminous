import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/dialog/sheet_drag_handle.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Result returned by [showWaterQuickEntrySheet].
class WaterQuickEntryResult {
  const WaterQuickEntryResult({required this.amountMl, required this.unit});

  final int amountMl;
  final String unit;
}

/// Preset water amounts (ml) shown in the quick-entry sheet.
const kWaterQuickEntryPresetMl = <int>[
  50,
  100,
  150,
  200,
  250,
  300,
  350,
  400,
  500,
  750,
  1000,
];

/// Shows a bottom sheet for quick water entry with preset amounts and manual input.
///
/// Returns [WaterQuickEntryResult] if the user selects an amount (preset or
/// manual), or null if the user dismisses the sheet.
///
/// `mainAxisMaxRatio: null` 是 Forui 对「主轴上含可滚动子节点」的建议值，也是配合 body 里
/// `DraggableScrollableSheet` 往上拖展开的前提。
Future<WaterQuickEntryResult?> showWaterQuickEntrySheet(BuildContext context) {
  return showFSheet<WaterQuickEntryResult>(
    context: context,
    side: FLayout.btt,
    useSafeArea: true,
    resizeToAvoidBottomInset: true,
    mainAxisMaxRatio: null,
    builder: (context) => const _WaterQuickEntrySheet(),
  );
}

class _WaterQuickEntrySheet extends StatefulWidget {
  const _WaterQuickEntrySheet();

  @override
  State<_WaterQuickEntrySheet> createState() => _WaterQuickEntrySheetState();
}

class _WaterQuickEntrySheetState extends State<_WaterQuickEntrySheet> {
  /// sheet 的初始/最小高度（占可用高度比例）；内容短，起点比睡眠 sheet 更低。
  static const _initialSize = 0.6;
  static const _minSize = 0.5;

  final TextEditingController _manualController = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _manualController.dispose();
    super.dispose();
  }

  void _selectAmount(int ml) {
    Navigator.of(context).pop(WaterQuickEntryResult(amountMl: ml, unit: 'ml'));
  }

  void _submitManual() {
    final text = _manualController.text.trim();
    final ml = int.tryParse(text);
    if (ml == null || ml <= 0) {
      setState(() {
        _errorText = AppLocalizations.of(
          context,
        )!.recordQuickSettingsWaterCustomDialogInvalid;
      });
      return;
    }
    Navigator.of(context).pop(WaterQuickEntryResult(amountMl: ml, unit: 'ml'));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final typography = context.theme.typography;

    return SheetSurface(
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: _initialSize,
        minChildSize: _minSize,
        maxChildSize: 1,
        snap: true,
        builder: (context, scrollController) => ScrollConfiguration(
          // 让鼠标/触控板也能拖动（桌面与 Web）。
          behavior: ScrollConfiguration.of(context).copyWith(
            dragDevices: const {
              PointerDeviceKind.touch,
              PointerDeviceKind.mouse,
              PointerDeviceKind.trackpad,
            },
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SheetDragHandle(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    Spacing.lg,
                    0,
                    Spacing.lg,
                    Spacing.sm,
                  ),
                  child: Text(
                    l10n.recordWaterQuickEntryTitle,
                    style: typography.body.lg.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                // 3-column preset grid (all "+X ml")
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: Spacing.md,
                          crossAxisSpacing: Spacing.md,
                          mainAxisExtent: 44,
                        ),
                    itemCount: kWaterQuickEntryPresetMl.length,
                    itemBuilder: (context, index) {
                      final ml = kWaterQuickEntryPresetMl[index];
                      return FButton(
                        variant: FButtonVariant.outline,
                        mainAxisSize: MainAxisSize.max,
                        style: FButtonStyleDelta.delta(
                          contentStyle: FButtonContentStyleDelta.delta(
                            textStyle: FVariantsDelta.delta([
                              .all(const TextStyleDelta.delta(fontSize: 14)),
                            ]),
                            padding: const .value(
                              EdgeInsets.symmetric(
                                horizontal: Spacing.sm,
                                vertical: Spacing.sm,
                              ),
                            ),
                          ),
                        ),
                        onPress: () => _selectAmount(ml),
                        child: Text('+$ml${l10n.recordWaterUnitMl}'),
                      );
                    },
                  ),
                ),
                // Manual input with confirm button to its right (no cancel:
                // tapping outside the sheet dismisses it).
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    Spacing.lg,
                    Spacing.md,
                    Spacing.lg,
                    Spacing.xl,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: FTextField(
                          key: const Key('water-quick-entry-manual-field'),
                          control: FTextFieldControl.managed(
                            controller: _manualController,
                          ),
                          label: Text(
                            l10n.recordQuickSettingsWaterCustomDialogLabel,
                          ),
                          hint: l10n.recordWaterQuickEntryManualHint,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          error: _errorText != null ? Text(_errorText!) : null,
                          onSubmit: (_) => _submitManual(),
                        ),
                      ),
                      const SizedBox(width: Spacing.md),
                      FButton(
                        key: const Key('water-quick-entry-manual-confirm'),
                        onPress: _submitManual,
                        child: Text(l10n.commonConfirm),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
