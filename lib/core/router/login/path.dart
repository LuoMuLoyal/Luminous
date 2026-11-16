/// Path of the sign-in page, mirrored for callers that cannot import
/// `features/auth/**` (`core/widgets/**` gates) — `core/` may not import
/// `features/`, so it keeps a literal instead of `LoginRoute.path`.
///
/// Drift is guarded by `test/core/widgets/login_path_test.dart`, which compares
/// it against the typed route.
library;

const String loginPath = '/login';
