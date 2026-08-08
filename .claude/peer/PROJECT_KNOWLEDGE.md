# bbarna — Project Knowledge Base

Maintained by `/peer`. Update only the affected section when a run discovers a new architectural fact — never regenerate this whole file. Last full survey: 2026-08-08 (via CodeGraph, 138 files / 1,629 nodes / 4,351 edges indexed).

## Project Overview

- **What it does**: Admin panel for an e-learning platform (courses, subjects, units, topics, quizzes, questions, videos/PDFs/audio documents, banners, students, admin login). Content-management/CRUD tool, not the learner-facing app.
- **Stack**: Flutter Web (Dart SDK `^3.5.3`), Firebase (`cloud_firestore`, `firebase_storage`, `firebase_core`), `provider` for state.
- **Platform**: Web is primary/active target (also has stub Android/iOS/Linux/macOS/Windows platform folders from `flutter create`, not evidenced to be actively shipped).
- **Architecture pattern**: Feature-based folders, each with `model/ repo/ screen/ viewModel/ widgets/`. Provider (`ChangeNotifier`) for state. Repos call Firestore/Storage **directly** — no domain/use-case layer, no repository interfaces/abstractions, no dependency injection. This is a flat CRUD-admin-over-Firestore shape, not Clean Architecture/MVVM in the formal sense. Full detail: see "Architecture Knowledge" below.

## Directory / Module Map

```
lib/
├── main.dart              — entry point; registers 11 ChangeNotifierProviders (one per feature); MaterialApp with single `home` (no named routes)
├── login/screen/           — LoginScreen; checks admin credentials directly against Firestore `admin` collection (see Security note below)
├── core/widgets/           — shared UI: Sidebar (app shell/nav), AppHeader, CustomTextField, RemoveAlert (delete-confirm dialog, reusable), ChooseImage (image-picker trigger, reusable), LoaderDialogs, AddWidget, SaveButton, etc.
├── resources/              — app_colors.dart (AppColorsInApp), constant.dart (global GlobalKeys, sharedPreferences, Firestore collection-name constants) — constant.dart is used by 57/138 files
├── utils/                  — helper.dart (Helper.showSnackBarMessage, showLoader — used by 50/138 files), size_config.dart
├── banners/, course/, subject/, units/, topic/, quiz/, question/, student/, documents/{audio,pdf,video}/
│                           — each follows model/repo/screen/viewModel[/widgets], independent of each other (no cross-feature imports found — low inter-feature coupling)
└── (no `web/`-specific Dart code; no routing package; no DI framework)
```

Each feature folder is a template for the next: `model` = plain class + `toMap()`/`fromDocumentSnapshot()`; `repo` = a class wrapping `FirebaseFirestore.instance`/`FirebaseStorage.instance` calls scoped to one collection; `viewModel` = `with ChangeNotifier`, owns a `Repo()` instance directly (`final XRepo _xRepo = XRepo();` — no injection), exposes CRUD futures + `notifyListeners()`; `screen` = StatefulWidget list/add/edit pages; `widgets` = feature-local card/list-item widgets.

## Architecture Knowledge

