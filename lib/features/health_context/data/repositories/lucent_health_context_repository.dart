// ignore_for_file: prefer_initializing_formals

import 'package:luminous/features/health_context/data/datasources/health_context_remote_data_source.dart';
import 'package:luminous/features/health_context/data/mappers/health_context_mapper.dart';
import 'package:luminous/features/health_context/domain/entities/health_context_snapshot.dart';
import 'package:luminous/features/health_context/domain/repositories/health_context_repository.dart';

/// Lucent-backed [HealthContextRepository] implementation.
class LucentHealthContextRepository implements HealthContextRepository {
  LucentHealthContextRepository({
    required HealthContextRemoteDataSource dataSource,
    required HealthContextMapper mapper,
  })  : _dataSource = dataSource,
        _mapper = mapper;

  final HealthContextRemoteDataSource _dataSource;
  final HealthContextMapper _mapper;

  @override
  Future<HealthContextSnapshot> fetchHealthContext() async {
    final dto = await _dataSource.fetchHealthContext();
    return _mapper.fromDto(dto);
  }
}
