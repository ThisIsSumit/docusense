// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'document_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DocumentModel _$DocumentModelFromJson(Map<String, dynamic> json) {
  return _DocumentModel.fromJson(json);
}

/// @nodoc
mixin _$DocumentModel {
  @HiveField(0)
  String get id => throw _privateConstructorUsedError;
  @HiveField(1)
  String get title => throw _privateConstructorUsedError;
  @HiveField(2)
  String get fileName => throw _privateConstructorUsedError;
  @HiveField(3)
  String get mimeType => throw _privateConstructorUsedError;
  @HiveField(4)
  int get fileSizeBytes => throw _privateConstructorUsedError;
  @HiveField(5)
  DocumentStatus get status => throw _privateConstructorUsedError;
  @HiveField(6)
  String? get summary => throw _privateConstructorUsedError;
  @HiveField(7)
  String? get thumbnailUrl => throw _privateConstructorUsedError;
  @HiveField(8)
  List<String> get tags => throw _privateConstructorUsedError;
  @HiveField(9)
  int get pageCount => throw _privateConstructorUsedError;
  @HiveField(10)
  int get queryCount => throw _privateConstructorUsedError;
  @HiveField(11)
  DateTime get createdAt => throw _privateConstructorUsedError;
  @HiveField(12)
  DateTime? get processedAt => throw _privateConstructorUsedError;
  @HiveField(13)
  DateTime? get cachedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DocumentModelCopyWith<DocumentModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DocumentModelCopyWith<$Res> {
  factory $DocumentModelCopyWith(
          DocumentModel value, $Res Function(DocumentModel) then) =
      _$DocumentModelCopyWithImpl<$Res, DocumentModel>;
  @useResult
  $Res call(
      {@HiveField(0) String id,
      @HiveField(1) String title,
      @HiveField(2) String fileName,
      @HiveField(3) String mimeType,
      @HiveField(4) int fileSizeBytes,
      @HiveField(5) DocumentStatus status,
      @HiveField(6) String? summary,
      @HiveField(7) String? thumbnailUrl,
      @HiveField(8) List<String> tags,
      @HiveField(9) int pageCount,
      @HiveField(10) int queryCount,
      @HiveField(11) DateTime createdAt,
      @HiveField(12) DateTime? processedAt,
      @HiveField(13) DateTime? cachedAt});
}

/// @nodoc
class _$DocumentModelCopyWithImpl<$Res, $Val extends DocumentModel>
    implements $DocumentModelCopyWith<$Res> {
  _$DocumentModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? fileName = null,
    Object? mimeType = null,
    Object? fileSizeBytes = null,
    Object? status = null,
    Object? summary = freezed,
    Object? thumbnailUrl = freezed,
    Object? tags = null,
    Object? pageCount = null,
    Object? queryCount = null,
    Object? createdAt = null,
    Object? processedAt = freezed,
    Object? cachedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      fileName: null == fileName
          ? _value.fileName
          : fileName // ignore: cast_nullable_to_non_nullable
              as String,
      mimeType: null == mimeType
          ? _value.mimeType
          : mimeType // ignore: cast_nullable_to_non_nullable
              as String,
      fileSizeBytes: null == fileSizeBytes
          ? _value.fileSizeBytes
          : fileSizeBytes // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as DocumentStatus,
      summary: freezed == summary
          ? _value.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as String?,
      thumbnailUrl: freezed == thumbnailUrl
          ? _value.thumbnailUrl
          : thumbnailUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      tags: null == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      pageCount: null == pageCount
          ? _value.pageCount
          : pageCount // ignore: cast_nullable_to_non_nullable
              as int,
      queryCount: null == queryCount
          ? _value.queryCount
          : queryCount // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      processedAt: freezed == processedAt
          ? _value.processedAt
          : processedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      cachedAt: freezed == cachedAt
          ? _value.cachedAt
          : cachedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DocumentModelImplCopyWith<$Res>
    implements $DocumentModelCopyWith<$Res> {
  factory _$$DocumentModelImplCopyWith(
          _$DocumentModelImpl value, $Res Function(_$DocumentModelImpl) then) =
      __$$DocumentModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@HiveField(0) String id,
      @HiveField(1) String title,
      @HiveField(2) String fileName,
      @HiveField(3) String mimeType,
      @HiveField(4) int fileSizeBytes,
      @HiveField(5) DocumentStatus status,
      @HiveField(6) String? summary,
      @HiveField(7) String? thumbnailUrl,
      @HiveField(8) List<String> tags,
      @HiveField(9) int pageCount,
      @HiveField(10) int queryCount,
      @HiveField(11) DateTime createdAt,
      @HiveField(12) DateTime? processedAt,
      @HiveField(13) DateTime? cachedAt});
}

