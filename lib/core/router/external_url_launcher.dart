import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class ExternalUrlLauncher {
  const ExternalUrlLauncher();

  Future<bool> open(Uri uri) {
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

final externalUrlLauncherProvider = Provider<ExternalUrlLauncher>((ref) {
  return const ExternalUrlLauncher();
});
