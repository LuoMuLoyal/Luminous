part of 'app_ornaments.dart';

/// 大分区卡片与横幅使用的轻量装饰样式。
enum AppOrnamentStyle { orbit, comet, petal, halo }

/// 装饰模板所属的卡片族。
enum AppOrnamentFamily { banner, section }

/// 单个装饰节点的形状类型。
enum AppOrnamentNodeShape { orb, pill, ring }

/// 单个装饰节点的透明度层级。
enum AppOrnamentTone { strong, medium, light, spark }

/// 单个装饰节点的取色角色。
enum AppOrnamentColorRole { accent, secondary }

/// 单个装饰节点的布局描述。
class AppOrnamentNodeSpec {
  const AppOrnamentNodeSpec({
    required this.shape,
    required this.alignment,
    required this.width,
    required this.height,
    required this.tone,
    this.colorRole = AppOrnamentColorRole.accent,
    this.offset = Offset.zero,
    this.rotation = 0,
  });

  final AppOrnamentNodeShape shape;
  final Alignment alignment;
  final double width;
  final double height;
  final AppOrnamentTone tone;
  final AppOrnamentColorRole colorRole;
  final Offset offset;
  final double rotation;

  AppOrnamentNodeSpec copyWith({
    AppOrnamentNodeShape? shape,
    Alignment? alignment,
    double? width,
    double? height,
    AppOrnamentTone? tone,
    AppOrnamentColorRole? colorRole,
    Offset? offset,
    double? rotation,
  }) {
    return AppOrnamentNodeSpec(
      shape: shape ?? this.shape,
      alignment: alignment ?? this.alignment,
      width: width ?? this.width,
      height: height ?? this.height,
      tone: tone ?? this.tone,
      colorRole: colorRole ?? this.colorRole,
      offset: offset ?? this.offset,
      rotation: rotation ?? this.rotation,
    );
  }
}

/// 一整套装饰布局模板。
class AppOrnamentLayout {
  const AppOrnamentLayout({required this.id, required this.nodes});

  final String id;
  final List<AppOrnamentNodeSpec> nodes;
}

AppOrnamentLayout buildVariantOrnamentLayout(
  AppOrnamentLayout base, {
  required String id,
  required AppOrnamentFamily family,
  required bool mirrorX,
  required bool mirrorY,
  required double scale,
  required double shiftX,
  required double shiftY,
  required double rotationDelta,
  required bool swapColorRoles,
}) {
  final safeScale = scale.clamp(0.78, 1.22);

  return AppOrnamentLayout(
    id: id,
    nodes: base.nodes.map((node) {
      final sizeScale = node.tone == AppOrnamentTone.spark
          ? safeScale * 0.9
          : safeScale;
      final translatedOffset = Offset(
        (mirrorX ? -node.offset.dx : node.offset.dx) + shiftX,
        (mirrorY ? -node.offset.dy : node.offset.dy) + shiftY,
      );
      final rotationSign = mirrorX != mirrorY ? -1.0 : 1.0;
      final nudgedRotation =
          (node.rotation * rotationSign) +
          (node.shape == AppOrnamentNodeShape.orb ? 0 : rotationDelta);
      final nudgedRole = swapColorRoles
          ? (node.colorRole == AppOrnamentColorRole.accent
                ? AppOrnamentColorRole.secondary
                : AppOrnamentColorRole.accent)
          : node.colorRole;

      return node.copyWith(
        alignment: Alignment(
          mirrorX ? -node.alignment.x : node.alignment.x,
          mirrorY ? -node.alignment.y : node.alignment.y,
        ),
        width: node.width * sizeScale,
        height: node.height * sizeScale,
        colorRole: nudgedRole,
        offset: translatedOffset,
        rotation: nudgedRotation,
        tone: _variantTone(node.tone, family, swapColorRoles),
      );
    }).toList(),
  );
}

AppOrnamentTone _variantTone(
  AppOrnamentTone tone,
  AppOrnamentFamily family,
  bool swapColorRoles,
) {
  if (!swapColorRoles) {
    return tone;
  }
  return switch ((family, tone)) {
    (AppOrnamentFamily.banner, AppOrnamentTone.medium) => AppOrnamentTone.light,
    (AppOrnamentFamily.banner, AppOrnamentTone.light) => AppOrnamentTone.medium,
    (AppOrnamentFamily.section, AppOrnamentTone.strong) =>
      AppOrnamentTone.medium,
    (AppOrnamentFamily.section, AppOrnamentTone.medium) =>
      AppOrnamentTone.strong,
    _ => tone,
  };
}

/// 将基础 alpha 与可见度倍率合成，统一控制氛围装饰透明度。
double resolveOrnamentAlpha({
  required double baseAlpha,
  required double visibilityFactor,
}) {
  final safeBase = baseAlpha.clamp(0.0, 1.0).toDouble();
  final safeVisibility = visibilityFactor.clamp(0.0, 1.0).toDouble();
  return (safeBase * safeVisibility).clamp(0.0, 1.0).toDouble();
}
