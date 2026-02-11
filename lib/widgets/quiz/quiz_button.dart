import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:multy_app/providers/quiz_notifier.dart';

class QuizButton extends StatelessWidget {
  final VoidCallback onPressed;
  final int option;

  const QuizButton({super.key, required this.option, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: _getOptionButtonColor(context, option),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
      child: Text('$option'),
    );
  }

  Color _getOptionButtonColor(BuildContext context, int option) {
    // Esta función no necesita cambiar
    final quizNotifier = Provider.of<QuizNotifier>(context, listen: false);
    final currentQuestion = quizNotifier.currentQuestion;
    if (currentQuestion == null) return Colors.grey;

    if (quizNotifier.selectedOption == null) {
      return Colors.blueAccent;
    }
    if (option == quizNotifier.selectedOption) {
      return option == currentQuestion.correctAnswer
          ? Colors.lightGreen
          : Colors.redAccent;
    } else if (option == currentQuestion.correctAnswer &&
        quizNotifier.selectedOption != null) {
      return Colors.lightGreen.withAlpha(179);
    }
    return Colors.grey.shade400;
  }
}