- **State management**: `provider` package, `ChangeNotifier` ViewModels, all 11 registered eagerly in `main.dart` `MultiProvider` regardless of active screen.
- **Navigation/routing**: No routing package, no named routes. `Sidebar` (`lib/core/widgets/sidebar.dart`) holds a hardcoded `List<Widget> screenList` and swaps the visible screen via an `int selectedIndex` — an index-swap shell, not real navigation. `ExtraSideBar` (`lib/core/widgets/extra_sidebar.dart`) is a **separate widget with its own independent hardcoded `drawerItems`/`iconList` arrays**, used for the narrow-width (<900px) `Drawer`; it navigates by pushing `Sidebar(sidebarIndex: index)` using its own local index — the two files' arrays must be kept manually in sync (a fragile, compiler-silent invariant). Add/Edit flows use `Navigator.push(MaterialPageRoute(...))`. No deep-linking; browser URL never reflects app state; `PopScope(canPop: false)` blocks back-navigation in the shell.
- **Data layer**: Firestore + Firebase Storage directly from the Flutter Web client. **There is no backend/REST API anywhere in this codebase.** Collection names are string constants in `resources/constant.dart` (e.g. `subject`, `course`, `student`...).
- **Repository pattern**: present as a naming convention only — no interfaces, ViewModels instantiate their repo directly (not mockable/swappable) in every existing feature.
- **Dependency injection**: none. Shared singletons (`navigatorKey`, `scaffoldKey`, `snackBarKey`, `sharedPreferences`) are global top-level variables in `constant.dart`.
- **Error handling**: inconsistent — some repo methods wrap Firestore calls in try/catch + `Helper.showSnackBarMessage`, others don't. No transactional writes anywhere prior to the Teacher feature.
- **Logging**: none structured; scattered `log()`/`print`-style debug calls in some ViewModels.
- **Configuration**: single Firebase project, hardcoded API keys in both `lib/main.dart` and `web/index.html` (the latter also has a redundant, likely-dead legacy Firebase JS SDK v8 init). No flavors/environments.
- **Testing strategy**: none existed before the Teacher feature. `test/widget_test.dart` is unmodified `flutter create` counter-app boilerplate (would fail if run). The Teacher feature introduces the repo's first real test infrastructure: `fake_cloud_firestore`, `firebase_storage_mocks`, `mocktail` as dev_dependencies, and a constructor-injectable repo pattern (`TeacherRepo({FirebaseFirestore? firestore, FirebaseStorage? storage})`) — scoped to that feature only, not retrofitted onto the other 9 repos.
- **Web-specific behavior**: no `dart:html`/`dart:js`/`kIsWeb`-conditional code anywhere; web support comes entirely from packages' own web implementations. `web/index.html` sets a deprecated `flutterWebRenderer = "html"` flag (likely a no-op on the current SDK). Responsive layout is ad hoc (`MediaQuery.of(context).size.width > 900` checks, e.g. in `Sidebar`), no shared breakpoint constants.
- **Build/deployment**: no CI (`.github/` absent), no `firebase.json`/`.firebaserc` — deploy is manual/undocumented.
- **Security note (pre-existing, not introduced by any one feature)**: `LoginScreen.loginAdmin` (`lib/login/screen/login_screen.dart`) queries Firestore for a document where `admin_password` equals the raw typed password — **plaintext password storage and client-side comparison, no Firebase Auth**. Session is just `sharedPreferences["admin_id"]` (browser localStorage). No hashing anywhere in the codebase prior to the Teacher feature, which introduces client-side SHA-256 hashing (`crypto` package) as a deliberate, explicitly-chosen improvement scoped to itself — not retrofitted onto admin login.

## Important Components (highest fan-in)

| Component | Fan-in | Role |
|---|---|---|
| `lib/resources/constant.dart` | 57 files | Global keys, `sharedPreferences`, Firestore collection-name constants |
| `lib/utils/helper.dart` | 50 files | `Helper.showSnackBarMessage`, `showLoader` |
| `lib/core/widgets/remove_alert.dart` (`RemoveAlert.showRemoveAlert`) | 12+ files | Reusable delete-confirmation dialog (title/description/onPressYes). **Never closes itself** — every caller's `onPressYes` must explicitly `Navigator.pop(context)` to dismiss it. |
| `lib/core/widgets/choose_image.dart` (`ChooseImage`) | 11+ files | Reusable "pick an image" trigger widget (wraps `file_picker`, caller owns the `Uint8List` state and upload). Neither `ChooseImage` nor any existing caller validates file extension/size — `PlatformFile` from `file_picker` exposes `.size` and an extension (via `.name`), but nothing in the codebase reads them before this feature. |
| `lib/core/widgets/loader_dialog.dart` (`LoaderDialogs.showLoadingDialog`) | many | Modal loading-spinner overlay — the codebase's only "loading state" pattern (no skeleton loaders anywhere) |
| `lib/core/widgets/sidebar.dart` + `lib/core/widgets/extra_sidebar.dart` | shell | Two separate, hand-synchronized parallel-array navigation lists — see Navigation/routing above |
| `lib/core/widgets/custom_text_field.dart` (`CustomTextField`) | 21 files | Wraps a bare `TextField` with `labelText` only — **no `helperText`/`errorText` parameter**. Any inline field guidance/errors must be a separate local `Text` widget in the calling screen; there's no shared mechanism. |

## Dependency Knowledge

Actual layering chain used throughout: **Screen (StatefulWidget) → ViewModel (ChangeNotifier via `context.read/watch`) → Repo (direct `FirebaseFirestore`/`FirebaseStorage` calls) → Model (`toMap()`/`fromDocumentSnapshot()`)**. No use-case/domain layer. No API layer (Firestore IS the API). Firestore document shape leaks all the way up to the ViewModel (`Map<String,dynamic>`, `DocumentSnapshot` types appear in ViewModel signatures in some features).

`SubjectRepo`/`SubjectViewModel`/`SubjectList`/`SubjectCard` (`lib/subject/`) is the closest existing template for a new "entity with a photo, add/list/delete" feature — used as the direct basis for the Teacher feature. `SubjectCard` renders its image via `ClipRRect(borderRadius: BorderRadius.circular(25))` + `Image.network(...).errorBuilder`, not `CircleAvatar`.

## Validation Commands

Detected from `pubspec.yaml` (Flutter project, no `package.json`/other stack markers):

```
flutter analyze
flutter test
flutter build web   # only when the change is web-build-relevant
```

No lint auto-fix script or CI config exists; run these manually before every PR.
