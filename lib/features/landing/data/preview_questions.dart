import '../domain/models/quiz_model.dart';

final previewQuestions = List<QuizQuestion>.unmodifiable([
  QuizQuestion(
    question: '7 × 8',
    options: const [
      QuizOption(value: 48),
      QuizOption(value: 56, isCorrect: true),
      QuizOption(value: 54),
      QuizOption(value: 63),
    ],
  ),
  QuizQuestion(
    question: '6 × 7',
    options: const [
      QuizOption(value: 36),
      QuizOption(value: 49),
      QuizOption(value: 42, isCorrect: true),
      QuizOption(value: 48),
    ],
  ),
  QuizQuestion(
    question: '8 × 9',
    options: const [
      QuizOption(value: 72, isCorrect: true),
      QuizOption(value: 64),
      QuizOption(value: 81),
      QuizOption(value: 63),
    ],
  ),
]);
