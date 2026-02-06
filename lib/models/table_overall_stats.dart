import 'package:objectbox/objectbox.dart';

@Entity()
class TableOverallStats {
  @Id()
  int id = 0; // ObjectBox lo asignará

  // Usaremos `tableNumber` como un identificador único también para estas estadísticas
  // Podríamos hacerlo un índice único si quisiéramos asegurar que solo haya una entrada por tabla.
  // Por ahora, lo manejaremos en la lógica de actualización.
  @Index() // Indexar para búsquedas rápidas
  int tableNumber;

  int totalAttempts;
  int totalCorrectAnswersSum; // Suma de todas las respuestas correctas para esta tabla
  int totalQuestionsSum;    // Suma de todas las preguntas hechas para esta tabla
  int? bestTimeInSeconds;
  // Para el "mejor puntaje", es más simple almacenar los componentes
  int bestScoreCorrect;
  int bestScoreTotal; // Total de preguntas en el intento del mejor puntaje

  // Constructor
  TableOverallStats({
    this.id = 0,
    required this.tableNumber,
    this.totalAttempts = 0,
    this.totalCorrectAnswersSum = 0,
    this.totalQuestionsSum = 0,
    this.bestTimeInSeconds,
    this.bestScoreCorrect = 0,
    this.bestScoreTotal = 0,
  });

  // Método de conveniencia para calcular la precisión
  double get averageAccuracy {
    if (totalQuestionsSum == 0) return 0.0;
    return (totalCorrectAnswersSum / totalQuestionsSum) * 100.0;
  }
}