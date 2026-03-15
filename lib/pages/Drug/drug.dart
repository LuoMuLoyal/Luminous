import 'package:flutter/material.dart';
import 'package:luminous/stores/app_database.dart';
import 'package:luminous/utils/toast_utils.dart';
import 'package:luminous/viewmodels/medicine.dart';
import 'package:luminous/pages/Drug/medicine_detail.dart';

// 药品页
//
// 设计要点：
// - 无顶部色块，直接展示搜索入口 + 快捷入口
// - 下方为"我的药品"列表，使用 ListView.builder 按需加载
// - 药品可通过手动搜索或拍照识别两种方式添加
class DrugView extends StatefulWidget {
  const DrugView({super.key});

  @override
  State<DrugView> createState() => _DrugViewState();
}

class _DrugViewState extends State<DrugView> {
  final List<_DrugQuickEntry> _quickEntries = const [
    _DrugQuickEntry(
      title: '手动搜索',
      subtitle: '名称/批准文号',
      icon: Icons.search_rounded,
      color: Color(0xFF0EA5E9),
      routeName: '/search',
    ),
    _DrugQuickEntry(
      title: '药物识别',
      subtitle: '拍照识别',
      icon: Icons.camera_alt_outlined,
      color: Color(0xFF10B981),
      routeName: '',
    ),
    _DrugQuickEntry(
      title: 'AI 解读',
      subtitle: '用法禁忌',
      icon: Icons.auto_awesome_rounded,
      color: Color(0xFF6366F1),
      routeName: '',
    ),
  ];

  List<Map<String, dynamic>> _myMedicines = [];
  bool _loadingMedicines = false;

  @override
  void initState() {
    super.initState();
    _loadMyMedicines();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 每次页面回到前台时刷新列表（比如从搜索页添加了药品后返回）
    _loadMyMedicines();
  }

  Future<void> _loadMyMedicines() async {
    if (_loadingMedicines) return;
    setState(() {
      _loadingMedicines = true;
    });
    try {
      final db = await AppDatabase.instance.database;
      final rows = await db.query('my_medicines', orderBy: 'createdAt DESC');
      if (!mounted) return;
      setState(() {
        _myMedicines = rows;
      });
    } catch (e) {
      if (mounted) {
        ToastUtils.instance.show(context, '加载我的药品失败');
      }
    } finally {
      if (mounted) {
        setState(() {
          _loadingMedicines = false;
        });
      }
    }
  }

