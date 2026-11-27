import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/device_memory.dart';

/// Reads total physical memory from the platform.
///
/// ## Why per-platform branches rather than one call
///
/// `device_info_plus` has no common memory field, and the ones it has are not
/// interchangeable:
///
/// - Android / iOS: `physicalRamSize` in **megabytes**.
/// - macOS: `memorySize` in **bytes**.
/// - Windows: `systemMemoryInMegabytes` in **megabytes**.
/// - Linux / web: nothing.
///
/// Reading the wrong one is off by a factor of 1048576 and silently makes every model
/// "not fit". Android's `memoryClass` is deliberately not used: it is the Java heap
/// class, not total RAM, and it underestimates every modern phone.
final class PlatformMemoryProbe implements DeviceMemoryProbe {
  const PlatformMemoryProbe();

  @override
  Future<int?> totalMemoryGb() async {
    final plugin = DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        return _mbToGb((await plugin.androidInfo).physicalRamSize);
      }
      if (Platform.isIOS) {
        return _mbToGb((await plugin.iosInfo).physicalRamSize);
      }
      if (Platform.isMacOS) {
        return _bytesToGb((await plugin.macOsInfo).memorySize);
      }
      if (Platform.isWindows) {
        return _mbToGb((await plugin.windowsInfo).systemMemoryInMegabytes);
      }
      return null;
    } on Object {
      // A probe failure must not break the picker: null reads as "unknown".
      return null;
    }
  }

  int? _mbToGb(int megabytes) {
    if (megabytes <= 0) return null;
    return (megabytes / 1024).floor();
  }

  int? _bytesToGb(int bytes) {
    if (bytes <= 0) return null;
    return (bytes / (1024 * 1024 * 1024)).floor();
  }
}

/// The probe used by the picker.
///
/// Overridden in tests with a fixed value so a model's "fits this device" flag can be
/// asserted without hardware.
final deviceMemoryProbeProvider = Provider<DeviceMemoryProbe>(
  (ref) => const PlatformMemoryProbe(),
  name: 'deviceMemoryProbe',
);
