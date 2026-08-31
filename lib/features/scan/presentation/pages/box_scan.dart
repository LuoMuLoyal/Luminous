import 'dart:async';
import 'dart:io';

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/logger/log_level.dart';
import 'package:luminous/core/utils/image_compressor.dart';
import 'package:luminous/core/widgets/auth/required_dialog.dart';
import 'package:luminous/core/widgets/common/dialog/dialog_shell.dart';
import 'package:luminous/features/scan/data/repositories/scan.dart';
import 'package:luminous/features/scan/domain/entities/scan_result.dart';
import 'package:luminous/features/scan/domain/services/candidate_merger.dart';
import 'package:luminous/features/scan/domain/services/medicine_ocr_extractor.dart';
import 'package:luminous/features/scan/domain/services/ocr_model_manager.dart';
import 'package:luminous/features/scan/domain/services/paddle_ocr_provider.dart';
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
        const SizedBox(height: Spacing.level4),
        _MethodTile(
          icon: SemanticIcons.actionCamera,
          title: l10n.scanMethodOcrTitle,
          subtitle: l10n.scanMethodOcrSubtitle,
          onTap: () => Navigator.of(dialogContext).pop(MedicineScanMethod.ocr),
        ),
        const SizedBox(height: Spacing.level3),
        _MethodTile(
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
      final shouldDownload = await _showModelDownloadDialog(context, l10n);
      if (shouldDownload != true || !context.mounted) return;

      // Download models with a progress overlay.
      _showProcessingOverlay(context, MedicineScanMethod.ocr);
      try {
        await modelManager.downloadModels();
      } catch (e, st) {
        appTalker.error('OCR model download failed: $e', e, st);
        if (context.mounted) {
          _dismissOverlay(context);
          await _showModelDownloadFailedDialog(context, l10n);
        }
        return;
      }
      if (context.mounted) _dismissOverlay(context);
    }

    final ocrEngine = await container.read(paddleOcrProvider.future);
    try {
      await ocrEngine.ensureInitialized();
    } catch (e, st) {
      appTalker.warning('OCR engine init failed (ABI pre-check): $e', e, st);
      if (context.mounted) {
        await _showOcrUnavailableDialog(context, l10n);
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
  _showProcessingOverlay(context, method);

  try {
    final results = await _processPhoto(context, photo, method);
    if (!context.mounted) return;

    // Dismiss processing overlay safely.
    _dismissOverlay(context);

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
      _dismissOverlay(context);
      if (context.mounted) {
        await _showScanFailureDialog(context, l10n);
      }
    }
  }
}

/// Shows a dialog prompting the user to download OCR model files (~30MB).
///
/// Returns `true` if the user confirms the download, `false` otherwise.
Future<bool?> _showModelDownloadDialog(
  BuildContext context,
  AppLocalizations l10n,
) async {
  return showAppDialog<bool>(
    context: context,
    scrollable: false,
    builder: (dialogContext) => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.scanModelDownloadTitle,
          style: dialogContext.theme.dialogStyle.titleTextStyle,
        ),
        const SizedBox(height: Spacing.level2),
        Text(
          l10n.scanModelDownloadMessage,
          style: dialogContext.theme.dialogStyle.bodyTextStyle,
        ),
        const SizedBox(height: Spacing.level5),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FButton(
              variant: FButtonVariant.outline,
              onPress: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.scanModelDownloadCancel),
            ),
            const SizedBox(width: Spacing.level3),
            FButton(
              onPress: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.scanModelDownloadConfirm),
            ),
          ],
        ),
      ],
    ),
  );
}

