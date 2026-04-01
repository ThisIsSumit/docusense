import 'dart:convert';
import 'package:docusense/core/constants/app_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/auth_models.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/dio_client.dart';

part 'auth_provider.g.dart';

@riverpod
FlutterSecureStorage secureStorage(SecureStorageRef ref) {
  return const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );
}

@riverpod
Future<SharedPreferences> sharedPrefs(SharedPrefsRef ref) async {
  return await SharedPreferences.getInstance();
}

class AuthState {
  final bool isAuthenticated;
  final bool isOnboarded;
  final bool isLoading;
  final UserModel? user;
  final AuthTokens? tokens;
  final String? error;
  const AuthState({
    this.isAuthenticated = false,
    this.isOnboarded = false,
    this.isLoading = false,
    this.user,
    this.tokens,
    this.error,
  });
  AuthState copyWith({
    bool? isAuthenticated,
    bool? isOnboarded,
    bool? isLoading,
    UserModel? user,
    AuthTokens? tokens,
    String? error,
    bool clearError = false,
  }) =>
      AuthState(
        isAuthenticated: isAuthenticated ?? this.isAuthenticated,
        isOnboarded: isOnboarded ?? this.isOnboarded,
        isLoading: isLoading ?? this.isLoading,
        user: user ?? this.user,
        tokens: tokens ?? this.tokens,
        error: clearError ? null : (error ?? this.error),
      );
}

@riverpod
class AuthStateNotifier extends _$AuthStateNotifier {
  late FlutterSecureStorage _storage;

  @override
  Future<AuthState> build() async {
    _storage = ref.read(secureStorageProvider);
    return await _loadPersistedAuth();
  }

  Future<AuthState> _loadPersistedAuth() async {
    try {
      final prefs = await ref.read(sharedPrefsProvider.future);
      final isOnboarded = prefs.getBool(AppConstants.onboardedKey) ?? false;
      final at = await _storage.read(key: AppConstants.accessTokenKey);
      final rt = await _storage.read(key: AppConstants.refreshTokenKey);
      final userJson = await _storage.read(key: AppConstants.userKey);
      if (at == null || userJson == null)
        return AuthState(isOnboarded: isOnboarded);
      UserModel user;
      try {
        user = UserModel.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
      } catch (_) {
        return AuthState(isOnboarded: isOnboarded);
      }
      try {
        final fresh = await ref.read(authRemoteDatasourceProvider).getMe();
        await _storage.write(
            key: AppConstants.userKey, value: jsonEncode(fresh.toJson()));
        user = fresh;
      } catch (_) {}
      final tokens = AuthTokens(
        accessToken: at,
        refreshToken: rt ?? '',
        expiresAt: DateTime.now().add(const Duration(minutes: 14)),
      );
      return AuthState(
          isAuthenticated: true,
          isOnboarded: isOnboarded,
          user: user,
          tokens: tokens);
    } catch (_) {
      return const AuthState();
    }
  }

  Future<void> _persistTokens(AuthTokens t) async {
    await Future.wait([
      _storage.write(key: AppConstants.accessTokenKey, value: t.accessToken),
      _storage.write(key: AppConstants.refreshTokenKey, value: t.refreshToken),
    ]);
  }

  Future<void> _persistUser(UserModel u) async {
    await _storage.write(
        key: AppConstants.userKey, value: jsonEncode(u.toJson()));
  }

  Future<void> _clearStorage() async {
    await Future.wait([
      _storage.delete(key: AppConstants.accessTokenKey),
      _storage.delete(key: AppConstants.refreshTokenKey),
      _storage.delete(key: AppConstants.userKey),
    ]);
  }

  Future<void> markOnboarded() async {
    final prefs = await ref.read(sharedPrefsProvider.future);
    await prefs.setBool(AppConstants.onboardedKey, true);
    state = AsyncData(
        (state.valueOrNull ?? const AuthState()).copyWith(isOnboarded: true));
  }

  Future<bool> login({required String email, required String password}) async {
    final cur = state.valueOrNull ?? const AuthState();
    state = AsyncData(cur.copyWith(isLoading: true, clearError: true));
    try {
      final res = await ref
          .read(authRemoteDatasourceProvider)
          .login(email: email, password: password);
      await Future.wait([_persistTokens(res.tokens), _persistUser(res.user)]);
      state = AsyncData(cur.copyWith(
          isAuthenticated: true,
          isLoading: false,
          user: res.user,
          tokens: res.tokens,
          clearError: true));
      return true;
    } on ApiException catch (e) {
      state = AsyncData(cur.copyWith(
          isLoading: false,
          error: e.isUnauthorized ? 'Invalid email or password' : e.message));
      return false;
    } catch (_) {
      state = AsyncData(cur.copyWith(
          isLoading: false, error: 'Something went wrong. Try again.'));
      return false;
    }
  }

  Future<bool> register(
      {required String name,
      required String email,
      required String password}) async {
    final cur = state.valueOrNull ?? const AuthState();
    state = AsyncData(cur.copyWith(isLoading: true, clearError: true));
    try {
      final res = await ref
          .read(authRemoteDatasourceProvider)
          .register(name: name, email: email, password: password);
      await Future.wait([_persistTokens(res.tokens), _persistUser(res.user)]);
      state = AsyncData(cur.copyWith(
          isAuthenticated: true,
          isLoading: false,
          user: res.user,
          tokens: res.tokens,
          clearError: true));
      return true;
    } on ApiException catch (e) {
      state = AsyncData(cur.copyWith(
          isLoading: false,
          error: e.isConflict
              ? 'An account with this email already exists'
              : e.message));
      return false;
    } catch (_) {
      state = AsyncData(cur.copyWith(
          isLoading: false, error: 'Registration failed. Try again.'));
      return false;
    }
  }

  Future<void> logout() async {
    try {
      final rt = await _storage.read(key: AppConstants.refreshTokenKey);
      await ref.read(authRemoteDatasourceProvider).logout(refreshToken: rt);
    } catch (_) {}
    await _clearStorage();
    state = AsyncData(
        AuthState(isOnboarded: state.valueOrNull?.isOnboarded ?? false));
  }

  Future<bool> refreshTokens() async {
    try {
      final rt = await _storage.read(key: AppConstants.refreshTokenKey);
      if (rt == null) return false;
      final tokens = await ref.read(authRemoteDatasourceProvider).refresh(rt);
      final newT = AuthTokens(
        accessToken: tokens['accessToken']!,
        refreshToken: tokens['refreshToken']!,
        expiresAt: DateTime.now().add(const Duration(minutes: 14)),
      );
      await _persistTokens(newT);
      final cur = state.valueOrNull;
      if (cur != null) state = AsyncData(cur.copyWith(tokens: newT));
      return true;
    } catch (_) {
      await logout();
      return false;
    }
  }

  Future<void> refreshProfile() async {
    try {
      final u = await ref.read(authRemoteDatasourceProvider).getMe();
      await _persistUser(u);
      final cur = state.valueOrNull;
      if (cur != null) state = AsyncData(cur.copyWith(user: u));
    } catch (_) {}
  }

  void clearError() {
    final cur = state.valueOrNull;
    if (cur != null) state = AsyncData(cur.copyWith(clearError: true));
  }

  Future<String?> getCurrentAccessToken() async =>
      _storage.read(key: AppConstants.accessTokenKey);
}
