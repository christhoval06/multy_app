// lib/providers/quiz_notifier.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart'; // Para ChangeNotifier
import 'package:multy_app/configs/settings.dart';
import 'package:multy_app/models/quiz_attemp.dart';
import 'package:multy_app/models/quiz_question.dart';
import 'package:multy_app/providers/quiz_attemp_provider.dart';
import 'package:multy_app/services/timer_settings_service.dart';

// Clase auxiliar para el resultado final
class QuizResult {
  final int score;
  final int totalQuestions;
  final bool passed;
  final bool timedOut;
  final double percentage;
  final int? durationInSeconds;
  final bool wasSaved;
  final bool isGuestSession;
  final String? savedProfileName;

  QuizResult({
    required this.score,
    required this.totalQuestions,
    required this.passed,
    required this.timedOut,
    required this.percentage,
    this.durationInSeconds,
    this.wasSaved = false,
    this.isGuestSession = false,
    this.savedProfileName,
  });

  QuizResult copyWith({
    int? score,
    int? totalQuestions,
    bool? passed,
    bool? timedOut,
    double? percentage,
    int? durationInSeconds,
    bool? wasSaved,
    bool? isGuestSession,
    String? savedProfileName,
  }) {
    return QuizResult(
      score: score ?? this.score,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      passed: passed ?? this.passed,
      timedOut: timedOut ?? this.timedOut,
      percentage: percentage ?? this.percentage,
      durationInSeconds: durationInSeconds ?? this.durationInSeconds,
      wasSaved: wasSaved ?? this.wasSaved,
      isGuestSession: isGuestSession ?? this.isGuestSession,
      savedProfileName: savedProfileName ?? this.savedProfileName,
    );
  }
}

class QuizNotifier extends ChangeNotifier {
  final QuizAttempProvider quizAttempProvider;
  final int tableNumber;

  // --- Estado ---
  List<QuizQuestion> questions = [];
  int currentQuestionIndex = 0;
  int score = 0;
  Timer? _timer; // Timer es interno, no necesita ser accedido directamente
  int _remainingSeconds = Settings.defaultQuizDurationSeconds; // Tiempo inicial
  int _quizDurationSeconds = Settings.defaultQuizDurationSeconds;
  final int _totalQuestions = Settings.totalQuestions; // Preguntas por quiz
  bool _quizFinished = false;
  int? _selectedOption;
  QuizResult? _finalResult; // Almacena el resultado final para el diálogo
  QuizAttemp? _pendingAttempt;
  bool _isResultDialogShown = false; // Nueva bandera
  bool get isResultDialogShown => _isResultDialogShown;

  // --- Getters (para acceder al estado desde la UI) ---
  int get remainingSeconds => _remainingSeconds;
  bool get quizFinished => _quizFinished;
  int? get selectedOption => _selectedOption;
  QuizResult? get finalResult => _finalResult;
  QuizAttemp? get pendingAttempt => _pendingAttempt;
  QuizQuestion? get currentQuestion =>
      questions.isNotEmpty ? questions[currentQuestionIndex] : null;
  int get totalQuizQuestions =>
      _totalQuestions; // Exporta el total si la UI lo necesita

  // --- Constructor ---
  final TimerSettingsService? timerSettingsService;

  QuizNotifier(
    this.quizAttempProvider,
    this.tableNumber, {
    this.timerSettingsService,
  }) {
    // Configuración inicial si fuera necesaria (tiempo, etc.)
    _syncQuizDuration();
    _remainingSeconds = _quizDurationSeconds;
    // Iniciar el quiz al crear el notifier
    resetQuiz(); // Usamos resetQuiz para la lógica inicial
  }

  // --- Lógica ---

  void _syncQuizDuration() {
    _quizDurationSeconds =
        timerSettingsService?.readQuizDurationSeconds() ??
        Settings.defaultQuizDurationSeconds;
  }

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
      if (_quizFinished) return;
      if (_timer == null) return;
      if (!_timer!.isActive && !_quizFinished) return;

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
    final elapsedSeconds = (_quizDurationSeconds - _remainingSeconds).clamp(
      0,
      _quizDurationSeconds,
    );
    _finalResult = QuizResult(
      score: score,
      totalQuestions: questions.length,
      passed: passed,
      timedOut: timedOut,
      percentage: percentage,
      durationInSeconds: timedOut ? null : elapsedSeconds,
    );

    _pendingAttempt = QuizAttemp(
      profileId: 0,
      timestamp: DateTime.now(),
      tableNumber: tableNumber,
      correctAnswers: score,
      totalQuestions: questions.length,
      durationInSeconds: timedOut ? null : elapsedSeconds,
    );

    notifyListeners(); // Notifica que el quiz ha terminado y hay resultado
  }

  void setResultDialogShown(bool value) {
    _isResultDialogShown = value;
    // No es necesario notificar listeners usualmente para esto,
    // pero podrías si alguna UI dependiera de ello.
  }

  void resetQuiz() {
    _syncQuizDuration();
    score = 0;
    currentQuestionIndex = 0;
    _remainingSeconds = _quizDurationSeconds; // Reinicia el tiempo
    _quizFinished = false;
    _selectedOption = null;
    _finalResult = null; // Limpia el resultado anterior
    _pendingAttempt = null;
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
