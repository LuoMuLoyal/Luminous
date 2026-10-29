/// Repository-boundary failure vocabulary, published for the `data/` layer.
///
/// `data/**` may import `core/network/` but not `core/errors/` or
/// `core/logger/`. Repositories still have to hand a typed failure back to
/// their domain interface (`TaskEither<LucentFailure, T>`), so this file
/// re-publishes that vocabulary on the allowed side of the boundary. It holds
/// no logic — the types stay owned by `core/errors/` and the wire codes by
/// `core/network/contract/error_code.dart`.
library;

export 'package:luminous/core/errors/client_error_code.dart'
    show ClientErrorCode;
export 'package:luminous/core/errors/lucent_failure.dart'
    show LucentFailure, LucentFailureKind;
export 'package:luminous/core/network/contract/error_code.dart'
    show NetworkErrorCode;
