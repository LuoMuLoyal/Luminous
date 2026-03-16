import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:luminous/api/scan_api.dart';
import 'package:luminous/pages/Drug/medicine_detail.dart';
import 'package:luminous/stores/app_database.dart';
import 'package:luminous/stores/user_controller.dart';
import 'package:luminous/utils/gallery_saver.dart';
import 'package:luminous/utils/toast_utils.dart';
import 'package:luminous/viewmodels/medicine.dart';
import 'package:luminous/viewmodels/scan.dart';
import 'package:permission_handler/permission_handler.dart';

enum ScanEntryMode {
  /// 首页入口：拍照后主要展示识别结果
  result,

  /// 药品页入口：拍照后主要展示操作项（添加/保存/查看/重拍）
  actions,
}

class MedicineScanPage extends StatefulWidget {
  const MedicineScanPage({
    super.key,
    this.mode = ScanEntryMode.result,
    this.autoStart = true,
  });

  final ScanEntryMode mode;
  final bool autoStart;

  @override
  State<MedicineScanPage> createState() => _MedicineScanPageState();
}

class _MedicineScanPageState extends State<MedicineScanPage> {
  final UserController _userController = Get.find<UserController>();

  final DraggableScrollableController _sheetController =
      DraggableScrollableController();
  double _sheetSize = 0.36;

  Uint8List? _photoBytes;
  String _photoMimeType = 'image/jpeg';

  bool _savingToGallery = false;
  bool _scanning = false;
  MedicineScanResult? _scanResult;
  int _selectedIndex = 0;

  String? _lastError;