/// @nodoc
class __$$DocumentModelImplCopyWithImpl<$Res>
    extends _$DocumentModelCopyWithImpl<$Res, _$DocumentModelImpl>
    implements _$$DocumentModelImplCopyWith<$Res> {
  __$$DocumentModelImplCopyWithImpl(
      _$DocumentModelImpl _value, $Res Function(_$DocumentModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? fileName = null,
    Object? mimeType = null,
    Object? fileSizeBytes = null,
    Object? status = null,
    Object? summary = freezed,
    Object? thumbnailUrl = freezed,
    Object? tags = null,
    Object? pageCount = null,
    Object? queryCount = null,
    Object? createdAt = null,
    Object? processedAt = freezed,
    Object? cachedAt = freezed,
  }) {
    return _then(_$DocumentModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      fileName: null == fileName
          ? _value.fileName
          : fileName // ignore: cast_nullable_to_non_nullable
              as String,
      mimeType: null == mimeType
          ? _value.mimeType
          : mimeType // ignore: cast_nullable_to_non_nullable
              as String,
      fileSizeBytes: null == fileSizeBytes
          ? _value.fileSizeBytes
          : fileSizeBytes // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as DocumentStatus,
      summary: freezed == summary
          ? _value.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as String?,
      thumbnailUrl: freezed == thumbnailUrl
          ? _value.thumbnailUrl
          : thumbnailUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      tags: null == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      pageCount: null == pageCount
          ? _value.pageCount
          : pageCount // ignore: cast_nullable_to_non_nullable
              as int,
      queryCount: null == queryCount
          ? _value.queryCount
          : queryCount // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      processedAt: freezed == processedAt
          ? _value.processedAt
          : processedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      cachedAt: freezed == cachedAt
          ? _value.cachedAt
          : cachedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DocumentModelImpl implements _DocumentModel {
  const _$DocumentModelImpl(
      {@HiveField(0) required this.id,
      @HiveField(1) required this.title,
      @HiveField(2) required this.fileName,
      @HiveField(3) required this.mimeType,
      @HiveField(4) required this.fileSizeBytes,
      @HiveField(5) required this.status,
      @HiveField(6) this.summary,
      @HiveField(7) this.thumbnailUrl,
      @HiveField(8) final List<String> tags = const [],
      @HiveField(9) this.pageCount = 0,
      @HiveField(10) this.queryCount = 0,
      @HiveField(11) required this.createdAt,
      @HiveField(12) this.processedAt,
      @HiveField(13) this.cachedAt})
      : _tags = tags;

  factory _$DocumentModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$DocumentModelImplFromJson(json);

  @override
  @HiveField(0)
  final String id;
  @override
  @HiveField(1)
  final String title;
  @override
  @HiveField(2)
  final String fileName;
  @override
  @HiveField(3)
  final String mimeType;
  @override
  @HiveField(4)
  final int fileSizeBytes;
  @override
  @HiveField(5)
  final DocumentStatus status;
  @override
  @HiveField(6)
  final String? summary;
  @override
  @HiveField(7)
  final String? thumbnailUrl;
  final List<String> _tags;
  @override
  @JsonKey()
  @HiveField(8)
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  @JsonKey()
  @HiveField(9)
  final int pageCount;
  @override
  @JsonKey()
  @HiveField(10)
  final int queryCount;
  @override
  @HiveField(11)
  final DateTime createdAt;
  @override
  @HiveField(12)
  final DateTime? processedAt;
  @override
  @HiveField(13)
  final DateTime? cachedAt;

  @override
  String toString() {
    return 'DocumentModel(id: $id, title: $title, fileName: $fileName, mimeType: $mimeType, fileSizeBytes: $fileSizeBytes, status: $status, summary: $summary, thumbnailUrl: $thumbnailUrl, tags: $tags, pageCount: $pageCount, queryCount: $queryCount, createdAt: $createdAt, processedAt: $processedAt, cachedAt: $cachedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DocumentModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.fileName, fileName) ||
                other.fileName == fileName) &&
            (identical(other.mimeType, mimeType) ||
                other.mimeType == mimeType) &&
            (identical(other.fileSizeBytes, fileSizeBytes) ||
                other.fileSizeBytes == fileSizeBytes) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.summary, summary) || other.summary == summary) &&
            (identical(other.thumbnailUrl, thumbnailUrl) ||
                other.thumbnailUrl == thumbnailUrl) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.pageCount, pageCount) ||
                other.pageCount == pageCount) &&
            (identical(other.queryCount, queryCount) ||
                other.queryCount == queryCount) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.processedAt, processedAt) ||
                other.processedAt == processedAt) &&
            (identical(other.cachedAt, cachedAt) ||
                other.cachedAt == cachedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      fileName,
      mimeType,
      fileSizeBytes,
      status,
      summary,
      thumbnailUrl,
      const DeepCollectionEquality().hash(_tags),
      pageCount,
      queryCount,
      createdAt,
      processedAt,
      cachedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DocumentModelImplCopyWith<_$DocumentModelImpl> get copyWith =>
      __$$DocumentModelImplCopyWithImpl<_$DocumentModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DocumentModelImplToJson(
      this,
    );
  }
}

