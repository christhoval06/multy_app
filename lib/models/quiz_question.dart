import 'dart:math';

import 'package:multy_app/models/quiz_models.dart';

class QuizQuestion {
  final String questionText; // Ej: "7 x 5 = ?"
  final int correctAnswer;
  final List<int> options; // Lista con 4 opciones (1 correcta, 3 incorrectas)
  final int operand1;
  final int operand2;
  final OperationType operationType;

  QuizQuestion({
    required this.questionText,
    required this.correctAnswer,
    required this.options,
    required this.operand1,
    required this.operand2,
    required this.operationType,
  });

  // Fábrica para crear una pregunta con opciones aleatorias
  factory QuizQuestion.generate(int tableNumber, int multiplier) {
    final correctAnswer = tableNumber * multiplier;
    final questionText = '$tableNumber x $multiplier = ?';

    // Generar opciones incorrectas
    final random = Random();
    Set<int> incorrectOptions =
        {}; // Usamos Set para evitar duplicados iniciales

    while (incorrectOptions.length < 3) {
      int incorrect;
      // Estrategia simple para opciones incorrectas (puedes mejorarla)
      int strategy = random.nextInt(4); // Elige una estrategia
      switch (strategy) {
        case 0: // Respuesta +/- número pequeño
          int offset = random.nextInt(5) + 1; // 1 a 5
          incorrect = correctAnswer + (random.nextBool() ? offset : -offset);
          break;
        case 1: // Respuesta +/- número de tabla
          incorrect =
              correctAnswer + (random.nextBool() ? tableNumber : -tableNumber);
          break;
        case 2: // Respuesta +/- multiplicador
          incorrect =
              correctAnswer + (random.nextBool() ? multiplier : -multiplier);
          break;
        default: // Número completamente aleatorio cerca de la respuesta
          int range = max(
            10,
            (correctAnswer * 0.3).round(),
          ); // Rango del 30% o 10
          incorrect = correctAnswer - range + random.nextInt(range * 2);
          break;
      }

      // Asegurarse de que no sea la respuesta correcta y sea positiva
      if (incorrect != correctAnswer && incorrect > 0) {
        incorrectOptions.add(incorrect);
      }
    }

    // Crear la lista final de opciones y barajarla
    List<int> allOptions = [correctAnswer, ...incorrectOptions];
    allOptions.shuffle(random); // Baraja las opciones

    return QuizQuestion(
      questionText: questionText,
      correctAnswer: correctAnswer,
      options: allOptions,
      operand1: tableNumber,
      operand2: multiplier,
      operationType: OperationType.multiplication,
    );
  }
}
