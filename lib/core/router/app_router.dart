import 'package:docusense/features/chat/presentation/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:docusense/core/constants/app_constants.dart';
import 'package:docusense/features/auth/presentation/providers/auth_provider.dart';
import 'package:docusense/features/auth/presentation/screens/splash_screen.dart';
import 'package:docusense/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:docusense/features/auth/presentation/screens/login_screen.dart';
import 'package:docusense/features/auth/presentation/screens/register_screen.dart';
import 'package:docusense/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:docusense/features/home/presentation/screens/home_shell.dart';
import 'package:docusense/features/home/presentation/screens/home_screen.dart';
import 'package:docusense/features/documents/presentation/screens/documents_screen.dart';
import 'package:docusense/features/documents/presentation/screens/document_detail_screen.dart';
import 'package:docusense/features/search/presentation/screens/search_screen.dart';
import 'package:docusense/features/auth/presentation/screens/profile_screen.dart';
import 'package:docusense/features/documents/presentation/screens/document_upload_screen.dart'
    hide AppRoutes;

part 'app_router.g.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  final authState = ref.watch(authStateNotifierProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull?.isAuthenticated ?? false;
      final isOnboarded = authState.valueOrNull?.isOnboarded ?? false;
      final location = state.matchedLocation;

      // Splash always shows first
      if (location == AppRoutes.splash) return null;

      // If not onboarded, only allow onboarding or auth routes
      final authRoutes = [
        AppRoutes.login,
        AppRoutes.register,
        AppRoutes.forgotPassword,
      ];
      if (!isOnboarded && location != AppRoutes.onboarding) {
        // Allow login/register/forgotPassword during onboarding if needed
        if (authRoutes.contains(location)) {
          return null;
        }
        return AppRoutes.onboarding;
      }

      // If onboarded but not logged in, only allow auth routes
      if (isOnboarded && !isLoggedIn && !authRoutes.contains(location)) {
        return AppRoutes.login;
      }

      // If logged in, prevent access to auth routes
      if (isLoggedIn && authRoutes.contains(location)) {
        return AppRoutes.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const SplashScreen(),
          transitionDuration: Duration.zero,
          transitionsBuilder: (_, __, ___, child) => child,
        ),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        pageBuilder: (context, state) => _fadeSlide(
          state,
          const OnboardingScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.login,
        pageBuilder: (context, state) => _fadeSlide(state, const LoginScreen()),
      ),
      GoRoute(
        path: AppRoutes.register,
        pageBuilder: (context, state) =>
            _slideUp(state, const RegisterScreen()),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        pageBuilder: (context, state) =>
            _slideUp(state, const ForgotPasswordScreen()),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        pageBuilder: (context, state, child) => NoTransitionPage(
          child: HomeShell(child: child),
        ),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            pageBuilder: (context, state) =>
                NoTransitionPage(child: const HomeScreen()),
          ),
          GoRoute(
            path: AppRoutes.documents,
            pageBuilder: (context, state) =>
                NoTransitionPage(child: const DocumentsScreen()),
          ),
          GoRoute(
            path: AppRoutes.search,
            pageBuilder: (context, state) =>
                NoTransitionPage(child: const SearchScreen()),
          ),
          GoRoute(
            path: AppRoutes.profile,
            pageBuilder: (context, state) =>
                NoTransitionPage(child: const ProfileScreen()),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.documentDetail,
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return _slideUp(state, DocumentDetailScreen(documentId: id));
        },
      ),
      GoRoute(
        path: AppRoutes.upload,
        pageBuilder: (context, state) =>
            _slideUp(state, const DocumentUploadScreen()),
      ),
      GoRoute(
        path: AppRoutes.chat,
        pageBuilder: (context, state) => _slideUp(state, const ChatScreen()),
      ),
      GoRoute(
        path: AppRoutes.chatDocument,
        pageBuilder: (context, state) {
          final docId = state.pathParameters['docId']!;
          return _slideUp(state, ChatScreen(documentId: docId));
        },
      ),
    ],
  );
}

CustomTransitionPage<void> _fadeSlide(GoRouterState state, Widget child) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: AppConstants.pageTransitionDuration,
    reverseTransitionDuration: AppConstants.pageTransitionDuration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final tween = Tween(begin: 0.0, end: 1.0).chain(
        CurveTween(curve: Curves.easeOutCubic),
      );
      final offsetTween = Tween(
        begin: const Offset(0, 0.04),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeOutCubic));

      return FadeTransition(
        opacity: animation.drive(tween),
        child: SlideTransition(
          position: animation.drive(offsetTween),
          child: child,
        ),
      );
    },
  );
}

CustomTransitionPage<void> _slideUp(GoRouterState state, Widget child) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: AppConstants.pageTransitionDuration,
    reverseTransitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final tween = Tween(
        begin: const Offset(0, 1.0),
        end: Offset.zero,
      ).chain(CurveTween(curve: const Cubic(0.16, 1, 0.3, 1)));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}
