/// Unified cache and sync constants.
///
/// All time-based constants related to Drift cache management, background
/// refresh throttling, and the offline sync queue live here so they can be
/// audited and adjusted in one place.
///
/// ## Cache strategy
///
/// The app uses a cache-first pattern: cached data is returned immediately
/// (if available), then a background refresh fetches fresh data from the
/// network. There is no per-cache TTL expiration — `cachedAt` is stored for
/// cleanup purposes only. The [cacheCleanup] provider purges old synced
/// rows based on the user's data retention preference (30/90/forever).
///
/// ## Sync strategy
///
/// Offline writes are enqueued in [PendingSyncItems] and replayed by
/// [SyncWorker] when connectivity is restored. Retries use exponential
/// backoff. After [defaultMaxRetry] attempts, an item is permanently
/// failed and surfaced to the user via the [syncFailedCountProvider].
library;

// ── Background refresh throttle ──────────────────────────────────────

/// Minimum interval between background refresh attempts for the same
/// cache entry (e.g. health context snapshot).
///
/// Prevents redundant network calls when the user rapidly navigates
/// between screens that read the same cache.
const Duration backgroundRefreshThrottle = Duration(seconds: 30);

// ── Network timeouts ─────────────────────────────────────────────────

/// Short timeout for dashboard/initial-load network calls that have a
/// cache fallback. If the network doesn't respond within this window,
/// the app falls back to cached data.
const Duration networkTimeoutShort = Duration(seconds: 5);

/// Loading floor timeout: when first load (empty cache) exceeds this
/// duration, a "loading slow" hint with a retry option is shown instead
/// of an indefinite skeleton.
const Duration loadingFloorTimeout = Duration(seconds: 6);

/// Session restore timeout: abandon waiting after this duration and
/// degrade to a signed-out-with-timeout state so tabs can show fallback
/// content or error UI instead of an indefinite skeleton.
const Duration sessionRestoreTimeout = Duration(seconds: 8);

// ── Sync queue ───────────────────────────────────────────────────────

/// Default maximum retry attempts for a pending sync item before it is
/// marked as permanently failed.
const int defaultMaxRetry = 5;

/// Base delay for exponential backoff between sync retries.
/// Actual delay = [syncBackoffBase] * 2^retryCount, capped at
/// [syncBackoffMax].
const Duration syncBackoffBase = Duration(seconds: 30);

/// Maximum backoff delay between sync retries.
const Duration syncBackoffMax = Duration(minutes: 30);
