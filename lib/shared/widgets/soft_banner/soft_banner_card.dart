part of 'soft_banner.dart';

/// 浅色渐变横幅容器。
class SoftBannerCard extends StatelessWidget {
  const SoftBannerCard({
    super.key,
    required this.palette,
    required this.builder,
    this.padding = const EdgeInsets.all(18),
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
  });

  final SoftBannerPalette palette;

  /// 允许调用方根据 theme 调整前景色（标题、chip、按钮等）。
  final Widget Function(BuildContext context, SoftBannerTheme theme) builder;

  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = palette.createTheme();

    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        border: Border.all(color: theme.borderColor),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [theme.startColor, theme.endColor],
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor,
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0, 0.2, 0.62, 1],
                      colors: [
                        Colors.white.withValues(alpha: 0.12),
                        Colors.white.withValues(alpha: 0.038),
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.014),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: -36,
              left: 18,
              right: 18,
              child: IgnorePointer(
                child: Container(
                  height: 96,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        theme.accentColor.withValues(alpha: 0.09),
                        theme.accentColor.withValues(alpha: 0),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
            Padding(
              padding: padding,
              child: SizedBox(
                width: double.infinity,
                child: builder(context, theme),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
