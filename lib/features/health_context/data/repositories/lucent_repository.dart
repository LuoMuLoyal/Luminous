// ignore_for_file: prefer_initializing_formals

import 'package:luminous/features/health_context/data/datasources/remote_data_source.dart';
import 'package:luminous/features/health_context/data/mappers/mapper.dart';
import 'package:luminous/features/health_context/domain/entities/snapshot.dart';
import 'package:luminous/features/health_context/domain/entities/write_inputs.dart';
import 'package:luminous/features/health_context/domain/repositories/repository.dart';

/// Lucent-backed [HealthContextRepository] implementation.
class LucentHealthContextRepository implements HealthContextRepository {
  LucentHealthContextRepository({
    required HealthContextRemoteDataSource dataSource,
    required HealthContextMapper mapper,
  }) : _dataSource = dataSource,
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
    HealthProfileUpdateInput input,
  ) async {
    final result = await _dataSource.updateProfile(input);
    return _mapper.fromDto(result);
  }

  @override
  Future<HealthContextSnapshot> createAllergy(
    HealthAllergyWriteInput input,
  ) async {
    final result = await _dataSource.createAllergy(input);
    return _mapper.fromDto(result);
  }

  @override
  Future<HealthContextSnapshot> updateAllergy(
    String id,
    HealthAllergyUpdateInput input,
  ) async {
    final result = await _dataSource.updateAllergy(id, input);
    return _mapper.fromDto(result);
  }

  @override
  Future<HealthContextSnapshot> deleteAllergy(String id) async {
    final result = await _dataSource.deleteAllergy(id);
    return _mapper.fromDto(result);
  }

  @override
  Future<HealthContextSnapshot> createCondition(
    HealthConditionWriteInput input,
  ) async {
    final result = await _dataSource.createCondition(input);
    return _mapper.fromDto(result);
  }

  @override
  Future<HealthContextSnapshot> updateCondition(
    String id,
    HealthConditionUpdateInput input,
  ) async {
    final result = await _dataSource.updateCondition(id, input);
    return _mapper.fromDto(result);
  }

  @override
  Future<HealthContextSnapshot> deleteCondition(String id) async {
    final result = await _dataSource.deleteCondition(id);
    return _mapper.fromDto(result);
  }

  @override
  Future<HealthContextSnapshot> createCurrentMedicine(
    CurrentMedicineWriteInput input,
  ) async {
    final result = await _dataSource.createCurrentMedicine(input);
    return _mapper.fromDto(result);
  }

  @override
  Future<HealthContextSnapshot> updateCurrentMedicine(
    String id,
    CurrentMedicineUpdateInput input,
  ) async {
    final result = await _dataSource.updateCurrentMedicine(id, input);
    return _mapper.fromDto(result);
  }

  @override
  Future<HealthContextSnapshot> deleteCurrentMedicine(String id) async {
    final result = await _dataSource.deleteCurrentMedicine(id);
    return _mapper.fromDto(result);
  }
}