abstract class _DocumentModel implements DocumentModel {
  const factory _DocumentModel(
      {@HiveField(0) required final String id,
      @HiveField(1) required final String title,
      @HiveField(2) required final String fileName,
      @HiveField(3) required final String mimeType,
      @HiveField(4) required final int fileSizeBytes,
      @HiveField(5) required final DocumentStatus status,
      @HiveField(6) final String? summary,
      @HiveField(7) final String? thumbnailUrl,
      @HiveField(8) final List<String> tags,
      @HiveField(9) final int pageCount,
      @HiveField(10) final int queryCount,
      @HiveField(11) required final DateTime createdAt,
      @HiveField(12) final DateTime? processedAt,
      @HiveField(13) final DateTime? cachedAt}) = _$DocumentModelImpl;

  factory _DocumentModel.fromJson(Map<String, dynamic> json) =
      _$DocumentModelImpl.fromJson;

  @override
  @HiveField(0)
  String get id;
  @override
  @HiveField(1)
  String get title;
  @override
  @HiveField(2)
  String get fileName;
  @override
  @HiveField(3)
  String get mimeType;
  @override
  @HiveField(4)
  int get fileSizeBytes;
  @override
  @HiveField(5)
  DocumentStatus get status;
  @override
  @HiveField(6)
  String? get summary;
  @override
  @HiveField(7)
  String? get thumbnailUrl;
  @override
  @HiveField(8)
  List<String> get tags;
  @override
  @HiveField(9)
  int get pageCount;
  @override
  @HiveField(10)
  int get queryCount;
  @override
  @HiveField(11)
  DateTime get createdAt;
  @override
  @HiveField(12)
  DateTime? get processedAt;
  @override
  @HiveField(13)
  DateTime? get cachedAt;
  @override
  @JsonKey(ignore: true)
  _$$DocumentModelImplCopyWith<_$DocumentModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
