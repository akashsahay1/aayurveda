# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Aayurveda is a Flutter mobile app for browsing Ayurvedic health and wellness content. It consumes a WordPress REST API backend (`aayurveda.stime.in`) to display categorized posts, and includes user authentication, likes, bookmarks, and sharing features. The WordPress backend lives in `appbackend/`.

## Build & Run Commands

```bash
cd mobileapp
flutter pub get                      # Install dependencies
flutter run                          # Run on connected device/emulator
flutter build apk                    # Build Android APK
flutter build ios                    # Build iOS app
flutter analyze                      # Run static analysis (uses flutter_lints)
flutter test                         # Run tests
flutter test test/widget_test.dart   # Run a single test file
```

### Platform-Specific

- **Android**: Package name `ayurveda.stime.in`, minSdk 21. Release signing configured via `android/key.properties` (not in repo).
- **iOS**: Bundle ID `aayurveda.stime.in`
- Launcher icons: `flutter pub run flutter_launcher_icons`
- Package rename: `flutter pub run package_rename`

## Architecture

### Repo Structure

```
aayurveda/              (git repo root)
├── mobileapp/          Flutter app
└── appbackend/         WordPress backend (wp-config.php gitignored)
```

### State Management
Uses **Provider** with a single `ChangeNotifierProvider<UserState>` at the app root (`lib/main.dart`). Auth tokens stored in `FlutterSecureStorage` (Keychain/EncryptedSharedPreferences), non-sensitive user data in SharedPreferences.

### Navigation
Imperative navigation using `Navigator.push(MaterialPageRoute(...))`. A `Bottombar` widget provides 5-tab navigation: Home, Search, Saved, Liked, Account.

### Data Flow
- API endpoints defined in `lib/constants/apis.dart` (base URL: `https://aayurveda.stime.in`)
- Pages fetch data directly using `http` package in `FutureBuilder` widgets — no repository/service layer
- Posts fetched from WordPress REST API (`/wp-json/wp/v2/posts`)
- Custom REST API at `/wp-json/aayurveda/v1/` for auth (signup, login, logout) and likes
- Post HTML content rendered using `flutter_html`
- Images use `cached_network_image` for caching

### Auth System
- Login/signup via `POST /wp-json/aayurveda/v1/login` and `/signup` (JSON body)
- Token returned on success, stored in `FlutterSecureStorage`
- All authenticated requests send `Authorization: Bearer <token>` header
- Auth validated server-side via `app_token` user meta in WordPress

### Likes System
- `POST /wp-json/aayurveda/v1/posts/{id}/like` — add like (requires auth)
- `DELETE /wp-json/aayurveda/v1/posts/{id}/like` — remove like
- `GET /wp-json/aayurveda/v1/posts/{id}/liked` — check if current user liked
- `GET /wp-json/aayurveda/v1/user/liked-posts` — list user's liked post IDs
- Likes stored in `wp_likes` table with unique `(post_id, user_id)` constraint

### Bookmarks
Local-only via `BookmarkService` in `lib/models/bookmarks.dart` using SharedPreferences. Not synced to server.

### App Entry Flow
1. `DisclaimerGate` checks `hasAcceptedDisclaimer` in SharedPreferences
2. First launch → medical disclaimer screen → must accept to proceed
3. After acceptance → Home page with featured articles

### Project Structure

```
mobileapp/lib/
├── main.dart                          # App entry, Provider setup, DisclaimerGate
├── models/
│   ├── user.dart                      # UserState (ChangeNotifier) - auth with secure storage
│   └── bookmarks.dart                 # BookmarkService - local bookmark storage
├── constants/
│   ├── apis.dart                      # All API endpoint URLs (WP + custom REST)
│   └── texts.dart                     # App strings, categories, legal text (disclaimers, privacy, terms)
├── components/
│   ├── pages/                         # disclaimer, home, categories, post, search, login, signup, about, privacy, terms, bookmarks, liked_posts
│   └── common/                        # appbar, bottombar (5 tabs), horizontalposts
```

### Theme
Material 3 with seed color `Color(0xfff7770f)` (orange). Custom font: OpenSans (weights 300-800). Debug banner disabled.

### Key Conventions
- Uses `debugPrint()` instead of `print()` for logging
- `const` constructors used throughout widgets
- Uses `WidgetStatePropertyAll` (Flutter 3.22+) for button styling
- All legal text centralized in `texts.dart` (marked TODO for legal review)
- Format-on-save enabled for Dart files (`.vscode/settings.json`)

### Backend (appbackend)
- WordPress theme: `stime` at `wp-content/themes/stime/`
- `functions.php` — REST API endpoints, post response customization, likes table setup
- `ajax.php` — deprecated, kept for reference
- ACF Pro used for `sources` field on posts
- All SQL uses `$wpdb->prepare()` for parameterized queries
