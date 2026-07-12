import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucent_api/api/export.dart';
import '../auth/test_helpers.dart' as auth_helpers;
import 'package:luminous/core/network/network_providers.dart';
import 'package:luminous/features/auth/presentation/providers/session.dart';
import 'package:luminous/features/notification/presentation/providers/notification.dart';

// ── Fake NotificationsApi ───────────────────────────────────────────────────

class FakeNotificationsApi implements NotificationsApi {
  FakeNotificationsApi({
    this.unreadCount = 0,
    this.notifications = const [],
    this.detail,
    this.shouldThrow = false,
  });

  int unreadCount;
  List<NotificationListItemDto> notifications;
  NotificationDetailDto? detail;
  bool shouldThrow;
  int findAllCallCount = 0;

  @override
  Future<UnreadCountResponseDto>
  notificationsControllerGetUnreadCountV1() async {
    if (shouldThrow) {
      throw DioException(requestOptions: RequestOptions(path: ''));
    }
    return UnreadCountResponseDto(code: 0, message: '', count: unreadCount);
  }

  @override
  Future<NotificationListResponseDto> notificationsControllerFindAllV1({
    required num page,
    required num pageSize,
  }) async {
    findAllCallCount++;
    if (shouldThrow) {
      throw DioException(requestOptions: RequestOptions(path: ''));
    }
    return NotificationListResponseDto(
      code: 0,
      message: '',
      items: notifications,
      total: notifications.length,
    );
  }

  @override
  Future<NotificationDetailResponseDto> notificationsControllerFindOneV1({
    required String id,
  }) async {
    if (shouldThrow) {
      throw DioException(requestOptions: RequestOptions(path: ''));
    }
    return NotificationDetailResponseDto(
      code: 0,
      message: '',
      data:
          detail ??
          NotificationDetailDto(
            id: id,
            type: UserNotificationType.systemAnnouncement,
            title: '',
            content: '',
            isRead: false,
            createdAt: '2026-06-10T08:00:00.000Z',
          ),
    );
  }

  @override
  Future<void> notificationsControllerRemoveV1({required String id}) async {}

  @override
  Future<UnreadCountResponseDto>
  notificationsControllerMarkAllAsReadV1() async {
    return const UnreadCountResponseDto(code: 0, message: '', count: 0);
  }

  @override
  Future<NotificationListResponseDto> notificationsControllerCreateV1({
    required CreateNotificationDto body,
  }) async {
    return const NotificationListResponseDto(
      code: 0,
      message: '',
      items: [],
      total: 0,
    );
  }

  @override
  Future<NotificationDetailResponseDto> notificationsControllerMarkAsReadV1({
    required String id,
  }) async {
    return NotificationDetailResponseDto(
      code: 0,
      message: '',
      data:
          detail ??
          NotificationDetailDto(
            id: id,
            type: UserNotificationType.systemAnnouncement,
            title: '',
            content: '',
            isRead: true,
            createdAt: '2026-06-10T08:00:00.000Z',
          ),
    );
  }

  @override
  Future<NotificationDetailResponseDto> notificationsControllerMarkAsUnreadV1({
    required String id,
  }) async {
    return NotificationDetailResponseDto(
      code: 0,
      message: '',
      data:
          detail ??
          NotificationDetailDto(
            id: id,
            type: UserNotificationType.systemAnnouncement,
            title: '',
            content: '',
            isRead: false,
            createdAt: '2026-06-10T08:00:00.000Z',
          ),
    );
  }
}

// ── Error-returning API for throws test ──────────────────────────────────────

/// A [LucentClient] subclass that returns a fake [NotificationsApi].
class _FakeLucentClient extends LucentClient {
  _FakeLucentClient({required this.notificationsApi}) : super(Dio());

  final NotificationsApi notificationsApi;

  @override
  NotificationsApi get notifications => notificationsApi;
}

class _ErrorUnreadCountApi extends FakeNotificationsApi {
  _ErrorUnreadCountApi() : super(unreadCount: 0);

  @override
  Future<UnreadCountResponseDto>
  notificationsControllerGetUnreadCountV1() async {
    return const UnreadCountResponseDto(
      code: 500001,
      message: 'Server error',
      count: 0,
    );
  }
}

// ── Helpers ─────────────────────────────────────────────────────────────────

NotificationListItemDto _item({
  required String id,
  String title = 'Title',
  String content = 'Content',
  bool isRead = false,
}) {
  return NotificationListItemDto(
    id: id,
    type: UserNotificationType.systemAnnouncement,
    title: title,
    content: content,
    isRead: isRead,
    createdAt: '2026-06-10T08:00:00.000Z',
  );
}

