// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserModelImpl _$$UserModelImplFromJson(Map json) => $checkedCreate(
      r'_$UserModelImpl',
      json,
      ($checkedConvert) {
        final val = _$UserModelImpl(
          id: $checkedConvert('id', (v) => v as String),
          email: $checkedConvert('email', (v) => v as String),
          name: $checkedConvert('name', (v) => v as String),
          avatarUrl: $checkedConvert('avatar_url', (v) => v as String?),
          documentsCount: $checkedConvert(
              'documents_count', (v) => (v as num?)?.toInt() ?? 0),
          queriesCount: $checkedConvert(
              'queries_count', (v) => (v as num?)?.toInt() ?? 0),
          createdAt:
              $checkedConvert('created_at', (v) => DateTime.parse(v as String)),
          lastLoginAt: $checkedConvert('last_login_at',
              (v) => v == null ? null : DateTime.parse(v as String)),
        );
        return val;
      },
      fieldKeyMap: const {
        'avatarUrl': 'avatar_url',
        'documentsCount': 'documents_count',
        'queriesCount': 'queries_count',
        'createdAt': 'created_at',
        'lastLoginAt': 'last_login_at'
      },
    );

Map<String, dynamic> _$$UserModelImplToJson(_$UserModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'name': instance.name,
      'avatar_url': instance.avatarUrl,
      'documents_count': instance.documentsCount,
      'queries_count': instance.queriesCount,
      'created_at': instance.createdAt.toIso8601String(),
      'last_login_at': instance.lastLoginAt?.toIso8601String(),
    };

_$AuthTokensImpl _$$AuthTokensImplFromJson(Map json) => $checkedCreate(
      r'_$AuthTokensImpl',
      json,
      ($checkedConvert) {
        final val = _$AuthTokensImpl(
          accessToken: $checkedConvert('access_token', (v) => v as String),
          refreshToken: $checkedConvert('refresh_token', (v) => v as String),
          expiresAt:
              $checkedConvert('expires_at', (v) => DateTime.parse(v as String)),
        );
        return val;
      },
      fieldKeyMap: const {
        'accessToken': 'access_token',
        'refreshToken': 'refresh_token',
        'expiresAt': 'expires_at'
      },
    );

Map<String, dynamic> _$$AuthTokensImplToJson(_$AuthTokensImpl instance) =>
    <String, dynamic>{
      'access_token': instance.accessToken,
      'refresh_token': instance.refreshToken,
      'expires_at': instance.expiresAt.toIso8601String(),
    };

_$LoginRequestImpl _$$LoginRequestImplFromJson(Map json) => $checkedCreate(
      r'_$LoginRequestImpl',
      json,
      ($checkedConvert) {
        final val = _$LoginRequestImpl(
          email: $checkedConvert('email', (v) => v as String),
          password: $checkedConvert('password', (v) => v as String),
        );
        return val;
      },
    );

Map<String, dynamic> _$$LoginRequestImplToJson(_$LoginRequestImpl instance) =>
    <String, dynamic>{
      'email': instance.email,
      'password': instance.password,
    };

_$RegisterRequestImpl _$$RegisterRequestImplFromJson(Map json) =>
    $checkedCreate(
      r'_$RegisterRequestImpl',
      json,
      ($checkedConvert) {
        final val = _$RegisterRequestImpl(
          name: $checkedConvert('name', (v) => v as String),
          email: $checkedConvert('email', (v) => v as String),
          password: $checkedConvert('password', (v) => v as String),
        );
        return val;
      },
    );

Map<String, dynamic> _$$RegisterRequestImplToJson(
        _$RegisterRequestImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'email': instance.email,
      'password': instance.password,
    };

_$AuthResponseImpl _$$AuthResponseImplFromJson(Map json) => $checkedCreate(
      r'_$AuthResponseImpl',
      json,
      ($checkedConvert) {
        final val = _$AuthResponseImpl(
          user: $checkedConvert('user',
              (v) => UserModel.fromJson(Map<String, dynamic>.from(v as Map))),
          tokens: $checkedConvert('tokens',
              (v) => AuthTokens.fromJson(Map<String, dynamic>.from(v as Map))),
        );
        return val;
      },
    );

Map<String, dynamic> _$$AuthResponseImplToJson(_$AuthResponseImpl instance) =>
    <String, dynamic>{
      'user': instance.user.toJson(),
      'tokens': instance.tokens.toJson(),
    };
