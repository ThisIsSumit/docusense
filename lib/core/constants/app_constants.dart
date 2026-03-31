abstract class AppConstants {
  // API
  static const baseUrl = 'https://api.docusense.app/v1';
  static const connectTimeout = Duration(seconds: 30);
  static const receiveTimeout = Duration(seconds: 60);

  // Auth
  static const accessTokenKey = 'access_token';
  static const refreshTokenKey = 'refresh_token';
  static const userKey = 'user_data';
  static const onboardedKey = 'onboarded';

  // Cache
  static const documentCacheBox = 'documents';
  static const userCacheBox = 'user';
  static const searchCacheBox = 'search';
  static const prefetchCacheBox = 'prefetch';
  static const maxCacheSize = 200; // items
  static const cacheTtlHours = 24;

  // Pagination
  static const pageSize = 20;
  static const prefetchThreshold = 5; // items from end

  // Animation
  static const splashDuration = Duration(milliseconds: 2800);
  static const pageTransitionDuration = Duration(milliseconds: 350);
  static const microDuration = Duration(milliseconds: 200);
  static const standardDuration = Duration(milliseconds: 400);

  // Storage
  static const maxFileSizeMB = 50;
  static const supportedExtensions = ['pdf', 'png', 'jpg', 'jpeg', 'docx', 'txt'];
}

abstract class AppRoutes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const home = '/home';
  static const documents = '/documents';
  static const documentDetail = '/documents/:id';
  static const search = '/search';
  static const chat = '/chat';
  static const chatDocument   = '/chat/:docId';
  static const profile = '/profile';
  static const settings = '/settings';
  static const upload = '/upload';
}
