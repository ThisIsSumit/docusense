Here is your **final, clean, copy-paste-ready `README.md`** (no extra IDs, fully polished):

```md
# 🚀 DocuSense — AI Document Intelligence Platform

![Flutter](https://img.shields.io/badge/Flutter-3.16%2B-blue?logo=flutter)
![Riverpod](https://img.shields.io/badge/Riverpod-2.x-green)
![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)
![Platforms](https://img.shields.io/badge/Platforms-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Desktop-blueviolet)

> **Production-grade cross-platform document platform with AI-powered search, offline-first caching, and scalable architecture.**

---

## 📌 Overview

**DocuSense** is a modern **AI-powered document management platform** built with Flutter.  
It enables users to securely upload, search, and manage documents with **semantic search, offline-first caching, and smooth UI experiences**.

Designed with **scalability and performance in mind**, it demonstrates production-level architecture using Riverpod, GoRouter, and modular design.

---

## ✨ Features

- 🔐 **Secure Authentication**
  - JWT-based login with refresh token rotation
  - Stored securely using AES-256 (Android) / Keychain (iOS)

- ⚡ **Offline-First Architecture**
  - Hive-powered caching (24h TTL)
  - Instant UI from cache + background sync

- 🔍 **AI Semantic Search**
  - 380ms debounced queries
  - Highlighted results + similarity ranking

- 📄 **Document Management**
  - Upload, view, delete, organize documents
  - Metadata + detail view with animations

- 🎨 **Modern UI/UX**
  - Smooth animations (`flutter_animate`)
  - Shimmer loaders, glassmorphism UI
  - Custom fonts (Syne + JetBrains Mono)

- 🌍 **Cross-Platform**
  - Android, iOS, Web, Windows, macOS, Linux

---

## 🧱 Tech Stack

| Layer            | Tools / Packages |
|------------------|------------------|
| State Management | flutter_riverpod, riverpod_annotation |
| Navigation       | go_router |
| Models           | freezed, json_annotation |
| Networking       | dio, retrofit |
| Local Storage    | hive, hive_flutter |
| Secure Storage   | flutter_secure_storage |
| UI & Animation   | flutter_animate, lottie, shimmer |
| Images           | cached_network_image |
| Connectivity     | connectivity_plus |

---

## 🏗️ Architecture

```

lib/
├── core/
│   ├── constants/
│   ├── theme/
│   ├── router/
│   └── utils/
│
├── features/
│   ├── auth/
│   ├── documents/
│   ├── home/
│   └── search/
│
└── shared/
├── providers/
└── widgets/

```

---

## 🔄 Core Workflows

### 🔐 Authentication Flow

```

Splash → Onboarding → Login → Home

```

- Secure token persistence  
- Auto-login on restart  
- Token refresh on 401  

---

### ⚡ Caching Strategy

```

Cache Hit (<24h) → Instant UI → Background Refresh
Cache Miss       → API Call → Store → Render

````

- Hive-based caching  
- LRU eviction (200 items)  

---

### 📜 Lazy Loading + Prefetch

- Fetch triggered before reaching list end  
- Eliminates loading flicker  

---

### 🔍 Debounced Search

- 380ms debounce  
- Prevents excessive API calls  
- Highlights matched terms  

---

## 🚀 Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/ThisIsSumit/docusense.git
cd docusense
````

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Run Code Generation

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 4. Run the App

```bash
flutter run
```

### Dev Mode (Watch)

```bash
dart run build_runner watch --delete-conflicting-outputs
```

---

## 🎨 Required Assets

### Fonts

Download and place inside `assets/fonts/`:

* Syne → [https://fonts.google.com/specimen/Syne](https://fonts.google.com/specimen/Syne)
* JetBrains Mono → [https://www.jetbrains.com/legalnotice/fonts/](https://www.jetbrains.com/legalnotice/fonts/)

---

### Placeholder Directories

```bash
mkdir -p assets/images assets/icons assets/lottie
touch assets/images/.gitkeep assets/icons/.gitkeep assets/lottie/.gitkeep
```

---

## ⚙️ Code Generation

Generated files include:

* `*.freezed.dart`
* `*.g.dart`
* `*.provider.g.dart`

Used for:

* Immutable models
* JSON serialization
* Riverpod providers
* Hive adapters

---

## 🔌 Backend Integration

Replace mock APIs with real endpoints:

```dart
final response = await dio.get(
  '/documents',
  queryParameters: {'page': page, 'limit': pageSize},
);

final items = (response.data['data'] as List)
    .map((j) => DocumentModel.fromJson(j))
    .toList();
```

---

## 📱 Screens & Routes

| Screen          | Route            | Description                |
| --------------- | ---------------- | -------------------------- |
| Splash          | `/`              | App bootstrap + auth check |
| Onboarding      | `/onboarding`    | Intro slides               |
| Login           | `/login`         | Authentication             |
| Register        | `/register`      | Signup                     |
| Home            | `/home`          | Dashboard                  |
| Documents       | `/documents`     | List + filters             |
| Document Detail | `/documents/:id` | Metadata + AI summary      |
| Search          | `/search`        | Semantic search            |
| Profile         | `/profile`       | User settings              |

---

## 📸 Screenshots

> Add screenshots or demo GIFs here

---

## 🤝 Contributing

Contributions are welcome!

1. Fork the repo
2. Create a feature branch
3. Submit a PR

---

## 📄 License

This project is licensed under the **MIT License**.

---

## 📬 Contact

**Sumit Kumar**
📧 [sumitkumar453827@gmail.com](mailto:sumitkumar453827@gmail.com)
🔗 [https://github.com/ThisIsSumit](https://github.com/ThisIsSumit)

---

## ⭐ Support

If you like this project:

* ⭐ Star the repo
* 🍴 Fork it
* 🚀 Share it

