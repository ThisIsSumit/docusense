// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DocumentModelAdapter extends TypeAdapter<DocumentModel> {
  @override
  final int typeId = 1;

  @override
  DocumentModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DocumentModel(
      id: fields[0] as String,
      title: fields[1] as String,
      fileName: fields[2] as String,
      mimeType: fields[3] as String,
      fileSizeBytes: fields[4] as int,
      status: fields[5] as DocumentStatus,
      summary: fields[6] as String?,
      thumbnailUrl: fields[7] as String?,
      tags: (fields[8] as List).cast<String>(),
      pageCount: fields[9] as int,
      queryCount: fields[10] as int,
      createdAt: fields[11] as DateTime,
      processedAt: fields[12] as DateTime?,
      cachedAt: fields[13] as DateTime?,
      storageKey: fields[14] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, DocumentModel obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.fileName)
      ..writeByte(3)
      ..write(obj.mimeType)
      ..writeByte(4)
      ..write(obj.fileSizeBytes)
      ..writeByte(5)
      ..write(obj.status)
      ..writeByte(6)
      ..write(obj.summary)
      ..writeByte(7)
      ..write(obj.thumbnailUrl)
      ..writeByte(8)
      ..write(obj.tags)
      ..writeByte(9)
      ..write(obj.pageCount)
      ..writeByte(10)
      ..write(obj.queryCount)
      ..writeByte(11)
      ..write(obj.createdAt)
      ..writeByte(12)
      ..write(obj.processedAt)
      ..writeByte(13)
      ..write(obj.cachedAt)
      ..writeByte(14)
      ..write(obj.storageKey);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DocumentModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DocumentModelImpl _$$DocumentModelImplFromJson(Map json) => $checkedCreate(
      r'_$DocumentModelImpl',
      json,
      ($checkedConvert) {
        final val = _$DocumentModelImpl(
          id: $checkedConvert('id', (v) => v as String),
          title: $checkedConvert('title', (v) => v as String),
          fileName: $checkedConvert('file_name', (v) => v as String),
          mimeType: $checkedConvert('mime_type', (v) => v as String),
          fileSizeBytes:
              $checkedConvert('file_size_bytes', (v) => (v as num).toInt()),
          status: $checkedConvert(
              'status', (v) => $enumDecode(_$DocumentStatusEnumMap, v)),
          summary: $checkedConvert('summary', (v) => v as String?),
          thumbnailUrl: $checkedConvert('thumbnail_url', (v) => v as String?),
          tags: $checkedConvert(
              'tags',
              (v) =>
                  (v as List<dynamic>?)?.map((e) => e as String).toList() ??
                  const []),
          pageCount:
              $checkedConvert('page_count', (v) => (v as num?)?.toInt() ?? 0),
          queryCount:
              $checkedConvert('query_count', (v) => (v as num?)?.toInt() ?? 0),
          createdAt:
              $checkedConvert('created_at', (v) => DateTime.parse(v as String)),
          processedAt: $checkedConvert('processed_at',
              (v) => v == null ? null : DateTime.parse(v as String)),
          cachedAt: $checkedConvert('cached_at',
              (v) => v == null ? null : DateTime.parse(v as String)),
          storageKey: $checkedConvert('storage_key', (v) => v as String?),
        );
        return val;
      },
      fieldKeyMap: const {
        'fileName': 'file_name',
        'mimeType': 'mime_type',
        'fileSizeBytes': 'file_size_bytes',
        'thumbnailUrl': 'thumbnail_url',
        'pageCount': 'page_count',
        'queryCount': 'query_count',
        'createdAt': 'created_at',
        'processedAt': 'processed_at',
        'cachedAt': 'cached_at',
        'storageKey': 'storage_key'
      },
    );

Map<String, dynamic> _$$DocumentModelImplToJson(_$DocumentModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'file_name': instance.fileName,
      'mime_type': instance.mimeType,
      'file_size_bytes': instance.fileSizeBytes,
      'status': _$DocumentStatusEnumMap[instance.status]!,
      'summary': instance.summary,
      'thumbnail_url': instance.thumbnailUrl,
      'tags': instance.tags,
      'page_count': instance.pageCount,
      'query_count': instance.queryCount,
      'created_at': instance.createdAt.toIso8601String(),
      'processed_at': instance.processedAt?.toIso8601String(),
      'cached_at': instance.cachedAt?.toIso8601String(),
      'storage_key': instance.storageKey,
    };

const _$DocumentStatusEnumMap = {
  DocumentStatus.pending: 'pending',
  DocumentStatus.processing: 'processing',
  DocumentStatus.ready: 'ready',
  DocumentStatus.failed: 'failed',
};
