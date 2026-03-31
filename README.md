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

# DocuSense: AI Document Intelligence Platform

![Flutter](https://img.shields.io/badge/Flutter-3.16%2B-blue?logo=flutter)
![Riverpod](https://img.shields.io/badge/Riverpod-2.x-green)
![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)
![Platforms](https://img.shields.io/badge/Platforms-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Desktop-blueviolet)

---

## Overview

**DocuSense** is a production-grade, cross-platform AI Document Intelligence Platform built with Flutter. It enables users to securely upload, search, and manage documents with advanced offline caching, semantic search, and a modern, animated UI. Designed for extensibility and robust state management, DocuSense is ideal for teams and individuals seeking a seamless document experience across devices.

---

## Features

- 🔒 **Secure Auth**: JWT-based login, secure token storage (AES-256/Keychain), refresh token rotation
- ⚡ **Offline-First**: Hive-powered local cache with LRU eviction and 24h TTL
- 🔍 **Semantic Search**: Debounced, highlighted, and ranked search results
- 📄 **Document Management**: Upload, view, delete, and organize documents
- 🚀 **Modern UI**: Animated transitions, shimmer/skeleton loaders, glassmorphism, and custom fonts
- 📱 **Multi-Platform**: Android, iOS, Web, Windows, macOS, Linux
- 🛠️ **Extensible Architecture**: Riverpod 2, GoRouter, Freezed, Dio, Hive, and more

---

## Screenshots

<!-- Add screenshots or GIFs here -->

---

## Tech Stack

| Layer            | Package(s)                        | Purpose                                 |
|------------------|-----------------------------------|-----------------------------------------|
| State Management | flutter_riverpod, riverpod_annotation | Async state, code-gen providers         |
| Navigation       | go_router                         | Declarative routing, auth guards         |
| Models           | freezed, json_annotation          | Immutable models, JSON serialization     |
| Local Storage    | hive_flutter, hive                | Fast binary cache, offline docs          |
| Secure Storage   | flutter_secure_storage            | JWT tokens, secure key storage           |
| Preferences      | shared_preferences                | User flags, settings                     |
| HTTP             | dio                               | REST client, interceptors, retry         |
| Animation        | flutter_animate, lottie, shimmer  | UI polish, loading states                |
| Images           | cached_network_image              | Network image cache                      |
| Connectivity     | connectivity_plus                 | Online/offline detection                 |

---

## Architecture

```
lib/
├── core/
│   ├── constants/       # App-wide constants, keys, timeouts
│   ├── theme/           # Colors, typography, theme
│   ├── router/          # GoRouter config, auth redirect
│   └── utils/           # Bootstrap, Dio client, Hive init
├── features/
│   ├── auth/            # Auth models, providers, screens
│   ├── documents/       # Document models, providers, screens
│   ├── home/            # Home shell, dashboard
│   └── search/          # Search screen, logic
└── shared/
    ├── providers/       # Shared Riverpod providers
    └── widgets/         # Reusable widgets (TextField, Button, etc.)
```

---

## Key Patterns & Workflows

### Authentication Flow

Splash → Onboarding → Login/Register → Home

- Auth state persisted in secure storage
- Tokens survive app restart; refresh on 401

### Caching & Offline

- Documents cached in Hive (LRU, 200 items, 24h TTL)
- Serve cache instantly, refresh in background

### Lazy Loading & Prefetch

- Next-page fetch triggered before scroll end for zero loading flicker

### Debounced Search

- 380ms debounce, single network call per typing burst
- Results ranked and highlighted

---

## Setup & Getting Started

```bash
# 1. Clone
git clone https://github.com/your-org/docusense.git
cd docusense

# 2. Install dependencies
flutter pub get

# 3. Run code generation (Riverpod, Freezed, JSON, Hive)
dart run build_runner build --delete-conflicting-outputs

# 4. Launch the app
flutter run

# (Optional) Watch mode for codegen
dart run build_runner watch --delete-conflicting-outputs
```

### Required Assets

- Download and place fonts in `assets/fonts/`:
  - Syne (Regular, Medium, Bold, ExtraBold): https://fonts.google.com/specimen/Syne
  - JetBrains Mono (Regular, Medium): https://www.jetbrains.com/legalnotice/fonts/
- Ensure `assets/images/`, `assets/icons/`, and `assets/lottie/` exist (see pubspec.yaml)

---

## Generated Files

After running code generation, these files are auto-created:

| Source                  | Generated Files                        |
|-------------------------|----------------------------------------|
| auth_models.dart        | auth_models.freezed.dart, .g.dart      |
| document_model.dart     | document_model.freezed.dart, .g.dart   |
| auth_provider.dart      | auth_provider.g.dart                   |
| documents_provider.dart | documents_provider.g.dart              |
| app_router.dart         | app_router.g.dart                      |
| search_screen.dart      | search_screen.g.dart                   |
| dio_client.dart         | dio_client.g.dart                      |
| connectivity_provider.dart | connectivity_provider.g.dart         |

---

## Connecting to a Real Backend

Replace mock delays in providers with real Dio API calls. Example:

```dart
final response = await ref.read(dioClientProvider).get('/documents', queryParameters: {'page': page, 'limit': pageSize});
final items = (response.data['data'] as List).map((j) => DocumentModel.fromJson(j)).toList();
```

---

## Screens & Routes

| Screen           | Route              | Features                                              |
|------------------|--------------------|-------------------------------------------------------|
| Splash           | `/`                | Animated splash, parallel auth resolve                 |
| Onboarding       | `/onboarding`      | Multi-slide intro, animated icons, dot indicators      |
| Login            | `/login`           | Secure login, animated fields, JWT storage             |
| Register         | `/register`        | Slide-up sheet, password validation                    |
| Forgot Password  | `/forgot-password` | Success state, animated check                          |
| Home             | `/home`            | Stats, recent docs, shimmer loading                    |
| Documents        | `/documents`       | Filter, lazy load, prefetch, swipe-to-delete           |
| Document Detail  | `/documents/:id`   | Hero animation, AI summary, metadata grid              |
| Search           | `/search`          | Debounced input, highlight, similarity score           |
| Profile          | `/profile`         | Avatar, stats, settings, sign out                      |

---

## Contributing

Contributions are welcome! Please open issues or submit pull requests for improvements, bug fixes, or new features. For major changes, open an issue first to discuss what you would like to change.

---

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

## Contact

For support, questions, or feedback, please open an issue or contact the maintainer at [sumitkumar453827@gmail.com].
