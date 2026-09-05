import 'package:clock/clock.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucent_api/lucent_api.dart' as lucent;
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/network/contract/error_code.dart';
import 'package:luminous/core/network/contract/problem_details.dart';
import 'package:luminous/features/assistant/data/datasources/assistant.dart';
import 'package:luminous/features/assistant/data/repositories/lucent.dart';
import 'package:luminous/features/assistant/domain/entities/models.dart';
import 'package:luminous/features/assistant/domain/repositories/assistant.dart';

import '../../../helpers/task_either.dart';

// ── Fake data source ───────────────────────────────────────────

class _FakeAssistantRemoteDataSource extends AssistantRemoteDataSource {
  _FakeAssistantRemoteDataSource({
    this._capabilities,
    this._latestConversation,
    this._recentConversations,
    this._openedConversation,
    this._clearResult,
    this._stream,
    this._regenerateStream,
    this.failureToThrow,
  }) : super(
         api: lucent.AssistantApi(Dio(BaseOptions())),
         dio: Dio(BaseOptions()),
       );

  final lucent.AssistantCapabilitiesResponse? _capabilities;
  final lucent.AssistantConversationData? _latestConversation;
  final List<lucent.AssistantConversationSummaryItem>? _recentConversations;
  final lucent.AssistantConversationData? _openedConversation;
  final bool? _clearResult;
  final Stream<AssistantRemoteEvent>? _stream;
  final Stream<AssistantRemoteEvent>? _regenerateStream;

  /// When set, every non-stream method throws this error instead of
  /// returning its canned value (used to exercise the repository failure
  /// boundary).
  final Object? failureToThrow;

  String? lastOpenedConversationId;
  String? lastStreamConversationId;
  String? lastRegenerateConversationId;
  final List<(String, List<String>, String, String?)> confirmProposalsCalls =
      <(String, List<String>, String, String?)>[];

  void _maybeThrow() {
    final failure = failureToThrow;
    if (failure != null) {
      throw failure;
    }
  }

  @override
  Future<lucent.AssistantCapabilitiesResponse> getCapabilities() async {
    _maybeThrow();
    if (_capabilities == null) {
      throw const LucentFailure(
        kind: LucentFailureKind.unknown,
        message: 'not configured',
      );
    }
    return _capabilities;
  }

  @override
  Future<lucent.AssistantConversationData?> getLatestConversation() async {
    _maybeThrow();
    return _latestConversation;
  }

  @override
  Future<List<lucent.AssistantConversationSummaryItem>>
  listRecentConversations() async {
    _maybeThrow();
    return _recentConversations ?? const [];
  }

  @override
  Future<lucent.AssistantConversationData> openConversation(
    String conversationId,
  ) async {
    lastOpenedConversationId = conversationId;
    _maybeThrow();
    if (_openedConversation == null) {
      throw const LucentFailure(
        kind: LucentFailureKind.unknown,
        message: 'not found',
      );
    }
    return _openedConversation;
  }

  @override
  Future<bool> clearLatestConversation() async {
    _maybeThrow();
    return _clearResult ?? true;
  }

  @override
  Stream<AssistantRemoteEvent> streamMessages({
    required List<lucent.StreamMessagesRequestMessages> messages,
    String? conversationId,
  }) {
    lastStreamConversationId = conversationId;
    return _stream ?? const Stream.empty();
  }

  @override
  Stream<AssistantRemoteEvent> regenerateLastMessage({
    required String conversationId,
  }) {
    lastRegenerateConversationId = conversationId;
    return _regenerateStream ?? const Stream.empty();
  }

  @override
  Future<String?> confirmProposals({
    required String conversationId,
    required List<String> proposalIds,
    required String decision,
    String? note,
  }) async {
    _maybeThrow();
    confirmProposalsCalls.add((conversationId, proposalIds, decision, note));
    return null;
  }

  final List<(String, String)> renameCalls = <(String, String)>[];
  final List<String> deleteCalls = <String>[];

  @override
  Future<lucent.AssistantConversationData> renameConversation({
    required String conversationId,
    required String title,
  }) async {
    _maybeThrow();
    renameCalls.add((conversationId, title));
    return _conversationDto(id: conversationId, title: title);
  }

  @override
  Future<void> deleteConversation(String conversationId) async {
    _maybeThrow();
    deleteCalls.add(conversationId);
  }
}

// ── DTO factories ──────────────────────────────────────────────

lucent.AssistantCapabilitiesResponseAssistantContext _context({
  bool health = true,
  bool daily = true,
  bool sleep = false,
  bool meds = true,
}) {
  return lucent.AssistantCapabilitiesResponseAssistantContext(
    healthProfile: health,
    dailyRecords: daily,
    sleepRecords: sleep,
    currentMedicines: meds,
  );
}

lucent.AssistantCapabilitiesResponseTools _tool({
  lucent.AssistantCapabilitiesResponseToolsNameEnum? name,
  bool enabled = true,
  bool implemented = true,
  bool permitted = true,
  List<lucent.AssistantCapabilitiesResponseToolsRequiredContextSourcesEnum>?
  required,
  lucent.AssistantCapabilitiesResponseToolsDisabledReasonEnum? disabledReason,
}) {
  return lucent.AssistantCapabilitiesResponseTools(
    name:
        name ??
        lucent.AssistantCapabilitiesResponseToolsNameEnum.getTodayRecords,
    requiredContextSources:
        required ??
        const <
          lucent.AssistantCapabilitiesResponseToolsRequiredContextSourcesEnum
        >[
          lucent
              .AssistantCapabilitiesResponseToolsRequiredContextSourcesEnum
              .healthProfile,
        ],
    permittedByUser: permitted,
    enabled: enabled,
    implemented: implemented,
    disabledReason: disabledReason,
  );
}

