import 'package:luminous/core/network/client_providers.dart';
import 'package:luminous/features/auth/data/repositories/sessions.dart';
import 'package:luminous/features/auth/domain/repositories/sessions.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sessions.g.dart';

@riverpod
AuthSessionsRepository authSessionsRepository(Ref ref) {
  return LucentAuthSessionsRepository(
    dio: ref.watch(lucentDioClientProvider).dio,
  );
}
