import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucent_openapi/lucent_openapi.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/feedback/app_toast.dart';
import 'package:luminous/core/widgets/common/app_back_button.dart';
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
        unawaited(AppToast.show(context, '未找到该条码对应的药品'));
        setState(() => _hasScanned = false);
        unawaited(_controller?.start());
        return;
      }

      if (items.length == 1) {
        final item = items.first;
        unawaited(context.push('/medicine/reminders/${item.id}'));
      } else {
        // Multiple results — show list for user to pick
        _showCandidatePicker(items);
      }
    } catch (e) {
      if (mounted) {
        unawaited(AppToast.show(context, '搜索失败: $e'));
        setState(() => _hasScanned = false);
        unawaited(_controller?.start());
      }
    }
  }

  void _showCandidatePicker(List<MedicineSearchItemDto> items) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;

    showModalBottomSheet(
      context: context,
      builder: (ctx) => ListView.builder(
        shrinkWrap: true,
        itemCount: items.length,
        itemBuilder: (_, i) {
          final item = items[i];
          return FTappable(
            onPress: () {
              Navigator.pop(ctx);
              unawaited(context.push('/medicine/reminders/${item.id}'));
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
    return Scaffold(
      backgroundColor: context.theme.colors.background,
      appBar: AppBar(
        backgroundColor: context.theme.colors.background,
        leading: const AppBackButton(),
        title: Text(
          '扫描条形码',
          style: TextStyle(color: context.theme.colors.primaryForeground),
        ),
        actions: [
          FButton.icon(
            variant: FButtonVariant.ghost,
            onPress: () => _controller?.toggleTorch(),
            child: Icon(
              _controller?.torchEnabled == true
                  ? Icons.flash_on
                  : Icons.flash_off,
              color: context.theme.colors.primaryForeground,
            ),
          ),
        ],
      ),
      body: _controller == null
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