  Future<void> _deleteMedicine(int id) async {
    try {
      final db = await AppDatabase.instance.database;
      await db.delete('my_medicines', where: 'id = ?', whereArgs: [id]);
      await _loadMyMedicines();
      if (mounted) {
        ToastUtils.instance.show(context, '已从我的药品中移除');
      }
    } catch (e) {
      if (mounted) {
        ToastUtils.instance.show(context, '删除失败');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: const Color(0xFFF3F7FB),
        child: RefreshIndicator(
          onRefresh: _loadMyMedicines,
          child: CustomScrollView(
            slivers: [
              _buildSearchEntry(),
              _buildQuickEntrySection(),
              _buildMyMedicinesHeader(),
              if (_loadingMedicines && _myMedicines.isEmpty)
                _buildLoadingSliver()
              else if (_myMedicines.isEmpty)
                _buildEmptyMedicinesSliver()
              else
                _buildMyMedicinesList(),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchEntry() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0F000000),
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => Navigator.pushNamed(context, '/search'),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0EA5E9).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.search_rounded,
                      color: Color(0xFF0EA5E9),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '搜索药品',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '支持：产品名称 / 批准文号 / 生产单位',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF94A3B8),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickEntrySection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '快捷入口',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: _quickEntries
                      .map(
                        (item) => Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: item == _quickEntries.last ? 0 : 10,
                            ),
                            child: _QuickEntryCard(
                              item: item,
                              onTap: () => _onTapQuick(item),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMyMedicinesHeader() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
        child: Row(
          children: [
            const Text(
              '我的药品',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF0EA5E9).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '${_myMedicines.length}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0EA5E9),
                ),
              ),
            ),
            const Spacer(),
            if (_loadingMedicines)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingSliver() {
    return const SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyMedicinesSliver() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 36),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF0EA5E9).withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.medication_outlined,
                  size: 30,
                  color: Color(0xFF0EA5E9),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                '暂无药品',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                '通过"手动搜索"或"药物识别"\n将药品添加到这里',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                  height: 1.55,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMyMedicinesList() {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      sliver: SliverList.builder(
        itemCount: _myMedicines.length,
        itemBuilder: (context, index) {
          final row = _myMedicines[index];
          return Padding(
            padding: EdgeInsets.only(
              bottom: index == _myMedicines.length - 1 ? 0 : 10,
            ),
            child: _MyMedicineCard(
              row: row,
              onDelete: () => _deleteMedicine(row['id'] as int),
              onTap: () => _openMedicineDetail(row),
            ),
          );
        },
      ),
    );
  }

  void _openMedicineDetail(Map<String, dynamic> row) {
    final item = MedicineItem(
      serialNo: '',
      approvalNo: (row['approvalNo'] ?? '').toString(),
      productName: (row['productName'] ?? '').toString(),
      dosageForm: (row['dosageForm'] ?? '').toString(),
      specification: (row['specification'] ?? '').toString(),
      marketingAuthorizationHolder: '',
      manufacturer: (row['manufacturer'] ?? '').toString(),
      drugCode: (row['drugCode'] ?? '').toString(),
      drugCodeRemark: '',
    );
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MedicineDetailPage(initialItem: item),
      ),
    );
  }

  void _onTapQuick(_DrugQuickEntry entry) {
    if (entry.routeName.isNotEmpty) {
      Navigator.pushNamed(context, entry.routeName).then((_) {
        _loadMyMedicines();
      });
      return;
    }
    if (entry.title == '药物识别') {
      _showCameraScanSheet();
      return;
    }
    ToastUtils.instance.show(context, '功能开发中');
  }

  void _showCameraScanSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.camera_alt_outlined,
                        color: Color(0xFF10B981),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '药物识别',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            '拍照上传，后端 AI 识别药品信息',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _SheetAction(
                  icon: Icons.camera_alt_rounded,
                  color: const Color(0xFF10B981),
                  label: '拍照识别',
                  subtitle: '调用相机拍摄药品',
                  onTap: () {
                    Navigator.pop(ctx);
                    ToastUtils.instance.show(context, '拍照识别功能开发中');
                  },
                ),
                const SizedBox(height: 10),
                _SheetAction(
                  icon: Icons.add_circle_outline_rounded,
                  color: const Color(0xFF0EA5E9),
                  label: '添加到我的药品',
                  subtitle: '识别后直接加入药品列表',
                  onTap: () {
                    Navigator.pop(ctx);
                    ToastUtils.instance.show(context, '请先完成拍照识别');
                  },
                ),
                const SizedBox(height: 10),
                _SheetAction(
                  icon: Icons.photo_library_outlined,
                  color: const Color(0xFF6366F1),
                  label: '保存到相册',
                  subtitle: '将拍摄的照片保存至相册',
                  onTap: () {
                    Navigator.pop(ctx);
                    ToastUtils.instance.show(context, '相册功能开发中');
                  },
                ),
                const SizedBox(height: 10),
                _SheetAction(
                  icon: Icons.info_outline_rounded,
                  color: const Color(0xFFF59E0B),
                  label: '查看详细信息',
                  subtitle: '识别后查看 AI 解读与基础信息',
                  onTap: () {
                    Navigator.pop(ctx);
                    ToastUtils.instance.show(context, '请先完成拍照识别');
                  },
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF64748B),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: const Text('取消'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── 药品卡片 ──────────────────────────────────────────────────────────────────

class _MyMedicineCard extends StatelessWidget {
  const _MyMedicineCard({
    required this.row,
    required this.onDelete,
    required this.onTap,
  });

  final Map<String, dynamic> row;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final productName = (row['productName'] ?? '未知药品').toString();
    final dosageForm = (row['dosageForm'] ?? '').toString();
    final specification = (row['specification'] ?? '').toString();
    final manufacturer = (row['manufacturer'] ?? '').toString();
    final approvalNo = (row['approvalNo'] ?? '').toString();
    final source = (row['source'] ?? '').toString();

    final subtitle = [
      if (dosageForm.isNotEmpty) dosageForm,
      if (specification.isNotEmpty) specification,
    ].join(' · ');

    final createdAt = row['createdAt'];
    String dateStr = '';
    if (createdAt != null) {
      final dt = DateTime.fromMillisecondsSinceEpoch(
        (createdAt as int),
        isUtc: false,
      );
      dateStr =
          '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
    }

    return Container(
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
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF0EA5E9).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.medication_rounded,
                  color: Color(0xFF0EA5E9),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      productName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF475569),
                        ),
                      ),
                    ],
                    if (manufacturer.isNotEmpty || approvalNo.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        [
                          if (manufacturer.isNotEmpty) manufacturer,
                          if (approvalNo.isNotEmpty) '批准文号: $approvalNo',
                        ].join('  '),
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFF94A3B8),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (source.isNotEmpty)
                          _badge(
                            source == 'scan' ? '拍照识别' : '手动搜索',
                            source == 'scan'
                                ? const Color(0xFF10B981)
                                : const Color(0xFF0EA5E9),
                          ),
                        if (dateStr.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Text(
                            dateStr,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFFB0BAC8),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // 删除按钮
              GestureDetector(
                onTap: onDelete,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8, top: 2),
                  child: Icon(
                    Icons.delete_outline_rounded,
                    size: 20,
                    color: Colors.red.shade300,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

// ── 底部弹窗操作项 ──────────────────────────────────────────────────────────────

class _SheetAction extends StatelessWidget {
  const _SheetAction({
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
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF94A3B8),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

// ── 快捷入口卡片 ────────────────────────────────────────────────────────────────

class _QuickEntryCard extends StatelessWidget {
  const _QuickEntryCard({required this.item, required this.onTap});

  final _DrugQuickEntry item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(item.icon, color: item.color),
            ),
            const SizedBox(height: 10),
            Text(
              item.title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              item.subtitle,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrugQuickEntry {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String routeName;

  const _DrugQuickEntry({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.routeName,
  });
}
