# DocuSense — AI Document Intelligence Platform

> Production-grade Flutter app · Riverpod 2 · GoRouter · Hive · Freezed

---

## Tech Stack

| Layer | Package | Purpose |
|---|---|---|
| State | `flutter_riverpod` + `riverpod_annotation` | Code-gen providers, async state |
| Navigation | `go_router` | Declarative routing, auth guards, shell routes |
| Models | `freezed` + `json_annotation` | Immutable models, JSON serialization |
| Local Storage | `hive_flutter` | Fast binary cache (documents, search) |
| Secure Storage | `flutter_secure_storage` | JWT tokens (AES-256 on Android, Keychain on iOS) |
| Preferences | `shared_preferences` | Flags (onboarded, settings) |
| HTTP | `dio` + `retrofit` | REST client, auth interceptor, retry |
| Animation | `flutter_animate` | Staggered reveals, physics springs |
| Images | `cached_network_image` | Network image cache |
| Connectivity | `connectivity_plus` | Online/offline detection |

---

## Architecture

```
lib/
├── core/
│   ├── constants/       app_constants.dart      routes, keys, timeouts
│   ├── theme/           app_theme.dart           colors, typography, theme
│   ├── router/          app_router.dart          GoRouter + auth redirect
│   └── utils/           app_bootstrap.dart       Hive init, SystemChrome
│                        dio_client.dart          Dio + interceptors
│
├── features/
│   ├── auth/
│   │   ├── data/models/ auth_models.dart         Freezed UserModel, AuthTokens
│   │   └── presentation/
│   │       ├── providers/ auth_provider.dart     AuthStateNotifier (Riverpod)
│   │       └── screens/  splash, onboarding,
│   │                      login, register,
│   │                      forgot_password,
│   │                      profile
│   │
│   ├── documents/
│   │   ├── data/models/ document_model.dart      Freezed + Hive annotations
│   │   └── presentation/
│   │       ├── providers/ documents_provider.dart Pagination + prefetch + cache
│   │       └── screens/  documents, document_detail
│   │
│   ├── home/
│   │   └── presentation/screens/  home_shell, home_screen
│   │
│   └── search/
│       └── presentation/screens/  search_screen (debounce + highlight)
│
└── shared/
    ├── providers/  connectivity_provider.dart
    └── widgets/    app_widgets.dart   (TextField, GlowButton, ShimmerBox, ErrorBanner)
```

---

## Key Patterns

### Auth Flow
```
Splash (2.8s + auth resolve) 
  → not onboarded  →  Onboarding  →  Login
  → onboarded + logged out         →  Login
  → onboarded + logged in          →  Home
```

Auth state persists in **FlutterSecureStorage** (AES-256).  
Tokens survive app restart. Refresh token rotation on 401.

### Caching Strategy
```
Network request
  ├── Cache hit (< 24h)  → serve cache immediately → background refresh
  └── Cache miss         → fetch → render → persist to Hive
```

Documents cached in `Hive.openBox<Map>('documents')` keyed by `doc.id`.  
LRU eviction at 200 items.

### Lazy Loading + Prefetch
```dart
void _onScroll() {
  final threshold = maxScrollExtent - prefetchThreshold * 120.0;
  if (pixels >= threshold) {
    ref.read(documentsNotifierProvider.notifier).onScrolledNearEnd();
  }
}
```
Triggers next-page fetch 5 items **before** the user hits the bottom — zero loading flicker.

### Debounced Search
```dart
_debounce = Timer(Duration(milliseconds: 380), () => _search(query));
```
380ms debounce → single network call per typing burst.  
Results ranked by mock vector similarity score.  
Query terms highlighted in results via `_HighlightText` widget.

---

## Setup

```bash
# 1. Clone
git clone https://github.com/you/docusense
cd docusense

# 2. Get deps
flutter pub get

# 3. Run code generation (Riverpod, Freezed, JSON, Hive)
dart run build_runner build --delete-conflicting-outputs

# 4. Run
flutter run

# Watch mode during development
dart run build_runner watch --delete-conflicting-outputs
```

### Required assets (add before build)
Download and place fonts in `assets/fonts/`:
- `Syne-Regular.ttf`, `Syne-Medium.ttf`, `Syne-Bold.ttf`, `Syne-ExtraBold.ttf`  
  → https://fonts.google.com/specimen/Syne
- `JetBrainsMono-Regular.ttf`, `JetBrainsMono-Medium.ttf`  
  → https://www.jetbrains.com/legalnotice/fonts/

Create empty placeholder dirs (required by pubspec):
```bash
mkdir -p assets/images assets/icons assets/lottie
touch assets/images/.gitkeep assets/icons/.gitkeep assets/lottie/.gitkeep
```

---

## Generated Files

After `build_runner`, these files are created automatically:

| Source | Generated |
|---|---|
| `auth_models.dart` | `auth_models.freezed.dart`, `auth_models.g.dart` |
| `document_model.dart` | `document_model.freezed.dart`, `document_model.g.dart` |
| `auth_provider.dart` | `auth_provider.g.dart` |
| `documents_provider.dart` | `documents_provider.g.dart` |
| `app_router.dart` | `app_router.g.dart` |
| `search_screen.dart` | `search_screen.g.dart` |
| `dio_client.dart` | `dio_client.g.dart` |
| `connectivity_provider.dart` | `connectivity_provider.g.dart` |

---

## Connecting a Real Backend

Replace mock delays in providers with Dio calls:

```dart
// documents_provider.dart — replace mock with:
final response = await ref.read(dioClientProvider).get('/documents', 
  queryParameters: {'page': page, 'limit': pageSize});
final items = (response.data['data'] as List)
    .map((j) => DocumentModel.fromJson(j))
    .toList();
```

Auth provider similarly — swap `Future.delayed` blocks with:
```dart
final response = await ref.read(dioClientProvider).post('/auth/login', 
  data: LoginRequest(email: email, password: password).toJson());
final auth = AuthResponse.fromJson(response.data);
```

---

## Resume Bullets

- Architected Riverpod 2 state layer with code-gen providers, async notifiers, and persistent auth across JWT refresh token rotation
- Built staggered splash → onboarding → auth flow with physics-spring animations (cubic-bezier overshoot) and 2.8s minimum display with parallel auth resolution
- Implemented offline-first document cache (Hive + LRU eviction at 200 items, 24h TTL) with background silent refresh and 380ms debounced semantic search
- Engineered prefetch scroll listener triggering next-page fetch 5 items before viewport end, eliminating perceived loading latency on paginated lists of 60+ documents
- Secured auth tokens with FlutterSecureStorage (AES-256 on Android, iOS Keychain) and automatic 401 retry with refresh token rotation via Dio interceptor

---

## Screens

| Screen | Route | Key Features |
|---|---|---|
| Splash | `/` | Particle field, radial rings, animated progress bar, parallel auth resolve |
| Onboarding | `/onboarding` | 3-slide PageView, animated icons, dot indicators, persisted flag |
| Login | `/login` | Staggered field reveals, glow button, JWT + secure storage |
| Register | `/register` | Slide-up sheet, confirm password validation |
| Forgot Password | `/forgot-password` | Success state transition, animated check |
| Home | `/home` | Stats cards, recent docs with shimmer, greeting |
| Documents | `/documents` | Filter chips, lazy load, prefetch, swipe-to-delete, skeleton loaders |
| Document Detail | `/documents/:id` | Hero-style reveal, AI summary, metadata grid, Ask CTA |
| Search | `/search` | Debounced input, recent queries, topic pills, highlight match, similarity score |
| Profile | `/profile` | Avatar, stats, settings groups, animated toggle, sign out |
