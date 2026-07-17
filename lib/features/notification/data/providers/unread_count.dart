import 'package:luminous/core/providers/auth_guarded.dart';
import 'package:luminous/features/auth/presentation/providers/session.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/lucent.dart';

part 'unread_count.g.dart';

/// Unread notification count provider.
///
/// This is a pure data-fetching provider (no presentation state) that
/// lives in the data layer so that other features (e.g. mine) can depend
/// on it without importing notification/presentation/.
@Riverpod(keepAlive: true)
Future<int> notificationUnreadCount(Ref ref) async {
  return authGuarded(
    ref: ref,
    fetch: () => ref.watch(notificationRepositoryProvider).getUnreadCount(),
    signedOutFallback: () => pendingAuthSessionResolution(),
  );
}
