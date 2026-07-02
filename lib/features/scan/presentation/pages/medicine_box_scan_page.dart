import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/feedback/app_toast.dart';
import 'package:luminous/features/scan/data/scan_repository.dart';
import 'package:luminous/features/scan/domain/services/ocr_service.dart';
import 'package:luminous/features/scan/domain/services/medicine_text_matcher.dart';
import 'package:luminous/features/scan/presentation/widgets/medicine_recognize_dialog.dart';

enum _ScanMethod { ocr, ai }

/// Shows a bottom sheet for medicine box recognition method selection,
/// then launches the camera, processes the photo, and shows the result dialog.
Future<void> showMedicineBoxScanSheet(BuildContext context) async {
  final method = await showDialog<_ScanMethod>(
    context: context,
    builder: (ctx) => Dialog(child: _MethodSelector()),
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
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => MedicineRecognizeDialog(
          imagePath: photo.path,
          methodLabel: method == _ScanMethod.ocr ? 'OCR 识别' : 'AI 识别',
          results: results,
          onRetake: () {
            Navigator.pop(ctx);
            // Re-show the scan sheet after dismiss
            showMedicineBoxScanSheet(context);
          },
        ),
      ),
    );
  } catch (e) {
    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pop();
      unawaited(AppToast.show(context, '识别失败: $e'));
    }
  }
}

void _showProcessingOverlay(BuildContext context, _ScanMethod method) {
  showDialog(
    context: context,
    barrierDismissible: false,
    useRootNavigator: true,
    builder: (_) => PopScope(
      canPop: false,
      child: Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacingTokens.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: AppSpacingTokens.md),
                Text(
                  method == _ScanMethod.ocr ? '正在 OCR 识别...' : '正在 AI 识别...',
                ),
              ],
            ),
          ),
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
      fileName: 'medicine-box-${DateTime.now().millisecondsSinceEpoch}.jpg',
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

class _MethodSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(AppSpacingTokens.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.photo_camera_outlined,
            size: 48,
            color: Color(0xFF0F766E),
          ),
          const SizedBox(height: AppSpacingTokens.md),
          Text('选择识别方式', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacingTokens.lg),
          _MethodTile(
            icon: Icons.text_snippet_outlined,
            title: 'OCR 文字识别',
            subtitle: '设备端识别，快速离线',
            onTap: () => Navigator.pop(context, _ScanMethod.ocr),
          ),
          const SizedBox(height: AppSpacingTokens.sm),
          _MethodTile(
            icon: Icons.auto_awesome_outlined,
            title: 'AI 智能识别',
            subtitle: '云端大模型，更准确',
            onTap: () => Navigator.pop(context, _ScanMethod.ai),
          ),
          const SizedBox(height: AppSpacingTokens.lg),
        ],
      ),
    );
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
    return ListTile(
      leading: Icon(icon, color: Color(0xFF0F766E), size: 32),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
