# Timer Settings Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add configurable study and quiz timers in settings, persist them with defaults, and apply them consistently across the app.

**Architecture:** Keep default values centralized in `lib/configs/settings.dart`, preference keys in `lib/configs/app_prefs.dart`, and persistence in a focused settings service that wraps `SharedPreferences`. Read the persisted values from `SettingsScreen`, `StudyTableScreen`, and `QuizNotifier` so the UI, timers, and saved durations stay in sync.

**Tech Stack:** Flutter, Dart, Provider, SharedPreferences, Flutter widget tests

## Global Constraints

- Use fixed options instead of sliders.
- Study auto-advance options must be `3s`, `5s`, `8s` with default `5s`.
- Quiz duration options must be `30s`, `50s`, `60s` with default `50s`.
- Add a restore-defaults action in settings.
- Persist values with `SharedPreferences`.
- Fall back to defaults when saved values are missing or invalid.
- Preserve existing sound and vibration settings behavior.

---

### Task 1: Add timer settings persistence

**Files:**
- Modify: `lib/configs/settings.dart`
- Modify: `lib/configs/app_prefs.dart`
- Create: `lib/services/timer_settings_service.dart`
- Test: `test/services/timer_settings_service_test.dart`

**Interfaces:**
- Consumes: `SharedPreferences`
- Produces: `TimerSettingsService.readStudyAutoSwipeSeconds() -> int`, `TimerSettingsService.readQuizDurationSeconds() -> int`, `TimerSettingsService.updateStudyAutoSwipeSeconds(int value) -> Future<void>`, `TimerSettingsService.updateQuizDurationSeconds(int value) -> Future<void>`, `TimerSettingsService.restoreDefaults() -> Future<void>`

- [ ] **Step 1: Write the failing test**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:multy_app/configs/settings.dart';
import 'package:multy_app/services/timer_settings_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('timer settings service returns defaults and rejects invalid values', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'studyAutoSwipeSeconds': 99,
      'quizDurationSeconds': 99,
    });

    final prefs = await SharedPreferences.getInstance();
    final service = TimerSettingsService(prefs);

    expect(service.readStudyAutoSwipeSeconds(), Settings.defaultStudyAutoSwipeSeconds);
    expect(service.readQuizDurationSeconds(), Settings.defaultQuizDurationSeconds);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/services/timer_settings_service_test.dart`
Expected: FAIL because `TimerSettingsService` and new `Settings` members do not exist yet.

- [ ] **Step 3: Write minimal implementation**

```dart
class Settings {
  static const int defaultStudyAutoSwipeSeconds = 5;
  static const int defaultQuizDurationSeconds = 50;
  static const List<int> studyAutoSwipeOptions = <int>[3, 5, 8];
  static const List<int> quizDurationOptions = <int>[30, 50, 60];
}

class TimerSettingsService {
  TimerSettingsService(this._prefs);

  final SharedPreferences _prefs;

  int readStudyAutoSwipeSeconds() {
    final value = _prefs.getInt(AppPrefs.studyAutoSwipeSeconds);
    return Settings.studyAutoSwipeOptions.contains(value)
        ? value!
        : Settings.defaultStudyAutoSwipeSeconds;
  }

