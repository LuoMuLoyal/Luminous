/// Water-target constants and provider.
///
/// The constants are domain values (`record/domain/constants/water.dart`); the
/// provider itself is composed in `lib/app/composition/record_water_target.dart`
/// because it reads the settings feature's repository, which `record/data/`
/// may not import.
library;

export 'package:luminous/app/composition/tokens/record_water_target.dart';
export 'package:luminous/features/record/domain/constants/water.dart';
