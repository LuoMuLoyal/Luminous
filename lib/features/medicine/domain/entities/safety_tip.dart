// TODO(archive): 无 UI 消费方（死代码保留）；若未来做随机安全贴士，
// 应在移动端药品详情页内以经过审核的内容卡片形式重做，勿直接复用本链路。
class MedicineSafetyTip {
  const MedicineSafetyTip({
    required this.id,
    required this.text,
    required this.category,
  });

  final String id;
  final String text;
  final String category;
}
