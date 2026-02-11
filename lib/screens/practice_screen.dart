// lib/screens/practice_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:multy_app/l10n/app_localizations.dart';
import 'package:multy_app/configs/route_paths.dart';
import 'package:multy_app/theme/app_fonts.dart';

class PracticeScreen extends StatefulWidget {
  static const routeName = '/practice';
  final int tableNumber;

  const PracticeScreen({super.key, required this.tableNumber});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  late List<TextEditingController> _controllers;
  late List<bool?> _results;
  bool _isGraded = false;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(12, (index) => TextEditingController());
    _results = List.generate(12, (index) => null);
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _gradeAnswers(AppLocalizations l10n) {
    setState(() {
      _isGraded = true;
      for (int i = 0; i < 12; i++) {
        int multiplier = i + 1;
        int correctAnswer = widget.tableNumber * multiplier;
        int? userAnswer;
        try {
          userAnswer = int.parse(_controllers[i].text.trim());
        } catch (e) {
          userAnswer = null;
        }
        _results[i] = (userAnswer != null && userAnswer == correctAnswer);
      }
    });

    int correctCount = _results.where((r) => r == true).length;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            correctCount == 12
                ? l10n.congratulationsDialogTitle
                : l10n.summaryDialogTitle,
          ),
          content: Text(l10n.summaryDialogContent(correctCount)),
          actions: <Widget>[
            TextButton(
              child: Text(l10n.dialogOkButton),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _resetQuiz() {
    setState(() {
      _isGraded = false;
      _results = List.generate(12, (index) => null);
      for (var controller in _controllers) {
        controller.clear();
      }
    });
  }

  Widget _getResultIcon(int index) {
    if (!_isGraded || _results[index] == null) {
      return const SizedBox(width: 24, height: 24);
    }
    return Icon(
      _results[index]! ? Icons.check_circle_outline : Icons.highlight_off,
      color: _results[index]! ? Colors.green.shade600 : Colors.red.shade600,
      size: 24,
    );
  }

  Color _getBorderColor(int index) {
    if (!_isGraded || _results[index] == null) {
      return Colors.grey.shade400;
    }
    return _results[index]! ? Colors.green : Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.practiceScreenTitle(widget.tableNumber)),
        backgroundColor: Colors.lightBlueAccent,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 24.0),
        child: Column(
          children: [
            Expanded(
              // --- CAMBIO AQUÍ: USA ListView.separated ---
              child: ListView.separated(
                itemCount: 12, // Número total de elementos
                // El itemBuilder sigue siendo el mismo que antes
                itemBuilder: (context, index) {
                  int multiplier = index + 1;
                  int correctAnswer = widget.tableNumber * multiplier;

                  // El Padding y Row para cada item no cambian
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 6.0,
                    ), // Padding vertical para cada item
                    child: Row(
                      children: [
                        SizedBox(
                          width: 85,
                          child: Text(
                            l10n.multiplicationOperation(
                              widget.tableNumber,
                              multiplier,
                            ),
                            style: const TextStyle(
                              fontFamily: AppFonts.display,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          width: 70,
                          height: 55,
                          child: TextField(
                            controller: _controllers[index],
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(3),
                            ],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: InputDecoration(
                              hintText: l10n.answerHint,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 10,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: _getBorderColor(index),
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                  width: 2.0,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              errorText: (_isGraded && _results[index] == false)
                                  ? l10n.correctAnswerWas(correctAnswer)
                                  : null,
                              errorStyle: const TextStyle(
                                fontSize: 11,
                                color: Colors.redAccent,
                                fontWeight: FontWeight.w500,
                              ),
                              errorMaxLines: 1,
                            ),
                            textInputAction: (index < 11)
                                ? TextInputAction.next
                                : TextInputAction.done,
                            onSubmitted: (_) {
                              if (index < 11) {
                                FocusScope.of(context).nextFocus();
                              } else {
                                FocusScope.of(context).unfocus();
                                if (!_isGraded) _gradeAnswers(l10n);
                              }
                            },
                          ),
                        ),
                        const Spacer(),
                        _getResultIcon(index),
                      ],
                    ),
                  );
                },

                // --- NUEVO: separatorBuilder ---
                // Esta función construye el widget que va ENTRE cada item
                separatorBuilder: (context, index) {
                  // Devuelve un Divider (línea horizontal)
                  return Divider(
                    color:
                        Colors.grey.shade300, // Color del separador (opcional)
                    thickness: 1.0, // Grosor del separador (opcional)
                    height:
                        10, // Altura total del espacio del separador (incluye espacio arriba/abajo)
                    // indent: 16,            // Sangría izquierda (opcional)
                    // endIndent: 16,         // Sangría derecha (opcional)
                  );
                  // O podrías devolver solo espacio: return SizedBox(height: 10);
                },

                // --- FIN DE separatorBuilder ---
              ),
              // --- FIN DE ListView.separated ---
            ),
            const SizedBox(height: 20),

            Row(
              // Envuelve los botones en un Row si quieres ponerlos lado a lado
              mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Espaciado
              children: [
                if (_isGraded) // Mostrar "Intentar de nuevo" solo si ya calificó
                  ElevatedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: Text(l10n.tryAgainButton),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 25,
                        vertical: 12,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: _resetQuiz,
                  ),

                if (!_isGraded) // Mostrar "Calificar" solo si NO calificó
                  ElevatedButton.icon(
                    icon: const Icon(Icons.check_circle),
                    label: Text(l10n.gradeButton),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber.shade700,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () => _gradeAnswers(l10n),
                  ),

                // --- BOTÓN PARA IR AL TEST ---
                OutlinedButton.icon(
                  icon: const Icon(Icons.quiz_outlined),
                  label: Text(
                    l10n.practiceScreenTestButton,
                  ), // "¡Hacer un Test!"
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.deepPurple,
                    side: const BorderSide(
                      color: Colors.deepPurple,
                      width: 1.5,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    // Navegar a QuizScreen pasando el número de tabla actual
                    Navigator.pushNamed(
                      context,
                      RoutePaths.multiplicationQuiz,
                      arguments: widget.tableNumber,
                    );
                  },
                ),
                // --- FIN BOTÓN TEST ---
              ],
            ),
          ],
        ),
      ),
    );
  }
}
