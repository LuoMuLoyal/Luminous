import 'dart:async';
import 'dart:io';

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:image_picker/image_picker.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/utils/image_compressor.dart';
import 'package:luminous/core/widgets/common/dialog/dialog_shell.dart';
import 'package:luminous/features/scan/data/repositories/scan.dart';
import 'package:luminous/features/scan/domain/entities/scan_result.dart';
import 'package:luminous/features/scan/domain/services/candidate_merger.dart';
import 'package:luminous/features/scan/domain/services/medicine_ocr_extractor.dart';
import 'package:luminous/features/scan/domain/services/paddle_ocr_provider.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Processes a captured photo through OCR or AI recognition and returns
/// matched medicine candidates.
Future<List<MedicineMatchResult>> processPhoto(
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

/// Shows a dialog prompting the user to download OCR model files (~30MB).
///
/// Returns `true` if the user confirms the download, `false` otherwise.
Future<bool?> showModelDownloadDialog(
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
        const SizedBox(height: Spacing.sm),
        Text(
          l10n.scanModelDownloadMessage,
          style: dialogContext.theme.dialogStyle.bodyTextStyle,
        ),
        const SizedBox(height: Spacing.xl),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FButton(
              variant: FButtonVariant.outline,
              onPress: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.scanModelDownloadCancel),
            ),
            const SizedBox(width: Spacing.md),
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
///
/// [onRetry] is called when the user taps the retry button.
Future<void> showModelDownloadFailedDialog(
  BuildContext context,
  AppLocalizations l10n, {
  required Future<void> Function() onRetry,
}) async {
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
        const SizedBox(height: Spacing.sm),
        Text(
          l10n.scanModelDownloadFailedMessage,
          style: dialogContext.theme.dialogStyle.bodyTextStyle,
        ),
        const SizedBox(height: Spacing.xl),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FButton(
              variant: FButtonVariant.outline,
              onPress: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.scanCloseAction),
            ),
            const SizedBox(width: Spacing.md),
            FButton(
              onPress: () {
                Navigator.of(dialogContext).pop();
                unawaited(onRetry());
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
///
/// [onUseAi] is called when the user taps the AI fallback button.
Future<void> showOcrUnavailableDialog(
  BuildContext context,
  AppLocalizations l10n, {
  required Future<void> Function() onUseAi,
}) async {
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
        const SizedBox(height: Spacing.sm),
        Text(
          l10n.scanOcrUnavailableMessage,
          style: dialogContext.theme.dialogStyle.bodyTextStyle,
        ),
        const SizedBox(height: Spacing.xl),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FButton(
              variant: FButtonVariant.outline,
              onPress: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.scanCloseAction),
            ),
            const SizedBox(width: Spacing.md),
            FButton(
              onPress: () {
                Navigator.of(dialogContext).pop();
                // Jump straight to the AI camera flow (F-7) instead of
                // re-showing the method picker; the F-5 auth gate lives
                // inside _startPhotoScan, so signed-out users still get the
                // login prompt before the camera opens.
                unawaited(onUseAi());
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
void dismissOverlay(BuildContext context) {
  final navigator = Navigator.of(context, rootNavigator: true);
  if (navigator.canPop()) {
    navigator.pop();
  }
}

/// Shows a dialog when scan recognition fails, offering manual search or retry.
///
/// [onRetry] is called when the user taps the retake button.
/// [onManualSearch] is called when the user taps the manual search button.
Future<void> showScanFailureDialog(
  BuildContext context,
  AppLocalizations l10n, {
  required Future<void> Function() onRetry,
  required Future<void> Function() onManualSearch,
}) async {
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
        const SizedBox(height: Spacing.sm),
        Text(
          l10n.scanManualSearchToast,
          style: dialogContext.theme.dialogStyle.bodyTextStyle,
        ),
        const SizedBox(height: Spacing.xl),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FButton(
              variant: FButtonVariant.outline,
              onPress: () {
                Navigator.of(dialogContext).pop();
                unawaited(onRetry());
              },
              child: Text(l10n.scanRetakeAction),
            ),
            const SizedBox(width: Spacing.md),
            FButton(
              onPress: () {
                Navigator.of(dialogContext).pop();
                unawaited(onManualSearch());
              },
              child: Text(l10n.scanManualSearchAction),
            ),
          ],
        ),
      ],
    ),
  );
}

/// Shows a non-dismissible processing overlay with a progress indicator.
void showProcessingOverlay(BuildContext context, MedicineScanMethod method) {
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
            const SizedBox(height: Spacing.lg),
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