  int readQuizDurationSeconds() {
    final value = _prefs.getInt(AppPrefs.quizDurationSeconds);
    return Settings.quizDurationOptions.contains(value)
        ? value!
        : Settings.defaultQuizDurationSeconds;
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/services/timer_settings_service_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/configs/settings.dart lib/configs/app_prefs.dart lib/services/timer_settings_service.dart test/services/timer_settings_service_test.dart
git commit -m "feat: add persisted timer settings service"
```

### Task 2: Add settings UI for timer preferences

**Files:**
- Modify: `lib/screens/settings_screen.dart`
- Modify: `lib/l10n/app_en.arb`
- Modify: `lib/l10n/app_es.arb`
- Modify: `lib/l10n/app_localizations.dart`
- Modify: `lib/l10n/app_localizations_en.dart`
- Modify: `lib/l10n/app_localizations_es.dart`
- Test: `test/widgets/settings_screen_test.dart`

**Interfaces:**
- Consumes: `TimerSettingsService`, `Settings.studyAutoSwipeOptions`, `Settings.quizDurationOptions`
- Produces: settings rows keyed for tests and a restore-defaults action that updates persisted values and visible subtitles immediately

- [ ] **Step 1: Write the failing test**

```dart
testWidgets('settings persists timer selections and can restore defaults', (tester) async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  final prefs = await SharedPreferences.getInstance();
  await FeedbackService.instance.initialize(prefs);

  await tester.pumpWidget(buildSettingsTestApp());
  await tester.pumpAndSettle();

  await tester.scrollUntilVisible(find.byKey(const Key('settings-study-timer-tile')), 200);
  await tester.tap(find.byKey(const Key('settings-study-timer-tile')));
  await tester.pumpAndSettle();
  await tester.tap(find.text('8s').last);
  await tester.pumpAndSettle();

  await tester.tap(find.byKey(const Key('settings-quiz-timer-tile')));
  await tester.pumpAndSettle();
  await tester.tap(find.text('60s').last);
  await tester.pumpAndSettle();

  expect(prefs.getInt('studyAutoSwipeSeconds'), 8);
  expect(prefs.getInt('quizDurationSeconds'), 60);

  await tester.tap(find.byKey(const Key('settings-restore-timers-tile')));
  await tester.pumpAndSettle();

  expect(prefs.getInt('studyAutoSwipeSeconds'), 5);
  expect(prefs.getInt('quizDurationSeconds'), 50);
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/widgets/settings_screen_test.dart`
Expected: FAIL because the timer settings rows and restore action do not exist yet.

- [ ] **Step 3: Write minimal implementation**

```dart
ListTile(
  key: const Key('settings-study-timer-tile'),
  leading: const Icon(Icons.style_outlined),
  title: Text(l10n.settingsStudyTimerTitle),
  subtitle: Text(l10n.settingsTimerSecondsLabel(_studyAutoSwipeSeconds)),
  onTap: () => _selectStudyTimer(),
),
ListTile(
  key: const Key('settings-quiz-timer-tile'),
  leading: const Icon(Icons.timer_outlined),
  title: Text(l10n.settingsQuizTimerTitle),
  subtitle: Text(l10n.settingsTimerSecondsLabel(_quizDurationSeconds)),
  onTap: () => _selectQuizTimer(),
),
ListTile(
  key: const Key('settings-restore-timers-tile'),
  leading: const Icon(Icons.restart_alt),
  title: Text(l10n.settingsRestoreTimerDefaultsTitle),
  onTap: _restoreTimerDefaults,
),
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/widgets/settings_screen_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/screens/settings_screen.dart lib/l10n/app_en.arb lib/l10n/app_es.arb lib/l10n/app_localizations.dart lib/l10n/app_localizations_en.dart lib/l10n/app_localizations_es.dart test/widgets/settings_screen_test.dart
git commit -m "feat: add timer controls to settings"
```

### Task 3: Apply persisted values to study and quiz flows

**Files:**
- Modify: `lib/screens/study_table_screen.dart`
- Modify: `lib/providers/quiz_notifier.dart`
- Create or Modify: `test/providers/quiz_notifier_test.dart`

**Interfaces:**
- Consumes: `TimerSettingsService.readStudyAutoSwipeSeconds()`, `TimerSettingsService.readQuizDurationSeconds()`
- Produces: study timers that use the persisted interval and quiz timers/duration tracking that use the persisted duration everywhere

- [ ] **Step 1: Write the failing test**

```dart
test('quiz notifier uses persisted quiz duration for initial and reset state', () async {
  SharedPreferences.setMockInitialValues(<String, Object>{
    'quizDurationSeconds': 60,
  });
  final prefs = await SharedPreferences.getInstance();
  final notifier = QuizNotifier(
    quizAttempProvider: fakeQuizAttempProvider,
    tableNumber: 7,
    timerSettingsService: TimerSettingsService(prefs),
  );

  expect(notifier.remainingSeconds, 60);

  notifier.resetQuiz();

  expect(notifier.remainingSeconds, 60);
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/providers/quiz_notifier_test.dart`
Expected: FAIL because `QuizNotifier` does not yet accept the timer settings service or use persisted values.

- [ ] **Step 3: Write minimal implementation**

```dart
class QuizNotifier extends ChangeNotifier {
  QuizNotifier({
    required this.quizAttempProvider,
    required this.tableNumber,
    required this.timerSettingsService,
  }) : _quizDurationSeconds = timerSettingsService.readQuizDurationSeconds() {
    _remainingSeconds = _quizDurationSeconds;
    resetQuiz();
  }

  final TimerSettingsService timerSettingsService;
  int _quizDurationSeconds;

  void resetQuiz() {
    _quizDurationSeconds = timerSettingsService.readQuizDurationSeconds();
    _remainingSeconds = _quizDurationSeconds;
    ...
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/providers/quiz_notifier_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/screens/study_table_screen.dart lib/providers/quiz_notifier.dart test/providers/quiz_notifier_test.dart
git commit -m "feat: apply timer settings to study and quiz flows"
```

## Self-Review

- Spec coverage: persistence, defaults, settings UI, restore action, study integration, quiz integration, and testing are all mapped to tasks.
- Placeholder scan: no `TODO`, `TBD`, or undefined follow-up work left in the plan.
- Type consistency: `TimerSettingsService` method names and `Settings` constants are used consistently across tasks.
