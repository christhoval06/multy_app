import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multy_app/l10n/app_localizations.dart';
import 'package:multy_app/providers/quiz_attemp_provider.dart';
import 'package:multy_app/providers/quiz_notifier.dart';
import 'package:multy_app/screens/quiz_screen.dart';
import 'package:multy_app/services/timer_settings_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('quiz screen shows game header with progress and timer', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();
    final notifier = QuizNotifier(
      _FakeQuizAttempProvider(),
      4,
      timerSettingsService: TimerSettingsService(prefs),
    );

    await tester.pumpWidget(
      _QuizScreenTestApp(
        notifier: notifier,
        child: const QuizScreen(),
      ),
    );
    await tester.pump();

    final context = tester.element(find.byType(QuizScreen));
    final l10n = AppLocalizations.of(context)!;

    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(find.byIcon(Icons.timer_outlined), findsOneWidget);
    expect(find.byIcon(Icons.flag_rounded), findsOneWidget);
    expect(
      find.text(
        l10n.quizQuestionProgress(
          notifier.currentQuestionIndex + 1,
          notifier.questions.length,
        ),
      ),
      findsOneWidget,
    );
    expect(find.textContaining('${notifier.remainingSeconds}'), findsWidgets);

    await tester.pumpWidget(const SizedBox.shrink());
    notifier.dispose();
  });
}

class _QuizScreenTestApp extends StatelessWidget {
  const _QuizScreenTestApp({
    required this.notifier,
    required this.child,
  });

  final QuizNotifier notifier;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<QuizNotifier>.value(value: notifier),
      ],
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      ),
    );
  }
}

class _FakeQuizAttempProvider extends ChangeNotifier
    implements QuizAttempProvider {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
