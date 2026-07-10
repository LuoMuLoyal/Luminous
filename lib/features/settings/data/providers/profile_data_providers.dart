import 'package:luminous/core/network/network_providers.dart';
import 'package:luminous/features/settings/data/datasources/profile_remote_data_source.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_data_providers.g.dart';

@riverpod
SettingsProfileRemoteDataSource settingsProfileRemoteDataSource(Ref ref) {
  final dio = ref.watch(lucentDioClientProvider).dio;
  return SettingsProfileRemoteDataSource(dio: dio);
}
