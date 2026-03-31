import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/chat_models.dart';
import '../../../../core/theme/app_theme.dart';

part 'chat_provider.g.dart';

// ── Chat state ────────────────────────────────────────────────────────────────

class ChatState {
  final List<ChatMessage> messages;
  final bool isStreaming;
  final String? error;
  final String? documentId;
  final String? documentTitle;

  const ChatState({
    this.messages = const [],
    this.isStreaming = false,
    this.error,
    this.documentId,
    this.documentTitle,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isStreaming,
    String? error,
    String? documentId,
    String? documentTitle,
    bool clearError = false,
  }) => ChatState(
    messages: messages ?? this.messages,
    isStreaming: isStreaming ?? this.isStreaming,
    error: clearError ? null : (error ?? this.error),
    documentId: documentId ?? this.documentId,
    documentTitle: documentTitle ?? this.documentTitle,
  );
}

// ── Provider ──────────────────────────────────────────────────────────────────

@riverpod
class ChatNotifier extends _$ChatNotifier {
  static const _uuid = Uuid();

  @override
  ChatState build({String? documentId}) {
    return ChatState(
      documentId: documentId,
      messages: documentId != null
          ? [
              ChatMessage(
                id: _uuid.v4(),
                role: MessageRole.assistant,
                content: 'Ask me anything about this document. '
                    'I\'ll search the indexed content and cite my sources.',
                status: MessageStatus.done,
                createdAt: DateTime.now(),
              ),
            ]
          : [
              ChatMessage(
                id: _uuid.v4(),
                role: MessageRole.assistant,
                content: 'Ask me anything about your documents. '
                    'I\'ll search across your entire library.',
                status: MessageStatus.done,
                createdAt: DateTime.now(),
              ),
            ],
    );
  }

  Future<void> sendMessage(String question) async {
    if (question.trim().isEmpty || state.isStreaming) return;

    // Add user message
    final userMsg = ChatMessage(
      id: _uuid.v4(),
      role: MessageRole.user,
      content: question.trim(),
      status: MessageStatus.done,
      createdAt: DateTime.now(),
    );

    // Add placeholder assistant message
    final assistantId = _uuid.v4();
    final assistantPlaceholder = ChatMessage(
      id: assistantId,
      role: MessageRole.assistant,
      content: '',
      status: MessageStatus.streaming,
      createdAt: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg, assistantPlaceholder],
      isStreaming: true,
      clearError: true,
    );

    try {
      await _streamAnswer(question, assistantId);
    } catch (e) {
      _replaceMessage(
        assistantId,
        (m) => m.copyWith(
          content: 'Sorry, something went wrong. Please try again.',
          status: MessageStatus.error,
        ),
      );
      state = state.copyWith(isStreaming: false, error: e.toString());
    }
  }

  Future<void> _streamAnswer(String question, String msgId) async {
    final tokens = ref.read(authStateNotifierProvider).valueOrNull?.tokens;

    // ── Real SSE implementation ───────────────────────────────────────────────
    // Uncomment and wire when backend is live:
    //
    // final request = http.Request('POST',
    //   Uri.parse('${AppConstants.baseUrl}/search/query'));
    // request.headers['Content-Type']  = 'application/json';
    // request.headers['Authorization'] = 'Bearer ${tokens?.accessToken}';
    // request.body = jsonEncode({
    //   'question': question,
    //   'documentId': state.documentId,
    //   'stream': true,
    // });
    // final streamedResponse = await request.send();
    // final stream = streamedResponse.stream
    //     .transform(utf8.decoder)
    //     .transform(const LineSplitter());
    //
    // await for (final line in stream) {
    //   if (!line.startsWith('data: ')) continue;
    //   final payload = jsonDecode(line.substring(6));
    //   switch (payload['type']) {
    //     case 'sources':
    //       _replaceMessage(msgId, (m) => m.copyWith(
    //         sources: (payload['sources'] as List)
    //             .map((s) => SourceCitation.fromJson(s)).toList(),
    //       ));
    //     case 'delta':
    //       _appendDelta(msgId, payload['text'] as String);
    //     case 'done':
    //       _replaceMessage(msgId, (m) => m.copyWith(
    //         status: MessageStatus.done,
    //         tokensUsed: payload['totalTokens'],
    //       ));
    //   }
    // }

    // ── Mock SSE simulation ───────────────────────────────────────────────────
    final mockSources = [
      SourceCitation(
        chunkId: 'chunk_001',
        documentId: state.documentId ?? 'doc_01',
        documentTitle: state.documentTitle ?? 'Q4 Financial Report',
        pageNumber: 4,
        similarity: 0.94,
        excerpt: 'Revenue grew 23% year-over-year, reaching \$4.2M in Q4...',
      ),
      SourceCitation(
        chunkId: 'chunk_002',
        documentId: state.documentId ?? 'doc_01',
        documentTitle: state.documentTitle ?? 'Q4 Financial Report',
        pageNumber: 7,
        similarity: 0.81,
        excerpt: 'EBITDA margin improved to 18% driven by operational efficiency...',
      ),
    ];

    // Emit sources
    await Future.delayed(const Duration(milliseconds: 400));
    _replaceMessage(msgId, (m) => m.copyWith(sources: mockSources));

    // Stream answer tokens
    final mockAnswer =
        'Based on [Source 1], revenue reached \$4.2M in Q4, representing 23% '
        'year-over-year growth. The report attributes this to strong enterprise '
        'segment performance and new customer acquisitions.\n\n'
        'According to [Source 2], EBITDA margin improved to 18%, up from 14% '
        'in Q3. Key drivers included a 12% reduction in infrastructure costs '
        'and improved sales team efficiency.';

    final words = mockAnswer.split(' ');
    for (int i = 0; i < words.length; i++) {
      await Future.delayed(const Duration(milliseconds: 28));
      _appendDelta(msgId, (i == 0 ? '' : ' ') + words[i]);
    }

    await Future.delayed(const Duration(milliseconds: 100));
    _replaceMessage(msgId, (m) => m.copyWith(
      status: MessageStatus.done,
      tokensUsed: 342,
      latencyMs: 1840,
    ));

    state = state.copyWith(isStreaming: false);
  }

  void _replaceMessage(String id, ChatMessage Function(ChatMessage) fn) {
    state = state.copyWith(
      messages: state.messages.map((m) => m.id == id ? fn(m) : m).toList(),
    );
  }

  void _appendDelta(String id, String delta) {
    state = state.copyWith(
      messages: state.messages.map((m) {
        if (m.id != id) return m;
        return m.copyWith(content: m.content + delta);
      }).toList(),
    );
  }

  void clearMessages() {
    state = build(documentId: state.documentId);
  }
}
