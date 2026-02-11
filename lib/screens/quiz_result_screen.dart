import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

import 'package:multy_app/l10n/app_localizations.dart';
import 'package:multy_app/providers/quiz_notifier.dart'; // Importa el Notifier y el QuizResult
import 'package:multy_app/theme/app_fonts.dart';
import 'package:multy_app/utils/emoji.dart';

import 'package:multy_app/widgets/quiz_result/card_result.dart';
import 'package:multy_app/widgets/quiz_result/confetti_animation.dart';
import 'package:multy_app/widgets/quiz_result/main_button.dart';
import 'package:multy_app/widgets/quiz_result/main_outline_button.dart'; // Importa el paquete de confeti

class QuizResultScreenArguments {
  final QuizResult result;
  final int tableNumber;

  QuizResultScreenArguments({required this.result, required this.tableNumber});
}

class QuizResultScreen extends StatefulWidget {
  static const routeName = '/quiz-result';

  // Los argumentos se pasan a través de la ruta
  final QuizResultScreenArguments args;

  const QuizResultScreen({super.key, required this.args});

  @override
  State<QuizResultScreen> createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends State<QuizResultScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 10),
    );
    // Reproducir confeti si el usuario aprobó
    if (widget.args.result.passed) {
      // WidgetsBinding.instance.addPostFrameCallback((_) {
      _confettiController.play();
      // });
    }
  }

  @override
  void dispose() {
    _confettiController.dispose(); // ¡Importante!
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final result = widget.args.result;
    final tableNumber = widget.args.tableNumber;
    final emoji = Emoji.getEmojiForScore(result.percentage);

    return Scaffold(
      // Un AppBar simple o sin AppBar
      appBar: AppBar(
        title: Text(
          l10n.quizResultScreenTitle(tableNumber),
        ), // "Resultados: Tabla del X"
        backgroundColor: result.passed
            ? Colors.green.shade600
            : Colors.red.shade400,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false, // Quita el botón de atrás por defecto
        centerTitle: true,
      ),
      body: PopScope(
        canPop: false,
        child: Stack(
          // Stack para poner el confeti encima
          alignment: Alignment.topCenter, // Alinea el confeti arriba
          children: [
            Align(
              alignment: Alignment.center,
              child: ConfettiAnimation(confettiController: _confettiController),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Emoji Gigante
                    Text(emoji, style: const TextStyle(fontSize: 80)),
                    const SizedBox(height: 20),

                    // Mensaje Principal (Pasó / Falló)
                    Text(
                      result.passed
                          ? l10n
                                .quizPassedMessageLarge // "¡FELICIDADES!"
                          : l10n.quizFailedMessageLarge, // "¡OH NO! SIGUE INTENTANDO"
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppFonts.display,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: result.passed
                            ? Colors.green.shade800
                            : Colors.red.shade800,
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Puntaje y Porcentaje
                    CardResult(result: result),
                    const SizedBox(height: 30),

                    // Botones de Acción
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Botón Volver a Intentar
                        MainButton(
                          onPressed: () {
                            Navigator.pop(
                              context,
                              1,
                            ); // Devuelve 'true' para reintentar
                          },
                          label: l10n.quizRetryButton,
                          icon: const Icon(Icons.refresh),
                        ),
                        MainOutlineButton(
                          onPressed: () {
                            // Volver hasta la pantalla de selección de tabla
                            // Navigator.pushReplacementNamed(context, RoutePaths.multiplicationSelection);
                            Navigator.popUntil(
                              context,
                              ModalRoute.withName('/'),
                            );
                          },
                          label: l10n.quizMainMenuButton,
                          icon: const Icon(Icons.home_outlined),
                        ),
                      ],
                    ),
                    // Mensaje si se acabó el tiempo (opcional)
                    if (result.timedOut) ...[
                      const SizedBox(height: 20),
                      Text(
                        l10n.quizResultTimedOutInfo, // "Se acabó el tiempo en esta ocasión."
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            // Widget de Confeti
          ],
        ),
      ),
    );
  }
}
