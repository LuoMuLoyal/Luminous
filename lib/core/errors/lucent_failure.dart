/// Re-export façade: the failure vocabulary now lives in the shared domain
/// kernel (`lib/shared/domain/failure.dart`) so feature `domain/` layers can
/// speak it without importing `lib/core/**` (clean-layers R1/R2).
///
/// Existing imports of this path keep working unchanged.
library;

export 'package:luminous/shared/domain/failure.dart';
