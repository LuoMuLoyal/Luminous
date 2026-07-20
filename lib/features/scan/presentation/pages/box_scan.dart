import 'dart:async';
import 'dart:io';

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:image_picker/image_picker.dart';

import 'package:go_router/go_router.dart';

import 'package:luminous/app/router.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/logger/logger.dart';
import 'package:luminous/core/utils/image_compressor.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/features/scan/data/scan_repository.dart';
import 'package:luminous/features/scan/domain/services/ocr_service.dart';
import 'package:luminous/features/scan/domain/services/text_matcher.dart';
import 'package:luminous/features/scan/presentation/widgets/dialogs/recognize_dialog.dart';

enum _ScanMethod { ocr, ai }

/// Shows a bottom sheet for medicine box recognition method selection,
/// then launches the camera, processes the photo, and shows the result dialog.
Future<void> showMedicineBoxScanSheet(BuildContext context) async {
  final l10n = AppLocalizations.of(context)!;
  final method = await showFDialog<_ScanMethod>(
    context: context,
    builder: (dialogContext, style, animation) => FDialog(
      title: Text(l10n.scanMethodPickerTitle),
      actions: const [],
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _MethodTile(
            icon: FLucideIcons.camera,
            title: l10n.scanMethodOcrTitle,
            subtitle: l10n.scanMethodOcrSubtitle,
            onTap: () => Navigator.of(dialogContext).pop(_ScanMethod.ocr),
          ),
          const SizedBox(height: Spacing.level3),
          _MethodTile(
            icon: FLucideIcons.sparkles,
            title: l10n.scanMethodAiTitle,
            subtitle: l10n.scanMethodAiSubtitle,
            onTap: () => Navigator.of(dialogContext).pop(_ScanMethod.ai),
          ),
        ],
      ),
    ),
  );

  if (method == null || !context.mounted) return;

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
      showFDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext, style, animation) => MedicineRecognizeDialog(
          imagePath: photo.path,
          methodLabel: method == _ScanMethod.ocr
              ? l10n.scanMethodOcrLabel
              : l10n.scanMethodAiLabel,
          results: results,
          onRetake: () {
            Navigator.of(dialogContext).pop();
            // Re-show the scan sheet after dismiss
            showMedicineBoxScanSheet(context);
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
  await showFDialog<void>(
    context: context,
    builder: (dialogContext, style, animation) => FDialog(
      title: Text(l10n.scanRecognitionFailedToast),
      body: Text(l10n.scanManualSearchToast),
      actions: [
        FButton(
          variant: FButtonVariant.outline,
          onPress: () {
            Navigator.of(dialogContext).pop();
            showMedicineBoxScanSheet(context);
          },
          child: Text(l10n.scanRetakeAction),
        ),
        FButton(
          onPress: () {
            Navigator.of(dialogContext).pop();
            context.push(AppRoutes.medicineSearch);
          },
          child: Text(l10n.scanManualSearchAction),
        ),
      ],
    ),
  );
}

void _showProcessingOverlay(BuildContext context, _ScanMethod method) {
  final l10n = AppLocalizations.of(context)!;
  showFDialog(
    context: context,
    barrierDismissible: false,
    builder: (_, style, animation) => PopScope(
      canPop: false,
      child: FDialog(
        actions: const [],
        body: Column(
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
    final ocrText = await const OcrService().recognizeText(photo);
    final candidates = const MedicineTextMatcher().extractCandidates(ocrText);

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
    final bytes = await AppImageCompressor.compressForAiRecognition(rawBytes);
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

    return FCard.raw(
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
        prefix: Icon(icon, color: colors.primary, size: 32),
        title: Text(title),
        subtitle: Text(
          subtitle,
          style: typography.body.sm.copyWith(color: colors.mutedForeground),
        ),
        suffix: Icon(FLucideIcons.chevronRight, color: colors.mutedForeground),
      ),
    );
  }
}