  @override
  void initState() {
    super.initState();
    _sheetController.addListener(_onSheetChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Auto slide up for the "photo shrink / content reveal" effect.
      unawaited(_autoExpandSheet());
      if (widget.autoStart) {
        await _retakeAndScan();
      }
    });
  }

  @override
  void dispose() {
    _sheetController.removeListener(_onSheetChanged);
    _sheetController.dispose();
    super.dispose();
  }

  void _onSheetChanged() {
    final next = _sheetController.size;
    if ((next - _sheetSize).abs() < 0.001) {
      return;
    }
    setState(() {
      _sheetSize = next;
    });
  }

  Future<void> _autoExpandSheet() async {
    try {
      await Future<void>.delayed(const Duration(milliseconds: 60));
      if (!mounted) return;
      await _sheetController.animateTo(
        0.72,
        duration: const Duration(milliseconds: 520),
        curve: Curves.easeOutCubic,
      );
    } catch (_) {
      // Ignore: controller might not be attached yet.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(widget.mode == ScanEntryMode.actions ? '药物识别' : '识别结果'),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final minChildSize = 0.22;
          final maxChildSize = 0.90;

          final t = ((_sheetSize - minChildSize) / (maxChildSize - minChildSize))
              .clamp(0.0, 1.0);
          final maxImageHeight = constraints.maxHeight * 0.62;
          final minImageHeight = constraints.maxHeight * 0.28;
          final imageHeight = maxImageHeight - (maxImageHeight - minImageHeight) * t;

          return Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: imageHeight,
                child: _buildPhotoArea(),
              ),
              Positioned.fill(
                child: DraggableScrollableSheet(
                  controller: _sheetController,
                  minChildSize: minChildSize,
                  maxChildSize: maxChildSize,
                  initialChildSize: 0.36,
                  snap: true,
                  snapSizes: const [0.36, 0.72, 0.90],
                  builder: (context, scrollController) {
                    return _buildSheet(scrollController);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPhotoArea() {
    final bytes = _photoBytes;
    return Container(
      color: Colors.black,
      alignment: Alignment.center,
      child: bytes == null
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt_outlined,
                    color: Colors.white,
                    size: 34,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  '准备拍照识别',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            )
          : ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(18)),
              child: Image.memory(
                bytes,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
    );
  }

  Widget _buildSheet(ScrollController scrollController) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Color(0xFFF3F7FB),
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: ListView(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
        children: [
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: 10),
          _buildHeaderRow(),
          const SizedBox(height: 12),
          if (_lastError != null) _buildErrorCard(_lastError!),
          if (widget.mode == ScanEntryMode.actions)
            _buildActionsSection()
          else
            _buildResultSection(),
          const SizedBox(height: 10),
          if (widget.mode == ScanEntryMode.actions) _buildResultSection(compact: true),
          const SizedBox(height: 10),
          _buildBottomButtons(),
        ],
      ),
    );
  }

  Widget _buildHeaderRow() {
    final title = widget.mode == ScanEntryMode.actions ? '药物识别' : '识别结果';
    final subtitle = _scanning
        ? '识别中，请稍等...'
        : _scanResult == null
            ? '拍照后上传，由后端调用腾讯云智能问药能力识别药品信息'
            : '共识别 ${_scanResult!.candidates.length} 个候选结果';

    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.camera_alt_outlined, color: Color(0xFF10B981)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        FilledButton.tonalIcon(
          onPressed: _savingToGallery || _scanning ? null : _retakeAndScan,
          icon: const Icon(Icons.camera_alt_rounded, size: 16),
          label: const Text('重拍'),
        ),
      ],
    );
  }

  Widget _buildErrorCard(String message) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFFEE2E2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF7F1D1D),
                fontWeight: FontWeight.w700,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsSection() {
    return Column(
      children: [
        _ActionTile(
          icon: Icons.add_circle_outline_rounded,
          color: const Color(0xFF0EA5E9),
          label: '添加到我的药品',
          subtitle: '识别后直接加入药品列表',
          onTap: _scanResult == null ? null : _addSelectedToMyMedicines,
        ),
        const SizedBox(height: 10),
        _ActionTile(
          icon: Icons.photo_library_outlined,
          color: const Color(0xFF6366F1),
          label: '保存到相册',
          subtitle: _savingToGallery ? '保存中...' : '将拍摄的照片保存至相册',
          onTap: _photoBytes == null ? null : _saveToGalleryOnly,
        ),
        const SizedBox(height: 10),
        _ActionTile(
          icon: Icons.info_outline_rounded,
          color: const Color(0xFFF59E0B),
          label: '查看详细信息',
          subtitle: '查看基础信息与 AI 解读',
          onTap: _scanResult == null ? null : _openSelectedDetail,
        ),
      ],
    );
  }

  Widget _buildResultSection({bool compact = false}) {
    final result = _scanResult;
    if (_scanning) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        alignment: Alignment.center,
        child: const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    if (result == null) {
      return Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: const Text(
          '拍照后我们会把图片上传到后端，由腾讯云智能问药能力完成识别。\n如识别到多个结果，你可以在列表里选择正确的药品。',
          style: TextStyle(
            fontSize: 13,
            height: 1.55,
            color: Color(0xFF475569),
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    if (result.candidates.isEmpty) {
      return Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: const Text(
          '未识别到有效结果，请尝试重新拍摄（保证光线充足、文字清晰）。',
          style: TextStyle(
            fontSize: 13,
            height: 1.55,
            color: Color(0xFF475569),
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    final title = compact ? '识别结果（可选择）' : '识别结果';

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 10),
          ...result.candidates.asMap().entries.map((entry) {
            final index = entry.key;
            final c = entry.value;
            final selected = index == _selectedIndex;
            return Padding(
              padding: EdgeInsets.only(bottom: index == result.candidates.length - 1 ? 0 : 10),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => setState(() => _selectedIndex = index),
                child: Ink(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                  decoration: BoxDecoration(
                    color: selected ? const Color(0xFFEFF6FF) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: selected ? const Color(0xFF93C5FD) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        selected ? Icons.radio_button_checked : Icons.radio_button_off,
                        color: selected ? const Color(0xFF2563EB) : const Color(0xFF94A3B8),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              c.displayName,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              c.displaySubtitle,
                              style: const TextStyle(
                                fontSize: 12.5,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              c.manufacturer.trim().isEmpty
                                  ? (c.approvalNo.trim().isEmpty ? '' : '批准文号: ${c.approvalNo}')
                                  : c.manufacturer,
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: Color(0xFF94A3B8),
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      if (c.score > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '${(c.score * 100).clamp(0, 100).toStringAsFixed(0)}%',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF10B981),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    final canUseResult = _scanResult != null && _scanResult!.candidates.isNotEmpty;
    return Column(
      children: [
        if (widget.mode == ScanEntryMode.result) ...[
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: canUseResult ? _addSelectedToMyMedicines : null,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0EA5E9),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('添加到我的药品'),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonal(
              onPressed: canUseResult ? _openSelectedDetail : null,
              style: FilledButton.styleFrom(
                foregroundColor: const Color(0xFF0F172A),
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('查看详细信息'),
            ),
          ),
          const SizedBox(height: 10),
        ],
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF64748B),
              side: const BorderSide(color: Color(0xFFE2E8F0)),
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('取消'),
          ),
        ),
      ],
    );
  }

  Future<void> _retakeAndScan() async {
    setState(() {
      _lastError = null;
      _scanResult = null;
      _selectedIndex = 0;
      _photoBytes = null;
    });

    final granted = await Permission.camera.request();
    if (!granted.isGranted) {
      if (mounted) {
        setState(() => _lastError = '相机权限被拒绝，请在系统设置中允许相机权限');
      }
      return;
    }

    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 92,
      maxWidth: 1800,
    );
    if (!mounted) {
      return;
    }
    if (file == null) {
      Navigator.pop(context);
      return;
    }

    Uint8List bytes;
    try {
      bytes = await file.readAsBytes();
    } catch (e) {
      setState(() => _lastError = '读取图片失败，请重试');
      return;
    }

    setState(() {
      _photoBytes = bytes;
      _photoMimeType = _guessMimeType(file.path);
    });

    // Save to system gallery in background
    unawaited(_saveToGallery(bytes));
    await _scan(bytes);
  }

  Future<void> _saveToGallery(Uint8List bytes) async {
    if (_savingToGallery) return;
    setState(() => _savingToGallery = true);
    try {
      await GallerySaver.saveImage(
        bytes,
        fileName: 'luminous_${DateTime.now().millisecondsSinceEpoch}.jpg',
        mimeType: _photoMimeType,
      );
    } catch (_) {
      // ignore, we still keep local record
    } finally {
      if (mounted) {
        setState(() => _savingToGallery = false);
      }
    }
  }

  Future<void> _saveToGalleryOnly() async {
    final bytes = _photoBytes;
    if (bytes == null) return;
    await _saveToGallery(bytes);
    if (mounted) {
      ToastUtils.instance.show(context, '已保存到系统相册');
    }
  }

  Future<void> _scan(Uint8List bytes) async {
    if (_scanning) return;
    setState(() => _scanning = true);
    try {
      final base64 = base64Encode(bytes);
      final userId = _userController.user.value?.id;
      final response = await ScanApi.scanMedicine(
        userId: userId,
        imageBase64: base64,
        mimeType: _photoMimeType,
      );
      if (!mounted) return;

      final result = response.result;
      setState(() {
        _scanResult = result;
        _selectedIndex = _findBestCandidateIndex(result);
      });

      await _persistAlbumRecord(bytes, result);
    } catch (e) {
      if (!mounted) return;
      setState(() => _lastError = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _scanning = false);
      }
    }
  }

  Future<void> _persistAlbumRecord(Uint8List bytes, MedicineScanResult result) async {
    final selected = _getSelectedCandidateOrNull();
    final thumbBase64 = result.thumbBase64.trim().isNotEmpty
        ? result.thumbBase64.trim()
        : _generateThumbBase64(bytes);

    final now = DateTime.now().millisecondsSinceEpoch;
    String? remoteId;
    final userId = _userController.user.value?.id ?? '';
    if (userId.isNotEmpty && thumbBase64.isNotEmpty) {
      try {
        final r = await ScanApi.createScanRecord(
          userId: userId,
          thumbBase64: thumbBase64,
          drugCode: selected?.drugCode,
          approvalNo: selected?.approvalNo,
          productName: selected?.productName,
          takenAt: now,
        );
        remoteId = r.result.id;
      } catch (_) {
        // ignore sync errors
      }
    }

    try {
      final db = await AppDatabase.instance.database;
      await db.insert('album_items', {
        'remoteId': remoteId,
        'identityKey': _buildIdentityKey(selected),
        'drugCode': selected?.drugCode ?? '',
        'approvalNo': selected?.approvalNo ?? '',
        'productName': selected?.productName ?? '',
        'filePath': '',
        'thumbBase64': thumbBase64,
        'takenAt': now,
        'source': 'scan',
        'createdAt': now,
      });
    } catch (_) {
      // ignore local album errors
    }
  }

  int _findBestCandidateIndex(MedicineScanResult result) {
    if (result.candidates.isEmpty) return 0;
    for (final entry in result.candidates.asMap().entries) {
      if (entry.value.hasIdentity) {
        return entry.key;
      }
    }
    return 0;
  }

  ScanCandidate? _getSelectedCandidateOrNull() {
    final result = _scanResult;
    if (result == null) return null;
    if (result.candidates.isEmpty) return null;
    final index = _selectedIndex.clamp(0, result.candidates.length - 1);
    return result.candidates[index];
  }

  Future<void> _addSelectedToMyMedicines() async {
    final c = _getSelectedCandidateOrNull();
    if (c == null) return;

    final item = MedicineItem(
      serialNo: '',
      approvalNo: c.approvalNo,
      productName: c.productName,
      dosageForm: c.dosageForm,
      specification: c.specification,
      marketingAuthorizationHolder: '',
      manufacturer: c.manufacturer,
      drugCode: c.drugCode,
      drugCodeRemark: '',
    );

    final identityKey = _buildIdentityKey(c);
    try {
      final db = await AppDatabase.instance.database;
      await db.insert('my_medicines', {
        'identityKey': identityKey,
        'drugCode': item.drugCode,
        'approvalNo': item.approvalNo,
        'productName': item.productName,
        'dosageForm': item.dosageForm,
        'specification': item.specification,
        'manufacturer': item.manufacturer,
        'source': 'scan',
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      });
      if (!mounted) return;
      ToastUtils.instance.show(context, '已添加到我的药品');
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString();
      if (msg.contains('UNIQUE')) {
        ToastUtils.instance.show(context, '该药品已在我的药品列表中');
      } else {
        ToastUtils.instance.show(context, '添加失败，请重试');
      }
    }
  }

  Future<void> _openSelectedDetail() async {
    final c = _getSelectedCandidateOrNull();
    if (c == null) return;

    final item = MedicineItem(
      serialNo: '',
      approvalNo: c.approvalNo,
      productName: c.productName,
      dosageForm: c.dosageForm,
      specification: c.specification,
      marketingAuthorizationHolder: '',
      manufacturer: c.manufacturer,
      drugCode: c.drugCode,
      drugCodeRemark: '',
    );

    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => MedicineDetailPage(initialItem: item)),
    );
  }

  String _generateThumbBase64(Uint8List bytes) {
    try {
      final decoded = img.decodeImage(bytes);
      if (decoded == null) return '';
      final resized = img.copyResize(decoded, width: 240);
      final jpg = img.encodeJpg(resized, quality: 80);
      return base64Encode(jpg);
    } catch (_) {
      return '';
    }
  }

  String _buildIdentityKey(ScanCandidate? candidate) {
    if (candidate == null) {
      return 'scan:${DateTime.now().millisecondsSinceEpoch}';
    }
    if (candidate.drugCode.trim().isNotEmpty) return 'drugCode:${candidate.drugCode.trim()}';
    if (candidate.approvalNo.trim().isNotEmpty) return 'approvalNo:${candidate.approvalNo.trim()}';
    return 'name:${candidate.productName.trim()}';
  }

  String _guessMimeType(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    return 'image/jpeg';
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.color,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              onTap == null ? Icons.lock_outline_rounded : Icons.chevron_right_rounded,
              color: const Color(0xFF94A3B8),
            ),
          ],
        ),
      ),
    );
  }
}
