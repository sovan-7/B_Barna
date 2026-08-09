# PRD — Teacher Module-Based Access Control

| | |
|---|---|
| **Feature** | Module Access assignment on Add Teacher, sidebar enforcement for teacher logins |
| **Platform** | Flutter Web (bbarna) |
| **Status** | Draft v1.0 |
| **Date** | 2026-08-09 |
| **Depends on** | Existing Teacher Management feature (`lib/teacher/`, shipped in commit `e105342`) |

---

## 1. Problem

Admin can currently create a teacher (name, image, username, password) but every teacher, once logged in, would see every sidebar module — there is no way to restrict a teacher to only the modules they're supposed to manage. This PRD adds a module-access step to teacher creation and ties it to sidebar rendering.

## 2. Source of truth for module list

The sidebar is defined in `lib/core/widgets/sidebar.dart` (`_SidebarState`). It currently holds **three parallel lists**, all indexed together:

```dart
List<String> drawerItems = [
  "BANNERS", "COURSES", "SUBJECT", "UNIT", "TOPIC",
  "VIDEOS", "PDF", "AUDIO", "QUIZ", "QUESTIONS",
  "STUDENTS", "TEACHERS",
];
List<Widget> screenList = [ BannerList(), CourseList(), SubjectList(), UnitList(),
  TopicList(), VideoList(), PDFList(), AudioList(), QuizList(), QuestionList(),
  StudentList(), TeacherList() ];
List<IconData> iconList = [ ... ];
```

**Correction vs. earlier draft:** the module *names* live in `drawerItems` (`List<String>`), not `screenList` (`List<Widget>`, which holds screen instances, not labels). The checkbox options must be generated from `drawerItems`. `screenList` is referenced here only insofar as its indices line up with `drawerItems` — each drawer label at index *i* maps to the screen widget at `screenList[i]`.

**Correction vs. earlier draft:** the module set is not just Banner/Course/Subject/Unit/Topic. All 12 current entries are candidates: Banners, Courses, Subject, Unit, Topic, Videos, PDF, Audio, Quiz, Questions, Students, Teachers.

**Duplication risk:** `lib/core/widgets/extra_sidebar.dart` (`_ExtraSideBarState`, used for the narrow-viewport drawer) independently redeclares the same `drawerItems` and `iconList` arrays. Any module-access filtering must be applied in both places, or `sidebar.dart`'s list must become the single source that `extra_sidebar.dart` consumes instead of duplicating it — otherwise the two navigation surfaces will drift and a restricted teacher could still reach a module via the narrow-viewport drawer that was hidden in the wide-viewport sidebar.

**Open question:** should `TEACHERS` and `STUDENTS` be assignable to a teacher at all, or excluded from the checkbox list (a teacher managing other teacher accounts is likely unintended)? Flagging for admin decision before implementation.

## 3. Requirements

### 3.1 Add Teacher form — Module Access field

- Add a new required section to `lib/teacher/screen/add_teacher.dart`: a checkbox list, one entry per item in `drawerItems` (icon from `iconList` at the same index for visual parity with the sidebar itself).
- Generated dynamically from `drawerItems` at build time — no hardcoded copy of the module names in the form. If `drawerItems` gains/loses an entry, the checkbox list reflects it automatically on next build.
- At least one module must be checked before `_onSave()` allows submission — same validation pattern as the existing Name/Username/Password checks in `add_teacher.dart:72-140`.

### 3.2 Data model

- `TeacherModel` (`lib/teacher/model/teacher_model.dart`) gains a new field:
  ```dart
  List<String> moduleAccess; // subset of drawerItems values, e.g. ["COURSES", "SUBJECT"]
  ```
- `toMap()` / `fromDocumentSnapshot()` updated to serialize/deserialize `moduleAccess` as a Firestore array field.
- `TeacherRepo.addTeacher()` (`lib/teacher/repo/teacher_repo.dart:44`) persists the selected `moduleAccess` list alongside the existing fields in the same transaction.

### 3.3 Sidebar enforcement

- On teacher login, `Sidebar` (`lib/core/widgets/sidebar.dart`) and `ExtraSideBar` (`lib/core/widgets/extra_sidebar.dart`) must build their `drawerItems`/`screenList`/`iconList` triples filtered down to only the indices present in the logged-in teacher's `moduleAccess`.
- **Blocking dependency:** there is currently no teacher login flow. `lib/login/screen/login_screen.dart` only implements `loginAdmin()` against the `admin` Firestore collection (`login_screen.dart:173-182`) — there is no equivalent `loginTeacher()`, no teacher session storage, and no code path that distinguishes "logged in as teacher" from "logged in as admin." Sidebar filtering cannot be implemented until a teacher-auth/session mechanism exists. This PRD's scope for v1 is therefore:
  - **In scope:** capturing and persisting `moduleAccess` at teacher-creation time (3.1, 3.2).
  - **Out of scope for this PRD, tracked as a follow-up:** actual sidebar filtering at runtime, which requires a teacher login flow first.

### 3.4 Editing module access

- No edit-teacher flow exists yet (confirmed — out of scope per the parent Teacher Management PRD). Until one exists, changing a teacher's module access requires delete + recreate. Flagging as the same open question already raised in the parent PRD (§9.1/§9.7) — worth resolving once, since it affects both name/password edits and module-access edits identically.

## 4. Acceptance Criteria (v1 scope: 3.1 + 3.2 only)

- [ ] Add Teacher form renders one checkbox per entry in `sidebar.dart`'s `drawerItems`, with matching icon.
- [ ] Checkbox list is generated from `drawerItems` at build time, not a hardcoded literal in `add_teacher.dart`.
- [ ] Form blocks submission when zero modules are checked, with a visible validation message (consistent with existing field validation UX).
- [ ] Selected modules are saved to Firestore as `moduleAccess` on the new teacher document.
- [ ] `TeacherModel.fromDocumentSnapshot` round-trips `moduleAccess` correctly (unit test).
- [ ] `TeacherRepo.addTeacher` test coverage extended to assert `moduleAccess` is written.
- [ ] `add_teacher_form_test.dart` extended with: zero-modules-selected rejected, one-or-more-selected accepted.

## 5. Explicitly deferred (needs a separate PRD / follow-up ticket)

- Teacher login/session flow (`loginTeacher`, session storage distinguishing admin vs. teacher).
- Sidebar/drawer filtering by `moduleAccess` at runtime (both `sidebar.dart` and `extra_sidebar.dart`).
- Server-side authorization on module-related Firestore reads/writes based on `moduleAccess` (client-side hiding is UX only, not security).
- Resolving whether `TEACHERS`/`STUDENTS` should be excludable from assignment.
- Edit-teacher flow (to change module access without delete+recreate).
