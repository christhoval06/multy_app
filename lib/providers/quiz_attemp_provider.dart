import 'package:flutter/material.dart';
import 'package:multy_app/models/quiz_attemp.dart';
import 'package:multy_app/models/table_overall_stats.dart';
import 'package:multy_app/services/objectbox_service.dart';
import 'package:multy_app/objectbox.g.dart';

class OverallStatsData {
  final int totalQuizzesPlayed;
  final double overallAccuracy;

  OverallStatsData({
    required this.totalQuizzesPlayed,
    required this.overallAccuracy,
  });
}

class TableStatData {
  final int tableNumber;
  final int attemptsCount;
  final double averageAccuracy;
  final int bestScoreCorrect;
  final int bestScoreTotal;
  final int? bestTimeInSeconds;

  TableStatData({
    required this.tableNumber,
    required this.attemptsCount,
    required this.averageAccuracy,
    required this.bestScoreCorrect,
    required this.bestScoreTotal,
    this.bestTimeInSeconds,
  });
}

class QuizAttempProvider extends ChangeNotifier {
  final Box<QuizAttemp> _quizAttempBox;
  final Box<TableOverallStats> _tableOverallStats;
  final Store _store; // For transactions
  ObjectBoxService objectboxService;

  QuizAttempProvider({required this.objectboxService})
    : _store = objectboxService.store,
      _quizAttempBox = objectboxService.quizAttempBox,
      _tableOverallStats = objectboxService.tableOverallStats;

  Future<void> deleteAllData() async => objectboxService.deleteAllData();

  Future<int> createQuizAttemp(QuizAttemp quizAttemp) async {
    // if (raffle.endNumber < raffle.startNumber) {
    //   throw ArgumentError(
    //     'El número final no puede ser menor que el número inicial en la rifa.',
    //   );
    // }
    // if ((raffle.endNumber - raffle.startNumber + 1) > 10000) {
    //   // Mismo límite que en la UI
    //   throw ArgumentError(
    //     'El rango de números es demasiado grande para crear (máximo 10,000 números).',
    //   );
    // }

    final quizAttempId = _quizAttempBox.put(quizAttemp);
    return quizAttempId;
  }

  Future<List<QuizAttemp>> getAllQuizAttemp() async => _quizAttempBox.getAll();
  Future<List<TableOverallStats>> getAllTableOverallStats() async =>
      _tableOverallStats.getAll();

  OverallStatsData? _overallStats;
  OverallStatsData? get overallStats => _overallStats;
  List<TableOverallStats> _allTableStats = []; // TablaN -> Sus stats
  List<TableOverallStats> get allTableStats => _allTableStats;

  final List<int> _tablesToDisplay = List.generate(12, (index) => index + 1);
  List<int> get tablesToDisplay => _tablesToDisplay;

  Future<void> loadStatistics() async {
    // Obtener todos los intentos de la base de datos
    _allTableStats = await getAllTableOverallStats();
    _allTableStats.sort(
      (a, b) => a.tableNumber.compareTo(b.tableNumber),
    ); // Ordenar por número de tabla

    // Calcular estadísticas generales a partir de las agregadas
    int totalQuizzesPlayedOverall = 0;
    double accuracyOverall = 0.0;

    int totalCorrectSumGlobal = 0;
    int totalQuestionsSumGlobal = 0;

    for (var stat in _allTableStats) {
      totalQuizzesPlayedOverall += stat.totalAttempts;
      totalCorrectSumGlobal += stat.totalCorrectAnswersSum;
      totalQuestionsSumGlobal += stat.totalQuestionsSum;
    }

    accuracyOverall = totalQuestionsSumGlobal > 0
        ? (totalCorrectSumGlobal / totalQuestionsSumGlobal) * 100
        : 0.0;

    // Si una tabla no tiene entrada en _allTableStats, necesitamos crear un objeto placeholder
    // para que se muestre en la UI con "No attempts yet"
    List<TableOverallStats> displayStats = [];
    for (int tableNum in _tablesToDisplay) {
      TableOverallStats? foundStat = _allTableStats.firstWhere(
        (s) => s.tableNumber == tableNum,
        orElse: () => TableOverallStats(tableNumber: tableNum), // Placeholder
      );
      displayStats.add(foundStat);
    }
    _allTableStats = displayStats;

    _overallStats = OverallStatsData(
      totalQuizzesPlayed: totalQuizzesPlayedOverall,
      overallAccuracy: accuracyOverall,
    );

    notifyListeners();
  }

  void updateTableOverallStats(QuizAttemp newAttempt) {
    final tableNum = newAttempt.tableNumber;

    // Intentar obtener las estadísticas existentes para esta tabla
    TableOverallStats? existingStats = _tableOverallStats
        .query(TableOverallStats_.tableNumber.equals(tableNum))
        .build()
        .findFirst();

    if (existingStats == null) {
      // Si no existen, crear nuevas estadísticas
      existingStats = TableOverallStats(
        tableNumber: tableNum,
        totalAttempts: 1,
        totalCorrectAnswersSum: newAttempt.correctAnswers,
        totalQuestionsSum: newAttempt.totalQuestions,
        bestTimeInSeconds: newAttempt.durationInSeconds,
        bestScoreCorrect: newAttempt.correctAnswers,
        bestScoreTotal: newAttempt.totalQuestions,
      );
    } else {
      // Si existen, actualizarlas
      existingStats.totalAttempts += 1;
      existingStats.totalCorrectAnswersSum += newAttempt.correctAnswers;
      existingStats.totalQuestionsSum += newAttempt.totalQuestions;

      // Actualizar mejor tiempo
      if (newAttempt.durationInSeconds != null) {
        if (existingStats.bestTimeInSeconds == null ||
            newAttempt.durationInSeconds! < existingStats.bestTimeInSeconds!) {
          existingStats.bestTimeInSeconds = newAttempt.durationInSeconds;
        }
      }

      // Actualizar mejor puntuación
      if (newAttempt.totalQuestions > 0) {
        double newAttemptAccuracy =
            newAttempt.correctAnswers / newAttempt.totalQuestions;
        double currentBestAccuracy = (existingStats.bestScoreTotal > 0)
            ? existingStats.bestScoreCorrect / existingStats.bestScoreTotal
            : 0.0;

        if (newAttemptAccuracy > currentBestAccuracy) {
          existingStats.bestScoreCorrect = newAttempt.correctAnswers;
          existingStats.bestScoreTotal = newAttempt.totalQuestions;
        } else if (newAttemptAccuracy == currentBestAccuracy &&
            newAttempt.correctAnswers > existingStats.bestScoreCorrect) {
          existingStats.bestScoreCorrect = newAttempt.correctAnswers;
          existingStats.bestScoreTotal = newAttempt.totalQuestions;
        }
      } else if (existingStats.bestScoreTotal == 0) {
        // Si el mejor actual es 0/0 y el nuevo también
        existingStats.bestScoreCorrect = newAttempt.correctAnswers;
        existingStats.bestScoreTotal = newAttempt.totalQuestions;
      }
    }

    _tableOverallStats.put(
      existingStats,
    ); // Guardar (o actualizar) las estadísticas agregadas
  }
}
