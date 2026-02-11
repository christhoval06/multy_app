import 'package:flutter/material.dart';
import 'package:multy_app/l10n/app_localizations.dart';
import 'package:multy_app/theme/app_fonts.dart';

import 'package:multy_app/providers/quiz_notifier.dart';

class CardResult extends StatelessWidget {
  final QuizResult result;

  const CardResult({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            Text(
              l10n.quizScoreDetailed(
                result.score,
                result.totalQuestions,
              ), // "Obtuviste X de Y respuestas correctas"
              style: const TextStyle(
                fontFamily: AppFonts.body,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.quizPercentageDetailed(
                result.percentage.toStringAsFixed(0),
              ), // "Eso es un Z% de acierto."
              style: const TextStyle(
                fontFamily: AppFonts.body,
                fontSize: 18,
                fontWeight: FontWeight.w500,
                // color: Colors.deepPurple,
              ),
              // style: const TextStyle(
              //   fontSize: 18,
              //   fontWeight: FontWeight.w500,
              // ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
