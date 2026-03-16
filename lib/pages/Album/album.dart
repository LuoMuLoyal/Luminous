import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:luminous/api/scan_api.dart';
import 'package:luminous/pages/Drug/medicine_detail.dart';
import 'package:luminous/stores/app_database.dart';
import 'package:luminous/stores/user_controller.dart';
import 'package:luminous/utils/toast_utils.dart';
import 'package:luminous/viewmodels/album.dart';
import 'package:luminous/viewmodels/medicine.dart';
import 'package:sqflite/sqflite.dart';

class AlbumView extends StatefulWidget {
  const AlbumView({super.key});

  @override
  State<AlbumView> createState() => _AlbumViewState();
}

class _AlbumViewState extends State<AlbumView> {
  final UserController _userController = Get.find<UserController>();

  bool _loading = false;
  String? _error;
  List<_AlbumEntry> _entries = [];

  String get _userId => _userController.user.value?.id ?? '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final local = await _loadLocal();
      if (!mounted) return;
      setState(() => _entries = local);

      final loggedIn = _userController.isLoggedIn && _userId.isNotEmpty;
      if (loggedIn) {
        final remote = await ScanApi.listScanRecords(
          userId: _userId,
          page: 1,
          pageSize: 50,
        );
        if (!mounted) return;
        final merged = _merge(local, remote.result.items);
        setState(() => _entries = merged);
        await _cacheRemoteToLocal(remote.result.items);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<List<_AlbumEntry>> _loadLocal() async {
    try {
      final db = await AppDatabase.instance.database;
      final rows = await db.query('album_items', orderBy: 'createdAt DESC');
      return rows.map(_rowToEntry).toList();
    } catch (_) {
      return [];
    }
  }

  _AlbumEntry _rowToEntry(Map<String, dynamic> row) {
    return _AlbumEntry(
      remoteId: (row['remoteId'] ?? '').toString(),
      productName: (row['productName'] ?? '').toString(),
      drugCode: (row['drugCode'] ?? '').toString(),
      approvalNo: (row['approvalNo'] ?? '').toString(),
      thumbBase64: (row['thumbBase64'] ?? '').toString(),
      takenAt: (row['takenAt'] as int?) ?? (row['createdAt'] as int?) ?? 0,
    );
  }

  List<_AlbumEntry> _merge(List<_AlbumEntry> local, List<ScanRecordItem> remote) {
    final map = <String, _AlbumEntry>{};
    for (final e in local) {
      final key = e.remoteId.trim();
      if (key.isNotEmpty) {
        map[key] = e;
      }
    }
    final result = <_AlbumEntry>[];
    for (final r in remote) {
      final key = r.id.trim();
      final entry = _AlbumEntry(
        remoteId: key,
        productName: r.productName,
        drugCode: r.drugCode,
        approvalNo: r.approvalNo,
        thumbBase64: r.thumbBase64,
        takenAt: r.takenAt,
      );
      map[key] = entry;
    }

    // Keep locals without remoteId
    result.addAll(local.where((e) => e.remoteId.trim().isEmpty));
    result.addAll(map.values);
    result.sort((a, b) => b.takenAt.compareTo(a.takenAt));
    return result;
  }

  Future<void> _cacheRemoteToLocal(List<ScanRecordItem> items) async {
    try {
      final db = await AppDatabase.instance.database;
      for (final r in items) {
        await db.insert(
          'album_items',
          {
            'remoteId': r.id,
            'identityKey': _buildIdentityKey(r.drugCode, r.approvalNo, r.productName),
            'drugCode': r.drugCode,
            'approvalNo': r.approvalNo,
            'productName': r.productName,
            'filePath': '',
            'thumbBase64': r.thumbBase64,
            'takenAt': r.takenAt,
            'source': 'scan',
            'createdAt': r.takenAt == 0 ? DateTime.now().millisecondsSinceEpoch : r.takenAt,
          },
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
    } catch (_) {}
  }

  String _buildIdentityKey(String drugCode, String approvalNo, String name) {
    if (drugCode.trim().isNotEmpty) return 'drugCode:${drugCode.trim()}';
    if (approvalNo.trim().isNotEmpty) return 'approvalNo:${approvalNo.trim()}';
    return 'name:${name.trim()}';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: const Color(0xFFF3F7FB),
        child: RefreshIndicator(
          onRefresh: _load,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHeader()),
              if (!_userController.isLoggedIn)
                SliverToBoxAdapter(child: _buildLoginBanner()),
              if (_error != null)
                SliverToBoxAdapter(child: _buildErrorBanner(_error!)),
              if (_entries.isEmpty && !_loading)
                SliverToBoxAdapter(child: _buildEmpty())
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  sliver: SliverGrid.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 0.92,
                    ),
                    itemCount: _entries.length,
                    itemBuilder: (context, index) {
                      final e = _entries[index];
                      return _AlbumCard(entry: e, onTap: () => _openDetail(e));
                    },
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color(0xFF6366F1), Color(0xFF0EA5E9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x28000000),
              blurRadius: 14,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x28FFFFFF),
              ),
              child: const Icon(Icons.photo_library_outlined, color: Colors.white),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '识别相册',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '同步缩略图与识别结果',
                    style: TextStyle(
                      color: Color(0xE6FFFFFF),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (_loading)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorBanner(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBEB),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFDE68A)),
        ),
        child: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Color(0xFFF59E0B)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 12.5,
                  height: 1.45,
                  color: Color(0xFF92400E),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 44),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: const Column(
          children: [
            Icon(Icons.photo_outlined, size: 44, color: Color(0xFF94A3B8)),
            SizedBox(height: 10),
            Text(
              '暂无记录',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            SizedBox(height: 6),
            Text(
              '去“药物识别”拍照后会自动同步到这里',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFF0EA5E9).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.lock_outline_rounded, color: Color(0xFF0EA5E9)),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                '登录后可同步识别记录并跨设备查看缩略图',
                style: TextStyle(
                  fontSize: 12.5,
                  height: 1.45,
                  color: Color(0xFF475569),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0EA5E9),
                foregroundColor: Colors.white,
                minimumSize: const Size(78, 40),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('登录'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openDetail(_AlbumEntry entry) async {
    final item = MedicineItem(
      serialNo: '',
      approvalNo: entry.approvalNo,
      productName: entry.productName,
      dosageForm: '',
      specification: '',
      marketingAuthorizationHolder: '',
      manufacturer: '',
      drugCode: entry.drugCode,
      drugCodeRemark: '',
    );
    if (!item.hasIdentity) {
      ToastUtils.instance.show(context, '该记录缺少 drugCode/approvalNo，无法查看详情');
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => MedicineDetailPage(initialItem: item)),
    );
  }
}

class _AlbumEntry {
  final String remoteId;
  final String productName;
  final String drugCode;
  final String approvalNo;
  final String thumbBase64;
  final int takenAt;

  const _AlbumEntry({
    required this.remoteId,
    required this.productName,
    required this.drugCode,
    required this.approvalNo,
    required this.thumbBase64,
    required this.takenAt,
  });

  String get displayName => productName.trim().isEmpty ? '未知药品' : productName.trim();
}

class _AlbumCard extends StatelessWidget {
  const _AlbumCard({required this.entry, required this.onTap});

  final _AlbumEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    Uint8List? bytes;
    final raw = entry.thumbBase64.trim();
    if (raw.isNotEmpty) {
      try {
        bytes = base64Decode(raw);
      } catch (_) {
        bytes = null;
      }
    }

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                child: bytes == null
                    ? Container(
                        color: const Color(0xFFF1F5F9),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.photo_outlined,
                          color: Color(0xFF94A3B8),
                          size: 34,
                        ),
                      )
                    : Image.memory(
                        bytes,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    entry.approvalNo.trim().isEmpty ? '点击查看详情' : '批准文号: ${entry.approvalNo}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
