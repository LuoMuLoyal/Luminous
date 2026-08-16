import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/logger/logger.dart';
import 'package:luminous/core/widgets/common/divider.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/core/widgets/layout/page_scaffold.dart';
import 'package:luminous/features/medicine/presentation/routes.dart';
import 'package:luminous/features/scan/data/repositories/scan.dart';
import 'package:luminous/features/scan/domain/entities/scan_result.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

const _scanFrameWidth = 280.0;
const _scanFrameHeight = 120.0;

class BarcodeScannerPage extends ConsumerStatefulWidget {
  const BarcodeScannerPage({super.key});

  @override
  ConsumerState<BarcodeScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends ConsumerState<BarcodeScannerPage>
    with WidgetsBindingObserver {
  MobileScannerController? _controller;
  bool _hasScanned = false;
  bool _isSearching = false;
  bool _permissionDenied = false;
  bool _torchOn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_initScanner());
  }

  Future<void> _initScanner() async {
    final status = await Permission.camera.status;
    if (!mounted) return;

    if (status.isPermanentlyDenied) {
      setState(() => _permissionDenied = true);
      return;
    }

    if (!status.isGranted) {
      final result = await Permission.camera.request();
      if (!mounted) return;
      if (!result.isGranted) {
        setState(() => _permissionDenied = true);
        return;
      }
    }

    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
    );
    if (mounted) {
      setState(() => _permissionDenied = false);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Re-check permission when returning from system settings.
    if (state == AppLifecycleState.resumed && _permissionDenied) {
      unawaited(_initScanner());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_controller?.dispose());
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    unawaited(_handleDetect(capture));
  }

  Future<void> _handleDetect(BarcodeCapture capture) async {
    if (_hasScanned || _isSearching) return;
    final barcode = capture.barcodes.firstOrNull;
    if (barcode == null || barcode.rawValue == null) return;

    _hasScanned = true;
    _isSearching = true;
    if (mounted) setState(() {});
    await _controller?.stop();

    final repo = ref.read(scanRepositoryProvider);

    try {
      final items = await repo.search(barcode.rawValue!);

      if (!mounted) return;

      if (items.isEmpty) {
        unawaited(
          Toast.show(
            context,
            AppLocalizations.of(context)!.scanBarcodeNotFoundToast,
          ),
        );
        _resetScanning();
        return;
      }

      if (items.length == 1) {
        final item = items.first;
        unawaited(MedicineDetailRoute(source: 'cn', id: item.id).push(context));
      } else {
        _showCandidatePicker(items);
      }
    } catch (e) {
      ref
          .read(talkerProvider)
          .error('BarcodeScannerPage._handleDetect: failed: $e');
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        unawaited(Toast.show(context, l10n.scanRecognitionFailedToast));
        _resetScanning();
      }
    } finally {
      _isSearching = false;
    }
  }

  void _resetScanning() {
    _hasScanned = false;
    if (mounted) setState(() {});
    unawaited(_controller?.start());
  }

  void _showCandidatePicker(List<ScanSearchResult> items) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.theme.colors;
    final typography = context.theme.typography;

    unawaited(
      showFSheet(
        context: context,
        side: FLayout.btt,
        useSafeArea: true,
        mainAxisMaxRatio: null,
        builder: (ctx) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(Spacing.level4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.scanCandidateSheetTitle,
                        style: typography.body.lg.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    FButton.icon(
                      variant: FButtonVariant.ghost,
                      size: FButtonSizeVariant.sm,
                      onPress: () => Navigator.pop(ctx),
                      child: const Icon(
                        SemanticIcons.actionClose,
                        size: IconSizeTokens.level3,
                      ),
                    ),
                  ],
                ),
              ),
              const AppDivider(),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.paddingOf(ctx).bottom + Spacing.level4,
                  ),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const AppDivider(),
                  itemBuilder: (_, i) {
                    final item = items[i];
                    return FTappable(
                      onPress: () {
                        Navigator.pop(ctx);
                        unawaited(
                          MedicineDetailRoute(
                            source: 'cn',
                            id: item.id,
                          ).push(context),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Spacing.level5,
                          vertical: Spacing.level4,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.name, style: typography.body.md),
                            if (item.subtitle != null)
                              Text(
                                item.subtitle!,
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _goToManualSearch() {
    unawaited(context.push(Routes.medicineSearch));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.theme.colors;

    if (_permissionDenied) {
      return PageScaffold(
        title: l10n.medicineQuickActionBarcodeTitle,
        useSafeArea: false,
        child: StateErrorView(
          title: l10n.scanPermissionDeniedTitle,
          description: l10n.scanPermissionDeniedHint,
          icon: SemanticIcons.statusUnavailable,
          actionLabel: l10n.scanPermissionOpenSettings,
          onAction: () => openAppSettings(),
          tone: StateTone.warning,
        ),
      );
    }

    return PageScaffold(
      title: l10n.medicineQuickActionBarcodeTitle,
      useSafeArea: false,
      actions: [
        if (_controller != null)
          FButton.icon(
            variant: FButtonVariant.ghost,
            onPress: () {
              unawaited(_controller?.toggleTorch());
              setState(() => _torchOn = !_torchOn);
            },
            child: Icon(
              _torchOn
                  ? SemanticIcons.safetyAllergy
                  : SemanticIcons.safetyAllergy,
              color: colors.foreground,
            ),
          ),
      ],
      child: _controller == null
          ? const Center(child: FCircularProgress())
          : Stack(
              children: [
                MobileScanner(controller: _controller!, onDetect: _onDetect),
                // Camera overlay — uses literal colors because the camera
                // preview is always dark, regardless of the app theme.
                // Colors.red here is a blend-mode cutout color (actual hue
                // is irrelevant; only opacity matters for dstOut).
                ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    const Color(0xFF000000).withValues(alpha: 0.45),
                    BlendMode.srcOut,
                  ),
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF000000,
                          ).withValues(alpha: 0.45),
                          backgroundBlendMode: BlendMode.dstOut,
                        ),
                      ),
                      Center(
                        child: Container(
                          width: _scanFrameWidth,
                          height: _scanFrameHeight,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF0000),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Corner brackets around scan frame
                Center(
                  child: SizedBox(
                    width: _scanFrameWidth,
                    height: _scanFrameHeight,
                    child: CustomPaint(
                      painter: _ScanCornerPainter(
                        color: colors.primary,
                        strokeWidth: 3,
                        cornerLength: 24,
                      ),
                    ),
                  ),
                ),
                // Bottom guidance + manual search fallback
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(Spacing.level5),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _isSearching
                                ? l10n.scanRecognizingHint
                                : l10n.scanGuideHint,
                            textAlign: TextAlign.center,
                            style: TypographyToken.level4
                                .body(context)
                                .copyWith(color: const Color(0xFFFFFFFF)),
                          ),
                          if (_isSearching) ...[
                            const SizedBox(height: Spacing.level3),
                            const SizedBox(
                              width: 24,
                              height: 24,
                              child: FCircularProgress(),
                            ),
                          ],
                          const SizedBox(height: Spacing.level4),
                          FButton(
                            variant: FButtonVariant.ghost,
                            onPress: _goToManualSearch,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  SemanticIcons.actionSearch,
                                  size: 16,
                                  color: Color(0xFFFFFFFF),
                                ),
                                const SizedBox(width: Spacing.level2),
                                Text(
                                  l10n.scanManualSearchAction,
                                  style: const TextStyle(
                                    color: Color(0xFFFFFFFF),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

/// Paints L-shaped corner brackets around the scan area.
class _ScanCornerPainter extends CustomPainter {
  const _ScanCornerPainter({
    required this.color,
    required this.strokeWidth,
    required this.cornerLength,
  });

  final Color color;
  final double strokeWidth;
  final double cornerLength;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Top-left
    canvas.drawLine(Offset.zero, Offset(cornerLength, 0), paint);
    canvas.drawLine(Offset.zero, Offset(0, cornerLength), paint);
    // Top-right
    canvas.drawLine(
      Offset(size.width, 0),
      Offset(size.width - cornerLength, 0),
      paint,
    );
    canvas.drawLine(
      Offset(size.width, 0),
      Offset(size.width, cornerLength),
      paint,
    );
    // Bottom-left
    canvas.drawLine(
      Offset(0, size.height),
      Offset(cornerLength, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(0, size.height),
      Offset(0, size.height - cornerLength),
      paint,
    );
    // Bottom-right
    canvas.drawLine(
      Offset(size.width, size.height),
      Offset(size.width - cornerLength, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(size.width, size.height),
      Offset(size.width, size.height - cornerLength),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScanCornerPainter oldDelegate) =>
      oldDelegate.color != color;
}
