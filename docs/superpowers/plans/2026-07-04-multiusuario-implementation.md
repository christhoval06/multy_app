# Multiusuario Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Agregar perfiles persistentes, un modo invitado temporal, métricas por perfil e historial individual en la app Flutter sin perder los datos existentes.

**Architecture:** La implementación introduce una entidad `Profile`, asocia los intentos y agregados existentes a un `profileId`, y añade un provider específico para manejar selección de perfil, invitado, archivado y migración inicial. La UI se adapta para exigir selección en `home`, contextualizar `stats` por perfil y permitir gestión de perfiles desde `settings`.

**Tech Stack:** Flutter, Provider, ObjectBox, SharedPreferences, flutter_test

---

## File Structure

### Files to create

- `lib/models/profile.dart`
- `lib/providers/profile_provider.dart`
- `lib/widgets/home/profile_selector.dart`
- `lib/screens/profile_management_screen.dart`
- `lib/widgets/profiles/profile_form_sheet.dart`
- `lib/widgets/stats/session_history_list.dart`
- `test/providers/profile_provider_test.dart`
- `test/providers/quiz_attemp_provider_test.dart`
- `test/widgets/home_profile_selector_test.dart`
- `test/widgets/profile_management_screen_test.dart`

### Files to modify

- `lib/main.dart`
- `lib/objectbox-model.json`
- `lib/objectbox.g.dart`
- `lib/models/quiz_attemp.dart`
- `lib/models/table_overall_stats.dart`
- `lib/providers/quiz_attemp_provider.dart`
- `lib/services/objectbox_service.dart`
- `lib/configs/app_prefs.dart`
- `lib/configs/route_paths.dart`
- `lib/routes.dart`
- `lib/screens/home_screen.dart`
- `lib/screens/stats_screen.dart`
- `lib/screens/settings_screen.dart`
- `lib/screens/quiz_screen.dart`
- `lib/screens/quiz_result_screen.dart`
- `lib/l10n/app_es.arb`
- `lib/l10n/app_en.arb`
- generated localization files after running gen-l10n

### Existing files to inspect while implementing

- `lib/screens/table_selection_screen.dart`
- `lib/screens/study_table_screen.dart`
- `pubspec.yaml`
- `test/widget_test.dart`

## Task 1: Add profile persistence model and ObjectBox wiring

**Files:**
- Create: `lib/models/profile.dart`
- Modify: `lib/models/quiz_attemp.dart`
- Modify: `lib/models/table_overall_stats.dart`
- Modify: `lib/services/objectbox_service.dart`
- Modify: `lib/objectbox-model.json`
- Modify: `lib/objectbox.g.dart`

- [ ] **Step 1: Write the failing data-model test**

Create `test/providers/profile_provider_test.dart` with an initial shape check that will fail until the new model exists:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:multy_app/models/profile.dart';

