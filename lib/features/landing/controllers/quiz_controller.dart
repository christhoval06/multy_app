import 'package:flutter/foundation.dart';
import '../data/preview_questions.dart';
import '../domain/models/quiz_model.dart';

/// Owns preview progression; widgets only render state and submit choices.
class QuizController extends ChangeNotifier {
  QuizController({List<QuizQuestion>? questions})
    : _questions = List.unmodifiable(questions ?? previewQuestions) {
    if (_questions.isEmpty) {
      throw ArgumentError('At least one question is required.');
    }
  }
  final List<QuizQuestion> _questions;
  int _index = 0;
  int _score = 0;
  bool _solved = false;
  String _feedback = '';

  QuizQuestion get question => _questions[_index];
  int get score => _score;
  bool get solved => _solved;
  String get feedback => _feedback;
  bool get isLast => _index == _questions.length - 1;

  bool submit(int value) {
    if (_solved) return true;
    if (!question.options.any((option) => option.value == value)) return false;
    _solved = value == question.answer;
    if (_solved) _score += 10;
    _feedback = _solved
        ? 'Spot on! ${question.question} = ${question.answer}!'
        : 'Almost! Try again!';
    notifyListeners();
    return _solved;
  }

  void next() {
    if (!_solved) return;
    if (isLast) {
      _index = 0;
      _score = 0;
    } else {
      _index++;
    }
    _solved = false;
    _feedback = '';
    notifyListeners();
  }
}
