import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_models.freezed.dart';
part 'chat_models.g.dart';

enum MessageRole { user, assistant }
enum MessageStatus { sending, streaming, done, error }

@freezed
class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    required String id,
    required MessageRole role,
    required String content,
    @Default(MessageStatus.done) MessageStatus status,
    @Default([]) List<SourceCitation> sources,
    required DateTime createdAt,
    int? tokensUsed,
    int? latencyMs,
  }) = _ChatMessage;

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);
}

@freezed
class SourceCitation with _$SourceCitation {
  const factory SourceCitation({
    required String chunkId,
    required String documentId,
    required String documentTitle,
    int? pageNumber,
    required double similarity,
    String? excerpt,
  }) = _SourceCitation;

  factory SourceCitation.fromJson(Map<String, dynamic> json) =>
      _$SourceCitationFromJson(json);
}