lucent.AssistantCapabilitiesResponse _capabilitiesDto({
  String phase = 'preview',
  bool enabled = true,
  bool memory = false,
  bool chatModel = true,
  bool chatReady = true,
  bool langGraph = true,
  bool streaming = true,
  String transport = 'sse',
  bool markdown = true,
  bool rag = false,
  List<lucent.AssistantCapabilitiesResponseTools>? tools,
  String? updatedAt,
}) {
  return lucent.AssistantCapabilitiesResponse(
    phase: phase,
    assistantEnabled: enabled,
    assistantMemoryEnabled: memory,
    assistantContext: _context(),
    chatModelConfigured: chatModel,
    interactiveChatReady: chatReady,
    langGraphReady: langGraph,
    streamingSupported: streaming,
    streamingTransport: transport,
    markdownRenderingRecommended: markdown,
    ragEnabled: rag,
    tools: tools ?? [_tool()],
    updatedAt: updatedAt,
  );
}

lucent.AssistantConversationDataMessages _messageDto({
  lucent.AssistantConversationDataMessagesRoleEnum? role,
  String content = 'hello',
  List<String>? usedTools,
  String? createdAt,
}) {
  return lucent.AssistantConversationDataMessages(
    role: role ?? lucent.AssistantConversationDataMessagesRoleEnum.user,
    content: content,
    usedTools: usedTools ?? const [],
    createdAt: createdAt ?? '2026-07-01T10:00:00Z',
  );
}

lucent.AssistantConversationData _conversationDto({
  String id = 'conv-1',
  String? title = 'Test Conversation',
  lucent.AssistantConversationDataStatusEnum? status,
  List<lucent.AssistantConversationDataMessages>? messages,
  String? lastMessageAt,
  String? createdAt,
  String? updatedAt,
}) {
  return lucent.AssistantConversationData(
    id: id,
    title: title,
    status: status ?? lucent.AssistantConversationDataStatusEnum.active,
    messages: messages ?? [_messageDto()],
    lastMessageAt: lastMessageAt ?? '2026-07-01T10:30:00Z',
    createdAt: createdAt ?? '2026-07-01T10:00:00Z',
    updatedAt: updatedAt ?? '2026-07-01T10:30:00Z',
  );
}

lucent.AssistantConversationSummaryItem _summaryDto({
  String id = 'conv-1',
  String? title = 'Summary',
  lucent.AssistantConversationSummaryItemStatusEnum? status,
  String? lastMessageAt,
  String? createdAt,
  String? updatedAt,
}) {
  return lucent.AssistantConversationSummaryItem(
    id: id,
    title: title,
    status: status ?? lucent.AssistantConversationSummaryItemStatusEnum.active,
    lastMessageAt: lastMessageAt,
    createdAt: createdAt ?? '2026-07-01T10:00:00Z',
    updatedAt: updatedAt ?? '2026-07-01T10:30:00Z',
  );
}

// ── Tests ──────────────────────────────────────────────────────

