import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/network/lucent_network_providers.dart';
import 'package:luminous/features/settings/data/datasources/settings_profile_remote_data_source.dart';

final settingsProfileRemoteDataSourceProvider =
    Provider<SettingsProfileRemoteDataSource>((ref) {
      final dio = ref.watch(lucentDioClientProvider).dio;
      return SettingsProfileRemoteDataSource(dio: dio);
    });
