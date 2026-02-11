// lib/models/quiz_models.dart
import 'package:flutter/material.dart'; // Necesario para IconData

// --- Enum para el Tipo de Operación ---

enum OperationType {
  addition,
  subtraction,
  multiplication,
  division,
}

// --- Extensión para añadir funcionalidades a OperationType ---

extension OperationTypeExtension on OperationType {
  /// Devuelve el nombre legible para mostrar en la UI.
  String get displayName {
    switch (this) {
      case OperationType.addition:
        return 'Suma';
      case OperationType.subtraction:
        return 'Resta';
      case OperationType.multiplication:
        return 'Multiplicación';
      case OperationType.division:
        return 'División';
    }
  }

  /// Devuelve un icono representativo para la operación.
  IconData get icon {
     switch (this) {
      case OperationType.addition:
        return Icons.add;
      case OperationType.subtraction:
        return Icons.remove;
      case OperationType.multiplication:
        // Icono 'x' (close) es común para multiplicación
        return Icons.close;
      case OperationType.division:
        // No hay un icono estándar perfecto para '÷'.
        // Icons.percent podría usarse, o uno más genérico.
        // O considera no usar icono para división y solo el símbolo.
        return Icons.percent_outlined; // O usa Icons.calculate_outlined, etc.
    }
  }

   /// Devuelve el símbolo matemático para mostrar en las preguntas.
   String get symbol {
     switch (this) {
      case OperationType.addition:
        return '+';
      case OperationType.subtraction:
        return '-';
      case OperationType.multiplication:
        // Usa 'x' en lugar de '*' para ser más visual para niños
        return 'x';
      case OperationType.division:
        // Usa '÷' en lugar de '/'
        return '÷';
    }
  }
}

// --- Enum para el Nivel de Dificultad ---

enum Difficulty {
  level1, // 1 cifra (0-9)
  level2, // 2 cifras (10-99)
  level3, // 3 cifras (100-999)
  level4, // 4 cifras (1000-9999)
}

// --- Extensión para añadir funcionalidades a Difficulty ---

extension DifficultyExtension on Difficulty {
  /// Devuelve el nombre legible para mostrar en la UI.
  String get displayName {
    switch (this) {
      case Difficulty.level1: return 'Nivel 1 (1 Cifra)';
      case Difficulty.level2: return 'Nivel 2 (2 Cifras)';
      case Difficulty.level3: return 'Nivel 3 (3 Cifras)';
      case Difficulty.level4: return 'Nivel 4 (4 Cifras)';
    }
  }

  /// Devuelve el número máximo permitido para los operandos en este nivel.
  int get maxNumber {
     switch (this) {
      case Difficulty.level1: return 9;
      case Difficulty.level2: return 99;
      case Difficulty.level3: return 999;
      case Difficulty.level4: return 9999;
    }
  }

  /// Devuelve el número mínimo sugerido para los operandos en este nivel (excepto nivel 1).
  /// Útil para asegurar que los números tengan la cantidad de cifras esperada.
  int get minNumber {
     switch (this) {
       case Difficulty.level1: return 0; // Permite números de 0 a 9
       case Difficulty.level2: return 10;
       case Difficulty.level3: return 100;
       case Difficulty.level4: return 1000;
     }
   }
}

// --- (Opcional) Clase para representar un resultado del quiz ---
// Podrías añadir más modelos aquí si los necesitas, por ejemplo:
/*
class QuizResult {
  final int correctAnswers;
  final int totalQuestions;
  final Duration timeTaken;
  // ... otros datos relevantes

  QuizResult({
    required this.correctAnswers,
    required this.totalQuestions,
    required this.timeTaken,
  });
}
*/