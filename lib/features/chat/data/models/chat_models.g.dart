// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChatMessageImpl _$$ChatMessageImplFromJson(Map json) => $checkedCreate(
      r'_$ChatMessageImpl',
      json,
      ($checkedConvert) {
        final val = _$ChatMessageImpl(
          id: $checkedConvert('id', (v) => v as String),
          role: $checkedConvert(
              'role', (v) => $enumDecode(_$MessageRoleEnumMap, v)),
          content: $checkedConvert('content', (v) => v as String),
          status: $checkedConvert(
              'status',
              (v) =>
                  $enumDecodeNullable(_$MessageStatusEnumMap, v) ??
                  MessageStatus.done),
          sources: $checkedConvert(
              'sources',
              (v) =>
                  (v as List<dynamic>?)
                      ?.map((e) => SourceCitation.fromJson(
                          Map<String, dynamic>.from(e as Map)))
                      .toList() ??
                  const []),
          createdAt:
              $checkedConvert('created_at', (v) => DateTime.parse(v as String)),
          tokensUsed:
              $checkedConvert('tokens_used', (v) => (v as num?)?.toInt()),
          latencyMs: $checkedConvert('latency_ms', (v) => (v as num?)?.toInt()),
        );
        return val;
      },
      fieldKeyMap: const {
        'createdAt': 'created_at',
        'tokensUsed': 'tokens_used',
        'latencyMs': 'latency_ms'
      },
    );

Map<String, dynamic> _$$ChatMessageImplToJson(_$ChatMessageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'role': _$MessageRoleEnumMap[instance.role]!,
      'content': instance.content,
      'status': _$MessageStatusEnumMap[instance.status]!,
      'sources': instance.sources.map((e) => e.toJson()).toList(),
      'created_at': instance.createdAt.toIso8601String(),
      'tokens_used': instance.tokensUsed,
      'latency_ms': instance.latencyMs,
    };

const _$MessageRoleEnumMap = {
  MessageRole.user: 'user',
  MessageRole.assistant: 'assistant',
};

const _$MessageStatusEnumMap = {
  MessageStatus.sending: 'sending',
  MessageStatus.streaming: 'streaming',
  MessageStatus.done: 'done',
  MessageStatus.error: 'error',
};

_$SourceCitationImpl _$$SourceCitationImplFromJson(Map json) => $checkedCreate(
      r'_$SourceCitationImpl',
      json,
      ($checkedConvert) {
        final val = _$SourceCitationImpl(
          chunkId: $checkedConvert('chunk_id', (v) => v as String),
          documentId: $checkedConvert('document_id', (v) => v as String),
          documentTitle: $checkedConvert('document_title', (v) => v as String),
          pageNumber:
              $checkedConvert('page_number', (v) => (v as num?)?.toInt()),
          similarity:
              $checkedConvert('similarity', (v) => (v as num).toDouble()),
          excerpt: $checkedConvert('excerpt', (v) => v as String?),
        );
        return val;
      },
      fieldKeyMap: const {
        'chunkId': 'chunk_id',
        'documentId': 'document_id',
        'documentTitle': 'document_title',
        'pageNumber': 'page_number'
      },
    );

Map<String, dynamic> _$$SourceCitationImplToJson(
        _$SourceCitationImpl instance) =>
    <String, dynamic>{
      'chunk_id': instance.chunkId,
      'document_id': instance.documentId,
      'document_title': instance.documentTitle,
      'page_number': instance.pageNumber,
      'similarity': instance.similarity,
      'excerpt': instance.excerpt,
    };
