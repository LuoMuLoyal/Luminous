import 'package:fpdart/fpdart.dart';
import 'package:luminous/core/errors/lucent_failure.dart';

import '../entities/notification.dart';

/// Repository interface for user notifications.
///
/// All methods require an authenticated session; callers should guard with
/// [authGuarded] or equivalent session checks at the provider layer.
///
/// Repository boundary: every expected recoverable failure (network, server
/// business failure) is a `TaskEither` Left produced via
/// `LucentErrorMapper.fromObject`; a successful response is a Right.
abstract interface class NotificationRepository {
  /// Returns a single page of notifications.
  ///
  /// An empty page is a legal Right (empty inbox is not an error); server
  /// business failures (4xx/5xx Problem Details) are a Left that preserves
  /// the service `code`/`status`.
  TaskEither<LucentFailure, NotificationPage> findAll({
    required int page,
    required int pageSize,
  });

  /// Returns the full detail of a single notification.
  ///
  /// A not-found notification is a 404 Problem Details response → Left
  /// business failure (service `code`/`status` preserved); an empty success
  /// body is a `Left(network/emptyResponse)` (see [LucentNotificationRepository]
  /// `_requireData` contract). `Right(null)` is never produced — the nullable
  /// result type only mirrors the generated client payload.
  TaskEither<LucentFailure, NotificationDetail?> findOne(String id);

  /// Returns the count of unread notifications for the current user.
  TaskEither<LucentFailure, int> getUnreadCount();

  /// Marks all notifications as read.
  TaskEither<LucentFailure, void> markAllAsRead();

  /// Marks a single notification as read.
  TaskEither<LucentFailure, void> markAsRead(String id);

  /// Marks a single notification as unread.
  TaskEither<LucentFailure, void> markAsUnread(String id);

  /// Deletes a notification by id.
  TaskEither<LucentFailure, void> delete(String id);
}
