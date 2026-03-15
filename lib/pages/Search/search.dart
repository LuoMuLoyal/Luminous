import 'package:flutter/material.dart';
import 'package:luminous/api/medicine_api.dart';
import 'package:luminous/components/search.dart';
import 'package:luminous/pages/Drug/medicine_detail.dart';
import 'package:luminous/stores/app_database.dart';
import 'package:luminous/utils/toast_utils.dart';
import 'package:luminous/viewmodels/medicine.dart';

// 手动搜索页（对接 MySQL 药品库）
//
// 数据库字段说明：
//   productName         - 产品名称（主搜索字段）
//   approvalNo          - 批准文号（国药准字 HXXXXXXXX）
//   manufacturer        - 生产单位
//   marketingAuthorization - 上市许可持有人
//   dosageForm          - 剂型（片剂/胶囊/注射液等）
//   specification       - 规格（如 0.5g、10ml 等）
//   drugCode            - 药品编码（本位码）
//   serialNo            - 序号
//
// 搜索逻辑：
// - _draftKeyword：输入框实时内容（未提交）
// - _keyword：已提交的搜索关键词（触发请求）
// - 滚动到底部自动加载下一页
class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<String> _quickTags = const [
    '阿莫西林',
    '布洛芬',
    '维生素D',
    '头孢',
    '抗生素',
    '胃药',
  ];

  final List<String> _recentKeywords = ['阿莫西林', '布洛芬', '维生素D'];

  String _keyword = '';
  String _draftKeyword = '';
  String? _lastError;

  final List<MedicineItem> _results = [];
  // 记录哪些药品已添加（identityKey 集合）
  final Set<String> _addedKeys = {};
  bool _loading = false;
  bool _loadingMore = false;
  bool _hasMore = false;
  int _page = 1;
  static const int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _loadAddedKeys();
    _scrollController.addListener(() {
      if (!_scrollController.hasClients) {
        return;
      }
      if (_keyword.isEmpty || !_hasMore || _loadingMore || _loading) {
        return;
      }
      final maxScroll = _scrollController.position.maxScrollExtent;
      final current = _scrollController.offset;
      if (current >= maxScroll - 120) {
        _search(reset: false);
      }
    });
  }

  Future<void> _loadAddedKeys() async {
    try {
      final db = await AppDatabase.instance.database;
      final rows = await db.query('my_medicines', columns: ['identityKey']);
      if (!mounted) return;
      setState(() {
        _addedKeys.clear();
        for (final row in rows) {
          final key = row['identityKey']?.toString() ?? '';
          if (key.isNotEmpty) _addedKeys.add(key);
        }
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FB),
      body: SafeArea(
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            _buildHeaderSliver(),
            _buildSearchBarSliver(),
            _buildQuickTagsSliver(),
            _buildHistorySliver(),
            _buildResultTitleSliver(),
            if (_keyword.isEmpty && _draftKeyword.isEmpty)
              _buildGuideSliver()
            else if (_keyword.isEmpty && _draftKeyword.isNotEmpty)
              _buildReadySliver()
            else if (_loading && _results.isEmpty)
              _buildLoadingSliver()
            else if (_lastError != null && _results.isEmpty)
              _buildErrorSliver(_lastError!)
            else if (_results.isEmpty)
              _buildEmptySliver()
            else
              _buildResultListSliver(),
            if (_keyword.isNotEmpty && _loadingMore) _buildLoadingMoreSliver(),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSliver() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                InkWell(
                  onTap: () => Navigator.maybePop(context),
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 18,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    '手动搜索',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              '支持按药品名称、批准文号、生产单位搜索',
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBarSliver() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: SearchSurfaceCard(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _draftKeyword = value.trim();
                      });
                    },
                    onSubmitted: (_) => _commitSearch(),
                    decoration: InputDecoration(
                      hintText: '产品名称 / 批准文号 / 生产单位',
                      hintStyle: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 14,
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: Color(0xFF0EA5E9),
                      ),
                      suffixIcon: _draftKeyword.isEmpty
                          ? null
                          : IconButton(
                              onPressed: _clearKeyword,
                              icon: const Icon(
                                Icons.close_rounded,
                                size: 18,
                                color: Color(0xFF64748B),
                              ),
                            ),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _commitSearch,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF0EA5E9),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(76, 44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('搜索'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickTagsSliver() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
        child: SearchSurfaceCard(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '常用搜索',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _quickTags
                      .map(
                        (tag) => ActionChip(
                          onPressed: () => _applyQuickTag(tag),
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                          backgroundColor: const Color(0xFFF8FAFC),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                          label: Text(
                            tag,
                            style: const TextStyle(
                              color: Color(0xFF334155),
                              fontWeight: FontWeight.w600,
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

  Widget _buildHistorySliver() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 2, 16, 8),
        child: SearchSurfaceCard(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: Column(
              children: [
                Row(
                  children: [
                    const Text(
                      '最近搜索',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: _recentKeywords.isEmpty ? null : _clearHistory,
                      style: TextButton.styleFrom(
                        minimumSize: const Size(48, 30),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        foregroundColor: const Color(0xFF64748B),
                      ),
                      child: const Text('清空'),
                    ),
                  ],
                ),
                if (_recentKeywords.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Text(
                      '暂无搜索历史',
                      style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                    ),
                  )
                else
                  Column(
                    children: _recentKeywords
                        .map(
                          (keyword) => InkWell(
                            onTap: () => _applyQuickTag(keyword),
                            borderRadius: BorderRadius.circular(10),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 8,
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.history_rounded,
                                    size: 16,
                                    color: Color(0xFF64748B),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      keyword,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF1E293B),
                                      ),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.north_west_rounded,
                                    size: 16,
                                    color: Color(0xFF94A3B8),
                                  ),
                                ],
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

  Widget _buildResultTitleSliver() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
        child: Row(
          children: [
            const Text(
              '搜索结果',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '(${_keyword.isEmpty ? 0 : _results.length})',
              style: const TextStyle(
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

  Widget _buildResultListSliver() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList.builder(
        itemCount: _results.length,
        itemBuilder: (context, index) {
          final item = _results[index];
          final cardData = _toCardData(item);
          final identityKey = _buildIdentityKey(item);
          final isAdded = _addedKeys.contains(identityKey);
          return Padding(
            padding: EdgeInsets.only(
              bottom: index == _results.length - 1 ? 0 : 10,
            ),
            child: SearchResultCard(
              item: cardData,
              isAdded: isAdded,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => MedicineDetailPage(initialItem: item),
                  ),
                );
              },
              onAdd: isAdded ? null : () => _addToMyMedicines(item),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGuideSliver() {
    return const SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 26, 16, 10),
        child: SearchSurfaceCard(
          child: Padding(
            padding: EdgeInsets.fromLTRB(14, 14, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.tips_and_updates_rounded,
                      color: Color(0xFF0EA5E9),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '搜索提示',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                _TipRow(label: '产品名称', example: '阿莫西林胶囊、布洛芬片'),
                _TipRow(label: '批准文号', example: '国药准字 H20013191'),
                _TipRow(label: '生产单位', example: '石药集团、华润三九'),
                _TipRow(label: '药品编码', example: '86901000000000(本位码)'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReadySliver() {
    return const SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 18, 16, 10),
        child: SearchSurfaceCard(
          child: Padding(
            padding: EdgeInsets.fromLTRB(14, 14, 14, 14),
            child: Row(
              children: [
                Icon(Icons.keyboard_return_rounded, color: Color(0xFF0EA5E9)),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '按下"搜索"或回车键开始查询药品数据库',
                    style: TextStyle(
                      color: Color(0xFF475569),
                      fontSize: 13,
                      height: 1.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingSliver() {
    return const SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 26, 16, 10),
        child: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingMoreSliver() {
    return const SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 14, 16, 10),
        child: Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptySliver() {
    return const SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 30, 16, 12),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 38,
                color: Color(0xFF94A3B8),
              ),
              SizedBox(height: 8),
              Text(
                '暂无匹配结果',
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 2),
              Text(
                '可尝试产品名称、批准文号或生产单位重新搜索',
                style: TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorSliver(String message) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 26, 16, 10),
        child: SearchSurfaceCard(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: Color(0xFFEF4444),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '查询失败',
                        style: TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        message,
                        style: const TextStyle(
                          color: Color(0xFF475569),
                          fontSize: 13,
                          height: 1.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: FilledButton.tonal(
                          onPressed: () => _search(reset: true),
                          style: FilledButton.styleFrom(
                            foregroundColor: const Color(0xFF0F172A),
                            backgroundColor: const Color(0xFFF1F5F9),
                            minimumSize: const Size(88, 40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('重试'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _applyQuickTag(String tag) {
    _searchController.text = tag;
    _searchController.selection = TextSelection.collapsed(offset: tag.length);
    setState(() {
      _lastError = null;
      _draftKeyword = tag;
      _keyword = tag;
      _updateRecentKeywords(tag);
    });
    _search(reset: true);
  }

  void _commitSearch() {
    final keyword = _searchController.text.trim();
    if (keyword.isEmpty) {
      ToastUtils.instance.show(context, '请输入产品名称、批准文号或生产单位后再搜索');
      return;
    }
    setState(() {
      _lastError = null;
      _draftKeyword = keyword;
      _keyword = keyword;
      _updateRecentKeywords(keyword);
    });
    _search(reset: true);
    FocusScope.of(context).unfocus();
  }

  void _clearKeyword() {
    _searchController.clear();
    setState(() {
      _keyword = '';
      _draftKeyword = '';
      _lastError = null;
      _results.clear();
      _hasMore = false;
      _page = 1;
    });
  }

  void _clearHistory() {
    setState(() {
      _recentKeywords.clear();
    });
    ToastUtils.instance.show(context, '最近搜索已清空');
  }

  void _updateRecentKeywords(String keyword) {
    _recentKeywords.remove(keyword);
    _recentKeywords.insert(0, keyword);
    if (_recentKeywords.length > 8) {
      _recentKeywords.removeLast();
    }
  }

  SearchResultItemData _toCardData(MedicineItem item) {
    final tips = item.approvalNo.isNotEmpty
        ? '批准文号: ${item.approvalNo}'
        : item.displayTips;
    return SearchResultItemData(
      name: item.displayName,
      subtitle: item.displaySubtitle,
      tips: tips,
      badge: item.displayBadge,
    );
  }

  String _buildIdentityKey(MedicineItem item) {
    if (item.drugCode.isNotEmpty) return 'drugCode:${item.drugCode}';
    if (item.approvalNo.isNotEmpty) return 'approvalNo:${item.approvalNo}';
    return 'name:${item.productName}';
  }

  Future<void> _addToMyMedicines(MedicineItem item) async {
    final identityKey = _buildIdentityKey(item);
    try {
      final db = await AppDatabase.instance.database;
      await db.insert('my_medicines', {
        'identityKey': identityKey,
        'drugCode': item.drugCode,
        'approvalNo': item.approvalNo,
        'productName': item.productName,
        'dosageForm': item.dosageForm,
        'specification': item.specification,
        'manufacturer': item.manufacturer.isNotEmpty
            ? item.manufacturer
            : item.marketingAuthorizationHolder,
        'source': 'search',
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      });
      if (!mounted) return;
      setState(() {
        _addedKeys.add(identityKey);
      });
      ToastUtils.instance.show(context, '已添加到我的药品');
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString();
      if (msg.contains('UNIQUE')) {
        ToastUtils.instance.show(context, '该药品已在我的药品列表中');
        setState(() {
          _addedKeys.add(identityKey);
        });
      } else {
        ToastUtils.instance.show(context, '添加失败，请重试');
      }
    }
  }

  Future<void> _search({required bool reset}) async {
    final keyword = _keyword.trim();
    if (keyword.isEmpty) {
      return;
    }

    if (reset) {
      if (_loading) {
        return;
      }
      setState(() {
        _loading = true;
        _loadingMore = false;
        _lastError = null;
        _page = 1;
        _hasMore = false;
        _results.clear();
      });
    } else {
      if (_loadingMore || _loading || !_hasMore) {
        return;
      }
      setState(() {
        _loadingMore = true;
      });
    }

    try {
      final response = await MedicineApi.search(
        keyword: keyword,
        page: _page,
        pageSize: _pageSize,
      );

      if (!mounted) {
        return;
      }

      final result = response.result;
      setState(() {
        _results.addAll(result.items);
        _hasMore = result.hasMore;
        _page = result.page + 1;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      final msg = e.toString().replaceFirst('Exception: ', '');
      ToastUtils.instance.show(context, msg);
      if (reset) {
        setState(() {
          _lastError = msg;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
          _loadingMore = false;
        });
      }
    }
  }
}

// ── 搜索提示行 ────────────────────────────────────────────────────────────────

class _TipRow extends StatelessWidget {
  const _TipRow({required this.label, required this.example});

  final String label;
  final String example;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF0EA5E9).withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0369A1),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              example,
              style: const TextStyle(
                fontSize: 12.5,
                color: Color(0xFF475569),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
