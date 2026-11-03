import 'package:flutter/foundation.dart';

@immutable
class QuizQuestion {
  QuizQuestion({required this.question, required List<QuizOption> options})
    : options = List.unmodifiable(options) {
    if (this.options.where((option) => option.isCorrect).length != 1 ||
        this.options.map((option) => option.value).toSet().length !=
            this.options.length) {
      throw ArgumentError(
        'A question needs distinct options and exactly one correct answer.',
      );
    }
  }
  final String question;
  final List<QuizOption> options;
  int get answer => options.singleWhere((option) => option.isCorrect).value;
}

@immutable
class QuizOption {
  const QuizOption({required this.value, this.isCorrect = false});
  final int value;
  final bool isCorrect;
}
