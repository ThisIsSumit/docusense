import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../documents/data/datasources/search_remote_datasource.dart';
import '../../data/models/chat_models.dart';
import '../../../../core/utils/dio_client.dart';

part 'chat_provider.g.dart';

const _uuid = Uuid();

class ChatState {
  final List<ChatMessage> messages;
  final bool isStreaming;
  final String? error;
  final String? documentId;

  const ChatState({
    this.messages = const [], this.isStreaming = false,
    this.error, this.documentId,
  });

  ChatState copyWith({
    List<ChatMessage>? messages, bool? isStreaming,
    String? error, String? documentId, bool clearError = false,
  }) => ChatState(
    messages: messages ?? this.messages,
    isStreaming: isStreaming ?? this.isStreaming,
    error: clearError ? null : (error ?? this.error),
    documentId: documentId ?? this.documentId,
  );
}

@riverpod
class ChatNotifier extends _$ChatNotifier {
  @override
  ChatState build({String? documentId}) {
    return ChatState(
      documentId: documentId,
      messages: [
        ChatMessage(
          id: _uuid.v4(),
          role: MessageRole.assistant,
          content: documentId != null
              ? 'Ask me anything about this document. I\'ll search the indexed chunks and cite my sources.'
              : 'Ask me anything about your documents. I\'ll search across your entire library.',
          status: MessageStatus.done,
          createdAt: DateTime.now(),
        ),
      ],
    );
  }

  Future<void> sendMessage(String question) async {
    if (question.trim().isEmpty || state.isStreaming) return;
    final userMsg = ChatMessage(
      id: _uuid.v4(), role: MessageRole.user,
      content: question.trim(), status: MessageStatus.done,
      createdAt: DateTime.now(),
    );
    final assistantId = _uuid.v4();
    final placeholder = ChatMessage(
      id: assistantId, role: MessageRole.assistant,
      content: '', status: MessageStatus.streaming,
      createdAt: DateTime.now(),
    );
    state = state.copyWith(
      messages: [...state.messages, userMsg, placeholder],
      isStreaming: true, clearError: true,
    );
    await _stream(question.trim(), assistantId);
  }

  Future<void> _stream(String question, String msgId) async {
    final ds = ref.read(searchRemoteDatasourceProvider);
    final startMs = DateTime.now().millisecondsSinceEpoch;
    try {
      await for (final event in ds.queryStream(
          question: question, documentId: state.documentId)) {
        switch (event) {
          case SseSourcesEvent(:final sources):
            _replace(msgId, (m) => m.copyWith(sources: sources));
          case SseDeltaEvent(:final text):
            _append(msgId, text);
          case SseDoneEvent(:final totalTokens):
            final latency = DateTime.now().millisecondsSinceEpoch - startMs;
            _replace(msgId, (m) => m.copyWith(
              status: MessageStatus.done,
              tokensUsed: totalTokens, latencyMs: latency,
            ));
        }
      }
    } on ApiException catch (e) {
      final msg = e.code == 'OFFLINE' || e.code == 'NO_CONNECTION'
          ? 'Cannot reach server. Check your connection.'
          : e.code == 'STREAM_TIMEOUT'
              ? 'Response timed out. Please try again.'
              : 'Error: ${e.message}';
      _replace(msgId, (m) => m.copyWith(content: msg, status: MessageStatus.error));
      state = state.copyWith(isStreaming: false, error: e.message);
      return;
    } catch (e) {
      _replace(msgId, (m) => m.copyWith(
        content: 'Something went wrong. Please try again.',
        status: MessageStatus.error,
      ));
      state = state.copyWith(isStreaming: false);
      return;
    }
    state = state.copyWith(isStreaming: false);
  }

  void _replace(String id, ChatMessage Function(ChatMessage) fn) {
    state = state.copyWith(
      messages: state.messages.map((m) => m.id == id ? fn(m) : m).toList(),
    );
  }

  void _append(String id, String delta) {
    state = state.copyWith(
      messages: state.messages.map((m) {
        if (m.id != id) return m;
        return m.copyWith(content: m.content + delta);
      }).toList(),
    );
  }

  void retryLastMessage() {
    final msgs = state.messages;
    if (msgs.length < 2) return;
    final lastUser = msgs.lastWhere((m) => m.role == MessageRole.user,
        orElse: () => msgs.first);
    final idx = msgs.lastIndexOf(lastUser);
    state = state.copyWith(messages: msgs.sublist(0, idx),
        isStreaming: false, clearError: true);
    sendMessage(lastUser.content);
  }

  void clearMessages() => state = build(documentId: state.documentId);
}
