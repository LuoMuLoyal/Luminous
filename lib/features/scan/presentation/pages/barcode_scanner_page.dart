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
    showModalBottomSheet(
      context: context,
      builder: (ctx) => ListView.builder(
        shrinkWrap: true,
        itemCount: items.length,
        itemBuilder: (_, i) {
          final item = items[i];
          return ListTile(
            title: Text(item.name),
            subtitle: Text(item.subtitle?.toString() ?? ''),
            onTap: () {
              Navigator.pop(ctx);
              unawaited(context.push('/medicine/reminders/${item.id}'));
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: const AppBackButton(),
        title: const Text('扫描条形码', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(
              _controller?.torchEnabled == true
                  ? Icons.flash_on
                  : Icons.flash_off,
              color: Colors.white,
            ),
            onPressed: () => _controller?.toggleTorch(),
          ),
        ],
      ),
      body: _controller == null
          ? const Center(child: CircularProgressIndicator())
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
                        color: AppColorTokens.cyanDeep,
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
