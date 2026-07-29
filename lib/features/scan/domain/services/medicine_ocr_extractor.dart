import 'dart:math';
import 'dart:ui';

import 'package:luminous/features/scan/domain/entities/scan_result.dart';

/// Multi-strategy engine for extracting medicine info from structured OCR results.
///
/// Replaces the old plain-text matcher with layout-aware candidate ranking.
/// This extractor works with [OcrTextBlock]s that carry spatial metadata
/// (bounding box, confidence), enabling layout-aware candidate ranking.
class MedicineOcrExtractor {
  const MedicineOcrExtractor();

  /// Common OCR confusion pairs — the key is the OCR-misread character,
  /// the value is the correct character it should map back to.
  static const _ocrConfusion = {
    '淮': '准',
    '宇': '字',
    '0': 'O',
    'O': '0',
    '8': 'B',
    'B': '8',
    'l': '1',
    '1': 'l',
    '|': '1',
    '己': '已',
  };

  /// Approval number pattern after normalisation (allows some fuzzy chars).
  static final _approvalNumberPattern = RegExp(
    r'国药准[字淮宇][HhZzSsBbJjOo0l1|8B己已]\w{7,9}',
  );

  /// Extract candidates from OCR text blocks. Strategies run serially;
  /// if approval number is found, it takes priority.
  List<MedicineMatchCandidate> extractCandidates(List<OcrTextBlock> blocks) {
    if (blocks.isEmpty) return [];

    // Strategy 1: Approval number fuzzy match
    for (final block in blocks) {
      final normalized = _normalizeApprovalNumber(block.text);
      final match = _approvalNumberPattern.firstMatch(normalized);
      if (match != null) {
        final cleaned = _cleanApprovalNumber(match.group(0)!);
        return [
          MedicineMatchCandidate(
            query: cleaned,
            confidence: block.confidence.clamp(0.0, 1.0),
            matchType: MedicineMatchType.approvalNumber,
          ),
        ];
      }
    }

    // Strategy 2: Drug name via spatial layout scoring
    return _extractNameCandidates(blocks);
  }

  /// Normalise OCR text for approval-number matching:
  /// remove spaces and apply confusion mappings.
  String _normalizeApprovalNumber(String text) {
    final noSpaces = text.replaceAll(RegExp(r'\s'), '');
    final buffer = StringBuffer();
    for (final ch in noSpaces.split('')) {
      buffer.write(_ocrConfusion[ch] ?? ch);
    }
    return buffer.toString();
  }

  /// Clean a matched approval number to canonical form.
  String _cleanApprovalNumber(String matched) {
    final buffer = StringBuffer();
    for (final ch in matched.split('')) {
      buffer.write(_ocrConfusion[ch] ?? ch);
    }
    return buffer.toString();
  }

  /// Extract drug-name candidates using spatial layout scoring.
  ///
  /// On a medicine box the product name is typically the largest text element
  /// and positioned in the upper portion. We score each block by:
  /// - Area (0.5): block bounding-box area relative to image bounds
  /// - Position (0.3): blocks higher up score higher
  /// - OCR confidence (0.2): recognition confidence from the OCR engine
  /// Stop words receive a heavy penalty (×0.1).
  List<MedicineMatchCandidate> _extractNameCandidates(
    List<OcrTextBlock> blocks,
  ) {
    final imageSize = _deriveImageSize(blocks);
    final imageArea = imageSize.width * imageSize.height;

    final scored =
        blocks
            .where((b) => b.text.trim().isNotEmpty)
            .map((block) {
              final score = _nameScore(block, imageSize, imageArea);
              return (block: block, score: score);
            })
            .where((e) => e.score > 0.01)
            .toList()
          ..sort((a, b) => b.score.compareTo(a.score));

    return scored.take(5).map((e) {
      return MedicineMatchCandidate(
        query: e.block.text.trim(),
        confidence: e.score.clamp(0.0, 0.95),
        matchType: MedicineMatchType.nameFuzzy,
      );
    }).toList();
  }

  /// Derive approximate image dimensions from the max extents of all bounding boxes.
  Size _deriveImageSize(List<OcrTextBlock> blocks) {
    if (blocks.isEmpty) return Size.zero;
    var maxRight = 0.0;
    var maxBottom = 0.0;
    for (final b in blocks) {
      maxRight = max(maxRight, b.boundingBox.right);
      maxBottom = max(maxBottom, b.boundingBox.bottom);
    }
    return Size(max(maxRight, 1.0), max(maxBottom, 1.0));
  }

  /// Comprehensive score for a text block being a drug-name candidate.
  double _nameScore(OcrTextBlock block, Size imageSize, double imageArea) {
    if (imageArea <= 0) return 0.0;

    final blockArea = block.boundingBox.width * block.boundingBox.height;
    final areaScore = (blockArea / imageArea).clamp(0.0, 1.0);

    // Position: upper portion scores higher
    final positionScore =
        1.0 - (block.boundingBox.top / imageSize.height).clamp(0.0, 1.0);

    final ocrScore = block.confidence;

    final combined = areaScore * 0.5 + positionScore * 0.3 + ocrScore * 0.2;

    // Stop word penalty — exact match or substring (for multi-word labels like '用法用量')
    final text = block.text.trim();
    final isStopWord =
        _stopWords.contains(text) ||
        _stopWords.any((w) => w.length >= 2 && text.contains(w));
    if (isStopWord) {
      return combined * 0.1;
    }

    // Also penalise very short text (< 2 chars) — unlikely to be a drug name
    if (text.length < 2) {
      return combined * 0.3;
    }

    return combined;
  }

  /// Stop words commonly found on medicine packaging that are NOT drug names.
  static final _stopWords = {
    // Original set
    '药品', '用法', '用量', '注意', '事项', '禁忌', '不良反应',
    '贮藏', '规格', '厂商', '生产', '企业', '批准', '文号', '说明书',
    '包装', '本品', '一天', '每次', '每日', '一次', '两次', '三次',
    '毫克', '毫升', '克', '片', '粒',
    // Expanded — medicine box common text
    '口服', '外用', '饭前', '饭后', '睡前', '必要时',
    '儿童', '成人', '孕妇', '哺乳期', '婴幼儿', '老年人',
    '性状', '适应症', '功能主治', '药理毒理', '药代动力学',
    '有效期', '执行标准', '进口药品注册证号',
    '请仔细阅读', '请在医师指导下', '遮光', '密封', '置阴凉处',
    '常温', '冷藏', '冷冻', '避光', '干燥',
    '开封后', '本品为', '本品含', '辅料', '主要成分',
    '禁忌症', '注意事项', '药物相互作用',
    '特殊人群', '孕妇及哺乳期妇女', '儿童用药', '老年用药',
    '药物过量', '临床试验', '药理作用', '毒理研究',
    '贮藏条件', '包装材料', '铝塑包装', '纸盒',
    '批号', '生产日期', '有效期至',
    '进口', '分装', '总经销商', '代理商',
    '国药', '准字', '卫生许可证',
    '详见说明书', '请阅读',
    'mg', 'ml', 'IU', '微克', '国际单位',
  };
}
