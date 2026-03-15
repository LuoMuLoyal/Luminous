import 'dart:math';
import 'package:flutter/material.dart';
import 'package:luminous/api/home_api.dart';
import 'package:luminous/components/home.dart';
import 'package:luminous/utils/toast_utils.dart';
import 'package:luminous/viewmodels/home.dart';

// 首页
//
// 设计要点：
// - 顶部色块展示随机温馨提示（10条本地文案，每次启动随机一条）
// - "常用功能"是本地静态入口（纯 UI）
// - "今日提醒"来自后端接口 today-reminders
// - 接口失败时回退到本地 _fallbackReminders
class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  // 10 条温馨提示，每次应用启动随机选一条
  static const List<String> _healthTips = [
    '按时服药是控制慢性病的第一步，别让遗忘成为健康的绊脚石。',
    '药物与食物的相互作用不可忽视，服药前记得查阅注意事项。',
    '多喝水有助于药物吸收，除非医嘱有特别限制。',
    '漏服一次怎么办？不要加倍补服，请参照说明书或咨询药师。',
    '储存药品请避光、防潮、防高温，不要放在浴室或车内。',
    '抗生素需完整疗程服用，症状好转后擅自停药可能导致耐药。',
    '服药期间如出现皮疹、呼吸困难等异常，请立即就医。',
    '定期整理家中药箱，清理过期药品，安全处置是对环境的负责。',
    '有些药需要饭前服，有些需要饭后服，请仔细阅读说明书。',
    '良好的作息和均衡饮食是辅助药物发挥最佳效果的基础。',
  ];

  late final String _todayTip;

  final List<HomeFeatureItemData> _entries = const [
    HomeFeatureItemData(
      id: 'drugScan',
      title: '药物识别',
      subtitle: '拍照识别药品',
      icon: Icons.camera_alt_outlined,
      color: Color(0xFF0EA5E9),
    ),
    HomeFeatureItemData(
      id: 'manualSearch',
      title: '手动搜索',
      subtitle: '关键词查询',
      icon: Icons.search_outlined,
      color: Color(0xFF06B6D4),
    ),
    HomeFeatureItemData(
      id: 'reminder',
      title: '用药提醒',
      subtitle: '按时通知',
      icon: Icons.alarm_outlined,
      color: Color(0xFF10B981),
    ),
    HomeFeatureItemData(
      id: 'checkIn',
      title: '用药打卡',
      subtitle: '记录服药情况',
      icon: Icons.fact_check_outlined,
      color: Color(0xFFF59E0B),
    ),
    HomeFeatureItemData(
      id: 'drugInfo',
      title: '药物信息',
      subtitle: '成分与禁忌',
      icon: Icons.medication_outlined,
      color: Color(0xFF6366F1),
    ),
    HomeFeatureItemData(
      id: 'safety',
      title: '安全辅助',
      subtitle: '风险提示',
      icon: Icons.health_and_safety_outlined,
      color: Color(0xFFEC4899),
    ),
  ];

  static const List<HomeReminderItemData> _fallbackReminders = [
    HomeReminderItemData(
      icon: Icons.access_time_rounded,
      title: '08:30 维生素D',
      subtitle: '早餐后服用 1 粒',
      done: true,
    ),
    HomeReminderItemData(
      icon: Icons.access_time_rounded,
      title: '19:30 阿莫西林',
      subtitle: '晚餐后服用 1 粒',
      done: false,
    ),
    HomeReminderItemData(
      icon: Icons.access_time_rounded,
      title: '22:00 血压记录',
      subtitle: '睡前记录并上传',
      done: false,
    ),
  ];

  late List<HomeReminderItemData> _reminders = List<HomeReminderItemData>.from(
    _fallbackReminders,
  );
  bool _loadingReminders = false;

  @override
  void initState() {
    super.initState();
    // 随机选取一条温馨提示
    _todayTip = _healthTips[Random().nextInt(_healthTips.length)];
    _fetchTodayReminders();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: const Color(0xFFF3F7FB),
        child: CustomScrollView(
          slivers: [
            _buildTopSliver(),
            SliverToBoxAdapter(
              child: HomeFeatureSection(items: _entries, onTap: _onEntryTap),
            ),
            SliverToBoxAdapter(child: HomeReminderSection(items: _reminders)),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSliver() {
    final next = _reminders.cast<HomeReminderItemData?>().firstWhere(
      (e) => e != null && e.done == false,
      orElse: () => null,
    );
    final nextText = next == null
        ? '暂无提醒'
        : '下一次提醒: ${next.title} · ${next.subtitle}';

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              // 主页保留绿色渐变
              colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x30000000),
                blurRadius: 14,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0x28FFFFFF),
                    ),
                    child: const Icon(
                      Icons.favorite_outline,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      '健康助手',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  _buildStatusChip('已同步'),
                ],
              ),
              const SizedBox(height: 16),
              // 随机温馨提示
              Text(
                _todayTip,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                nextText,
                style: const TextStyle(color: Color(0xE6FFFFFF), fontSize: 14),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  _buildInfoPill(
                    _loadingReminders
                        ? '提醒加载中...'
                        : '今日提醒 ${_reminders.length} 条',
                  ),
                  const SizedBox(width: 8),
                  _buildInfoPill('健康小贴士'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onEntryTap(HomeFeatureItemData item) {
    if (item.id == 'manualSearch') {
      Navigator.pushNamed(context, '/search');
      return;
    }
    ToastUtils.instance.show(context, '功能开发中');
  }

  Widget _buildStatusChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: const Color(0x33FFFFFF),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildInfoPill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: const Color(0x29FFFFFF),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Future<void> _fetchTodayReminders() async {
    if (_loadingReminders) {
      return;
    }
    setState(() {
      _loadingReminders = true;
    });

    try {
      final response = await HomeApi.fetchTodayReminders();
      if (!mounted) {
        return;
      }
      final items = response.result.items;
      if (items.isEmpty) {
        return;
      }
      setState(() {
        _reminders = items.map(_toReminderUi).toList();
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      ToastUtils.instance.show(
        context,
        e.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loadingReminders = false;
        });
      }
    }
  }

  HomeReminderItemData _toReminderUi(ReminderItem item) {
    final time = item.time.trim();
    final title = item.title.trim();
    final combinedTitle = time.isEmpty ? title : '$time $title';

    return HomeReminderItemData(
      icon: Icons.access_time_rounded,
      title: combinedTitle,
      subtitle: item.subtitle.trim(),
      done: item.done,
    );
  }
}
