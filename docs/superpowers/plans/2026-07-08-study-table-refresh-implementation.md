# Study Table Refresh Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Refresh the study table screen and cards with a game-like presentation while preserving the current study behavior.

**Architecture:** Keep the existing study flow intact and concentrate changes in the screen plus its three supporting widgets. Introduce stronger layout structure, richer visual tokens, and a more expressive hero card while reusing the current timer, swiper, and fun-fact data.

**Tech Stack:** Flutter, Dart, Material 3, flutter_test

## Global Constraints

- No changes to swipe rules or timer behavior.
- No changes to route flow or study logic.
- The direction must stay game-like, energetic, and readable.
- The multiplication card must remain the focal point.
- The screen must stay responsive on small phones.

---

### Task 1: Lock the refreshed study screen structure with tests

**Files:**
- Modify: `test/widgets/study_table_screen_test.dart`
- Modify: `lib/screens/study_table_screen.dart`

**Interfaces:**
- Consumes: `StudyTableScreen(args: StudyTableScreenArguments(tableNumber: int))`
- Produces: a study screen that renders a status HUD, progress label, timer badge, and supporting fact area without changing behavior

- [ ] **Step 1: Write the failing test**

```dart
testWidgets('study screen renders the refreshed game-like HUD', (tester) async {
  SharedPreferences.setMockInitialValues(<String, Object>{
    AppPrefs.studyAutoSwipeSeconds: 8,
  });
  final prefs = await SharedPreferences.getInstance();

  await tester.pumpWidget(
    Provider<TimerSettingsService>.value(
      value: TimerSettingsService(prefs),
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: StudyTableScreen(
          args: StudyTableScreenArguments(tableNumber: 7),
        ),
      ),
    ),
  );

  expect(find.byKey(const Key('study-screen-hud')), findsOneWidget);
  expect(find.byKey(const Key('study-progress-label')), findsOneWidget);
  expect(find.byKey(const Key('study-timer-badge')), findsOneWidget);
  expect(find.byKey(const Key('study-fact-card')), findsOneWidget);
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/widgets/study_table_screen_test.dart`
Expected: FAIL because the new keyed HUD elements do not exist yet.

- [ ] **Step 3: Write minimal implementation**

```dart
Container(
  key: const Key('study-screen-hud'),
  child: Column(
    children: [
      Text('1 of 12', key: const Key('study-progress-label')),
      Container(key: const Key('study-timer-badge')),
    ],
  ),
)
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/widgets/study_table_screen_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add test/widgets/study_table_screen_test.dart lib/screens/study_table_screen.dart
git commit -m "feat: scaffold study mode visual refresh"
```

### Task 2: Redesign the multiplication card and progress indicator

**Files:**
- Modify: `lib/widgets/study_table/multiplication_card.dart`
- Modify: `lib/widgets/study_table/progress_indicator_widget.dart`
- Modify: `lib/screens/study_table_screen.dart`
- Test: `test/widgets/study_table_screen_test.dart`

**Interfaces:**
- Consumes: `MultiplicationCard(equation: String, result: int)` and `ProgressIndicatorWidget(currentIndex: int, totalItems: int)`
- Produces: a hero card with stronger hierarchy and a more expressive progress indicator that still reflects the active card index

- [ ] **Step 1: Write the failing test**

```dart
testWidgets('study screen highlights progress and hero card presentation', (tester) async {
  ...
  expect(find.byKey(const Key('study-hero-card')), findsOneWidget);
  expect(find.byKey(const Key('study-progress-track')), findsOneWidget);
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/widgets/study_table_screen_test.dart`
Expected: FAIL because the hero card and new progress indicator keys do not exist yet.

- [ ] **Step 3: Write minimal implementation**

```dart
return Container(
  key: const Key('study-hero-card'),
  decoration: ...,
  child: ...
);
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/widgets/study_table_screen_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/widgets/study_table/multiplication_card.dart lib/widgets/study_table/progress_indicator_widget.dart lib/screens/study_table_screen.dart test/widgets/study_table_screen_test.dart
git commit -m "feat: redesign study mode hero card"
```

### Task 3: Polish the fact card and final visual layout

**Files:**
- Modify: `lib/widgets/study_table/fun_fact_widget.dart`
- Modify: `lib/screens/study_table_screen.dart`
- Test: `test/widgets/study_table_screen_test.dart`

**Interfaces:**
- Consumes: `FunFactWidget(table: int, multiplier: int)`
- Produces: a supporting fact card and finished screen composition with gradient background and balanced spacing

- [ ] **Step 1: Write the failing test**

```dart
testWidgets('study screen renders the fun fact as a supporting card', (tester) async {
  ...
  expect(find.byKey(const Key('study-fact-card')), findsOneWidget);
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/widgets/study_table_screen_test.dart`
Expected: FAIL because the fact card presentation key does not exist yet.

- [ ] **Step 3: Write minimal implementation**

```dart
Container(
  key: const Key('study-fact-card'),
  decoration: ...,
  child: ...
)
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/widgets/study_table_screen_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/widgets/study_table/fun_fact_widget.dart lib/screens/study_table_screen.dart test/widgets/study_table_screen_test.dart
git commit -m "feat: polish study mode fact card layout"
```

## Self-Review

- Spec coverage: background, HUD, hero card, expressive progress, and fact card are all mapped to tasks.
- Placeholder scan: no TODO or undefined follow-up work left in the plan.
- Type consistency: screen and widget names match the current codebase, and the new keys are consistent across tasks.
