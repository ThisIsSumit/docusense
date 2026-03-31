import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/auth_models.dart';
import '../../../../core/constants/app_constants.dart';

part 'auth_provider.g.dart';

// ── Secure Storage ───────────────────────────────────────────────────────────

@riverpod
FlutterSecureStorage secureStorage(SecureStorageRef ref) {
  return const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );
}

// ── Shared Preferences ───────────────────────────────────────────────────────

@riverpod
Future<SharedPreferences> sharedPrefs(SharedPrefsRef ref) async {
  return await SharedPreferences.getInstance();
}

// ── Auth State ───────────────────────────────────────────────────────────────

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
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isOnboarded: isOnboarded ?? this.isOnboarded,
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      tokens: tokens ?? this.tokens,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

@riverpod
class AuthStateNotifier extends _$AuthStateNotifier {
  late FlutterSecureStorage _storage;

  @override
  Future<AuthState> build() async {
    _storage = ref.read(secureStorageProvider);
    return await _loadPersistedAuth();
  }

  // ── Persistence ─────────────────────────────────────────────────────────

  Future<AuthState> _loadPersistedAuth() async {
    try {
      final prefs = await ref.read(sharedPrefsProvider.future);
      final isOnboarded = prefs.getBool(AppConstants.onboardedKey) ?? false;

      final accessToken = await _storage.read(key: AppConstants.accessTokenKey);
      final refreshToken =
          await _storage.read(key: AppConstants.refreshTokenKey);
      final userJson = await _storage.read(key: AppConstants.userKey);

      if (accessToken == null || userJson == null) {
        return AuthState(isOnboarded: isOnboarded);
      }

      final user = UserModel.fromJson(jsonDecode(userJson));
      final tokens = AuthTokens(
        accessToken: accessToken,
        refreshToken: refreshToken ?? '',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      return AuthState(
        isAuthenticated: true,
        isOnboarded: isOnboarded,
        user: user,
        tokens: tokens,
      );
    } catch (_) {
      return const AuthState();
    }
  }

  Future<void> _persistAuth(UserModel user, AuthTokens tokens) async {
    await Future.wait([
      _storage.write(
          key: AppConstants.accessTokenKey, value: tokens.accessToken),
      _storage.write(
          key: AppConstants.refreshTokenKey, value: tokens.refreshToken),
      _storage.write(
          key: AppConstants.userKey, value: jsonEncode(user.toJson())),
    ]);
  }

  Future<void> _clearAuth() async {
    await Future.wait([
      _storage.delete(key: AppConstants.accessTokenKey),
      _storage.delete(key: AppConstants.refreshTokenKey),
      _storage.delete(key: AppConstants.userKey),
    ]);
  }

  // ── Actions ──────────────────────────────────────────────────────────────

  Future<void> markOnboarded() async {
    final prefs = await ref.read(sharedPrefsProvider.future);
    await prefs.setBool(AppConstants.onboardedKey, true);
    state = AsyncData(
      (state.valueOrNull ?? const AuthState()).copyWith(isOnboarded: true),
    );
  }

  Future<bool> login({required String email, required String password}) async {
    final current = state.valueOrNull ?? const AuthState();
    state = AsyncData(current.copyWith(isLoading: true, clearError: true));

    try {
      // Simulate API call — replace with actual Dio call
      await Future.delayed(const Duration(milliseconds: 1200));

      // Mock success
      final user = UserModel(
        id: 'usr_01',
        email: email,
        name: email.split('@').first,
        documentsCount: 12,
        queriesCount: 48,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );
      final tokens = AuthTokens(
        accessToken: 'mock_access_token',
        refreshToken: 'mock_refresh_token',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      await _persistAuth(user, tokens);

      state = AsyncData(current.copyWith(
        isAuthenticated: true,
        isLoading: false,
        user: user,
        tokens: tokens,
        clearError: true,
      ));
      return true;
    } catch (e) {
      state = AsyncData(current.copyWith(
        isLoading: false,
        error: 'Invalid email or password',
      ));
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final current = state.valueOrNull ?? const AuthState();
    state = AsyncData(current.copyWith(isLoading: true, clearError: true));

    try {
      await Future.delayed(const Duration(milliseconds: 1400));

      final user = UserModel(
        id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        name: name,
        createdAt: DateTime.now(),
      );
      final tokens = AuthTokens(
        accessToken: 'mock_access_token',
        refreshToken: 'mock_refresh_token',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      await _persistAuth(user, tokens);

      state = AsyncData(current.copyWith(
        isAuthenticated: true,
        isLoading: false,
        user: user,
        tokens: tokens,
      ));
      return true;
    } catch (e) {
      state = AsyncData(current.copyWith(
        isLoading: false,
        error: 'Registration failed. Please try again.',
      ));
      return false;
    }
  }

  Future<void> logout() async {
    await _clearAuth();
    state = AsyncData(
      AuthState(isOnboarded: state.valueOrNull?.isOnboarded ?? false),
    );
  }

  Future<bool> refreshTokens() async {
    final current = state.valueOrNull;
    if (current?.tokens?.refreshToken == null) return false;

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      final newTokens = AuthTokens(
        accessToken: 'new_access_token',
        refreshToken: current!.tokens!.refreshToken,
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );
      if (current.user != null) {
        await _persistAuth(current.user!, newTokens);
      }
      state = AsyncData(current.copyWith(tokens: newTokens));
      return true;
    } catch (_) {
      await logout();
      return false;
    }
  }

  void clearError() {
    final current = state.valueOrNull;
    if (current != null) {
      state = AsyncData(current.copyWith(clearError: true));
    }
  }
}
