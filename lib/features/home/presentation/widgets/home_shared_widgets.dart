part of '../home.dart';

Color _homeSecondaryTextColor(BuildContext context, {double emphasis = 0.24}) {
  final scheme = Theme.of(context).colorScheme;
  return Color.lerp(scheme.onSurfaceVariant, scheme.onSurface, emphasis)!;
}

Color _homeBannerSecondaryTextColor(
  SoftBannerTheme theme, {
  double emphasis = 0.18,
}) {
  return Color.lerp(theme.secondaryTextColor, theme.textColor, emphasis)!;
}

/// 首页顶部卡片中的状态 chip（例如“已同步”）。
class HomeStatusChip extends StatelessWidget {
  const HomeStatusChip({
    super.key,
    required this.text,
    this.backgroundColor = const Color(0x33FFFFFF),
    this.textColor = Colors.white,
  });

  final String text;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return TintedStatusChip(
      text: text,
      color: textColor,
      backgroundColor: backgroundColor,
      showBorder: false,
      enablePopup: false,
      fontSize: 12,
      fontWeight: FontWeight.w600,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    );
  }
}

/// 首页顶部卡片中的信息 pill（例如“今日提醒 3 条”）。
class HomeInfoPill extends StatelessWidget {
  const HomeInfoPill({
    super.key,
    required this.text,
    this.backgroundColor = const Color(0x29FFFFFF),
    this.textColor = Colors.white,
    this.onTap,
    this.onLongPress,
  });

  final String text;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final content = TintedStatusChip(
      text: text,
      color: textColor,
      backgroundColor: backgroundColor,
      showBorder: false,
      fontSize: 12.5,
      fontWeight: FontWeight.w600,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      enablePopup: onTap == null && onLongPress == null,
    );

    if (onTap == null && onLongPress == null) {
      return content;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(999)),
          child: content,
        ),
      ),
    );
  }
}