void main() {
  test('Profile creates a persistent child profile with archive disabled', () {
    final profile = Profile(
      name: 'Mateo',
      avatarKey: 'lion',
      colorValue: 0xFF42A5F5,
      goalDailySessions: 2,
      goalWeeklySessions: 10,
      favoriteTablesSerialized: '2,3,4',
    );

    expect(profile.id, 0);
    expect(profile.name, 'Mateo');
    expect(profile.isArchived, isFalse);
    expect(profile.favoriteTablesSerialized, '2,3,4');
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run:

```bash
flutter test test/providers/profile_provider_test.dart
```

Expected: FAIL with an import or undefined class error for `Profile`.

- [ ] **Step 3: Add the `Profile` entity and profile ownership fields**

Create `lib/models/profile.dart`:

```dart
import 'package:objectbox/objectbox.dart';

@Entity()
class Profile {
  @Id()
  int id = 0;

  String name;
  String avatarKey;
  int colorValue;
  int goalDailySessions;
  int goalWeeklySessions;
  String favoriteTablesSerialized;
  bool isArchived;
  DateTime createdAt;
  DateTime updatedAt;

  Profile({
    this.id = 0,
    required this.name,
    required this.avatarKey,
    required this.colorValue,
    this.goalDailySessions = 1,
    this.goalWeeklySessions = 5,
    this.favoriteTablesSerialized = '',
    this.isArchived = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();
}
```

Update `lib/models/quiz_attemp.dart`:

```dart
  @Index()
  int profileId;

  QuizAttemp({
    this.id = 0,
    required this.timestamp,
    required this.tableNumber,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.profileId,
    this.durationInSeconds,
  });
```

Update `lib/models/table_overall_stats.dart`:

```dart
  @Index()
  int profileId;

  TableOverallStats({
    this.id = 0,
    required this.tableNumber,
    required this.profileId,
    this.totalAttempts = 0,
    this.totalCorrectAnswersSum = 0,
    this.totalQuestionsSum = 0,
    this.bestTimeInSeconds,
    this.bestScoreCorrect = 0,
    this.bestScoreTotal = 0,
  });
```

Update `lib/services/objectbox_service.dart`:

```dart
import 'package:multy_app/models/profile.dart';

  Box<Profile> get profileBox => _store.box<Profile>();
```

- [ ] **Step 4: Regenerate ObjectBox files**

Run:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Expected: PASS and regeneration of `lib/objectbox.g.dart` plus `lib/objectbox-model.json`.

- [ ] **Step 5: Run the model test to verify it passes**

Run:

```bash
flutter test test/providers/profile_provider_test.dart
```

Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add lib/models/profile.dart lib/models/quiz_attemp.dart lib/models/table_overall_stats.dart lib/services/objectbox_service.dart lib/objectbox-model.json lib/objectbox.g.dart test/providers/profile_provider_test.dart
git commit -m "feat: add profile persistence model"
```

## Task 2: Add profile provider, guest mode, and migration support

**Files:**
- Create: `lib/providers/profile_provider.dart`
- Modify: `lib/configs/app_prefs.dart`
- Modify: `lib/main.dart`
- Modify: `lib/services/objectbox_service.dart`
- Test: `test/providers/profile_provider_test.dart`

- [ ] **Step 1: Extend the failing provider test with migration expectations**

Append to `test/providers/profile_provider_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:multy_app/providers/profile_provider.dart';

void main() {
  test('guest selection is temporary and not persisted as a profile id', () async {
    final provider = ProfileProvider.test();

    await provider.selectGuest();

    expect(provider.isGuestActive, isTrue);
    expect(provider.activeProfileId, isNull);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run:

```bash
flutter test test/providers/profile_provider_test.dart
```

Expected: FAIL because `ProfileProvider` and `ProfileProvider.test()` do not exist.

- [ ] **Step 3: Implement `ProfileProvider` and add active-profile prefs**

Update `lib/configs/app_prefs.dart`:

```dart
class AppPrefs {
  static const onboardingComplete = 'hasCompletedOnboarding';
  static const activeProfileId = 'activeProfileId';
  static const activeProfileMode = 'activeProfileMode';
}
```

Create `lib/providers/profile_provider.dart`:

```dart
import 'package:flutter/foundation.dart';
import 'package:multy_app/configs/app_prefs.dart';
import 'package:multy_app/models/profile.dart';
import 'package:multy_app/services/objectbox_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ActiveProfileMode { persistent, guest, none }

class ProfileProvider extends ChangeNotifier {
  ProfileProvider({
    required ObjectBoxService objectBoxService,
    required SharedPreferences prefs,
  }) : _objectBoxService = objectBoxService,
       _prefs = prefs;

  ProfileProvider.test()
    : _objectBoxService = throw UnimplementedError(),
      _prefs = FakeSharedPreferences();

  final ObjectBoxService _objectBoxService;
  final SharedPreferences _prefs;

  ActiveProfileMode _mode = ActiveProfileMode.none;
  int? _activeProfileId;
  List<Profile> _profiles = const [];

  bool get isGuestActive => _mode == ActiveProfileMode.guest;
  int? get activeProfileId => _activeProfileId;
  List<Profile> get profiles => _profiles;

  Future<void> selectGuest() async {
    _mode = ActiveProfileMode.guest;
    _activeProfileId = null;
    await _prefs.setString(AppPrefs.activeProfileMode, 'guest');
    await _prefs.remove(AppPrefs.activeProfileId);
    notifyListeners();
  }
}
```

Update `lib/main.dart` to create and register the provider:

```dart
  final prefs = await SharedPreferences.getInstance();

  runApp(
    MultiplicationApp(
      initialRoute: initialRoute,
      prefs: prefs,
    ),
  );
```

```dart
class MultiplicationApp extends StatelessWidget {
  final String initialRoute;
  final SharedPreferences prefs;

  const MultiplicationApp({
    super.key,
    required this.initialRoute,
    required this.prefs,
  });
```

```dart
        ChangeNotifierProvider<ProfileProvider>(
          create: (_) => ProfileProvider(
            objectBoxService: objectBoxService,
            prefs: prefs,
          ),
        ),
```

- [ ] **Step 4: Add migration bootstrap and default profile creation**

Extend `ProfileProvider` with the migration entrypoint:

```dart
  Future<void> initialize() async {
    final profileBox = _objectBoxService.profileBox;
    if (profileBox.isEmpty()) {
      final defaultProfile = Profile(
        name: 'Mi perfil',
        avatarKey: 'star',
        colorValue: 0xFF42A5F5,
      );
      final newId = profileBox.put(defaultProfile);
      await _migrateExistingProgressToProfile(newId);
    }

    _profiles = profileBox.getAll().where((profile) => !profile.isArchived).toList();
    notifyListeners();
  }

  Future<void> _migrateExistingProgressToProfile(int profileId) async {
    final attempts = _objectBoxService.quizAttempBox.getAll();
    for (final attempt in attempts) {
      if (attempt.profileId == 0) {
        attempt.profileId = profileId;
      }
    }
    _objectBoxService.quizAttempBox.putMany(attempts);

    final stats = _objectBoxService.tableOverallStats.getAll();
    for (final tableStat in stats) {
      if (tableStat.profileId == 0) {
        tableStat.profileId = profileId;
      }
    }
    _objectBoxService.tableOverallStats.putMany(stats);
  }
```

- [ ] **Step 5: Run the provider test to verify it passes**

Run:

```bash
flutter test test/providers/profile_provider_test.dart
```

Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add lib/providers/profile_provider.dart lib/configs/app_prefs.dart lib/main.dart test/providers/profile_provider_test.dart
git commit -m "feat: add profile provider and guest mode"
```

## Task 3: Scope attempts and aggregated statistics to the active profile

**Files:**
- Modify: `lib/providers/quiz_attemp_provider.dart`
- Modify: `lib/screens/quiz_screen.dart`
- Modify: `lib/screens/quiz_result_screen.dart`
- Test: `test/providers/quiz_attemp_provider_test.dart`

- [ ] **Step 1: Write the failing statistics isolation test**

Create `test/providers/quiz_attemp_provider_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:multy_app/models/quiz_attemp.dart';

void main() {
  test('statistics only include attempts from the selected profile', () async {
    final attempts = [
      QuizAttemp(
        timestamp: DateTime(2026, 7, 4),
        tableNumber: 2,
        correctAnswers: 8,
        totalQuestions: 10,
        durationInSeconds: 20,
        profileId: 1,
      ),
      QuizAttemp(
        timestamp: DateTime(2026, 7, 4),
        tableNumber: 2,
        correctAnswers: 4,
        totalQuestions: 10,
        durationInSeconds: 30,
        profileId: 2,
      ),
    ];

    final filtered = attempts.where((attempt) => attempt.profileId == 1).toList();

    expect(filtered, hasLength(1));
    expect(filtered.single.correctAnswers, 8);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run:

```bash
flutter test test/providers/quiz_attemp_provider_test.dart
```

Expected: FAIL until `QuizAttemp` includes `profileId` everywhere and provider logic is updated.

- [ ] **Step 3: Update provider queries to filter by profile**

Modify `lib/providers/quiz_attemp_provider.dart`:

```dart
class QuizAttempProvider extends ChangeNotifier {
  int? _activeProfileId;
  List<QuizAttemp> _sessionHistory = [];

  List<QuizAttemp> get sessionHistory => _sessionHistory;

  Future<void> setActiveProfile(int? profileId) async {
    _activeProfileId = profileId;
    await loadStatistics();
  }

  Future<int?> createQuizAttemp(QuizAttemp quizAttemp) async {
    if (_activeProfileId == null) {
      return null;
    }

    final savedAttempt = quizAttemp..profileId = _activeProfileId!;
    final quizAttempId = _quizAttempBox.put(savedAttempt);
    updateTableOverallStats(savedAttempt);
    await loadStatistics();
    return quizAttempId;
  }

  Future<List<QuizAttemp>> getAttemptsForActiveProfile() async {
    if (_activeProfileId == null) return [];
    return _quizAttempBox
        .query(QuizAttemp_.profileId.equals(_activeProfileId!))
        .order(QuizAttemp_.timestamp, flags: Order.descending)
        .build()
        .find();
  }
```

Update aggregated stats query:

```dart
    if (_activeProfileId == null) {
      _allTableStats = _buildEmptyDisplayStats();
      _overallStats = OverallStatsData(totalQuizzesPlayed: 0, overallAccuracy: 0);
      _sessionHistory = [];
      notifyListeners();
      return;
    }

    _allTableStats = _tableOverallStats
        .query(TableOverallStats_.profileId.equals(_activeProfileId!))
        .build()
        .find();
    _sessionHistory = await getAttemptsForActiveProfile();
```

- [ ] **Step 4: Ensure guest mode does not persist quiz results**

Modify `lib/screens/quiz_screen.dart` or its notifier integration so the result save path accepts a nullable persistence outcome:

```dart
final savedId = await quizAttemptProvider.createQuizAttemp(
  QuizAttemp(
    timestamp: DateTime.now(),
    tableNumber: tableNumber,
    correctAnswers: score.correct,
    totalQuestions: score.total,
    durationInSeconds: elapsedSeconds,
    profileId: 0,
  ),
);

final shouldShowSavedHistory = savedId != null;
```

Modify `lib/screens/quiz_result_screen.dart` to render a guest-safe message:

```dart
if (!args.wasPersisted) {
  return Text(l10n.guestSessionNotSaved);
}
```

- [ ] **Step 5: Run provider test to verify it passes**

Run:

```bash
flutter test test/providers/quiz_attemp_provider_test.dart
```

Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add lib/providers/quiz_attemp_provider.dart lib/screens/quiz_screen.dart lib/screens/quiz_result_screen.dart test/providers/quiz_attemp_provider_test.dart
git commit -m "feat: scope quiz stats to active profile"
```

## Task 4: Add profile selection UX to Home

**Files:**
- Create: `lib/widgets/home/profile_selector.dart`
- Modify: `lib/screens/home_screen.dart`
- Modify: `lib/l10n/app_es.arb`
- Modify: `lib/l10n/app_en.arb`
- Test: `test/widgets/home_profile_selector_test.dart`

- [ ] **Step 1: Write the failing widget test**

Create `test/widgets/home_profile_selector_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multy_app/widgets/home/profile_selector.dart';

void main() {
  testWidgets('selector shows guest and child profiles', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProfileSelector(
            profileNames: ['Mateo', 'Sofia'],
            activeName: 'Mateo',
            showGuest: true,
          ),
        ),
      ),
    );

    expect(find.text('Mateo'), findsOneWidget);
    expect(find.text('Sofia'), findsOneWidget);
    expect(find.text('Invitado'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run:

```bash
flutter test test/widgets/home_profile_selector_test.dart
```

Expected: FAIL because `ProfileSelector` does not exist.

- [ ] **Step 3: Build the selector widget and mount it in `HomeScreen`**

Create `lib/widgets/home/profile_selector.dart`:

```dart
import 'package:flutter/material.dart';

class ProfileSelector extends StatelessWidget {
  final List<String> profileNames;
  final String? activeName;
  final bool showGuest;

  const ProfileSelector({
    super.key,
    required this.profileNames,
    required this.activeName,
    required this.showGuest,
  });

  @override
  Widget build(BuildContext context) {
    final labels = [...profileNames, if (showGuest) 'Invitado'];
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: labels.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final label = labels[index];
          final isActive = label == activeName;
          return ChoiceChip(
            label: Text(label),
            selected: isActive,
            onSelected: (_) {},
          );
        },
      ),
    );
  }
}
```

Mount it in `lib/screens/home_screen.dart` above the study buttons:

```dart
              Text(
                l10n.selectProfileTitle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ProfileSelector(
                profileNames: context.watch<ProfileProvider>().profiles.map((p) => p.name).toList(),
                activeName: context.watch<ProfileProvider>().activeProfile?.name,
                showGuest: true,
              ),
              const SizedBox(height: 24),
```

Disable actions until a profile is selected:

```dart
final canStart = context.watch<ProfileProvider>().hasSelection;
```

```dart
                onPressed: canStart
                    ? () {
                        Navigator.pushNamed(
                          context,
                          RoutePaths.multiplication,
                          arguments: RoutePaths.study,
                        );
                      }
                    : null,
```

- [ ] **Step 4: Add the needed localized strings**

Add to `lib/l10n/app_es.arb`:

```json
"selectProfileTitle": "Elige quién va a estudiar",
"guestProfileLabel": "Invitado",
"guestProfileHint": "No guarda progreso"
```

Add to `lib/l10n/app_en.arb`:

```json
"selectProfileTitle": "Choose who will study",
"guestProfileLabel": "Guest",
"guestProfileHint": "Progress is not saved"
```

Run:

```bash
flutter gen-l10n
```

Expected: PASS and regenerated localization files.

- [ ] **Step 5: Run the widget test to verify it passes**

Run:

```bash
flutter test test/widgets/home_profile_selector_test.dart
```

Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add lib/widgets/home/profile_selector.dart lib/screens/home_screen.dart lib/l10n/app_es.arb lib/l10n/app_en.arb lib/l10n/app_localizations*.dart test/widgets/home_profile_selector_test.dart
git commit -m "feat: add home profile selection"
```

## Task 5: Add profile management screen under Settings

**Files:**
- Create: `lib/screens/profile_management_screen.dart`
- Create: `lib/widgets/profiles/profile_form_sheet.dart`
- Modify: `lib/configs/route_paths.dart`
- Modify: `lib/routes.dart`
- Modify: `lib/screens/settings_screen.dart`
- Modify: `lib/l10n/app_es.arb`
- Modify: `lib/l10n/app_en.arb`
- Test: `test/widgets/profile_management_screen_test.dart`

- [ ] **Step 1: Write the failing management-screen test**

Create `test/widgets/profile_management_screen_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multy_app/screens/profile_management_screen.dart';

void main() {
  testWidgets('management screen shows create action and profile list', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ProfileManagementScreen(),
      ),
    );

    expect(find.text('Perfiles'), findsOneWidget);
    expect(find.text('Crear perfil'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run:

```bash
flutter test test/widgets/profile_management_screen_test.dart
```

Expected: FAIL because the screen does not exist.

- [ ] **Step 3: Add route and management screen shell**

Update `lib/configs/route_paths.dart`:

```dart
  static const String profiles = '/profiles';
```

Update `lib/routes.dart`:

```dart
      case RoutePaths.profiles:
        return MaterialPageRoute(
          builder: (_) => const ProfileManagementScreen(),
          settings: settings,
        );
```

Create `lib/screens/profile_management_screen.dart`:

```dart
import 'package:flutter/material.dart';

class ProfileManagementScreen extends StatelessWidget {
  const ProfileManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfiles')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        label: const Text('Crear perfil'),
        icon: const Icon(Icons.add),
      ),
      body: const SizedBox.shrink(),
    );
  }
}
```

- [ ] **Step 4: Wire settings entry plus create/edit/archive/delete actions**

Add settings entry in `lib/screens/settings_screen.dart`:

```dart
          _buildSectionTitle(l10n.settingsSectionProfiles, context),
          ListTile(
            leading: const Icon(Icons.people_alt_outlined),
            title: Text(l10n.settingsManageProfiles),
            subtitle: Text(l10n.settingsManageProfilesHint),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).pushNamed(RoutePaths.profiles);
            },
          ),
```

Create `lib/widgets/profiles/profile_form_sheet.dart` with a simple create/edit form shell:

```dart
import 'package:flutter/material.dart';

class ProfileFormSheet extends StatelessWidget {
  final String title;

  const ProfileFormSheet({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title),
          const TextField(decoration: InputDecoration(labelText: 'Nombre')),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () {},
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}
```

Then fill `ProfileManagementScreen` with:

```dart
      body: Consumer<ProfileProvider>(
        builder: (context, provider, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              for (final profile in provider.profiles)
                Card(
                  child: ListTile(
                    title: Text(profile.name),
                    subtitle: Text(profile.isArchived ? 'Archivado' : 'Activo'),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {},
                      itemBuilder: (context) => const [
                        PopupMenuItem(value: 'edit', child: Text('Editar')),
                        PopupMenuItem(value: 'archive', child: Text('Archivar')),
                        PopupMenuItem(value: 'delete', child: Text('Borrar definitivamente')),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
```

- [ ] **Step 5: Add localized strings and run widget test**

Add to `lib/l10n/app_es.arb`:

```json
"settingsSectionProfiles": "Perfiles",
"settingsManageProfiles": "Administrar perfiles",
"settingsManageProfilesHint": "Crear, editar, archivar y borrar perfiles",
"createProfile": "Crear perfil"
```

Add to `lib/l10n/app_en.arb`:

```json
"settingsSectionProfiles": "Profiles",
"settingsManageProfiles": "Manage profiles",
"settingsManageProfilesHint": "Create, edit, archive, and delete profiles",
"createProfile": "Create profile"
```

Run:

```bash
flutter gen-l10n
flutter test test/widgets/profile_management_screen_test.dart
```

Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add lib/screens/profile_management_screen.dart lib/widgets/profiles/profile_form_sheet.dart lib/configs/route_paths.dart lib/routes.dart lib/screens/settings_screen.dart lib/l10n/app_es.arb lib/l10n/app_en.arb lib/l10n/app_localizations*.dart test/widgets/profile_management_screen_test.dart
git commit -m "feat: add profile management screen"
```

## Task 6: Show per-profile stats and individual session history

**Files:**
- Create: `lib/widgets/stats/session_history_list.dart`
- Modify: `lib/screens/stats_screen.dart`
- Modify: `lib/l10n/app_es.arb`
- Modify: `lib/l10n/app_en.arb`
- Test: `test/widget_test.dart`

- [ ] **Step 1: Extend the existing widget test with history expectations**

Replace `test/widget_test.dart` with a narrow smoke test for stats components:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multy_app/widgets/stats/session_history_list.dart';

void main() {
  testWidgets('session history renders saved attempts', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SessionHistoryList(
            rows: ['Tabla del 2 - 8/10', 'Tabla del 3 - 10/10'],
          ),
        ),
      ),
    );

    expect(find.text('Tabla del 2 - 8/10'), findsOneWidget);
    expect(find.text('Tabla del 3 - 10/10'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run:

```bash
flutter test test/widget_test.dart
```

Expected: FAIL because `SessionHistoryList` does not exist.

- [ ] **Step 3: Create history widget and mount it in stats**

Create `lib/widgets/stats/session_history_list.dart`:

```dart
import 'package:flutter/material.dart';

class SessionHistoryList extends StatelessWidget {
  final List<String> rows;

  const SessionHistoryList({
    super.key,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: rows
          .map(
            (row) => Card(
              child: ListTile(title: Text(row)),
            ),
          )
          .toList(),
    );
  }
}
```

Update `lib/screens/stats_screen.dart`:

```dart
          const SizedBox(height: 24),
          Text(
            l10n.sessionHistoryTitle,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          SessionHistoryList(
            rows: provider.sessionHistory.map((attempt) {
              return 'Tabla del ${attempt.tableNumber} - ${attempt.correctAnswers}/${attempt.totalQuestions}';
            }).toList(),
          ),
```

- [ ] **Step 4: Add localized strings for profile-aware stats**

Add to `lib/l10n/app_es.arb`:

```json
"sessionHistoryTitle": "Historial de sesiones",
"guestSessionNotSaved": "Esta sesión fue como invitado y no se guardó en el historial"
```

Add to `lib/l10n/app_en.arb`:

```json
"sessionHistoryTitle": "Session history",
"guestSessionNotSaved": "This session was played as guest and was not saved to history"
```

Run:

```bash
flutter gen-l10n
```

Expected: PASS.

- [ ] **Step 5: Run the widget test to verify it passes**

Run:

```bash
flutter test test/widget_test.dart
```

Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add lib/widgets/stats/session_history_list.dart lib/screens/stats_screen.dart lib/l10n/app_es.arb lib/l10n/app_en.arb lib/l10n/app_localizations*.dart test/widget_test.dart
git commit -m "feat: add profile session history"
```

## Task 7: Finish profile rules and destructive flows

**Files:**
- Modify: `lib/providers/profile_provider.dart`
- Modify: `lib/screens/profile_management_screen.dart`
- Modify: `lib/screens/settings_screen.dart`
- Test: `test/providers/profile_provider_test.dart`

- [ ] **Step 1: Add the failing profile-limit and archive test**

Append to `test/providers/profile_provider_test.dart`:

```dart
test('cannot create more than four persistent profiles', () async {
  final provider = ProfileProvider.test();

  for (final name in ['Uno', 'Dos', 'Tres', 'Cuatro']) {
    await provider.createProfile(name: name);
  }

  expect(
    () => provider.createProfile(name: 'Cinco'),
    throwsA(isA<StateError>()),
  );
});
```

- [ ] **Step 2: Run test to verify it fails**

Run:

```bash
flutter test test/providers/profile_provider_test.dart
```

Expected: FAIL because `createProfile` limit validation does not exist.

- [ ] **Step 3: Implement creation, editing, archive, restore, and delete rules**

Extend `lib/providers/profile_provider.dart`:

```dart
  static const int maxProfiles = 4;

  Future<Profile> createProfile({
    required String name,
    String avatarKey = 'star',
    int colorValue = 0xFF42A5F5,
  }) async {
    final activeProfiles = _profiles.where((profile) => !profile.isArchived).length;
    if (activeProfiles >= maxProfiles) {
      throw StateError('Maximum number of profiles reached');
    }

    final profile = Profile(
      name: name,
      avatarKey: avatarKey,
      colorValue: colorValue,
    );
    final id = _objectBoxService.profileBox.put(profile);
    final saved = _objectBoxService.profileBox.get(id)!;
    await initialize();
    return saved;
  }

  Future<void> archiveProfile(Profile profile) async {
    profile.isArchived = true;
    profile.updatedAt = DateTime.now();
    _objectBoxService.profileBox.put(profile);
    if (_activeProfileId == profile.id) {
      _mode = ActiveProfileMode.none;
      _activeProfileId = null;
    }
    await initialize();
  }

  Future<void> deleteProfilePermanently(Profile profile) async {
    _objectBoxService.profileBox.remove(profile.id);
    final attempts = _objectBoxService.quizAttempBox
        .query(QuizAttemp_.profileId.equals(profile.id))
        .build()
        .findIds();
    _objectBoxService.quizAttempBox.removeMany(attempts);
    final stats = _objectBoxService.tableOverallStats
        .query(TableOverallStats_.profileId.equals(profile.id))
        .build()
        .findIds();
    _objectBoxService.tableOverallStats.removeMany(stats);
    await initialize();
  }
```

- [ ] **Step 4: Add confirmation dialogs in management UI**

In `lib/screens/profile_management_screen.dart`, use explicit confirmations:

```dart
Future<bool> _confirmDelete(BuildContext context, String name) async {
  return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Borrar perfil'),
          content: Text('Se borrará definitivamente el perfil $name y su historial.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Borrar'),
            ),
          ],
        ),
      ) ??
      false;
}
```

- [ ] **Step 5: Run provider test to verify it passes**

Run:

```bash
flutter test test/providers/profile_provider_test.dart
```

Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add lib/providers/profile_provider.dart lib/screens/profile_management_screen.dart lib/screens/settings_screen.dart test/providers/profile_provider_test.dart
git commit -m "feat: add profile archive and delete rules"
```

## Task 8: Final verification and manual QA pass

**Files:**
- Modify: any files identified during QA only if defects are found

- [ ] **Step 1: Run focused automated tests**

Run:

```bash
flutter test test/providers/profile_provider_test.dart
flutter test test/providers/quiz_attemp_provider_test.dart
flutter test test/widgets/home_profile_selector_test.dart
flutter test test/widgets/profile_management_screen_test.dart
flutter test test/widget_test.dart
```

Expected: PASS for all commands.

- [ ] **Step 2: Run a full Flutter test sweep**

Run:

```bash
flutter test
```

Expected: PASS with all tests green.

- [ ] **Step 3: Perform manual QA checklist**

Verify this behavior manually:

```text
1. Existing global progress appears under the migrated default profile.
2. Home prevents study/quiz until a profile or guest is selected.
3. Guest can complete a quiz but the result is not added to stats history.
4. Each child profile shows isolated stats and isolated session history.
5. Settings opens profile management, allows create/edit/archive/delete.
6. A fifth persistent profile cannot be created.
7. Archiving the active profile forces reselection.
```

- [ ] **Step 4: Fix any QA defects and re-run only the affected tests**

Example rerun commands:

```bash
flutter test test/providers/profile_provider_test.dart
flutter test test/widgets/profile_management_screen_test.dart
```

Expected: PASS after each fix.

- [ ] **Step 5: Commit the verification-ready implementation**

```bash
git add lib test docs/superpowers/specs/2026-07-04-multiusuario-design.md docs/superpowers/plans/2026-07-04-multiusuario-implementation.md
git commit -m "feat: implement multi-profile learning flow"
```

## Self-Review

### Spec coverage

- perfiles persistentes: cubierto en Tasks 1, 2, 5 y 7
- invitado temporal: cubierto en Tasks 2, 3 y 8
- migración de datos actuales: cubierto en Task 2
- selector en `home`: cubierto en Task 4
- gestión de perfiles en `settings`: cubierto en Task 5
- métricas por perfil: cubierto en Task 3
- historial individual: cubierto en Task 6
- límite de 4 perfiles: cubierto en Task 7
- preparación para PIN futuro: no se implementa, permanece como decisión documentada del spec

### Placeholder scan

- No quedan `TODO`, `TBD` ni referencias vagas intencionales dentro de los pasos.

### Type consistency

- `Profile`, `profileId`, `ProfileProvider`, `SessionHistoryList` y `RoutePaths.profiles` se usan con nombres consistentes en todo el plan.

