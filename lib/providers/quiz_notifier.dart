// lib/providers/quiz_notifier.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart'; // Para ChangeNotifier
import 'package:multy_app/configs/settings.dart';
import 'package:multy_app/models/quiz_attemp.dart';
import 'package:multy_app/models/quiz_question.dart';
import 'package:multy_app/providers/quiz_attemp_provider.dart';

// Clase auxiliar para el resultado final
class QuizResult {
  final int score;
  final int totalQuestions;
  final bool passed;
  final bool timedOut;
  final double percentage;

  QuizResult({
    required this.score,
    required this.totalQuestions,
    required this.passed,
    required this.timedOut,
    required this.percentage,
  });
}

class QuizNotifier extends ChangeNotifier {
  final QuizAttempProvider quizAttempProvider;
  final int tableNumber;

  // --- Estado ---
  List<QuizQuestion> questions = [];
  int currentQuestionIndex = 0;
  int score = 0;
  Timer? _timer; // Timer es interno, no necesita ser accedido directamente
  int _remainingSeconds = Settings.quizTime; // Tiempo inicial
  final int _totalQuestions = Settings.totalQuestions; // Preguntas por quiz
  bool _quizFinished = false;
  int? _selectedOption;
  QuizResult? _finalResult; // Almacena el resultado final para el diálogo
  bool _isResultDialogShown = false; // Nueva bandera
  bool get isResultDialogShown => _isResultDialogShown;

  // --- Getters (para acceder al estado desde la UI) ---
  int get remainingSeconds => _remainingSeconds;
  bool get quizFinished => _quizFinished;
  int? get selectedOption => _selectedOption;
  QuizResult? get finalResult => _finalResult;
  QuizQuestion? get currentQuestion =>
      questions.isNotEmpty ? questions[currentQuestionIndex] : null;
  int get totalQuizQuestions =>
      _totalQuestions; // Exporta el total si la UI lo necesita

  // --- Constructor ---
  QuizNotifier(this.quizAttempProvider, this.tableNumber) {
    // Configuración inicial si fuera necesaria (tiempo, etc.)
    _remainingSeconds = 60;
    // Iniciar el quiz al crear el notifier
    resetQuiz(); // Usamos resetQuiz para la lógica inicial
  }

  // --- Lógica ---

  void _generateQuizQuestions() {
    final random = Random();
    List<int> multipliers = List<int>.generate(12, (i) => i + 1)
      ..shuffle(random);
    List<int> quizMultipliers = multipliers.take(_totalQuestions).toList();
    questions = quizMultipliers
        .map((multiplier) => QuizQuestion.generate(tableNumber, multiplier))
        .toList();
    questions.shuffle(random);
    // No necesitamos notifyListeners aquí si se llama desde resetQuiz que ya notifica
  }

  void _startTimer() {
    _timer?.cancel(); // Cancela cualquier timer existente
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        notifyListeners(); // Notifica cada segundo para actualizar UI del timer
      } else {
        endQuiz(timedOut: true);
      }
    });
  }

  void handleAnswer(
    int selectedAnswer,
    VoidCallback? onSuccess,
    VoidCallback? onFail,
  ) {
    if (_quizFinished) return;

    _selectedOption = selectedAnswer;
    notifyListeners(); // Notifica para mostrar feedback visual inmediato

    bool isCorrect =
        selectedAnswer == questions[currentQuestionIndex].correctAnswer;

    // Espera un poco antes de procesar y pasar a la siguiente
    Future.delayed(const Duration(milliseconds: 500), () {
      // Comprueba si el notifier aún existe (podría haberse desechado)
      if (_timer == null || !_timer!.isActive && !quizFinished) return;

      if (isCorrect) {
        score++;
        onSuccess?.call();
      } else {
        onFail?.call();
      }

      if (currentQuestionIndex < questions.length - 1) {
        currentQuestionIndex++;
        _selectedOption = null; // Resetea selección para la nueva pregunta
      } else {
        endQuiz(); // Última pregunta
      }
      notifyListeners(); // Notifica después de actualizar score/index/selectedOption
    });
  }

  void endQuiz({bool timedOut = false}) {
    if (_quizFinished) return;

    _timer?.cancel();
    _quizFinished = true;

    // Calcula y guarda el resultado final
    final double percentage =
        (questions.isEmpty ? 0 : (score / questions.length)) * 100;
    final bool passed = percentage >= 70; // Umbral
    _finalResult = QuizResult(
      score: score,
      totalQuestions: questions.length,
      passed: passed,
      timedOut: timedOut,
      percentage: percentage,
    );

    final newQuizAttemp = QuizAttemp(
      timestamp: DateTime.now(),
      // Aquí es donde necesitas saber qué tabla se estaba jugando
      // Si tu QuizScreen recibe el número de tabla, úsalo.
      // Si lo derivas de `difficulty` o `_currentQuestion`, asegúrate que sea correcto.
      tableNumber: tableNumber, // ¡¡IMPORTANTE: ASEGURA QUE ESTO SEA CORRECTO!!
      correctAnswers: score,
      totalQuestions: questions.length, // o _questionsPerQuizSession
      durationInSeconds: timedOut ? Settings.quizTime : _remainingSeconds,
    );

    quizAttempProvider.createQuizAttemp(newQuizAttemp);

    quizAttempProvider.updateTableOverallStats(newQuizAttemp);

    notifyListeners(); // Notifica que el quiz ha terminado y hay resultado
  }

  void setResultDialogShown(bool value) {
    _isResultDialogShown = value;
    // No es necesario notificar listeners usualmente para esto,
    // pero podrías si alguna UI dependiera de ello.
  }

  void resetQuiz() {
    score = 0;
    currentQuestionIndex = 0;
    _remainingSeconds = 60; // Reinicia el tiempo
    _quizFinished = false;
    _selectedOption = null;
    _finalResult = null; // Limpia el resultado anterior
    _generateQuizQuestions(); // Nuevas preguntas
    _startTimer(); // Inicia nuevo timer
    _isResultDialogShown = false; // Resetear la bandera
    notifyListeners(); // Notifica que el estado se ha reseteado
  }

  // --- Cleanup ---
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
