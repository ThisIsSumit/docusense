// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ChatMessage _$ChatMessageFromJson(Map<String, dynamic> json) {
  return _ChatMessage.fromJson(json);
}

/// @nodoc
mixin _$ChatMessage {
  String get id => throw _privateConstructorUsedError;
  MessageRole get role => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  MessageStatus get status => throw _privateConstructorUsedError;
  List<SourceCitation> get sources => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  int? get tokensUsed => throw _privateConstructorUsedError;
  int? get latencyMs => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ChatMessageCopyWith<ChatMessage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatMessageCopyWith<$Res> {
  factory $ChatMessageCopyWith(
          ChatMessage value, $Res Function(ChatMessage) then) =
      _$ChatMessageCopyWithImpl<$Res, ChatMessage>;
  @useResult
  $Res call(
      {String id,
      MessageRole role,
      String content,
      MessageStatus status,
      List<SourceCitation> sources,
      DateTime createdAt,
      int? tokensUsed,
      int? latencyMs});
}

/// @nodoc
class _$ChatMessageCopyWithImpl<$Res, $Val extends ChatMessage>
    implements $ChatMessageCopyWith<$Res> {
  _$ChatMessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? role = null,
    Object? content = null,
    Object? status = null,
    Object? sources = null,
    Object? createdAt = null,
    Object? tokensUsed = freezed,
    Object? latencyMs = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as MessageRole,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as MessageStatus,
      sources: null == sources
          ? _value.sources
          : sources // ignore: cast_nullable_to_non_nullable
              as List<SourceCitation>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      tokensUsed: freezed == tokensUsed
          ? _value.tokensUsed
          : tokensUsed // ignore: cast_nullable_to_non_nullable
              as int?,
      latencyMs: freezed == latencyMs
          ? _value.latencyMs
          : latencyMs // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ChatMessageImplCopyWith<$Res>
    implements $ChatMessageCopyWith<$Res> {
  factory _$$ChatMessageImplCopyWith(
          _$ChatMessageImpl value, $Res Function(_$ChatMessageImpl) then) =
      __$$ChatMessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      MessageRole role,
      String content,
      MessageStatus status,
      List<SourceCitation> sources,
      DateTime createdAt,
      int? tokensUsed,
      int? latencyMs});
}

/// @nodoc
class __$$ChatMessageImplCopyWithImpl<$Res>
    extends _$ChatMessageCopyWithImpl<$Res, _$ChatMessageImpl>
    implements _$$ChatMessageImplCopyWith<$Res> {
  __$$ChatMessageImplCopyWithImpl(
      _$ChatMessageImpl _value, $Res Function(_$ChatMessageImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? role = null,
    Object? content = null,
    Object? status = null,
    Object? sources = null,
    Object? createdAt = null,
    Object? tokensUsed = freezed,
    Object? latencyMs = freezed,
  }) {
    return _then(_$ChatMessageImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as MessageRole,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as MessageStatus,
      sources: null == sources
          ? _value._sources
          : sources // ignore: cast_nullable_to_non_nullable
              as List<SourceCitation>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      tokensUsed: freezed == tokensUsed
          ? _value.tokensUsed
          : tokensUsed // ignore: cast_nullable_to_non_nullable
              as int?,
      latencyMs: freezed == latencyMs
          ? _value.latencyMs
          : latencyMs // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ChatMessageImpl implements _ChatMessage {
  const _$ChatMessageImpl(
      {required this.id,
      required this.role,
      required this.content,
      this.status = MessageStatus.done,
      final List<SourceCitation> sources = const [],
      required this.createdAt,
      this.tokensUsed,
      this.latencyMs})
      : _sources = sources;

  factory _$ChatMessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChatMessageImplFromJson(json);

  @override
  final String id;
  @override
  final MessageRole role;
  @override
  final String content;
  @override
  @JsonKey()
  final MessageStatus status;
  final List<SourceCitation> _sources;
  @override
  @JsonKey()
  List<SourceCitation> get sources {
    if (_sources is EqualUnmodifiableListView) return _sources;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_sources);
  }

  @override
  final DateTime createdAt;
  @override
  final int? tokensUsed;
  @override
  final int? latencyMs;

  @override
  String toString() {
    return 'ChatMessage(id: $id, role: $role, content: $content, status: $status, sources: $sources, createdAt: $createdAt, tokensUsed: $tokensUsed, latencyMs: $latencyMs)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatMessageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality().equals(other._sources, _sources) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.tokensUsed, tokensUsed) ||
                other.tokensUsed == tokensUsed) &&
            (identical(other.latencyMs, latencyMs) ||
                other.latencyMs == latencyMs));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      role,
      content,
      status,
      const DeepCollectionEquality().hash(_sources),
      createdAt,
      tokensUsed,
      latencyMs);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatMessageImplCopyWith<_$ChatMessageImpl> get copyWith =>
      __$$ChatMessageImplCopyWithImpl<_$ChatMessageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChatMessageImplToJson(
      this,
    );
  }
}

