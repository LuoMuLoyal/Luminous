// ignore_for_file: prefer_initializing_formals

import 'package:lucent_openapi/lucent_openapi.dart';
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

  @override
  Future<HealthContextSnapshot> updateProfile(
    UpdateHealthContextProfileDto dto,
  ) async {
    final result = await _dataSource.updateProfile(dto);
    return _mapper.fromDto(result);
  }

  @override
  Future<HealthContextSnapshot> createAllergy(
    CreateHealthContextAllergyDto dto,
  ) async {
    final result = await _dataSource.createAllergy(dto);
    return _mapper.fromDto(result);
  }

  @override
  Future<HealthContextSnapshot> updateAllergy(
    String id,
    UpdateHealthContextAllergyDto dto,
  ) async {
    final result = await _dataSource.updateAllergy(id, dto);
    return _mapper.fromDto(result);
  }

  @override
  Future<HealthContextSnapshot> deleteAllergy(String id) async {
    final result = await _dataSource.deleteAllergy(id);
    return _mapper.fromDto(result);
  }

  @override
  Future<HealthContextSnapshot> createCondition(
    CreateHealthContextConditionDto dto,
  ) async {
    final result = await _dataSource.createCondition(dto);
    return _mapper.fromDto(result);
  }

  @override
  Future<HealthContextSnapshot> updateCondition(
    String id,
    UpdateHealthContextConditionDto dto,
  ) async {
    final result = await _dataSource.updateCondition(id, dto);
    return _mapper.fromDto(result);
  }

  @override
  Future<HealthContextSnapshot> deleteCondition(String id) async {
    final result = await _dataSource.deleteCondition(id);
    return _mapper.fromDto(result);
  }

  @override
  Future<HealthContextSnapshot> createCurrentMedicine(
    CreateCurrentMedicineDto dto,
  ) async {
    final result = await _dataSource.createCurrentMedicine(dto);
    return _mapper.fromDto(result);
  }

  @override
  Future<HealthContextSnapshot> updateCurrentMedicine(
    String id,
    UpdateCurrentMedicineDto dto,
  ) async {
    final result = await _dataSource.updateCurrentMedicine(id, dto);
    return _mapper.fromDto(result);
  }

  @override
  Future<HealthContextSnapshot> deleteCurrentMedicine(String id) async {
    final result = await _dataSource.deleteCurrentMedicine(id);
    return _mapper.fromDto(result);
  }
}
