import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/app/router.dart';
import 'package:lucent_api/api/export.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/feedback/app_toast.dart';
import 'package:luminous/core/widgets/layout/page_scaffold.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/features/scan/data/scan_repository.dart';
import 'package:forui/forui.dart';

class BarcodeScannerPage extends ConsumerStatefulWidget {
  const BarcodeScannerPage({super.key});

  @override
  ConsumerState<BarcodeScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends ConsumerState<BarcodeScannerPage> {
  MobileScannerController? _controller;
  bool _hasScanned = false;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    unawaited(_handleDetect(capture));
  }

  Future<void> _handleDetect(BarcodeCapture capture) async {
    if (_hasScanned) return;
    final barcode = capture.barcodes.firstOrNull;
    if (barcode == null || barcode.rawValue == null) return;

    _hasScanned = true;
    await _controller?.stop();

    final repo = ref.read(scanRepositoryProvider);

    try {
      final items = await repo.search(barcode.rawValue!);

      if (!mounted) return;

      if (items.isEmpty) {
        unawaited(
          AppToast.show(
            context,
            AppLocalizations.of(context)!.scanBarcodeNotFoundToast,
          ),
        );
        setState(() => _hasScanned = false);
        unawaited(_controller?.start());
        return;
      }

      if (items.length == 1) {
        final item = items.first;
        unawaited(context.push('${AppRoutes.medicineReminders}/${item.id}'));
      } else {
        // Multiple results — show list for user to pick
        _showCandidatePicker(items);
      }
    } catch (e) {
      debugPrint('BarcodeScannerPage._handleDetect: failed: $e');
      if (mounted) {
        unawaited(
          AppToast.show(
            context,
            AppLocalizations.of(context)!.scanSearchFailedToast(e.toString()),
          ),
        );
        setState(() => _hasScanned = false);
        unawaited(_controller?.start());
      }
    }
  }

  void _showCandidatePicker(List<MedicineSearchItemDto> items) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;

    showFSheet(
      context: context,
      side: FLayout.btt,
      useSafeArea: true,
      mainAxisMaxRatio: null,
      builder: (ctx) => ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.only(
          bottom: MediaQuery.paddingOf(ctx).bottom + AppSpacingTokens.level4,
        ),
        itemCount: items.length,
        itemBuilder: (_, i) {
          final item = items[i];
          return FTappable(
            onPress: () {
              Navigator.pop(ctx);
              unawaited(
                context.push('${AppRoutes.medicineReminders}/${item.id}'),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacingTokens.level5,
                vertical: AppSpacingTokens.level4,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: typography.body.md),
                  if (item.subtitle != null)
                    Text(
                      item.subtitle.toString(),
                      style: typography.body.sm.copyWith(
                        color: colors.mutedForeground,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return PageScaffold(
      title: l10n.medicineQuickActionBarcodeTitle,
      useSafeArea: false,
      actions: [
        FButton.icon(
          variant: FButtonVariant.ghost,
          onPress: () => _controller?.toggleTorch(),
          child: Icon(
            _controller?.torchEnabled == true
                ? FLucideIcons.zap
                : FLucideIcons.zapOff,
            color: context.theme.colors.primaryForeground,
          ),
        ),
      ],
      child: _controller == null
          ? const Center(child: FCircularProgress())
          : Stack(
              children: [
                MobileScanner(controller: _controller!, onDetect: _onDetect),
                // Scan frame overlay
                Center(
                  child: Container(
                    width: 280,
                    height: 120,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: context.theme.colors.primary,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
