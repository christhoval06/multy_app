import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multy_app/configs/app_prefs.dart';
import 'package:multy_app/l10n/app_localizations.dart';
import 'package:multy_app/models/profile.dart';
import 'package:multy_app/providers/profile_provider.dart';
import 'package:multy_app/providers/quiz_attemp_provider.dart';
import 'package:multy_app/screens/settings_screen.dart';
import 'package:multy_app/services/feedback_service.dart';
import 'package:multy_app/services/timer_settings_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<void> pumpSettingsApp(
    WidgetTester tester,
    SharedPreferences prefs,
  ) async {
    await FeedbackService.instance.initialize(prefs);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<QuizAttempProvider>(
            create: (_) => _FakeQuizAttempProvider(),
          ),
          ChangeNotifierProvider<ProfileProvider>(
            create: (_) => _FakeProfileProvider(),
          ),
          Provider<TimerSettingsService>.value(
            value: TimerSettingsService(prefs),
          ),
        ],
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: SettingsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('settings toggles feedback preferences and persists them', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();
    await pumpSettingsApp(tester, prefs);

    final context = tester.element(find.byType(SettingsScreen));
    final l10n = AppLocalizations.of(context)!;

    await tester.scrollUntilVisible(find.text(l10n.settingsSoundTitle), 200);
    await tester.ensureVisible(find.text(l10n.settingsSoundTitle));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('settings-feedback-card')), findsOneWidget);
    await tester.tap(find.text(l10n.settingsSoundTitle));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text(l10n.settingsVibrationTitle), 120);
    await tester.ensureVisible(find.text(l10n.settingsVibrationTitle));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.settingsVibrationTitle));
    await tester.pumpAndSettle();

    expect(prefs.getBool(AppPrefs.feedbackSoundEnabled), isFalse);
    expect(prefs.getBool(AppPrefs.feedbackVibrationEnabled), isFalse);
  });

  testWidgets('settings shows a dedicated profiles section', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();
    await pumpSettingsApp(tester, prefs);

    final context = tester.element(find.byType(SettingsScreen));
    final l10n = AppLocalizations.of(context)!;

    expect(find.byKey(const Key('settings-overview-card')), findsOneWidget);
    expect(find.text('Mateo'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const Key('settings-feedback-card')),
      150,
    );
    expect(find.byKey(const Key('settings-feedback-card')), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const Key('settings-manage-profiles-tile')),
      200,
    );

    expect(find.text(l10n.settingsSectionProfiles.toUpperCase()), findsOneWidget);
    expect(find.text(l10n.settingsManageProfilesTitle), findsOneWidget);
    expect(
      find.textContaining(l10n.settingsManageProfilesSubtitle),
      findsOneWidget,
    );
    expect(find.textContaining(l10n.settingsProfilesSummary(2)), findsOneWidget);
    expect(
      find.textContaining(l10n.settingsProfilesActiveSummary('Mateo')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('settings-profiles-badge')), findsOneWidget);
    expect(find.text('2/4'), findsOneWidget);
    expect(find.text('🦁'), findsWidgets);
  });

  testWidgets('settings shows a destructive data management card', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();
    await pumpSettingsApp(tester, prefs);

    final context = tester.element(find.byType(SettingsScreen));
    final l10n = AppLocalizations.of(context)!;

    await tester.scrollUntilVisible(find.text(l10n.settingsDeleteAllDataTitle), 300);

    expect(find.byKey(const Key('settings-delete-data-card')), findsOneWidget);
    expect(find.text(l10n.settingsDeleteAllDataTitle), findsOneWidget);
    expect(find.text(l10n.settingsDeleteProgressSubtitle), findsOneWidget);
  });

  testWidgets('settings persists timer selections and can restore defaults', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();
    await pumpSettingsApp(tester, prefs);

    await tester.scrollUntilVisible(
      find.byKey(const Key('settings-study-timer-tile')),
      200,
    );
    await tester.tap(find.byKey(const Key('settings-study-timer-tile')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('8s').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('settings-quiz-timer-tile')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('60s').last);
    await tester.pumpAndSettle();

    expect(prefs.getInt(AppPrefs.studyAutoSwipeSeconds), 8);
    expect(prefs.getInt(AppPrefs.quizDurationSeconds), 60);

    await tester.tap(find.byKey(const Key('settings-restore-timers-tile')));
    await tester.pumpAndSettle();

    expect(prefs.getInt(AppPrefs.studyAutoSwipeSeconds), 5);
    expect(prefs.getInt(AppPrefs.quizDurationSeconds), 50);
  });

  testWidgets('settings shows persisted timer values on reopen', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      AppPrefs.studyAutoSwipeSeconds: 8,
      AppPrefs.quizDurationSeconds: 60,
    });
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt(AppPrefs.studyAutoSwipeSeconds), 8);
    expect(prefs.getInt(AppPrefs.quizDurationSeconds), 60);
    await pumpSettingsApp(tester, prefs);

    await tester.scrollUntilVisible(
      find.byKey(const Key('settings-study-timer-tile')),
      200,
    );
    expect(find.textContaining('8s'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byKey(const Key('settings-quiz-timer-tile')),
      120,
    );
    expect(find.textContaining('60s'), findsOneWidget);
  });
}

class _FakeQuizAttempProvider extends ChangeNotifier
    implements QuizAttempProvider {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeProfileProvider extends ChangeNotifier implements ProfileProvider {
  final List<Profile> _profiles = <Profile>[
    Profile(
      id: 1,
      name: 'Mateo',
      avatarKey: 'lion',
      colorValue: 0xFF42A5F5,
    ),
    Profile(
      id: 2,
      name: 'Lucia',
      avatarKey: 'fox',
      colorValue: 0xFFF06292,
    ),
  ];

  @override
  Profile? get activeProfile => _profiles.first;

  @override
  bool get hasPersistentSelection => true;

  @override
  bool get hasSelection => true;

  @override
  bool get isGuestSelected => false;

  @override
  bool get isInitialized => true;

  @override
  ProfileSelectionMode get mode => ProfileSelectionMode.persistent;

  @override
  UnmodifiableListView<Profile> get profiles =>
      UnmodifiableListView<Profile>(_profiles);

  @override
  UnmodifiableListView<Profile> get allProfiles =>
      UnmodifiableListView<Profile>(_profiles);

  @override
  int get maxProfiles => 4;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
