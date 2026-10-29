import 'package:luminous/core/network/client/client_providers.dart';
import 'package:luminous/features/settings/data/datasources/profile_remote.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile.g.dart';

@riverpod
SettingsProfileRemoteDataSource settingsProfileRemoteDataSource(Ref ref) {
  final dio = ref.watch(lucentDioClientProvider).dio;
  return SettingsProfileRemoteDataSource(dio: dio);
}
