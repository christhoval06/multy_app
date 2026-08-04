import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multy_app/l10n/app_localizations.dart';
import 'package:multy_app/models/profile.dart';
import 'package:multy_app/providers/profile_provider.dart';
import 'package:multy_app/providers/quiz_notifier.dart';
import 'package:multy_app/screens/quiz_result_screen.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('quiz result shows celebration card with active profile', (
    tester,
  ) async {
    final profileProvider = _FakeProfileProvider(
      activeProfile: Profile(
        id: 1,
        name: 'Mateo',
        avatarKey: 'lion',
        colorValue: 0xFF42A5F5,
      ),
    );

    await tester.pumpWidget(
      _TestApp(
        profileProvider: profileProvider,
        child: QuizResultScreen(
          args: QuizResultScreenArguments(
            tableNumber: 4,
            result: QuizResult(
              score: 9,
              totalQuestions: 10,
              passed: true,
              timedOut: false,
              percentage: 90,
              durationInSeconds: 18,
              wasSaved: true,
              savedProfileName: 'Mateo',
            ),
          ),
        ),
      ),
    );

    await tester.pump();

    final context = tester.element(find.byType(QuizResultScreen));
    final l10n = AppLocalizations.of(context)!;

    expect(find.byKey(const Key('quiz-result-celebration-card')), findsOneWidget);
    expect(find.byKey(const Key('quiz-result-score-card')), findsOneWidget);
    expect(find.byKey(const Key('quiz-result-score-animated')), findsOneWidget);
    expect(find.byKey(const Key('quiz-result-metric-time')), findsOneWidget);
    expect(find.byKey(const Key('quiz-result-metric-best-time')), findsOneWidget);
    expect(find.byKey(const Key('quiz-result-primary-cta')), findsOneWidget);
    expect(find.text('90%'), findsOneWidget);
    expect(find.text('00:18'), findsOneWidget);
    expect(find.text(l10n.bestTime('00:18')), findsOneWidget);
    expect(find.text(l10n.quizResultRetryHint), findsOneWidget);
    expect(find.text('Mateo'), findsOneWidget);
    expect(find.text(l10n.quizRetryButton), findsOneWidget);
  });

  testWidgets(
    'quiz result falls back to active profile name when saved profile name is missing',
    (tester) async {
      final profileProvider = _FakeProfileProvider(
        activeProfile: Profile(
          id: 1,
          name: 'Lucia',
          avatarKey: 'lion',
          colorValue: 0xFF42A5F5,
        ),
      );

      await tester.pumpWidget(
        _TestApp(
          profileProvider: profileProvider,
          child: QuizResultScreen(
            args: QuizResultScreenArguments(
              tableNumber: 4,
              result: QuizResult(
                score: 9,
                totalQuestions: 10,
                passed: true,
                timedOut: false,
                percentage: 90,
                durationInSeconds: 22,
                wasSaved: true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Lucia'), findsOneWidget);
    },
  );
}

class _TestApp extends StatelessWidget {
  const _TestApp({
    required this.profileProvider,
    required this.child,
  });

  final ProfileProvider profileProvider;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ProfileProvider>.value(
      value: profileProvider,
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      ),
    );
  }
}

class _FakeProfileProvider extends ChangeNotifier implements ProfileProvider {
  _FakeProfileProvider({required this.activeProfile});

  @override
  final Profile? activeProfile;

  @override
  bool get hasPersistentSelection => activeProfile != null;

  @override
  bool get hasSelection => activeProfile != null;

  @override
  bool get isGuestSelected => false;

  @override
  bool get isInitialized => true;

  @override
  ProfileSelectionMode get mode => ProfileSelectionMode.persistent;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
