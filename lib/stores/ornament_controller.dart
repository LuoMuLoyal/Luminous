import 'dart:async';
import 'dart:math' as math;

import 'package:get/get.dart';
import 'package:luminous/components/app_ornaments.dart';
import 'package:luminous/constants/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppOrnamentTransparencyPreference {
  /// 透明度 0%，装饰完全可见。
  t0,

  /// 透明度 25%，保留 75% 装饰可见度。
  t25,

  /// 透明度 50%，保留 50% 装饰可见度。
  t50,

  /// 透明度 75%，保留 25% 装饰可见度。
  t75,

  /// 透明度 100%，等价于关闭装饰。
  t100;

  int get transparencyPercent {
    return switch (this) {
      AppOrnamentTransparencyPreference.t0 => 0,
      AppOrnamentTransparencyPreference.t25 => 25,
      AppOrnamentTransparencyPreference.t50 => 50,
      AppOrnamentTransparencyPreference.t75 => 75,
      AppOrnamentTransparencyPreference.t100 => 100,
    };
  }

  static AppOrnamentTransparencyPreference fromStorage(String? value) {
    return AppOrnamentTransparencyPreference.values.firstWhere(
      (item) => item.name == value,
      orElse: () => AppOrnamentTransparencyPreference.t50,
    );
  }
}

/// 会话级装饰布局控制器。
///
/// 启动后异步生成一次 session seed：
/// - 不阻塞首帧；
/// - 本次运行内稳定；
/// - 完整重启应用后允许变化。
class OrnamentController extends GetxController {
  static const int minTransparencyPercent = 0;
  static const int maxTransparencyPercent = 100;
  static const int transparencyStep = 5;

  final RxInt revision = 0.obs;
  final RxInt transparencyPercent =
      AppOrnamentTransparencyPreference.t50.transparencyPercent.obs;
  final math.Random _random = math.Random();
  Future<SharedPreferences>? _prefsFuture;

  int? _sessionSeed;
  bool _warming = false;

  bool get isReady => _sessionSeed != null;

  Future<SharedPreferences> get _prefs async {
    return _prefsFuture ??= SharedPreferences.getInstance();
  }

  /// 氛围装饰可见度倍率：1 表示完整显示，0 表示关闭。
  double get visibilityFactor {
    return ((maxTransparencyPercent - transparencyPercent.value) /
            maxTransparencyPercent)
        .clamp(0.0, 1.0)
        .toDouble();
  }

  bool get isDisabled => visibilityFactor <= 0;

  AppOrnamentTransparencyPreference? get matchedPreset {
    final current = transparencyPercent.value;
    for (final preset in AppOrnamentTransparencyPreference.values) {
      if (preset.transparencyPercent == current) {
        return preset;
      }
    }
    return null;
  }

  int normalizeTransparencyPercent(int rawPercent) {
    final clamped = rawPercent.clamp(
      minTransparencyPercent,
      maxTransparencyPercent,
    );
    final rounded = ((clamped / transparencyStep).round() * transparencyStep)
        .clamp(minTransparencyPercent, maxTransparencyPercent);
    return rounded;
  }

  Future<void> init() async {
    final prefs = await _prefs;
    final raw = prefs.get(GlobalConstants.ORNAMENT_TRANSPARENCY_KEY);

    final resolved = switch (raw) {
      int value => normalizeTransparencyPercent(value),
      double value => normalizeTransparencyPercent(value.round()),
      String value => _resolveTransparencyPercentFromString(value),
      _ => AppOrnamentTransparencyPreference.t50.transparencyPercent,
    };

    transparencyPercent.value = resolved;

    // 统一回写为 int，避免历史字符串值再次触发类型异常。
    if (raw is! int || raw != resolved) {
      await prefs.setInt(GlobalConstants.ORNAMENT_TRANSPARENCY_KEY, resolved);
    }
  }

  int _resolveTransparencyPercentFromString(String rawValue) {
    final parsedPercent = int.tryParse(rawValue);
    if (parsedPercent != null) {
      return normalizeTransparencyPercent(parsedPercent);
    }
    final mappedPreset = AppOrnamentTransparencyPreference.fromStorage(
      rawValue,
    );
    return mappedPreset.transparencyPercent;
  }

  Future<void> setTransparencyPreference(
    AppOrnamentTransparencyPreference preference,
  ) async {
    await setTransparencyPercent(preference.transparencyPercent);
  }

  Future<void> setTransparencyPercent(int percent) async {
    final normalized = normalizeTransparencyPercent(percent);
    if (transparencyPercent.value == normalized) {
      return;
    }
    transparencyPercent.value = normalized;
    revision.value++;
    final prefs = await _prefs;
    await prefs.setInt(GlobalConstants.ORNAMENT_TRANSPARENCY_KEY, normalized);
  }

  /// 异步预热装饰 seed。
  Future<void> warmup() async {
    if (_warming || isReady || isDisabled) {
      return;
    }
    _warming = true;
    try {
      await Future<void>.delayed(const Duration(milliseconds: 28));
      _sessionSeed =
          DateTime.now().microsecondsSinceEpoch ^ _random.nextInt(1 << 30);
      revision.value++;
    } finally {
      _warming = false;
    }
  }

  /// 根据稳定 key 返回本次会话内固定的装饰模板。
  AppOrnamentLayout? resolveLayout({
    required String ornamentKey,
    required AppOrnamentFamily family,
  }) {
    final seed = _sessionSeed;
    if (seed == null) {
      return null;
    }

    final templates = switch (family) {
      AppOrnamentFamily.banner => kBannerSessionLayouts,
      AppOrnamentFamily.section => kSectionSessionLayouts,
    };
    final templateHash = _stableHash(
      '$seed::template::$ornamentKey::${family.name}',
    );
    final variantHash = _stableHash(
      '$seed::variant::$ornamentKey::${family.name}',
    );
    final index = templateHash % templates.length;
    final base = templates[index];

    return buildVariantOrnamentLayout(
      base,
      id: '${base.id}-v${variantHash % 997}',
      family: family,
      mirrorX: variantHash.isEven,
      mirrorY: family == AppOrnamentFamily.section
          ? variantHash % 4 == 0
          : variantHash % 6 == 0,
      scale: _pickScale(variantHash, family),
      shiftX: _pickShift(
        variantHash >> 4,
        family == AppOrnamentFamily.banner ? 28 : 36,
      ),
      shiftY: _pickShift(
        variantHash >> 10,
        family == AppOrnamentFamily.banner ? 18 : 24,
      ),
      rotationDelta: _pickRotation(variantHash >> 16),
      swapColorRoles: variantHash % 5 == 0,
    );
  }

  double _pickScale(int hash, AppOrnamentFamily family) {
    final min = family == AppOrnamentFamily.banner ? 0.88 : 0.84;
    final max = family == AppOrnamentFamily.banner ? 1.18 : 1.16;
    final t = ((hash >> 2) & 0xFF) / 255;
    return min + (max - min) * t;
  }

  double _pickShift(int hash, double amplitude) {
    final t = (hash & 0xFF) / 255;
    return (t * 2 - 1) * amplitude;
  }

  double _pickRotation(int hash) {
    final t = (hash & 0xFF) / 255;
    return (t * 2 - 1) * 0.18;
  }

  int _stableHash(String value) {
    var hash = 0x811C9DC5;
    for (final codeUnit in value.codeUnits) {
      hash ^= codeUnit;
      hash = (hash * 0x01000193) & 0x7fffffff;
    }
    return hash;
  }
}
