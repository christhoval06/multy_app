import 'package:objectbox/objectbox.dart';

@Entity() // Esto le dice a ObjectBox que esta clase es un modelo
class QuizAttemp {
  @Id() // ID único para cada objeto, gestionado por ObjectBox
  int id = 0; // ObjectBox asignará un ID. 0 significa "no asignado aún".

  DateTime timestamp;
  int tableNumber; // El número de la tabla (ej: 2, 5, 10)
  int correctAnswers;
  int totalQuestions;
  int? durationInSeconds; // Opcional: duración del quiz

  QuizAttemp({
    this.id = 0,
    required this.timestamp,
    required this.tableNumber,
    required this.correctAnswers,
    required this.totalQuestions,
    this.durationInSeconds,
  });
}