void main() {
  group('LucentAssistantRepository.getCapabilities', () {
    test('maps all fields correctly', () async {
      final repo = LucentAssistantRepository(
        dataSource: _FakeAssistantRemoteDataSource(
          capabilities: _capabilitiesDto(
            phase: 'ga',
            enabled: true,
            memory: true,
            chatModel: true,
            chatReady: true,
            streaming: true,
            transport: 'sse',
            markdown: true,
            rag: true,
            tools: [
              _tool(
                name: lucent
                    .AssistantCapabilitiesResponseToolsNameEnum
                    .getUserProfile,
                enabled: true,
                implemented: true,
                required:
                    const <
                      lucent.AssistantCapabilitiesResponseToolsRequiredContextSourcesEnum
                    >[
                      lucent
                          .AssistantCapabilitiesResponseToolsRequiredContextSourcesEnum
                          .healthProfile,
                    ],
              ),
              _tool(
                name: lucent
                    .AssistantCapabilitiesResponseToolsNameEnum
                    .getCurrentMedicines,
                enabled: false,
                implemented: false,
                permitted: false,
                disabledReason: lucent
                    .AssistantCapabilitiesResponseToolsDisabledReasonEnum
                    .notImplemented,
              ),
            ],
            updatedAt: '2026-07-01T00:00:00Z',
          ),
        ),
      );

      final caps = await expectTaskRight(repo.getCapabilities());

      expect(caps.phase, 'ga');
      expect(caps.assistantEnabled, isTrue);
      expect(caps.assistantMemoryEnabled, isTrue);
      expect(caps.chatModelConfigured, isTrue);
      expect(caps.interactiveChatReady, isTrue);
      expect(caps.langGraphReady, isTrue);
      expect(caps.streamingSupported, isTrue);
      expect(caps.streamingTransport, 'sse');
      expect(caps.markdownRenderingRecommended, isTrue);
      expect(caps.ragEnabled, isTrue);
      expect(caps.updatedAt, DateTime.parse('2026-07-01T00:00:00Z'));
      expect(caps.tools, hasLength(2));
      expect(caps.tools[0].id, 'get_user_profile');
      expect(caps.tools[0].enabled, isTrue);
      expect(caps.tools[1].id, 'get_current_medicines');
      expect(caps.tools[1].enabled, isFalse);
      expect(caps.tools[1].disabledReason, 'not_implemented');
      expect(caps.canSendMessages, isTrue);
      expect(caps.enabledToolCount, 1);
    });

    test('canSendMessages is false when assistantEnabled is false', () async {
      final repo = LucentAssistantRepository(
        dataSource: _FakeAssistantRemoteDataSource(
          capabilities: _capabilitiesDto(enabled: false),
        ),
      );
      final caps = await expectTaskRight(repo.getCapabilities());
      expect(caps.canSendMessages, isFalse);
    });

    test('canSendMessages is false when streamingSupported is false', () async {
      final repo = LucentAssistantRepository(
        dataSource: _FakeAssistantRemoteDataSource(
          capabilities: _capabilitiesDto(streaming: false),
        ),
      );
      final caps = await expectTaskRight(repo.getCapabilities());
      expect(caps.canSendMessages, isFalse);
    });

    test('updatedAt is null when DTO field is null', () async {
      final repo = LucentAssistantRepository(
        dataSource: _FakeAssistantRemoteDataSource(
          capabilities: _capabilitiesDto(updatedAt: null),
        ),
      );
      final caps = await expectTaskRight(repo.getCapabilities());
      expect(caps.updatedAt, isNull);
    });

    test('updatedAt is null when DTO field is invalid date', () async {
      final repo = LucentAssistantRepository(
        dataSource: _FakeAssistantRemoteDataSource(
          capabilities: _capabilitiesDto(updatedAt: 'not-a-date'),
        ),
      );
      final caps = await expectTaskRight(repo.getCapabilities());
      expect(caps.updatedAt, isNull);
    });

    test('tool id falls back to empty string for unknown name', () async {
      final repo = LucentAssistantRepository(
        dataSource: _FakeAssistantRemoteDataSource(
          capabilities: _capabilitiesDto(
            tools: [
              _tool(
                name: lucent
                    .AssistantCapabilitiesResponseToolsNameEnum
                    .unknownDefaultOpenApi,
              ),
            ],
          ),
        ),
      );
      final caps = await expectTaskRight(repo.getCapabilities());
      expect(caps.tools.single.id, '');
    });

    test('maps datasource failures to Left(unknown)', () async {
      final repo = LucentAssistantRepository(
        dataSource: _FakeAssistantRemoteDataSource(),
      );
      final failure = await expectTaskLeft(repo.getCapabilities());
      expect(failure.kind, LucentFailureKind.unknown);
      expect(failure.message, 'not configured');
    });
  });

  group('LucentAssistantRepository.getLatestConversation', () {
    test('returns null when data source returns null', () async {
      final repo = LucentAssistantRepository(
        dataSource: _FakeAssistantRemoteDataSource(latestConversation: null),
      );
      expect(await expectTaskRight(repo.getLatestConversation()), isNull);
    });

    test('maps conversation with messages', () async {
      final repo = LucentAssistantRepository(
        dataSource: _FakeAssistantRemoteDataSource(
          latestConversation: _conversationDto(
            id: 'conv-99',
            title: 'Chat About Meds',
            messages: [
              _messageDto(
                role: lucent.AssistantConversationDataMessagesRoleEnum.user,
                content: 'What is atorvastatin?',
                createdAt: '2026-07-01T10:00:00Z',
              ),
              _messageDto(
                role:
                    lucent.AssistantConversationDataMessagesRoleEnum.assistant,
                content: 'It is a statin.',
                usedTools: const ['get_current_medicines'],
                createdAt: '2026-07-01T10:00:05Z',
              ),
            ],
          ),
        ),
      );

      final conv = await expectTaskRight(repo.getLatestConversation());

      expect(conv, isNotNull);
      expect(conv!.id, 'conv-99');
      expect(conv.title, 'Chat About Meds');
      expect(conv.status, 'active');
      expect(conv.messages, hasLength(2));
      expect(conv.messages[0].role, AssistantMessageRole.user);
      expect(conv.messages[0].content, 'What is atorvastatin?');
      expect(conv.messages[1].role, AssistantMessageRole.assistant);
      expect(conv.messages[1].content, 'It is a statin.');
      expect(conv.messages[1].usedTools, ['get_current_medicines']);
      expect(conv.messages[1].toolDetails, isEmpty);
      expect(conv.lastMessageAt, DateTime.parse('2026-07-01T10:30:00Z'));
    });

    test('falls back to clock.now when createdAt is null/invalid', () async {
      final fixedTime = DateTime(2026, 7, 1, 12, 0, 0);
      await withClock(Clock.fixed(fixedTime), () async {
        final repo = LucentAssistantRepository(
          dataSource: _FakeAssistantRemoteDataSource(
            latestConversation: _conversationDto(
              createdAt: 'not-a-date',
              updatedAt: 'also-bad',
            ),
          ),
        );
        final conv = await expectTaskRight(repo.getLatestConversation());
        expect(conv!.createdAt, fixedTime);
        expect(conv.updatedAt, fixedTime);
      });
    });

    test('maps unknown role to assistant', () async {
      final repo = LucentAssistantRepository(
        dataSource: _FakeAssistantRemoteDataSource(
          latestConversation: _conversationDto(
            messages: [
              _messageDto(
                role: lucent
                    .AssistantConversationDataMessagesRoleEnum
                    .unknownDefaultOpenApi,
              ),
            ],
          ),
        ),
      );
      final conv = await expectTaskRight(repo.getLatestConversation());
      expect(conv!.messages.single.role, AssistantMessageRole.assistant);
    });
  });

  group('LucentAssistantRepository.listRecentConversations', () {
    test('maps list of summaries', () async {
      final repo = LucentAssistantRepository(
        dataSource: _FakeAssistantRemoteDataSource(
          recentConversations: [
            _summaryDto(id: 'c1', title: 'First'),
            _summaryDto(
              id: 'c2',
              title: 'Second',
              status:
                  lucent.AssistantConversationSummaryItemStatusEnum.archived,
            ),
            _summaryDto(id: 'c3', title: null, lastMessageAt: null),
          ],
        ),
      );

      final list = await expectTaskRight(repo.listRecentConversations());

      expect(list, hasLength(3));
      expect(list[0].id, 'c1');
      expect(list[0].title, 'First');
      expect(list[0].status, 'active');
      expect(list[1].id, 'c2');
      expect(list[1].status, 'archived');
      expect(list[2].id, 'c3');
      expect(list[2].title, isNull);
      expect(list[2].lastMessageAt, isNull);
    });

    test('returns empty list when data source returns empty', () async {
      final repo = LucentAssistantRepository(
        dataSource: _FakeAssistantRemoteDataSource(recentConversations: []),
      );
      expect(await expectTaskRight(repo.listRecentConversations()), isEmpty);
    });
  });

  group('LucentAssistantRepository.openConversation', () {
    test('passes conversationId to data source', () async {
      final fake = _FakeAssistantRemoteDataSource(
        openedConversation: _conversationDto(id: 'conv-open'),
      );
      final repo = LucentAssistantRepository(dataSource: fake);

      await expectTaskRight(repo.openConversation('conv-open'));

      expect(fake.lastOpenedConversationId, 'conv-open');
    });

    test('returns mapped conversation', () async {
      final repo = LucentAssistantRepository(
        dataSource: _FakeAssistantRemoteDataSource(
          openedConversation: _conversationDto(id: 'conv-x', title: 'Opened'),
        ),
      );

      final conv = await expectTaskRight(repo.openConversation('conv-x'));

      expect(conv.id, 'conv-x');
      expect(conv.title, 'Opened');
    });

    test('maps datasource failures to Left', () async {
      final repo = LucentAssistantRepository(
        dataSource: _FakeAssistantRemoteDataSource(),
      );
      final failure = await expectTaskLeft(
        repo.openConversation('conv-missing'),
      );
      expect(failure.kind, LucentFailureKind.unknown);
      expect(failure.message, 'not found');
    });
  });

  group('LucentAssistantRepository.clearLatestConversation', () {
    test('delegates to data source', () async {
      final repo = LucentAssistantRepository(
        dataSource: _FakeAssistantRemoteDataSource(clearResult: true),
      );
      expect(await expectTaskRight(repo.clearLatestConversation()), isTrue);
    });

    test('returns false when data source returns false', () async {
      final repo = LucentAssistantRepository(
        dataSource: _FakeAssistantRemoteDataSource(clearResult: false),
      );
      expect(await expectTaskRight(repo.clearLatestConversation()), isFalse);
    });
  });

  group('LucentAssistantRepository.streamMessages', () {
    test('emits chunk events with content', () async {
      final repo = LucentAssistantRepository(
        dataSource: _FakeAssistantRemoteDataSource(
          stream: Stream.fromIterable([
            const AssistantRemoteChunkEvent('Hello '),
            const AssistantRemoteChunkEvent('world!'),
          ]),
        ),
      );

      final events = await repo.streamMessages([
        AssistantMessage(
          role: AssistantMessageRole.user,
          content: 'hi',
          createdAt: dummyDateTime,
        ),
      ]).toList();

      expect(events, hasLength(2));
      expect(events[0], isA<AssistantGenerationChunkEvent>());
      expect((events[0] as AssistantGenerationChunkEvent).content, 'Hello ');
      expect(events[1], isA<AssistantGenerationChunkEvent>());
      expect((events[1] as AssistantGenerationChunkEvent).content, 'world!');
    });

    test('emits result event with assistant message', () async {
      final fixedTime = DateTime(2026, 7, 1, 10, 0, 0);
      final repo = LucentAssistantRepository(
        dataSource: _FakeAssistantRemoteDataSource(
          stream: Stream.fromIterable([
            AssistantRemoteResultEvent(
              conversationId: 'conv-stream',
              content: 'Done!',
              usedTools: const ['tool_a'],
              generatedAt: fixedTime,
              proposedActions: const [],
            ),
          ]),
        ),
      );

      final events = await repo.streamMessages([
        AssistantMessage(
          role: AssistantMessageRole.user,
          content: 'go',
          createdAt: dummyDateTime,
        ),
      ]).toList();

      expect(events, hasLength(1));
      final result = events[0] as AssistantGenerationResultEvent;
      expect(result.conversationId, 'conv-stream');
      expect(result.message.role, AssistantMessageRole.assistant);
      expect(result.message.content, 'Done!');
      expect(result.message.usedTools, ['tool_a']);
      expect(result.message.createdAt, fixedTime);
      expect(result.message.proposedActions, isEmpty);
      expect(result.message.toolDetails, isEmpty);
    });

    test('maps toolDetails into the assistant message', () async {
      final repo = LucentAssistantRepository(
        dataSource: _FakeAssistantRemoteDataSource(
          stream: Stream.fromIterable([
            AssistantRemoteResultEvent(
              conversationId: 'c1',
              content: 'done',
              usedTools: const ['search_medicine_leaflets'],
              generatedAt: DateTime(2026, 7, 1),
              proposedActions: const [],
              toolDetails: [
                {
                  'name': 'search_medicine_leaflets',
                  'label': '布洛芬缓释胶囊',
                  'coverage': {'status': 'complete', 'reason': null},
                  'confidence': {'level': 'high', 'reason': '向量检索命中'},
                  'ambiguities': ['候选A', '候选B'],
                  'source': {
                    'tool': 'search_medicine_leaflets',
                    'generatedAt': '2026-08-17T00:00:00.000Z',
                    'tables': ['cn_medicine_leaflets'],
                  },
                  'confidenceNote': '基于持久化摘要',
                  'sourceVersion': 7,
                  'disclaimer': '仅供参考',
                },
              ],
            ),
          ]),
        ),
      );

      final events = await repo.streamMessages([
        AssistantMessage(
          role: AssistantMessageRole.user,
          content: 'go',
          createdAt: dummyDateTime,
        ),
      ]).toList();

      final result = events[0] as AssistantGenerationResultEvent;
      final detail = result.message.toolDetails.single;

      expect(detail.name, 'search_medicine_leaflets');
      expect(detail.label, '布洛芬缓释胶囊');
      expect(detail.coverageStatus, 'complete');
      expect(detail.coverageReason, isNull);
      expect(detail.confidenceLevel, 'high');
      expect(detail.confidenceReason, '向量检索命中');
      expect(detail.ambiguities, ['候选A', '候选B']);
      expect(detail.sourceTool, 'search_medicine_leaflets');
      expect(detail.sourceGeneratedAt, '2026-08-17T00:00:00.000Z');
      expect(detail.sourceTables, ['cn_medicine_leaflets']);
      // F-14:confidenceNote/sourceVersion 可选透传映射。
      expect(detail.confidenceNote, '基于持久化摘要');
      expect(detail.sourceVersion, '7');
      expect(detail.disclaimer, '仅供参考');
    });

    test('maps missing optional toolDetail fields to null/empty', () async {
      final repo = LucentAssistantRepository(
        dataSource: _FakeAssistantRemoteDataSource(
          stream: Stream.fromIterable([
            AssistantRemoteResultEvent(
              conversationId: 'c1',
              content: 'done',
              usedTools: const ['get_user_profile'],
              generatedAt: DateTime(2026, 7, 1),
              proposedActions: const [],
              toolDetails: [
                {'name': 'get_user_profile'},
              ],
            ),
          ]),
        ),
      );

      final events = await repo.streamMessages([
        AssistantMessage(
          role: AssistantMessageRole.user,
          content: 'go',
          createdAt: dummyDateTime,
        ),
      ]).toList();

      final result = events[0] as AssistantGenerationResultEvent;
      final detail = result.message.toolDetails.single;

      expect(detail.name, 'get_user_profile');
      expect(detail.label, isNull);
      expect(detail.coverageStatus, isNull);
      expect(detail.confidenceLevel, isNull);
      expect(detail.ambiguities, isEmpty);
      expect(detail.sourceTool, isNull);
      expect(detail.sourceTables, isEmpty);
      expect(detail.disclaimer, isNull);
      // F-14:缺失时保持 null,来源条不渲染该行。
      expect(detail.confidenceNote, isNull);
      expect(detail.sourceVersion, isNull);
    });

    test('maps create_daily_record proposed action', () async {
      final repo = LucentAssistantRepository(
        dataSource: _FakeAssistantRemoteDataSource(
          stream: Stream.fromIterable([
            AssistantRemoteResultEvent(
              conversationId: 'c1',
              content: 'creating record',
              usedTools: const [],
              generatedAt: DateTime(2026, 7, 1),
              proposedActions: [
                {
                  'id': 'pa-1',
                  'type': 'create_daily_record',
                  'title': 'Record blood pressure',
                  'summary': 'Create a BP record',
                  'reason': 'User asked',
                  'previewFields': [
                    {'label': 'Value', 'value': '120/80'},
                  ],
                  'target': {'kind': 'daily_record', 'label': 'Blood Pressure'},
                  'constraints': ['requires_confirmation'],
                  'expiresAt': '2026-07-02T00:00:00Z',
                  'payloadVersion': 2,
                  'payload': {
                    'draft': {
                      'kind': 'blood_pressure',
                      'occurredAt': '2026-07-01T10:00:00Z',
                      'title': 'Morning BP',
                      'value': '120/80',
                      'unit': 'mmHg',
                      'note': 'after breakfast',
                    },
                  },
                  'confirmationRequired': true,
                  'status': 'proposed',
                },
              ],
            ),
          ]),
        ),
      );

      final events = await repo.streamMessages([
        AssistantMessage(
          role: AssistantMessageRole.user,
          content: 'record bp',
          createdAt: dummyDateTime,
        ),
      ]).toList();

      final result = events[0] as AssistantGenerationResultEvent;
      final action = result.message.proposedActions.single;

      expect(action.id, 'pa-1');
      expect(action.type, AssistantProposedActionType.createDailyRecord);
      expect(action.title, 'Record blood pressure');
      expect(action.summary, 'Create a BP record');
      expect(action.reason, 'User asked');
      expect(action.previewFields, hasLength(1));
      expect(action.previewFields.first.label, 'Value');
      expect(action.previewFields.first.value, '120/80');
      expect(action.target.kind, 'daily_record');
      expect(action.target.label, 'Blood Pressure');
      expect(action.constraints, ['requires_confirmation']);
      expect(action.expiresAt, DateTime.parse('2026-07-02T00:00:00Z'));
      expect(action.payloadVersion, 2);
      expect(action.confirmationRequired, isTrue);
      expect(action.backendStatus, 'proposed');

      final payload =
          action.payload as AssistantCreateDailyRecordProposalPayload;
      expect(payload.draft.kind, 'blood_pressure');
      expect(payload.draft.occurredAt, '2026-07-01T10:00:00Z');
      expect(payload.draft.title, 'Morning BP');
      expect(payload.draft.value, '120/80');
      expect(payload.draft.unit, 'mmHg');
      expect(payload.draft.note, 'after breakfast');
    });

    test('maps update_daily_record proposed action', () async {
      final repo = LucentAssistantRepository(
        dataSource: _FakeAssistantRemoteDataSource(
          stream: Stream.fromIterable([
            AssistantRemoteResultEvent(
              conversationId: 'c1',
              content: 'updating',
              usedTools: const [],
              generatedAt: DateTime(2026, 7, 1),
              proposedActions: [
                {
                  'id': 'pa-2',
                  'type': 'update_daily_record',
                  'title': 'Update weight',
                  'summary': 'Update today weight',
                  'target': {'kind': 'daily_record', 'recordId': 'rec-1'},
                  'payload': {
                    'recordId': 'rec-1',
                    'draft': {'value': '70', 'unit': 'kg'},
                  },
                },
              ],
            ),
          ]),
        ),
      );

      final events = await repo.streamMessages([
        AssistantMessage(
          role: AssistantMessageRole.user,
          content: 'update',
          createdAt: dummyDateTime,
        ),
      ]).toList();

      final result = events[0] as AssistantGenerationResultEvent;
      final action = result.message.proposedActions.single;

      expect(action.type, AssistantProposedActionType.updateDailyRecord);
      final payload =
          action.payload as AssistantUpdateDailyRecordProposalPayload;
      expect(payload.recordId, 'rec-1');
      expect(payload.draft['value'], '70');
      expect(payload.draft['unit'], 'kg');
      expect(action.target.recordId, 'rec-1');
    });

    test('maps delete_daily_record proposed action', () async {
      final repo = LucentAssistantRepository(
        dataSource: _FakeAssistantRemoteDataSource(
          stream: Stream.fromIterable([
            AssistantRemoteResultEvent(
              conversationId: 'c1',
              content: 'deleting',
              usedTools: const [],
              generatedAt: DateTime(2026, 7, 1),
              proposedActions: [
                {
                  'id': 'pa-3',
                  'type': 'delete_daily_record',
                  'title': 'Delete record',
                  'summary': 'Remove old record',
                  'target': {'kind': 'daily_record', 'recordId': 'rec-2'},
                  'payload': {'recordId': 'rec-2'},
                },
              ],
            ),
          ]),
        ),
      );

      final events = await repo.streamMessages([
        AssistantMessage(
          role: AssistantMessageRole.user,
          content: 'delete',
          createdAt: dummyDateTime,
        ),
      ]).toList();

      final result = events[0] as AssistantGenerationResultEvent;
      final action = result.message.proposedActions.single;

      expect(action.type, AssistantProposedActionType.deleteDailyRecord);
      final payload =
          action.payload as AssistantDeleteDailyRecordProposalPayload;
      expect(payload.recordId, 'rec-2');
    });

    test('maps update_user_settings proposed action', () async {
      final repo = LucentAssistantRepository(
        dataSource: _FakeAssistantRemoteDataSource(
          stream: Stream.fromIterable([
            AssistantRemoteResultEvent(
              conversationId: 'c1',
              content: 'updating settings',
              usedTools: const [],
              generatedAt: DateTime(2026, 7, 1),
              proposedActions: [
                {
                  'id': 'pa-4',
                  'type': 'update_user_settings',
                  'title': 'Enable memory',
                  'summary': 'Turn on assistant memory',
                  'target': {
                    'kind': 'user_settings',
                    'settingKeys': ['assistantMemoryEnabled'],
                  },
                  'payload': {
                    'draft': {
                      'assistantEnabled': true,
                      'assistantMemoryEnabled': true,
                      'assistantContext': {
                        'healthProfile': true,
                        'dailyRecords': true,
                        'sleepRecords': false,
                        'currentMedicines': true,
                      },
                    },
                  },
                },
              ],
            ),
          ]),
        ),
      );

      final events = await repo.streamMessages([
        AssistantMessage(
          role: AssistantMessageRole.user,
          content: 'settings',
          createdAt: dummyDateTime,
        ),
      ]).toList();

      final result = events[0] as AssistantGenerationResultEvent;
      final action = result.message.proposedActions.single;

      expect(action.type, AssistantProposedActionType.updateUserSettings);
      final payload =
          action.payload as AssistantUpdateUserSettingsProposalPayload;
      expect(payload.draft.assistantEnabled, isTrue);
      expect(payload.draft.assistantMemoryEnabled, isTrue);
      expect(payload.draft.assistantContext!.healthProfile, isTrue);
      expect(payload.draft.assistantContext!.dailyRecords, isTrue);
      expect(payload.draft.assistantContext!.sleepRecords, isFalse);
      expect(payload.draft.assistantContext!.currentMedicines, isTrue);
      expect(action.target.settingKeys, ['assistantMemoryEnabled']);
    });

    test('filters out actions with unknown type', () async {
      final repo = LucentAssistantRepository(
        dataSource: _FakeAssistantRemoteDataSource(
          stream: Stream.fromIterable([
            AssistantRemoteResultEvent(
              conversationId: 'c1',
              content: 'mixed',
              usedTools: const [],
              generatedAt: DateTime(2026, 7, 1),
              proposedActions: [
                {
                  'id': 'pa-good',
                  'type': 'delete_daily_record',
                  'title': 'Valid',
                  'summary': 'ok',
                  'target': {'kind': 'daily_record'},
                  'payload': {'recordId': 'r1'},
                },
                {
                  'id': 'pa-bad',
                  'type': 'unknown_type',
                  'title': 'Invalid',
                  'summary': 'bad',
                  'target': {'kind': 'unknown'},
                  'payload': {},
                },
              ],
            ),
          ]),
        ),
      );

      final events = await repo.streamMessages([
        AssistantMessage(
          role: AssistantMessageRole.user,
          content: 'mixed',
          createdAt: dummyDateTime,
        ),
      ]).toList();

      final result = events[0] as AssistantGenerationResultEvent;
      expect(result.message.proposedActions, hasLength(1));
      expect(result.message.proposedActions.single.id, 'pa-good');
    });

    test('filters out actions with null payload', () async {
      final repo = LucentAssistantRepository(
        dataSource: _FakeAssistantRemoteDataSource(
          stream: Stream.fromIterable([
            AssistantRemoteResultEvent(
              conversationId: 'c1',
              content: 'test',
              usedTools: const [],
              generatedAt: DateTime(2026, 7, 1),
              proposedActions: [
                {
                  'id': 'pa-1',
                  'type': 'delete_daily_record',
                  'title': 'No payload',
                  'summary': 'missing',
                  'target': {'kind': 'daily_record'},
                  'payload': null,
                },
              ],
            ),
          ]),
        ),
      );

      final events = await repo.streamMessages([
        AssistantMessage(
          role: AssistantMessageRole.user,
          content: 'test',
          createdAt: dummyDateTime,
        ),
      ]).toList();

      final result = events[0] as AssistantGenerationResultEvent;
      expect(result.message.proposedActions, isEmpty);
    });

    test('confirmationRequired defaults to true when absent', () async {
      final repo = LucentAssistantRepository(
        dataSource: _FakeAssistantRemoteDataSource(
          stream: Stream.fromIterable([
            AssistantRemoteResultEvent(
              conversationId: 'c1',
              content: 'test',
              usedTools: const [],
              generatedAt: DateTime(2026, 7, 1),
              proposedActions: [
                {
                  'id': 'pa-1',
                  'type': 'delete_daily_record',
                  'title': 'T',
                  'summary': 'S',
                  'target': {'kind': 'daily_record'},
                  'payload': {'recordId': 'r1'},
                },
              ],
            ),
          ]),
        ),
      );

      final events = await repo.streamMessages([
        AssistantMessage(
          role: AssistantMessageRole.user,
          content: 'x',
          createdAt: dummyDateTime,
        ),
      ]).toList();

      final result = events[0] as AssistantGenerationResultEvent;
      expect(
        result.message.proposedActions.single.confirmationRequired,
        isTrue,
      );
    });

    test(
      'confirmationRequired is false when explicitly set to false',
      () async {
        final repo = LucentAssistantRepository(
          dataSource: _FakeAssistantRemoteDataSource(
            stream: Stream.fromIterable([
              AssistantRemoteResultEvent(
                conversationId: 'c1',
                content: 'test',
                usedTools: const [],
                generatedAt: DateTime(2026, 7, 1),
                proposedActions: [
                  {
                    'id': 'pa-1',
                    'type': 'delete_daily_record',
                    'title': 'T',
                    'summary': 'S',
                    'target': {'kind': 'daily_record'},
                    'payload': {'recordId': 'r1'},
                    'confirmationRequired': false,
                  },
                ],
              ),
            ]),
          ),
        );

        final events = await repo.streamMessages([
          AssistantMessage(
            role: AssistantMessageRole.user,
            content: 'x',
            createdAt: dummyDateTime,
          ),
        ]).toList();

        final result = events[0] as AssistantGenerationResultEvent;
        expect(
          result.message.proposedActions.single.confirmationRequired,
          isFalse,
        );
      },
    );

    test('payloadVersion defaults to 1 when absent', () async {
      final repo = LucentAssistantRepository(
        dataSource: _FakeAssistantRemoteDataSource(
          stream: Stream.fromIterable([
            AssistantRemoteResultEvent(
              conversationId: 'c1',
              content: 'test',
              usedTools: const [],
              generatedAt: DateTime(2026, 7, 1),
              proposedActions: [
                {
                  'id': 'pa-1',
                  'type': 'delete_daily_record',
                  'title': 'T',
                  'summary': 'S',
                  'target': {'kind': 'daily_record'},
                  'payload': {'recordId': 'r1'},
                },
              ],
            ),
          ]),
        ),
      );

      final events = await repo.streamMessages([
        AssistantMessage(
          role: AssistantMessageRole.user,
          content: 'x',
          createdAt: dummyDateTime,
        ),
      ]).toList();

      final result = events[0] as AssistantGenerationResultEvent;
      expect(result.message.proposedActions.single.payloadVersion, 1);
    });

    test('emits both chunk and result events in order', () async {
      final repo = LucentAssistantRepository(
        dataSource: _FakeAssistantRemoteDataSource(
          stream: Stream.fromIterable([
            const AssistantRemoteChunkEvent('partial 1'),
            const AssistantRemoteChunkEvent('partial 2'),
            AssistantRemoteResultEvent(
              conversationId: 'c1',
              content: 'final',
              usedTools: const [],
              generatedAt: DateTime(2026, 7, 1),
              proposedActions: const [],
            ),
          ]),
        ),
      );

      final events = await repo.streamMessages([
        AssistantMessage(
          role: AssistantMessageRole.user,
          content: 'x',
          createdAt: dummyDateTime,
        ),
      ]).toList();

      expect(events, hasLength(3));
      expect(events[0], isA<AssistantGenerationChunkEvent>());
      expect(events[1], isA<AssistantGenerationChunkEvent>());
      expect(events[2], isA<AssistantGenerationResultEvent>());
    });

    test('passes conversationId through to data source', () async {
      final fake = _FakeAssistantRemoteDataSource(
        stream: Stream.fromIterable(const []),
      );
      final repo = LucentAssistantRepository(dataSource: fake);

      await repo.streamMessages([
        AssistantMessage(
          role: AssistantMessageRole.user,
          content: 'hi',
          createdAt: dummyDateTime,
        ),
      ], conversationId: 'conv-persisted').toList();

      expect(fake.lastStreamConversationId, 'conv-persisted');
    });
  });

  group('LucentAssistantRepository.regenerateLastMessage', () {
    test(
      'forwards conversation id and calls onChunk for chunk events',
      () async {
        final fake = _FakeAssistantRemoteDataSource(
          regenerateStream: Stream<AssistantRemoteEvent>.fromIterable([
            const AssistantRemoteChunkEvent('新的'),
            AssistantRemoteResultEvent(
              conversationId: 'conv-1',
              content: '新的回答',
              usedTools: const <String>[],
              generatedAt: DateTime(2026, 8, 17, 10),
              proposedActions: const <Map<String, dynamic>>[],
            ),
          ]),
        );
        final repo = LucentAssistantRepository(dataSource: fake);
        final chunks = <String>[];

        final events = await repo
            .regenerateLastMessage('conv-1', onChunk: chunks.add)
            .toList();

        expect(fake.lastRegenerateConversationId, 'conv-1');
        expect(chunks, <String>['新的']);
        expect(events, hasLength(2));
        expect(events[0], isA<AssistantGenerationChunkEvent>());
        expect(events[1], isA<AssistantGenerationResultEvent>());
        final message = (events[1] as AssistantGenerationResultEvent).message;
        expect(message.role, AssistantMessageRole.assistant);
        expect(message.content, '新的回答');
      },
    );
  });

  group('LucentAssistantRepository.confirmProposals', () {
    test('delegates approved decision to data source', () async {
      final fake = _FakeAssistantRemoteDataSource();
      final repo = LucentAssistantRepository(dataSource: fake);

      final content = await expectTaskRight(
        repo.confirmProposals(
          conversationId: 'conv-1',
          proposalIds: const ['pa-1'],
          decision: 'approved',
        ),
      );

      expect(fake.confirmProposalsCalls, hasLength(1));
      final call = fake.confirmProposalsCalls.single;
      expect(call.$1, 'conv-1');
      expect(call.$2, ['pa-1']);
      expect(call.$3, 'approved');
      expect(call.$4, isNull);
      expect(content, isNull);
    });

    test('passes note when rejecting', () async {
      final fake = _FakeAssistantRemoteDataSource();
      final repo = LucentAssistantRepository(dataSource: fake);

      await expectTaskRight(
        repo.confirmProposals(
          conversationId: 'conv-1',
          proposalIds: const ['pa-1'],
          decision: 'rejected',
          note: 'looks wrong',
        ),
      );

      final call = fake.confirmProposalsCalls.single;
      expect(call.$3, 'rejected');
      expect(call.$4, 'looks wrong');
    });
  });

  group('LucentAssistantRepository.renameConversation', () {
    test('delegates conversationId and trimmed title to data source', () async {
      final fake = _FakeAssistantRemoteDataSource();
      final repo = LucentAssistantRepository(dataSource: fake);

      await expectTaskRight(
        repo.renameConversation(conversationId: 'conv-1', title: '新标题'),
      );

      expect(fake.renameCalls.single.$1, 'conv-1');
      expect(fake.renameCalls.single.$2, '新标题');
    });
  });

  group('LucentAssistantRepository.deleteConversation', () {
    test('delegates conversationId to data source', () async {
      final fake = _FakeAssistantRemoteDataSource();
      final repo = LucentAssistantRepository(dataSource: fake);

      await expectTaskRight(repo.deleteConversation('conv-1'));

      expect(fake.deleteCalls, <String>['conv-1']);
    });

    test('maps datasource failures to Left', () async {
      final repo = LucentAssistantRepository(
        dataSource: _FakeAssistantRemoteDataSource(
          failureToThrow: const LucentFailure(
            kind: LucentFailureKind.business,
            message: 'delete failed',
          ),
        ),
      );
      final failure = await expectTaskLeft(repo.deleteConversation('conv-1'));
      expect(failure.message, 'delete failed');
    });
  });

  group('LucentAssistantRepository — failure boundary', () {
    test('network failure becomes Left(network)', () async {
      final repo = LucentAssistantRepository(
        dataSource: _FakeAssistantRemoteDataSource(
          failureToThrow: DioException(
            requestOptions: RequestOptions(
              path: '/api/v1/user/assistant/latest',
            ),
            type: DioExceptionType.connectionError,
          ),
        ),
      );
      final failure = await expectTaskLeft(repo.getLatestConversation());
      expect(failure.kind, LucentFailureKind.network);
      expect(failure.networkErrorCode, NetworkErrorCode.connectionError);
    });

    test('empty success body becomes Left(network/emptyResponse)', () async {
      final repo = LucentAssistantRepository(
        dataSource: _FakeAssistantRemoteDataSource(
          failureToThrow: LucentFailure.network(
            message: 'API 返回空响应体（getCapabilities）',
            networkErrorCode: NetworkErrorCode.emptyResponse,
          ),
        ),
      );
      final failure = await expectTaskLeft(repo.getCapabilities());
      expect(failure.kind, LucentFailureKind.network);
      expect(failure.networkErrorCode, NetworkErrorCode.emptyResponse);
    });

    test('Problem Details business failure keeps code/status', () async {
      final repo = LucentAssistantRepository(
        dataSource: _FakeAssistantRemoteDataSource(
          failureToThrow: LucentFailure.fromProblemDetails(
            const ProblemDetails(
              type: 'https://lucent.example/errors/assistant',
              title: 'Conversation not found',
              code: 'CONVERSATION_NOT_FOUND',
              detail: '该会话不存在',
            ),
            statusCode: 404,
          ),
        ),
      );
      final failure = await expectTaskLeft(repo.openConversation('missing'));
      expect(failure.kind, LucentFailureKind.business);
      expect(failure.code, 'CONVERSATION_NOT_FOUND');
      expect(failure.statusCode, 404);
      expect(failure.message, '该会话不存在');
    });

    test('rename failure keeps the original cause on Left', () async {
      final repo = LucentAssistantRepository(
        dataSource: _FakeAssistantRemoteDataSource(
          failureToThrow: const LucentFailure(
            kind: LucentFailureKind.business,
            message: 'rename failed',
          ),
        ),
      );
      final failure = await expectTaskLeft(
        repo.renameConversation(conversationId: 'conv-1', title: '新标题'),
      );
      expect(failure.message, 'rename failed');
    });
  });
}

// Used by AssistantMessage in tests
final dummyDateTime = DateTime(2026, 1, 1);
