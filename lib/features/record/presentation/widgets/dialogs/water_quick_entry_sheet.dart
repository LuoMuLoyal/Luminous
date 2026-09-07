import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
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
/// Uses Forui's [showFSheet] modal sheet. Returns [WaterQuickEntryResult] if
/// the user selects an amount (preset or manual), or null if the user dismisses
/// the sheet (tap outside, drag handle, etc.).
Future<WaterQuickEntryResult?> showWaterQuickEntrySheet(BuildContext context) {
  return showFSheet<WaterQuickEntryResult>(
    context: context,
    side: FLayout.btt,
    useSafeArea: true,
    resizeToAvoidBottomInset: true,
    mainAxisMaxRatio: 0.85,
    builder: (context) => const _WaterQuickEntrySheet(),
  );
}

class _WaterQuickEntrySheet extends StatefulWidget {
  const _WaterQuickEntrySheet();

  @override
  State<_WaterQuickEntrySheet> createState() => _WaterQuickEntrySheetState();
}

class _WaterQuickEntrySheetState extends State<_WaterQuickEntrySheet> {
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

    return SafeArea(
      child: DecoratedBox(
        decoration: BoxDecoration(color: context.theme.colors.background),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag handle
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: Spacing.level2),
                  child: Container(
                    width: Spacing.level7,
                    height: Spacing.level1,
                    decoration: BoxDecoration(
                      color: SemanticColor.neutral.solid(context),
                      borderRadius: context.theme.style.borderRadius.pill,
                    ),
                  ),
                ),
              ),
              // Title
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  Spacing.level4,
                  Spacing.level3,
                  Spacing.level4,
                  Spacing.level2,
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
                padding: const EdgeInsets.symmetric(horizontal: Spacing.level4),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: Spacing.level3,
                    crossAxisSpacing: Spacing.level3,
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
                              horizontal: Spacing.level2,
                              vertical: Spacing.level2,
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
                  Spacing.level4,
                  Spacing.level3,
                  Spacing.level4,
                  Spacing.level4,
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
                    const SizedBox(width: Spacing.level3),
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
    );
  }
}