void main() {
  late auth_helpers.SignedInAuthSessionNotifier signedInSession;

  setUp(() {
    signedInSession = auth_helpers.SignedInAuthSessionNotifier();
  });

  group('notificationUnreadCountProvider', () {
    test('returns unread count', () async {
      final api = FakeNotificationsApi(unreadCount: 3);
      final container = ProviderContainer(
        overrides: [
          authSessionProvider.overrideWith(() => signedInSession),
          lucentClientProvider.overrideWithValue(
            _FakeLucentClient(notificationsApi: api),
          ),
        ],
      );
      addTearDown(container.dispose);

      final count = await container.read(
        notificationUnreadCountProvider.future,
      );
      expect(count, equals(3));
    });

    test('throws StateError when API returns non-zero code', () async {
      final errorApi = _ErrorUnreadCountApi();
      final container = ProviderContainer(
        overrides: [
          authSessionProvider.overrideWith(() => signedInSession),
          lucentClientProvider.overrideWithValue(
            _FakeLucentClient(notificationsApi: errorApi),
          ),
        ],
      );
      addTearDown(container.dispose);

      expect(
        container.read(notificationUnreadCountProvider.future),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('notificationListPageProvider', () {
    test('returns paginated notification list', () async {
      final api = FakeNotificationsApi(
        notifications: [
          _item(id: '1', title: 'First'),
          _item(id: '2', title: 'Second'),
        ],
      );
      final container = ProviderContainer(
        overrides: [
          authSessionProvider.overrideWith(() => signedInSession),
          lucentClientProvider.overrideWithValue(
            _FakeLucentClient(notificationsApi: api),
          ),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(notificationListPageProvider.future);
      expect(result.items, hasLength(2));
      expect(result.items[0].title, equals('First'));
    });
  });

  group('notificationDetailProvider', () {
    test('returns notification detail', () async {
      final api = FakeNotificationsApi(
        detail: const NotificationDetailDto(
          id: 'notif-1',
          type: UserNotificationType.systemAnnouncement,
          title: 'Missed dose',
          content: 'You missed a dose.',
          isRead: false,
          createdAt: '2026-06-10T08:00:00.000Z',
          readAt: null,
        ),
      );
      final container = ProviderContainer(
        overrides: [
          authSessionProvider.overrideWith(() => signedInSession),
          lucentClientProvider.overrideWithValue(
            _FakeLucentClient(notificationsApi: api),
          ),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(
        notificationDetailProvider('notif-1').future,
      );
      expect(result, isNotNull);
      expect(result!.title, equals('Missed dose'));
    });
  });

  group('NotificationListController', () {
    test('loads initial page on build', () async {
      final api = FakeNotificationsApi(
        notifications: [_item(id: '1', title: 'First')],
      );
      final container = ProviderContainer(
        overrides: [
          authSessionProvider.overrideWith(() => signedInSession),
          lucentClientProvider.overrideWithValue(
            _FakeLucentClient(notificationsApi: api),
          ),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(
        notificationListControllerProvider.future,
      );
      expect(result.items, hasLength(1));
      expect(result.items[0].title, equals('First'));
    });

    test('hasMore returns false when all items loaded', () async {
      final api = FakeNotificationsApi(notifications: [_item(id: '1')]);
      final container = ProviderContainer(
        overrides: [
          authSessionProvider.overrideWith(() => signedInSession),
          lucentClientProvider.overrideWithValue(
            _FakeLucentClient(notificationsApi: api),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(notificationListControllerProvider.future);
      final controller = container.read(
        notificationListControllerProvider.notifier,
      );
      expect(controller.hasMore, isFalse);
    });

    test('loadMore does nothing when hasMore is false', () async {
      final api = FakeNotificationsApi(notifications: [_item(id: '1')]);
      final container = ProviderContainer(
        overrides: [
          authSessionProvider.overrideWith(() => signedInSession),
          lucentClientProvider.overrideWithValue(
            _FakeLucentClient(notificationsApi: api),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(notificationListControllerProvider.future);
      final controller = container.read(
        notificationListControllerProvider.notifier,
      );
      await controller.loadMore();
      // findAllCallCount should remain 1 (only the build call)
      expect(api.findAllCallCount, equals(1));
    });

    test('markAllAsRead refreshes the list', () async {
      final api = FakeNotificationsApi(notifications: [_item(id: '1')]);
      final container = ProviderContainer(
        overrides: [
          authSessionProvider.overrideWith(() => signedInSession),
          lucentClientProvider.overrideWithValue(
            _FakeLucentClient(notificationsApi: api),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(notificationListControllerProvider.future);
      final controller = container.read(
        notificationListControllerProvider.notifier,
      );
      await controller.markAllAsRead();
      final result = container
          .read(notificationListControllerProvider)
          .requireValue;
      expect(result.items, hasLength(1));
    });

    test('deleteNotification refreshes the list', () async {
      final api = FakeNotificationsApi(notifications: [_item(id: '1')]);
      final container = ProviderContainer(
        overrides: [
          authSessionProvider.overrideWith(() => signedInSession),
          lucentClientProvider.overrideWithValue(
            _FakeLucentClient(notificationsApi: api),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(notificationListControllerProvider.future);
      final controller = container.read(
        notificationListControllerProvider.notifier,
      );
      await controller.deleteNotification('1');
      final result = container
          .read(notificationListControllerProvider)
          .requireValue;
      expect(result.items, hasLength(1));
    });
  });
}
