import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/logger/log_level.dart';
import 'package:luminous/core/widgets/auth/required_dialog.dart';
import 'package:luminous/core/widgets/common/dialog/dialog_shell.dart';
import 'package:luminous/features/scan/domain/entities/scan_result.dart';
import 'package:luminous/features/scan/domain/services/ocr_model_manager.dart';
import 'package:luminous/features/scan/domain/services/paddle_ocr_provider.dart';
import 'package:luminous/features/scan/presentation/utils/box_scan_handlers.dart';
import 'package:luminous/features/scan/presentation/widgets/box_scan_preview.dart';
import 'package:luminous/features/scan/presentation/widgets/dialogs/recognize_dialog.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Shows a bottom sheet for medicine box recognition method selection,
/// then launches the camera, processes the photo, and shows the result dialog.
Future<void> showMedicineBoxScanSheet(BuildContext context) async {
  final l10n = AppLocalizations.of(context)!;
  final method = await showAppDialog<MedicineScanMethod>(
    context: context,
    scrollable: false,
    builder: (dialogContext) => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.scanMethodPickerTitle,
          style: dialogContext.theme.dialogStyle.titleTextStyle,
        ),
        const SizedBox(height: Spacing.lg),
        MethodTile(
          icon: SemanticIcons.actionCamera,
          title: l10n.scanMethodOcrTitle,
          subtitle: l10n.scanMethodOcrSubtitle,
          onTap: () => Navigator.of(dialogContext).pop(MedicineScanMethod.ocr),
        ),
        const SizedBox(height: Spacing.md),
        MethodTile(
          icon: SemanticIcons.aiEntry,
          title: l10n.scanMethodAiTitle,
          subtitle: l10n.scanMethodAiSubtitle,
          onTap: () => Navigator.of(dialogContext).pop(MedicineScanMethod.ai),
        ),
      ],
    ),
  );

  if (method == null || !context.mounted) return;
  await _startPhotoScan(context, method);
}

/// Launches the camera for [method], processes the photo, and shows the result
/// dialog. Shared by the method picker and the OCR-unavailable fallback (F-7),
/// which jumps straight to AI recognition instead of re-selecting a method.
Future<void> _startPhotoScan(
  BuildContext context,
  MedicineScanMethod method,
) async {
  final l10n = AppLocalizations.of(context)!;

  // Auth gate: the AI recognition path (compress → COS presigned upload →
  // POST /api/v1/medicines/recognize) requires login, unlike the public OCR
  // search path. Signed-out users get the login prompt here instead of
  // falling into the generic recognition-failure dialog at the upload step
  // (F-5). The OCR branch below is deliberately not gated.
  if (method == MedicineScanMethod.ai) {
    final container = ProviderScope.containerOf(context);
    final authSession = container.read(authSessionProvider);
    if (!authSession.canAccessProtectedData) {
      if (authSession.isLoading) return;
      if (context.mounted) {
        await showAuthRequiredDialog(
          context,
          onLogin: () => context.push(loginRouteForCurrentLocation(context)),
        );
      }
      return;
    }
  }

  // Pre-check: verify the OCR engine can initialise before opening the camera.
  // This catches ABI incompatibility (non-arm64 devices), missing model files,
  // and model-loading failures early, instead of letting the user take a
  // photo first.
  if (method == MedicineScanMethod.ocr) {
    final container = ProviderScope.containerOf(context);
    final modelManager = await container.read(ocrModelManagerProvider.future);

    if (!modelManager.isModelAvailable()) {
      if (!context.mounted) return;
      final shouldDownload = await showModelDownloadDialog(context, l10n);
      if (shouldDownload != true || !context.mounted) return;

      // Download models with a progress overlay.
      showProcessingOverlay(context, MedicineScanMethod.ocr);
      try {
        await modelManager.downloadModels();
      } catch (e, st) {
        appTalker.error('OCR model download failed: $e', e, st);
        if (context.mounted) {
          dismissOverlay(context);
          await showModelDownloadFailedDialog(
            context,
            l10n,
            onRetry: () => showMedicineBoxScanSheet(context),
          );
        }
        return;
      }
      if (context.mounted) dismissOverlay(context);
    }

    final ocrEngine = await container.read(paddleOcrProvider.future);
    try {
      await ocrEngine.ensureInitialized();
    } catch (e, st) {
      appTalker.warning('OCR engine init failed (ABI pre-check): $e', e, st);
      if (context.mounted) {
        await showOcrUnavailableDialog(
          context,
          l10n,
          onUseAi: () => _startPhotoScan(context, MedicineScanMethod.ai),
        );
      }
      return;
    }
  }

  final photo = await ImagePicker().pickImage(
    source: ImageSource.camera,
    imageQuality: 90,
  );
  if (photo == null || !context.mounted) return;

  // Show processing overlay
  showProcessingOverlay(context, method);

  try {
    final results = await processPhoto(context, photo, method);
    if (!context.mounted) return;

    // Dismiss processing overlay safely.
    dismissOverlay(context);

    unawaited(
      showAppDialog<void>(
        context: context,
        barrierDismissible: false,
        scrollable: false,
        builder: (dialogContext) => MedicineRecognizeDialog(
          imagePath: photo.path,
          method: method,
          methodLabel: method == MedicineScanMethod.ocr
              ? l10n.scanMethodOcrLabel
              : l10n.scanMethodAiLabel,
          results: results,
          onRetake: () {
            Navigator.of(dialogContext).pop();
            // Re-show the scan sheet after dismiss
            unawaited(showMedicineBoxScanSheet(context));
          },
        ),
      ),
    );
  } catch (e) {
    appTalker.error('_startPhotoScan: failed: $e');
    if (context.mounted) {
      dismissOverlay(context);
      if (context.mounted) {
        await showScanFailureDialog(
          context,
          l10n,
          onRetry: () => showMedicineBoxScanSheet(context),
          onManualSearch: () => context.push(Routes.medicineSearch),
        );
      }
    }
  }
}
