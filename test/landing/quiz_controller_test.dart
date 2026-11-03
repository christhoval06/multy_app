import 'package:flutter_test/flutter_test.dart';
import 'package:multy_app/features/landing/controllers/quiz_controller.dart';

void main() {
  test('wrong answers allow retry and correct answers score only once', () {
    final quiz = QuizController();
    addTearDown(quiz.dispose);
    expect(quiz.submit(48), isFalse);
    expect(quiz.score, 0);
    expect(quiz.feedback, contains('Try again'));
    expect(quiz.submit(56), isTrue);
    expect(quiz.score, 10);
    quiz.submit(56);
    quiz.submit(48);
    expect(quiz.score, 10);
    expect(quiz.solved, isTrue);
  });

  test(
    'next question preserves score and completed preview restarts cleanly',
    () {
      final quiz = QuizController();
      addTearDown(quiz.dispose);
      quiz.next();
      expect(quiz.question.question, '7 × 8');
      for (final answer in [56, 42, 72]) {
        quiz.submit(answer);
        expect(quiz.solved, isTrue);
        quiz.next();
      }
      expect(quiz.question.question, '7 × 8');
      expect(quiz.score, 0);
      expect(quiz.feedback, isEmpty);
      expect(quiz.solved, isFalse);
    },
  );
}
