import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'document_model.freezed.dart';
part 'document_model.g.dart';

enum DocumentStatus { pending, processing, ready, failed }

enum DocumentType { pdf, image, docx, txt, unknown }

@freezed
@HiveType(typeId: 1)
class DocumentModel with _$DocumentModel {
  const factory DocumentModel({
    @HiveField(0) required String id,
    @HiveField(1) required String title,
    @HiveField(2) required String fileName,
    @HiveField(3) required String mimeType,
    @HiveField(4) required int fileSizeBytes,
    @HiveField(5) required DocumentStatus status,
    @HiveField(6) String? summary,
    @HiveField(7) String? thumbnailUrl,
    @HiveField(8) @Default([]) List<String> tags,
    @HiveField(9) @Default(0) int pageCount,
    @HiveField(10) @Default(0) int queryCount,
    @HiveField(11) required DateTime createdAt,
    @HiveField(12) DateTime? processedAt,
    @HiveField(13) DateTime? cachedAt,
  }) = _DocumentModel;

  factory DocumentModel.fromJson(Map<String, dynamic> json) =>
      _$DocumentModelFromJson(json);
}

extension DocumentModelX on DocumentModel {
  String get displaySize {
    if (fileSizeBytes < 1024) return '${fileSizeBytes}B';
    if (fileSizeBytes < 1024 * 1024) {
      return '${(fileSizeBytes / 1024).toStringAsFixed(1)}KB';
    }
    return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  DocumentType get type {
    if (mimeType.contains('pdf')) return DocumentType.pdf;
    if (mimeType.contains('image')) return DocumentType.image;
    if (mimeType.contains('word') || fileName.endsWith('.docx')) {
      return DocumentType.docx;
    }
    if (mimeType.contains('text')) return DocumentType.txt;
    return DocumentType.unknown;
  }

  bool get isStale {
    if (cachedAt == null) return true;
    return DateTime.now().difference(cachedAt!) >
        const Duration(hours: 24);
  }
}
