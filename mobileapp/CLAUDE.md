# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Aayurveda is a Flutter mobile app for browsing Ayurvedic health and wellness content. It consumes a WordPress REST API backend (`aayurveda.stime.in`) to display categorized posts, and includes user authentication via a custom AJAX endpoint.

## Build & Run Commands

```bash
flutter pub get          # Install dependencies
flutter run              # Run on connected device/emulator
flutter build apk        # Build Android APK
flutter build ios        # Build iOS app
flutter analyze          # Run static analysis (uses flutter_lints)
flutter test             # Run tests (test/widget_test.dart)
flutter test test/widget_test.dart  # Run a single test file
```

### Platform-Specific

- **Android**: Package name `ayurveda.stime.in`, minSdk 21. Release signing configured via `android/key.properties` (not in repo).
- **iOS**: Bundle ID `aayurveda.stime.in`
- Launcher icons: `flutter pub run flutter_launcher_icons`
- Package rename: `flutter pub run package_rename`

## Architecture

### State Management
Uses **Provider** with a single `ChangeNotifierProvider<UserState>` at the app root (`lib/main.dart`). User auth state is persisted via `SharedPreferences`.

### Navigation
Imperative navigation using `Navigator.push(MaterialPageRoute(...))`. No named routes. A `Bottombar` widget provides app-wide navigation between Categories, Search, About, and Login pages.

### Data Flow
- API endpoints are defined in `lib/constants/apis.dart` (base URL: `https://aayurveda.stime.in`)
- Pages fetch data directly using `http` package in `FutureBuilder` widgets — there is no repository/service layer
- Posts are fetched from WordPress REST API (`/wp-json/wp/v2/posts`), auth uses a custom AJAX endpoint (`ajax.php`)
- Post HTML content is rendered using `flutter_html` package
- Images use `cached_network_image` for caching; featured images are fetched via the WP media endpoint (`/wp-json/wp/v2/media/{id}`)

### Category System
`lib/constants/texts.dart` defines 12 Ayurvedic topic categories (`cat1`–`cat12`) with display names and WordPress category IDs. Categories page fetches child categories from the WP API and maps them to these constants.

### Authentication
Login and signup POST to `ajax.php` with `action=login` or `action=signup`. On success, `UserState` stores userId, username, and token in `SharedPreferences`.

### Project Structure

```
lib/
├── main.dart                          # App entry point, Provider setup, theme
├── models/user.dart                   # UserState (ChangeNotifier) - auth & session
├── constants/
│   ├── apis.dart                      # All API endpoint URLs
│   └── texts.dart                     # App strings and category name mappings
├── components/
│   ├── pages/                         # Full-screen pages (home, categories, post, search, login, signup, about, privacy)
│   └── common/                        # Reusable widgets (appbar, bottombar, horizontalposts, layout)
```

### Theme
Material 3 with seed color `Color(0xfff7770f)` (orange). Custom font: OpenSans (weights 300-800) in `assets/fonts/`.

### Key Conventions
- Uses `debugPrint()` instead of `print()` for logging
- `const` constructors used throughout widgets
- Uses `WidgetStatePropertyAll` (Flutter 3.22+) for button styling
- Format-on-save enabled for Dart files (`.vscode/settings.json`)
