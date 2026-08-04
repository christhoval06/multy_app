import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multy_app/configs/app_prefs.dart';
import 'package:multy_app/l10n/app_localizations.dart';
import 'package:multy_app/screens/study_table_screen.dart';
import 'package:multy_app/services/timer_settings_service.dart';
import 'package:multy_app/widgets/study_table/multiplication_card.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('study screen shows persisted auto-swipe timer value on first render', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      AppPrefs.studyAutoSwipeSeconds: 8,
    });
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt(AppPrefs.studyAutoSwipeSeconds), 8);

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

    expect(find.text('8s'), findsOneWidget);
  });

  testWidgets('study screen renders the refreshed game-like HUD', (
    tester,
  ) async {
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
    expect(find.byKey(const Key('study-appbar-title')), findsOneWidget);
    expect(find.byKey(const Key('study-progress-label')), findsOneWidget);
    expect(find.byKey(const Key('study-timer-badge')), findsOneWidget);
    expect(find.byKey(const Key('study-hero-card')), findsOneWidget);
    expect(find.byKey(const Key('study-progress-track')), findsOneWidget);
    expect(find.byKey(const Key('study-fact-card')), findsOneWidget);
  });

  testWidgets('multiplication card does not overflow at 296x301', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 296,
              height: 301,
              child: MultiplicationCard(
                equation: '7 x 12 = 84',
                result: 84,
                accentLabel: 'x7',
                isPrimary: true,
              ),
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'multiplication card does not overflow with larger text scale at 296x301',
    (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            textScaler: TextScaler.linear(1.3),
          ),
          child: const MaterialApp(
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 296,
                  height: 301,
                  child: MultiplicationCard(
                    equation: '7 x 12 = 84',
                    result: 84,
                    accentLabel: 'x7',
                    isPrimary: true,
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'multiplication card does not overflow in spacious mode with larger text scale',
    (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            textScaler: TextScaler.linear(1.3),
          ),
          child: const MaterialApp(
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 340,
                  height: 340,
                  child: MultiplicationCard(
                    equation: '7 x 12 = 84',
                    result: 84,
                    accentLabel: 'x7',
                    isPrimary: true,
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    },
  );
}
