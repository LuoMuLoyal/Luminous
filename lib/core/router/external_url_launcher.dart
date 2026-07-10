import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:url_launcher/url_launcher.dart';

part 'external_url_launcher.g.dart';

class ExternalUrlLauncher {
  const ExternalUrlLauncher();

  Future<bool> open(Uri uri) {
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

@riverpod
ExternalUrlLauncher externalUrlLauncher(Ref ref) {
  return const ExternalUrlLauncher();
}