/// Shows a dialog when OCR model download fails.
Future<void> _showModelDownloadFailedDialog(
  BuildContext context,
  AppLocalizations l10n,
) async {
  await showAppDialog<void>(
    context: context,
    scrollable: false,
    builder: (dialogContext) => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.scanModelDownloadFailedTitle,
          style: dialogContext.theme.dialogStyle.titleTextStyle,
        ),
        const SizedBox(height: Spacing.level2),
        Text(
          l10n.scanModelDownloadFailedMessage,
          style: dialogContext.theme.dialogStyle.bodyTextStyle,
        ),
        const SizedBox(height: Spacing.level5),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FButton(
              variant: FButtonVariant.outline,
              onPress: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.scanCloseAction),
            ),
            const SizedBox(width: Spacing.level3),
            FButton(
              onPress: () {
                Navigator.of(dialogContext).pop();
                unawaited(showMedicineBoxScanSheet(context));
              },
              child: Text(l10n.scanModelDownloadRetry),
            ),
          ],
        ),
      ],
    ),
  );
}

/// Shows a dialog when OCR is unavailable, offering to switch directly to AI
/// recognition (which skips the method picker, F-7).
Future<void> _showOcrUnavailableDialog(
  BuildContext context,
  AppLocalizations l10n,
) async {
  await showAppDialog<void>(
    context: context,
    scrollable: false,
    builder: (dialogContext) => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.scanOcrUnavailableTitle,
          style: dialogContext.theme.dialogStyle.titleTextStyle,
        ),
        const SizedBox(height: Spacing.level2),
        Text(
          l10n.scanOcrUnavailableMessage,
          style: dialogContext.theme.dialogStyle.bodyTextStyle,
        ),
        const SizedBox(height: Spacing.level5),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FButton(
              variant: FButtonVariant.outline,
              onPress: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.scanCloseAction),
            ),
            const SizedBox(width: Spacing.level3),
            FButton(
              onPress: () {
                Navigator.of(dialogContext).pop();
                // Jump straight to the AI camera flow (F-7) instead of
                // re-showing the method picker; the F-5 auth gate lives
                // inside _startPhotoScan, so signed-out users still get the
                // login prompt before the camera opens.
                unawaited(_startPhotoScan(context, MedicineScanMethod.ai));
              },
              child: Text(l10n.scanOcrUnavailableUseAi),
            ),
          ],
        ),
      ],
    ),
  );
}

/// Safely dismisses the processing overlay dialog from the root navigator.
void _dismissOverlay(BuildContext context) {
  final navigator = Navigator.of(context, rootNavigator: true);
  if (navigator.canPop()) {
    navigator.pop();
  }
}

/// Shows a dialog when scan recognition fails, offering manual search or retry.
Future<void> _showScanFailureDialog(
  BuildContext context,
  AppLocalizations l10n,
) async {
  await showAppDialog<void>(
    context: context,
    scrollable: false,
    builder: (dialogContext) => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.scanRecognitionFailedToast,
          style: dialogContext.theme.dialogStyle.titleTextStyle,
        ),
        const SizedBox(height: Spacing.level2),
        Text(
          l10n.scanManualSearchToast,
          style: dialogContext.theme.dialogStyle.bodyTextStyle,
        ),
        const SizedBox(height: Spacing.level5),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FButton(
              variant: FButtonVariant.outline,
              onPress: () {
                Navigator.of(dialogContext).pop();
                unawaited(showMedicineBoxScanSheet(context));
              },
              child: Text(l10n.scanRetakeAction),
            ),
            const SizedBox(width: Spacing.level3),
            FButton(
              onPress: () {
                Navigator.of(dialogContext).pop();
                unawaited(context.push(Routes.medicineSearch));
              },
              child: Text(l10n.scanManualSearchAction),
            ),
          ],
        ),
      ],
    ),
  );
}

void _showProcessingOverlay(BuildContext context, MedicineScanMethod method) {
  final l10n = AppLocalizations.of(context)!;
  unawaited(
    showAppDialog<void>(
      context: context,
      barrierDismissible: false,
      scrollable: false,
      builder: (_) => PopScope(
        canPop: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const FCircularProgress(),
            const SizedBox(height: Spacing.level4),
            Text(
              method == MedicineScanMethod.ocr
                  ? l10n.scanProcessingOcr
                  : l10n.scanProcessingAi,
            ),
          ],
        ),
      ),
    ),
  );
}

