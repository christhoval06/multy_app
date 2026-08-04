import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:multy_app/providers/quiz_notifier.dart';

class QuizButton extends StatelessWidget {
  final VoidCallback onPressed;
  final int option;

  const QuizButton({super.key, required this.option, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final quizNotifier = context.watch<QuizNotifier>();
    final selectedOption = quizNotifier.selectedOption;
    final isAnswered = selectedOption != null;
    final isSelected = selectedOption == option;
    final currentQuestion = quizNotifier.currentQuestion;
    final isCorrectOption = currentQuestion?.correctAnswer == option;

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: _getOptionButtonColor(context, option),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.0),
        ),
        elevation: isSelected ? 1 : 5,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        textStyle: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isAnswered
                    ? (isCorrectOption
                        ? Icons.check_rounded
                        : (isSelected
                            ? Icons.close_rounded
                            : Icons.circle_outlined))
                    : Icons.touch_app_rounded,
                color: Colors.white.withValues(alpha: 0.92),
                size: 18,
              ),
            ),
          ),
          Center(
            child: Text(
              '$option',
              style: const TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w900,
                height: 1,
              ),
            ),
          ),
        ],
      ),
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
