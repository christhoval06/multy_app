import 'dart:async'; // Para Future
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:multy_app/l10n/app_localizations.dart';
import 'package:multy_app/configs/route_paths.dart';
import 'package:multy_app/providers/profile_provider.dart';
import 'package:multy_app/providers/quiz_attemp_provider.dart';
import 'package:multy_app/providers/quiz_notifier.dart';
import 'package:multy_app/services/feedback_service.dart';

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

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
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
        _saveSessionAndNavigate(quizNotifier);
      });
    }
  }

  Future<void> _saveSessionAndNavigate(QuizNotifier quizNotifier) async {
    final pendingAttempt = quizNotifier.pendingAttempt;
    final baseResult = quizNotifier.finalResult;
    if (pendingAttempt == null || baseResult == null) {
      return;
    }

    try {
      final profileProvider = context.read<ProfileProvider>();
      final saveResult = await context.read<QuizAttempProvider>().saveQuizSession(
        quizAttemp: pendingAttempt,
        selectionMode: profileProvider.mode,
        activeProfileId: profileProvider.activeProfile?.id,
        activeProfileName: profileProvider.activeProfile?.name,
      );

      final resultForNavigation = baseResult.copyWith(
        wasSaved: saveResult.wasSaved,
        isGuestSession: saveResult.isGuestSession,
        savedProfileName: saveResult.profileName,
      );

      if (!mounted) return;

      await _navigateToResultScreen(
        resultForNavigation,
        quizNotifier.tableNumber,
      );
    } catch (_) {
      if (!mounted) return;
      final isSpanish = Localizations.localeOf(context).languageCode == 'es';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isSpanish
                ? 'No se pudo guardar este resultado.'
                : 'Could not save this result.',
          ),
          backgroundColor: Colors.red.shade400,
        ),
      );
      setState(() {
        _isNavigating = false;
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
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
          // Muestra el quiz si no ha terminado
          child: !quizNotifier.quizFinished
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _QuizStatusPanel(
                      progressLabel: l10n.quizQuestionProgress(
                        quizNotifier.currentQuestionIndex + 1,
                        quizNotifier.totalQuizQuestions,
                      ),
                      remainingSeconds: quizNotifier.remainingSeconds,
                      progressValue:
                          quizNotifier.totalQuizQuestions == 0
                              ? 0
                              : (quizNotifier.currentQuestionIndex + 1) /
                                  quizNotifier.totalQuizQuestions,
                    ),
                    const SizedBox(height: 18),
                    QuestionCard(
                      question: currentQuestion?.questionText ?? '...',
                    ),
                    const SizedBox(height: 18),
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: 1.55,
                        children: (currentQuestion?.options ?? []).map((
                          option,
                        ) {
                          return QuizButton(
                            onPressed: () {
                              if (quizNotifier.selectedOption == null) {
                                context.read<QuizNotifier>().handleAnswer(
                                  option,
                                  () {
                                    FeedbackService.instance.playAnswerFeedback(
                                      correct: true,
                                    );
                                  },
                                  () {
                                    FeedbackService.instance.playAnswerFeedback(
                                      correct: false,
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

class _QuizStatusPanel extends StatelessWidget {
  const _QuizStatusPanel({
    required this.progressLabel,
    required this.remainingSeconds,
    required this.progressValue,
  });

  final String progressLabel;
  final int remainingSeconds;
  final double progressValue;

  @override
  Widget build(BuildContext context) {
    final warning = remainingSeconds <= 10;
    final timerColor = warning
        ? const Color(0xFFE65100)
        : const Color(0xFF5E35B1);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFFF5F0FF), Color(0xFFE6F3FF)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.deepPurple.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: _QuizInfoChip(
                  icon: Icons.flag_rounded,
                  label: progressLabel,
                  backgroundColor: Colors.white.withValues(alpha: 0.88),
                  foregroundColor: const Color(0xFF4527A0),
                ),
              ),
              const SizedBox(width: 12),
              _QuizInfoChip(
                icon: Icons.timer_outlined,
                label: '$remainingSeconds s',
                backgroundColor: timerColor.withValues(alpha: 0.14),
                foregroundColor: timerColor,
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progressValue.clamp(0, 1),
              minHeight: 12,
              backgroundColor: Colors.white.withValues(alpha: 0.72),
              valueColor: AlwaysStoppedAnimation<Color>(
                warning ? const Color(0xFFFF8A3D) : const Color(0xFF6C63FF),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuizInfoChip extends StatelessWidget {
  const _QuizInfoChip({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: foregroundColor),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: foregroundColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
