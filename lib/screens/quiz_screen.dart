import 'dart:async'; // Para Future
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:multy_app/l10n/app_localizations.dart';
import 'package:multy_app/configs/route_paths.dart';
import 'package:multy_app/providers/quiz_notifier.dart';
import 'package:multy_app/utils/vibrate.dart';
import 'package:multy_app/utils/player.dart';

import 'package:multy_app/widgets/quiz/question_card.dart';
import 'package:multy_app/widgets/quiz/quiz_button.dart';

import 'quiz_result_screen.dart'; // Importa la pantalla de resultados

// Hacer StatefulWidget de nuevo
class QuizScreen extends StatefulWidget {
  static const routeName = '/quiz';
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  bool _isNavigating = false; // Bandera para evitar navegación múltiple

  // --- Instancia para el reproductor de audio ---
  final Player _audioPlayer = Player();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // --- ¡Importante! Liberar recursos del reproductor ---
    _audioPlayer.close();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Escuchar cambios en el notifier para disparar la navegación
    final quizNotifier = Provider.of<QuizNotifier>(context);
    if (quizNotifier.quizFinished &&
        quizNotifier.finalResult != null &&
        !_isNavigating) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateToResultScreen(
          quizNotifier.finalResult!,
          quizNotifier.tableNumber,
        );
      });
    }
  }

  Future<void> _navigateToResultScreen(
    QuizResult result,
    int tableNumber,
  ) async {
    if (!mounted) return; // Verificar si el widget sigue montado
    setState(() {
      _isNavigating = true; // Marcar que estamos navegando
    });

    // Navega y ESPERA el resultado (true si se debe reintentar)
    final shouldRetry = await Navigator.pushNamed(
      context,
      RoutePaths.multiplicationQuizResults,
      arguments: QuizResultScreenArguments(
        result: result,
        tableNumber: tableNumber,
      ),
    );

    if (!mounted) return; // Verificar de nuevo después del await

    if (shouldRetry == 1) {
      // Si la pantalla de resultados devolvió true, resetea el quiz
      Provider.of<QuizNotifier>(context, listen: false).resetQuiz();
    }
    // Siempre resetear la bandera de navegación al volver
    setState(() {
      _isNavigating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 'watch' es importante para reconstruir cuando el estado cambia (ej. termina el quiz)
    final quizNotifier = context.watch<QuizNotifier>();
    final l10n = AppLocalizations.of(context)!;
    final currentQuestion = quizNotifier.currentQuestion;

    // Ya no necesitamos llamar a _showResultsDialog aquí

    // Muestra carga si no hay pregunta y no ha terminado
    if (currentQuestion == null &&
        !quizNotifier.quizFinished &&
        !_isNavigating) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.quizScreenTitle(quizNotifier.tableNumber)),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Muestra carga o UI vacía mientras navega a resultados
    if (_isNavigating) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.quizScreenTitle(quizNotifier.tableNumber)),
        ),
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Colors.deepPurpleAccent),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.quizScreenTitle(quizNotifier.tableNumber)),
        backgroundColor: Colors.deepPurpleAccent,
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Center(
              child: Text(
                '${l10n.quizTimeLabel}: ${quizNotifier.remainingSeconds} s',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
        automaticallyImplyLeading: quizNotifier.quizFinished,
      ),
      body: PopScope(
        canPop: quizNotifier.quizFinished,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop && mounted) {
            // Verificar mounted aquí también
            final snackBar = SnackBar(
              content: Text(l10n.quizCannotExitMessage),
              duration: const Duration(seconds: 2),
            );
            ScaffoldMessenger.of(context).removeCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          // Muestra el quiz si no ha terminado
          child: !quizNotifier.quizFinished
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.quizQuestionProgress(
                        quizNotifier.currentQuestionIndex + 1,
                        quizNotifier.questions.length,
                      ),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 20),
                    QuestionCard(
                      question: currentQuestion?.questionText ?? '...',
                    ),
                    const SizedBox(height: 30),
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15,
                        childAspectRatio: 2.0,
                        children: (currentQuestion?.options ?? []).map((
                          option,
                        ) {
                          return QuizButton(
                            onPressed: () {
                              if (quizNotifier.selectedOption == null) {
                                context.read<QuizNotifier>().handleAnswer(
                                  option,
                                  () {
                                    Vibrate.vibrate(correct: true);
                                    _audioPlayer.playSound(
                                      'sounds/correct-choice.mp3',
                                    );
                                  },
                                  () {
                                    Vibrate.vibrate(correct: false);
                                    _audioPlayer.playSound(
                                      'sounds/error-choice.mp3',
                                    );
                                  },
                                );
                              }
                            },
                            option: option,
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                )
              // Muestra un indicador si ya terminó pero aún no navega (estado intermedio)
              : const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}
