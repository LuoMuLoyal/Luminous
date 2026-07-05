import 'dart:async';
import 'dart:io';

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:image_picker/image_picker.dart';

import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/feedback/app_toast.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/features/scan/data/scan_repository.dart';
import 'package:luminous/features/scan/domain/services/ocr_service.dart';
import 'package:luminous/features/scan/domain/services/medicine_text_matcher.dart';
import 'package:luminous/features/scan/presentation/widgets/medicine_recognize_dialog.dart';

enum _ScanMethod { ocr, ai }

/// Shows a bottom sheet for medicine box recognition method selection,
/// then launches the camera, processes the photo, and shows the result dialog.
Future<void> showMedicineBoxScanSheet(BuildContext context) async {
  final method = await showFDialog<_ScanMethod>(
    context: context,
    builder: (dialogContext, style, animation) => FDialog(
      title: Text(AppLocalizations.of(context)!.scanMethodPickerTitle),
      actions: const [],
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _MethodTile(
            icon: FLucideIcons.camera,
            title: 'OCR 文字识别',
            subtitle: '设备端识别，快速离线',
            onTap: () => Navigator.of(dialogContext).pop(_ScanMethod.ocr),
          ),
          const SizedBox(height: AppSpacingTokens.level3),
          _MethodTile(
            icon: FLucideIcons.sparkles,
            title: 'AI 智能识别',
            subtitle: '云端大模型，更准确',
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

    // Dismiss processing overlay
    Navigator.of(context, rootNavigator: true).pop();

    unawaited(
      showFDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext, style, animation) => MedicineRecognizeDialog(
          imagePath: photo.path,
          methodLabel: method == _ScanMethod.ocr ? 'OCR 识别' : 'AI 识别',
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
    debugPrint('showMedicineBoxScanSheet: failed: $e');
    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pop();
      unawaited(AppToast.show(context, '识别失败: $e'));
    }
  }
}

void _showProcessingOverlay(BuildContext context, _ScanMethod method) {
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
            const SizedBox(height: AppSpacingTokens.level4),
            Text(method == _ScanMethod.ocr ? '正在 OCR 识别...' : '正在 AI 识别...'),
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
    final bytes = await File(photo.path).readAsBytes();
    final imageUrl = await repo.uploadImage(
      bytes: bytes,
      contentType: 'image/jpeg',
      fileName: 'medicine-box-${clock.now().millisecondsSinceEpoch}.jpg',
    );
    final json = await repo.recognizeMedicine(imageUrl);

    final name = json['name'] as String? ?? '';
    final approvalNumber = json['approvalNumber'] as String? ?? '';
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
