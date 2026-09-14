import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/logger/log_level.dart';
import 'package:luminous/core/widgets/common/control/divider.dart';
import 'package:luminous/core/widgets/common/dialog/sheet_drag_handle.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/core/widgets/layout/page_scaffold.dart';
import 'package:luminous/features/health_context/data/providers/health_context.dart';
import 'package:luminous/features/medicine/presentation/routes.dart';
import 'package:luminous/features/scan/data/repositories/scan.dart';
import 'package:luminous/features/scan/domain/entities/scan_result.dart';
import 'package:luminous/features/scan/presentation/widgets/scan_corner_painter.dart';
import 'package:luminous/features/scan/presentation/widgets/scan_result_sheet.dart';
import 'package:luminous/features/search/presentation/widgets/shared/add_to_box.dart';
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
      final searchResult = await repo.search(barcode.rawValue!).run();
      if (!mounted) return;
      final items = searchResult.fold(
        (failure) => throw failure,
        (items) => items,
      );

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
        _showScanResultSheet(items.first);
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
    final typography = context.theme.typography;

    unawaited(
      showFSheet(
        context: context,
        side: FLayout.btt,
        useSafeArea: true,
        mainAxisMaxRatio: null,
        builder: (ctx) => SheetSurface(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SheetDragHandle(),
              Padding(
                padding: const EdgeInsets.all(Spacing.lg),
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
                        size: IconSizeTokens.md,
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
                    bottom: MediaQuery.paddingOf(ctx).bottom + Spacing.lg,
                  ),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const AppDivider(),
                  itemBuilder: (_, i) {
                    final item = items[i];
                    return FTappable(
                      onPress: () {
                        Navigator.pop(ctx);
                        _showScanResultSheet(item);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Spacing.xl,
                          vertical: Spacing.lg,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.name, style: typography.body.md),
                            if (item.subtitle != null)
                              Text(
                                item.subtitle!,
                                style: typography.body.sm.copyWith(
                                  color: SemanticColor.neutral.solid(context),
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

  /// Shows the scan result sheet for a barcode hit (single result or a
  /// candidate picked from [showCandidatePicker]).
  ///
  /// The scanned id is a medicine DB product id (`cn` source), not a drugbox
  /// record id. The sheet derives the「已加入」state live from
  /// [healthContextSnapshotProvider] (key `cn:<产品id>` → `source:sourceRefId`):
  /// not in the box → primary「加入药箱」(shared F-9 loop) + secondary
  /// 「查看说明书」; already in the box →「已添加」state + primary
  /// 「查看提醒详情」carrying the box record id + secondary「查看说明书」.
  /// After a successful add the DataChangeBus snapshot refresh flips the
  /// sheet to the added state without reopening (F-3 P2-1).
  void _showScanResultSheet(ScanSearchResult item) {
    final l10n = AppLocalizations.of(context)!;

    unawaited(
      showFSheet(
        context: context,
        side: FLayout.btt,
        useSafeArea: true,
        mainAxisMaxRatio: null,
        builder: (ctx) => SheetSurface(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SheetDragHandle(),
              BarcodeScanResultSheet(
                item: item,
                l10n: l10n,
                onAddToBox: () => addMedicineToBoxWithPrecheck(
                  context,
                  ref: ref,
                  source: 'cn',
                  sourceRefId: item.id,
                  displayName: item.name,
                ),
                onViewInstructions: () {
                  Navigator.pop(ctx);
                  unawaited(
                    MedicineDetailRoute(
                      source: 'cn',
                      id: item.id,
                    ).push(context),
                  );
                },
                onOpenReminder: (boxItem) {
                  Navigator.pop(ctx);
                  unawaited(
                    MedicineReminderDetailRoute(
                      medicineId: boxItem.id,
                    ).push(context),
                  );
                },
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
              _torchOn ? FLucideIcons.flashlight : FLucideIcons.flashlightOff,
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
                            borderRadius: context.theme.style.borderRadius.md,
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
                      painter: ScanCornerPainter(
                        color: SemanticColor.primary.solid(context),
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
                      padding: const EdgeInsets.all(Spacing.xl),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 相机预览恒为深色：底部引导文字/图标固定白色，不随主题变化
                          Text(
                            _isSearching
                                ? l10n.scanRecognizingHint
                                : l10n.scanGuideHint,
                            textAlign: TextAlign.center,
                            style: context.theme.typography.body.sm.copyWith(
                              color: const Color(0xFFFFFFFF),
                            ),
                          ),
                          if (_isSearching) ...[
                            const SizedBox(height: Spacing.md),
                            const SizedBox(
                              width: 24,
                              height: 24,
                              child: FCircularProgress(),
                            ),
                          ],
                          const SizedBox(height: Spacing.lg),
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
                                const SizedBox(width: Spacing.sm),
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