Future<List<MedicineMatchResult>> _processPhoto(
  BuildContext context,
  XFile photo,
  MedicineScanMethod method,
) async {
  final container = ProviderScope.containerOf(context);
  final repo = container.read(scanRepositoryProvider);

  if (method == MedicineScanMethod.ocr) {
    final ocrEngine = await container.read(paddleOcrProvider.future);
    final ocrBlocks = await ocrEngine.recognize(photo.path);
    // 候选先按规范化 query 去重（同一批准文号/药名可能从多个文本块重复
    // 提取），减少重复搜索；搜库结果再按稳定药品 id 合并（F-4）。
    final candidates = dedupeCandidates(
      const MedicineOcrExtractor().extractCandidates(ocrBlocks),
    );

    final results = <MedicineMatchResult>[];
    for (final candidate in candidates) {
      final searchResult = await repo.search(candidate.query).run();
      final items = searchResult.fold(
        (failure) => throw failure,
        (items) => items,
      );
      for (final item in items) {
        results.add(
          MedicineMatchResult(
            name: item.name,
            id: item.id,
            confidence: candidate.confidence,
            matchType: candidate.matchType,
          ),
        );
      }
    }

    // 不同候选 query 可能搜到同一药品，按稳定药品 id 合并（id 缺失按名称
    // 兜底），弹窗不再出现重复候选。
    return mergeSearchResults(results);
  } else {
    final rawBytes = await File(photo.path).readAsBytes();
    final bytes = await ImageCompressor.compressForAiRecognition(rawBytes);
    final uploadResult = await repo
        .uploadImage(
          bytes: bytes,
          contentType: 'image/jpeg',
          fileName: 'medicine-box-${clock.now().millisecondsSinceEpoch}.jpg',
        )
        .run();
    final imageUrl = uploadResult.fold(
      (failure) => throw failure,
      (url) => url,
    );
    final recognitionResult = await repo.recognizeMedicine(imageUrl).run();
    final recognition = recognitionResult.fold(
      (failure) => throw failure,
      (result) => result,
    );

    final name = recognition.name;
    final approvalNumber = recognition.approvalNumber ?? '';
    if (name.isEmpty && approvalNumber.isEmpty) return [];

    final query = approvalNumber.isNotEmpty ? approvalNumber : name;
    final aiSearchResult = await repo.search(query).run();
    final items = aiSearchResult.fold(
      (failure) => throw failure,
      (items) => items,
    );

    return items.map((item) {
      // The AI recognition path has no real confidence score from the
      // backend; leaving it null instead of fabricating one (F-6).
      return MedicineMatchResult(
        name: item.name,
        id: item.id,
        matchType: MedicineMatchType.nameFuzzy,
      );
    }).toList();
  }
}

class _MethodTile extends StatelessWidget {
  const _MethodTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;

    return FCard(
      style: .delta(
        decoration: .shapeDelta(
          color: colors.background,
          shape: RoundedSuperellipseBorder(
            side: BorderSide(color: SemanticColor.neutral.border(context)),
            borderRadius: context.theme.style.borderRadius.lg,
          ),
        ),
      ),
      child: FTile(
        onPress: onTap,
        prefix: Icon(
          icon,
          color: SemanticColor.primary.solid(context),
          size: IconSizeTokens.level6,
        ),
        title: Text(title),
        subtitle: Text(
          subtitle,
          style: typography.body.sm.copyWith(
            color: SemanticColor.neutral.solid(context),
          ),
        ),
        suffix: Icon(
          SemanticIcons.actionNext,
          color: SemanticColor.neutral.solid(context),
        ),
      ),
    );
  }
}
