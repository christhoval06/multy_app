import 'package:flutter/material.dart';
import 'package:multy_app/theme/app_fonts.dart';

class QuestionCard extends StatelessWidget {
  final String question;

  const QuestionCard({super.key, required this.question});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 64.0, horizontal: 16.0),
        child: Text(
          question,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: AppFonts.display,
            fontSize: 42,
            color: Colors.deepPurple,
          ),
        ),
      ),
    );
  }
}
