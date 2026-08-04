import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multy_app/configs/settings.dart';
import 'package:multy_app/providers/quiz_attemp_provider.dart';
import 'package:multy_app/providers/quiz_notifier.dart';
import 'package:multy_app/services/timer_settings_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('QuizNotifier', () {
    test('uses persisted quiz duration for initial and reset state', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'quizDurationSeconds': 60,
      });

      final prefs = await SharedPreferences.getInstance();
      final notifier = QuizNotifier(
        _FakeQuizAttempProvider(),
        7,
        timerSettingsService: TimerSettingsService(prefs),
      );

      expect(notifier.remainingSeconds, 60);

      notifier.resetQuiz();

      expect(notifier.remainingSeconds, 60);
      notifier.dispose();
    });

    testWidgets('stores elapsed time for completed quizzes', (tester) async {
      final notifier = QuizNotifier(_FakeQuizAttempProvider(), 7);

      await tester.pump(const Duration(seconds: 8));
      notifier.endQuiz();

      expect(notifier.pendingAttempt, isNotNull);
      expect(notifier.pendingAttempt!.durationInSeconds, 8);

      notifier.dispose();
    });

    testWidgets('does not store best-time duration for timed out quizzes', (
      tester,
    ) async {
      final notifier = QuizNotifier(_FakeQuizAttempProvider(), 7);

      await tester.pump(Duration(seconds: Settings.defaultQuizDurationSeconds));
      notifier.endQuiz(timedOut: true);

      expect(notifier.finalResult, isNotNull);
      expect(notifier.finalResult!.timedOut, isTrue);
      expect(notifier.pendingAttempt, isNotNull);
      expect(notifier.pendingAttempt!.durationInSeconds, isNull);

      notifier.dispose();
    });
  });
}

class _FakeQuizAttempProvider extends ChangeNotifier
    implements QuizAttempProvider {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