abstract class _ChatMessage implements ChatMessage {
  const factory _ChatMessage(
      {required final String id,
      required final MessageRole role,
      required final String content,
      final MessageStatus status,
      final List<SourceCitation> sources,
      required final DateTime createdAt,
      final int? tokensUsed,
      final int? latencyMs}) = _$ChatMessageImpl;

  factory _ChatMessage.fromJson(Map<String, dynamic> json) =
      _$ChatMessageImpl.fromJson;

  @override
  String get id;
  @override
  MessageRole get role;
  @override
  String get content;
  @override
  MessageStatus get status;
  @override
  List<SourceCitation> get sources;
  @override
  DateTime get createdAt;
  @override
  int? get tokensUsed;
  @override
  int? get latencyMs;
  @override
  @JsonKey(ignore: true)
  _$$ChatMessageImplCopyWith<_$ChatMessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SourceCitation _$SourceCitationFromJson(Map<String, dynamic> json) {
  return _SourceCitation.fromJson(json);
}

/// @nodoc
mixin _$SourceCitation {
  String get chunkId => throw _privateConstructorUsedError;
  String get documentId => throw _privateConstructorUsedError;
  String get documentTitle => throw _privateConstructorUsedError;
  int? get pageNumber => throw _privateConstructorUsedError;
  double get similarity => throw _privateConstructorUsedError;
  String? get excerpt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SourceCitationCopyWith<SourceCitation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SourceCitationCopyWith<$Res> {
  factory $SourceCitationCopyWith(
          SourceCitation value, $Res Function(SourceCitation) then) =
      _$SourceCitationCopyWithImpl<$Res, SourceCitation>;
  @useResult
  $Res call(
      {String chunkId,
      String documentId,
      String documentTitle,
      int? pageNumber,
      double similarity,
      String? excerpt});
}

/// @nodoc
class _$SourceCitationCopyWithImpl<$Res, $Val extends SourceCitation>
    implements $SourceCitationCopyWith<$Res> {
  _$SourceCitationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? chunkId = null,
    Object? documentId = null,
    Object? documentTitle = null,
    Object? pageNumber = freezed,
    Object? similarity = null,
    Object? excerpt = freezed,
  }) {
    return _then(_value.copyWith(
      chunkId: null == chunkId
          ? _value.chunkId
          : chunkId // ignore: cast_nullable_to_non_nullable
              as String,
      documentId: null == documentId
          ? _value.documentId
          : documentId // ignore: cast_nullable_to_non_nullable
              as String,
      documentTitle: null == documentTitle
          ? _value.documentTitle
          : documentTitle // ignore: cast_nullable_to_non_nullable
              as String,
      pageNumber: freezed == pageNumber
          ? _value.pageNumber
          : pageNumber // ignore: cast_nullable_to_non_nullable
              as int?,
      similarity: null == similarity
          ? _value.similarity
          : similarity // ignore: cast_nullable_to_non_nullable
              as double,
      excerpt: freezed == excerpt
          ? _value.excerpt
          : excerpt // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SourceCitationImplCopyWith<$Res>
    implements $SourceCitationCopyWith<$Res> {
  factory _$$SourceCitationImplCopyWith(_$SourceCitationImpl value,
          $Res Function(_$SourceCitationImpl) then) =
      __$$SourceCitationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String chunkId,
      String documentId,
      String documentTitle,
      int? pageNumber,
      double similarity,
      String? excerpt});
}

/// @nodoc
class __$$SourceCitationImplCopyWithImpl<$Res>
    extends _$SourceCitationCopyWithImpl<$Res, _$SourceCitationImpl>
    implements _$$SourceCitationImplCopyWith<$Res> {
  __$$SourceCitationImplCopyWithImpl(
      _$SourceCitationImpl _value, $Res Function(_$SourceCitationImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? chunkId = null,
    Object? documentId = null,
    Object? documentTitle = null,
    Object? pageNumber = freezed,
    Object? similarity = null,
    Object? excerpt = freezed,
  }) {
    return _then(_$SourceCitationImpl(
      chunkId: null == chunkId
          ? _value.chunkId
          : chunkId // ignore: cast_nullable_to_non_nullable
              as String,
      documentId: null == documentId
          ? _value.documentId
          : documentId // ignore: cast_nullable_to_non_nullable
              as String,
      documentTitle: null == documentTitle
          ? _value.documentTitle
          : documentTitle // ignore: cast_nullable_to_non_nullable
              as String,
      pageNumber: freezed == pageNumber
          ? _value.pageNumber
          : pageNumber // ignore: cast_nullable_to_non_nullable
              as int?,
      similarity: null == similarity
          ? _value.similarity
          : similarity // ignore: cast_nullable_to_non_nullable
              as double,
      excerpt: freezed == excerpt
          ? _value.excerpt
          : excerpt // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SourceCitationImpl implements _SourceCitation {
  const _$SourceCitationImpl(
      {required this.chunkId,
      required this.documentId,
      required this.documentTitle,
      this.pageNumber,
      required this.similarity,
      this.excerpt});

  factory _$SourceCitationImpl.fromJson(Map<String, dynamic> json) =>
      _$$SourceCitationImplFromJson(json);

  @override
  final String chunkId;
  @override
  final String documentId;
  @override
  final String documentTitle;
  @override
  final int? pageNumber;
  @override
  final double similarity;
  @override
  final String? excerpt;

  @override
  String toString() {
    return 'SourceCitation(chunkId: $chunkId, documentId: $documentId, documentTitle: $documentTitle, pageNumber: $pageNumber, similarity: $similarity, excerpt: $excerpt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SourceCitationImpl &&
            (identical(other.chunkId, chunkId) || other.chunkId == chunkId) &&
            (identical(other.documentId, documentId) ||
                other.documentId == documentId) &&
            (identical(other.documentTitle, documentTitle) ||
                other.documentTitle == documentTitle) &&
            (identical(other.pageNumber, pageNumber) ||
                other.pageNumber == pageNumber) &&
            (identical(other.similarity, similarity) ||
                other.similarity == similarity) &&
            (identical(other.excerpt, excerpt) || other.excerpt == excerpt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, chunkId, documentId,
      documentTitle, pageNumber, similarity, excerpt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SourceCitationImplCopyWith<_$SourceCitationImpl> get copyWith =>
      __$$SourceCitationImplCopyWithImpl<_$SourceCitationImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SourceCitationImplToJson(
      this,
    );
  }
}

abstract class _SourceCitation implements SourceCitation {
  const factory _SourceCitation(
      {required final String chunkId,
      required final String documentId,
      required final String documentTitle,
      final int? pageNumber,
      required final double similarity,
      final String? excerpt}) = _$SourceCitationImpl;

  factory _SourceCitation.fromJson(Map<String, dynamic> json) =
      _$SourceCitationImpl.fromJson;

  @override
  String get chunkId;
  @override
  String get documentId;
  @override
  String get documentTitle;
  @override
  int? get pageNumber;
  @override
  double get similarity;
  @override
  String? get excerpt;
  @override
  @JsonKey(ignore: true)
  _$$SourceCitationImplCopyWith<_$SourceCitationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
