import 'dart:async';
import 'dart:io';

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/logger/logger.dart';
import 'package:luminous/core/utils/image_compressor.dart';
import 'package:luminous/core/widgets/common/dialog_shell.dart';
import 'package:luminous/features/scan/data/repositories/scan.dart';
import 'package:luminous/features/scan/domain/entities/scan_result.dart';
import 'package:luminous/features/scan/domain/services/medicine_ocr_extractor.dart';
import 'package:luminous/features/scan/domain/services/paddle_ocr_provider.dart';
import 'package:luminous/features/scan/presentation/widgets/dialogs/recognize_dialog.dart';
import 'package:luminous/l10n/app_localizations.dart';

enum _ScanMethod { ocr, ai }

/// Shows a bottom sheet for medicine box recognition method selection,
/// then launches the camera, processes the photo, and shows the result dialog.
Future<void> showMedicineBoxScanSheet(BuildContext context) async {
  final l10n = AppLocalizations.of(context)!;
  final method = await showAppDialog<_ScanMethod>(
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
          onTap: () => Navigator.of(dialogContext).pop(_ScanMethod.ocr),
        ),
        const SizedBox(height: Spacing.level3),
        _MethodTile(
          icon: SemanticIcons.aiEntry,
          title: l10n.scanMethodAiTitle,
          subtitle: l10n.scanMethodAiSubtitle,
          onTap: () => Navigator.of(dialogContext).pop(_ScanMethod.ai),
        ),
      ],
    ),
  );

  if (method == null || !context.mounted) return;

  // Pre-check: verify the OCR engine can initialise before opening the camera.
  // This catches ABI incompatibility (non-arm64 devices) and model-loading
  // failures early, instead of letting the user take a photo first.
  if (method == _ScanMethod.ocr) {
    final container = ProviderScope.containerOf(context);
    final ocrEngine = container.read(paddleOcrProvider);
    try {
      await ocrEngine.ensureInitialized();
    } catch (e) {
      appTalker.warning('OCR engine init failed (ABI pre-check): $e');
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
          methodLabel: method == _ScanMethod.ocr
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
    appTalker.error('showMedicineBoxScanSheet: failed: $e');
    if (context.mounted) {
      _dismissOverlay(context);
      if (context.mounted) {
        await _showScanFailureDialog(context, l10n);
      }
    }
  }
}

/// Shows a dialog when OCR is unavailable, offering to switch to AI recognition.
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
                unawaited(showMedicineBoxScanSheet(context));
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

void _showProcessingOverlay(BuildContext context, _ScanMethod method) {
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
              method == _ScanMethod.ocr
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
  _ScanMethod method,
) async {
  final container = ProviderScope.containerOf(context);
  final repo = container.read(scanRepositoryProvider);

  if (method == _ScanMethod.ocr) {
    final ocrEngine = container.read(paddleOcrProvider);
    final ocrBlocks = await ocrEngine.recognize(photo.path);
    final candidates = const MedicineOcrExtractor().extractCandidates(
      ocrBlocks,
    );

    final results = <MedicineMatchResult>[];
    for (final candidate in candidates) {
      final items = await repo.search(candidate.query);
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

    return results;
  } else {
    final rawBytes = await File(photo.path).readAsBytes();
    final bytes = await ImageCompressor.compressForAiRecognition(rawBytes);
    final imageUrl = await repo.uploadImage(
      bytes: bytes,
      contentType: 'image/jpeg',
      fileName: 'medicine-box-${clock.now().millisecondsSinceEpoch}.jpg',
    );
    final recognition = await repo.recognizeMedicine(imageUrl);

    final name = recognition.name;
    final approvalNumber = recognition.approvalNumber ?? '';
    if (name.isEmpty && approvalNumber.isEmpty) return [];

    final query = approvalNumber.isNotEmpty ? approvalNumber : name;
    final items = await repo.search(query);

    return items.map((item) {
      return MedicineMatchResult(
        name: item.name,
        id: item.id,
        confidence: 0.9,
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
            side: BorderSide(color: colors.border),
            borderRadius: context.theme.style.borderRadius.lg,
          ),
        ),
      ),
      child: FTile(
        onPress: onTap,
        prefix: Icon(icon, color: colors.primary, size: IconSizeTokens.level5),
        title: Text(title),
        subtitle: Text(
          subtitle,
          style: typography.body.sm.copyWith(color: colors.mutedForeground),
        ),
        suffix: Icon(SemanticIcons.actionNext, color: colors.mutedForeground),
      ),
    );
  }
}
