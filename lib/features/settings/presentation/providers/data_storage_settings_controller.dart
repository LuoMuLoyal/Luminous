import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'data_storage_settings_controller.freezed.dart';

/// Offline data retention period.
enum DataRetentionPeriod {
  thirtyDays('30', 30),
  ninetyDays('90', 90),
  forever('forever', -1);

  const DataRetentionPeriod(this.storageValue, this.days);

  /// The value persisted in [SharedPreferences].
  final String storageValue;

  /// The retention period in days, or `-1` for unlimited.
  final int days;

  static DataRetentionPeriod fromStorage(String? value) {
    for (final period in DataRetentionPeriod.values) {
      if (period.storageValue == value) {
        return period;
      }
    }
    return DataRetentionPeriod.ninetyDays;
  }
}

/// Image quality preference for network images (e.g. medicine photos).
enum ImageQualityPreference {
  standard('standard'),
  dataSaver('dataSaver');

  const ImageQualityPreference(this.storageValue);

  final String storageValue;

  static ImageQualityPreference fromStorage(String? value) {
    for (final quality in ImageQualityPreference.values) {
      if (quality.storageValue == value) {
        return quality;
      }
    }
    return ImageQualityPreference.standard;
  }
}

/// Network sync preference.
enum SyncPreference {
  wifiOnly('wifiOnly'),
  wifiAndMobile('wifiAndMobile');

  const SyncPreference(this.storageValue);

  final String storageValue;

  static SyncPreference fromStorage(String? value) {
    for (final pref in SyncPreference.values) {
      if (pref.storageValue == value) {
        return pref;
      }
    }
    return SyncPreference.wifiAndMobile;
  }
}

@freezed
abstract class DataStorageSettingsState with _$DataStorageSettingsState {
  const factory DataStorageSettingsState({
    @Default(DataRetentionPeriod.ninetyDays)
    DataRetentionPeriod retentionPeriod,
    @Default(ImageQualityPreference.standard)
    ImageQualityPreference imageQuality,
    @Default(SyncPreference.wifiAndMobile) SyncPreference syncPreference,
  }) = _DataStorageSettingsState;
}

class DataStorageSettingsController
    extends AsyncNotifier<DataStorageSettingsState> {
  static const _retentionKey = 'settings.dataStorage.retentionPeriod';
  static const _imageQualityKey = 'settings.dataStorage.imageQuality';
  static const _syncKey = 'settings.dataStorage.syncPreference';

  @override
  Future<DataStorageSettingsState> build() async {
    final preferences = await SharedPreferences.getInstance();
    return DataStorageSettingsState(
      retentionPeriod: DataRetentionPeriod.fromStorage(
        preferences.getString(_retentionKey),
      ),
      imageQuality: ImageQualityPreference.fromStorage(
        preferences.getString(_imageQualityKey),
      ),
      syncPreference: SyncPreference.fromStorage(
        preferences.getString(_syncKey),
      ),
    );
  }

  Future<void> setRetentionPeriod(DataRetentionPeriod period) async {
    final next = (state.asData?.value ?? const DataStorageSettingsState())
        .copyWith(retentionPeriod: period);
    state = AsyncData(next);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_retentionKey, period.storageValue);
  }

  Future<void> setImageQuality(ImageQualityPreference quality) async {
    final next = (state.asData?.value ?? const DataStorageSettingsState())
        .copyWith(imageQuality: quality);
    state = AsyncData(next);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_imageQualityKey, quality.storageValue);
  }

  Future<void> setSyncPreference(SyncPreference pref) async {
    final next = (state.asData?.value ?? const DataStorageSettingsState())
        .copyWith(syncPreference: pref);
    state = AsyncData(next);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_syncKey, pref.storageValue);
  }

  Future<void> reset() async {
    state = const AsyncData(DataStorageSettingsState());
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_retentionKey);
    await preferences.remove(_imageQualityKey);
    await preferences.remove(_syncKey);
  }
}

final dataStorageSettingsControllerProvider =
    AsyncNotifierProvider<
      DataStorageSettingsController,
      DataStorageSettingsState
    >(DataStorageSettingsController.new);
