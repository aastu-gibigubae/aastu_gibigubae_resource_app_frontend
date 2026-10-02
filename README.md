# AASTU Freshman Resource App — Frontend

A Flutter mobile application that provides AASTU students with structured access to academic resources: past exams, lecture modules, handouts, and lecture slides organized by stream, department, year, and course.

---

## Table of Contents

- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Backend & Data Architecture](#backend--data-architecture)
- [API Reference](#api-reference)
- [Environment Setup](#environment-setup)
- [Authentication Flow](#authentication-flow)
- [Offline Sync Strategy](#offline-sync-strategy)
- [Subscription & Access Control](#subscription--access-control)
- [Running the App](#running-the-app)
- [Running Tests](#running-tests)
- [Contributing](#contributing)

---

## Tech Stack

| Layer | Technology |
|---|---|
| UI Framework | Flutter 3.x (Dart 3.12+) |
| State Management | Riverpod 2.x (AsyncNotifier, AutoDispose) |
| Navigation | go_router 14.x |
| HTTP Client | Dio 5.x (with auth interceptor) |
| Local Database | sqflite 2.x (SQLite) |
| Secure Storage | flutter_secure_storage 9.x |
| PDF Viewer | flutter_pdfview + flutter_cache_manager |
| Connectivity | connectivity_plus |
| Device Fingerprint | device_info_plus + uuid |

---

## Project Structure

```
lib/
├── app/
│   ├── providers/          # Shared app-level providers (Dio, storage, etc.)
│   ├── router/             # go_router config & route names
│   └── theme/              # Colors, typography, spacing
├── core/
│   ├── constants/          # API endpoints, storage keys, app constants
│   ├── errors/             # Error mapper (DioException -> AppFailure)
│   ├── storage/            # LocalDatabase (SQLite singleton)
│   ├── sync/               # SyncService (offline->online auto-sync)
│   └── widgets/            # Shared UI components
└── features/
    ├── auth/               # Login, Signup, Session management
    ├── device/             # Device heartbeat & status
    ├── notifications/      # Notification list, mark-as-read
    ├── profile/            # User profile, premium status display
    └── resources/          # Streams, Courses, Resources (core feature)
```

---

## Backend & Data Architecture

### Base URL

```
https://resource-app-h7e9.onrender.com
```

All endpoints require `Authorization: Bearer <token>` (except `/auth/login` and `/auth/signup`).

### 3-Tier Data Strategy

```
Remote API  -->  SQLite Cache  -->  UI (Riverpod)
(online)         (offline)
```

1. **Remote first** — every provider tries a live fetch on mount.
2. **Cache on success** — remote results are batch-written to SQLite.
3. **Cache fallback** — if the network call fails, SQLite is read instead.
4. **Empty state** — if both fail, an empty list is returned with a friendly message.

### SQLite Tables

| Table | Purpose |
|---|---|
| `cached_resources` | Downloaded PDF files with paths & premium flag |
| `cached_resource_items` | Resource metadata for offline browsing |
| `cached_streams` | Academic streams |
| `cached_departments` | Departments per stream |
| `cached_courses` | Courses with year, semester, icon |
| `cached_notifications` | User notifications with read/unread status |

---

## API Reference

### Auth

| Method | Endpoint | Description |
|---|---|---|
| POST | /auth/login | Login with email + password + device fingerprint |
| POST | /auth/signup | Register a new account |
| POST | /auth/logout | Invalidate refresh token |
| POST | /auth/refresh | Refresh access token (Dio interceptor handles this) |

**Signup / Login body:**
```json
{
  "email": "student@aastu.edu.et",
  "password": "SecurePass123",
  "device_fingerprint": "<uuid-v4>",
  "name": "Abebe Kebede",
  "phone": "0911XXXXXX",
  "field_of_study": "Software Engineering",
  "academic_year": 1
}
```

**Auth response:**
```json
{
  "access_token": "eyJ...",
  "refresh_token": "eyJ...",
  "user": {
    "id": "abc123",
    "name": "Abebe Kebede",
    "email": "student@aastu.edu.et",
    "role": "student",
    "subscription_status": "none",
    "subscription_expires_at": null,
    "activation_status": "active",
    "created_at": "2026-10-01T00:00:00Z"
  }
}
```

### Browse

| Method | Endpoint | Query Params | Description |
|---|---|---|---|
| GET | /streams | — | All academic streams |
| GET | /departments | stream_id | Departments in a stream |
| GET | /courses | stream_id, department_id, year, page, limit | Paginated courses |
| GET | /courses/:id/resources | category, page, limit | Resources for a course |
| GET | /search | q | Full-text resource search |

**Category values:** `midterms` `finals` `tests` `modules` `ppts` `handouts`

### Notifications

| Method | Endpoint | Description |
|---|---|---|
| GET | /notifications | Fetch all user notifications |
| POST | /notifications/:id/read | Mark notification as read |

### Device Heartbeat

| Method | Endpoint | Description |
|---|---|---|
| POST | /verify/heartbeat | Validates device + returns subscription status |

---

## Environment Setup

### Prerequisites

| Tool | Version |
|---|---|
| Flutter SDK | >= 3.12.0 |
| Dart | >= 3.12.0 |
| Android SDK | API 21+ |
| Java | 17 |

### Steps

```bash
# 1. Clone
git clone https://github.com/your-org/aastu_gibigubae_resource_app_frontend.git
cd aastu_gibigubae_resource_app_frontend

# 2. Install dependencies
flutter pub get

# 3. Verify
flutter doctor

# 4. Run
flutter run
```

> No .env file needed. The backend URL is in lib/core/constants/api_constants.dart.
> Change ApiConstants.baseUrl to point at a different server.

---

## Authentication Flow

```
App Start
   |
   +-- SecureStorage has access_token?
          |
         YES --> Restore session --> Home
          |
          NO  --> Login / Signup
          
Login / Signup
   |
   +-- POST /auth/login or /auth/signup
   +-- Store tokens + user metadata in SecureStorage
   +-- Navigate to Home

Token Refresh (Dio interceptor, transparent)
   |
   +-- 401 received --> POST /auth/refresh
   +-- Update stored access_token
   +-- Retry original request
```

### What is Stored on Signup (DB Fields)

| Field | Stored | Description |
|---|---|---|
| name | YES | Display name |
| email | YES | University email |
| password | YES (hashed) | Bcrypt hash, server-side |
| phone | YES (optional) | Contact number |
| field_of_study | YES | E.g. "Software Engineering" |
| academic_year | YES | 1-5, used to pre-filter courses |
| device_fingerprint | YES | UUID tied to the device |

The `field_of_study` and `academic_year` are used by the backend to filter courses for the user by default.

---

## Offline Sync Strategy

### Auto-sync on reconnect

`SyncService` listens to connectivity changes. When offline -> online:

1. Re-fetches and caches: streams, courses, notifications
2. Refreshes: downloaded resource list
3. Calls device heartbeat

### Manual sync

The rotating refresh icon on the Home page runs the same sync and shows a toast when done.

### Notification diff-sync (efficient)

1. One SQL query: fetch all existing IDs -> Set<int> (O(1) lookup)
2. Filter incoming list to new-only in Dart (O(N))
3. Batch-insert new items in a single SQLite transaction

This avoids N database round-trips during sync.

---

## Subscription & Access Control

### Premium vs Free

| Content | Free | Premium |
|---|---|---|
| Free sample resources | YES | YES |
| Full resource library | LOCKED | YES |
| Offline downloads | LOCKED | YES |

### Expiry

- Online: reads subscription_expires_at from heartbeat response.
- Offline: 7-day grace period from last heartbeat timestamp.
- After 7 days offline: premium features locked until reconnect.

### Lock UI

- Lock badge on resource cards
- "Subscription Required" dialog on tap
- Expiry banner on already-downloaded expired resources

---

## Running the App

```bash
flutter run              # debug
flutter run --release    # release
flutter devices          # list devices
```

---

## Running Tests

```bash
flutter test             # all tests
flutter test --coverage  # with coverage report
```

### Coverage areas

- auth/ -- Login, signup, token refresh
- resources/ -- Download locking, expiry, premium enforcement
- notifications/ -- Cache diff-sync correctness
- sync/ -- SyncService trigger behavior

---

## Contributing

### Branch naming

| Prefix | Purpose |
|---|---|
| feat/ | New feature |
| fix/ | Bug fix |
| refactor/ | Code restructure |
| chore/ | Dependencies, CI |

### Adding a new endpoint

1. Add constant to lib/core/constants/api_constants.dart
2. Add method to the *_remote_datasource.dart
3. Add Riverpod provider in *_providers.dart
4. Cache results in *_local_datasource.dart

### Code style

Run `flutter analyze` before submitting a PR.

---

## Architecture Decisions

| Decision | Rationale |
|---|---|
| Riverpod (not BLoC) | Simpler boilerplate, built-in async handling |
| sqflite (not Hive) | Relational structure fits resource/course relationships |
| Dio interceptor for auth | Transparent token refresh without manual retry |
| batchInsert for sync | One transaction vs N round-trips |
| ConflictAlgorithm.ignore for notifications | Preserves locally set read_status during sync |
