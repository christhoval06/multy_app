import 'package:flutter/material.dart';
import 'package:multy_app/theme/app_fonts.dart';

enum TableSelectionMode { study, quiz }

class TableButton extends StatelessWidget {
  final int tableNumber;
  final String nextRoute;
  final TableSelectionMode selectionMode;

  const TableButton({
    super.key,
    required this.tableNumber,
    required this.nextRoute,
    required this.selectionMode,
  });

  void _navigateToPracticeScreen(BuildContext context, int tableNumber) {
    Navigator.pushNamed(
      context,
      // RoutePaths.multiplicationQuiz, // Usa el nombre de la ruta definida
      nextRoute,
      arguments: tableNumber, // Pasa el número de la tabla como argumento
    );
  }

  @override
  Widget build(BuildContext context) {
    final isQuizMode = selectionMode == TableSelectionMode.quiz;
    final gradientColors = isQuizMode
        ? const <Color>[Color(0xFFFF8A3D), Color(0xFFFFB347)]
        : const <Color>[Color(0xFF4F86F7), Color(0xFF6CA8FF)];
    final shadowColor = isQuizMode
        ? const Color(0x33FF8A3D)
        : const Color(0x334F86F7);
    final borderColor = isQuizMode
        ? const Color(0xFFFFC58D)
        : const Color(0xFF8DB7FF);

    return ElevatedButton(
      onPressed: () {
        _navigateToPracticeScreen(context, tableNumber);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        shadowColor: Colors.transparent,
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22.0),
        ),
      ),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: shadowColor,
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(color: borderColor, width: 1.4),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -8,
              right: -6,
              child: Container(
                width: 66,
                height: 66,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            SizedBox.expand(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(height: 4),
                    Expanded(
                      child: Center(
                        child: Text(
                          '$tableNumber',
                          style: TextStyle(
                            fontFamily: AppFonts.display,
                            fontSize: tableNumber >= 10 ? 50 : 60,
                            color: Colors.white,
                            height: 0.92,
                            shadows: <Shadow>[
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.12),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.end,
                    //   children: [
                    //     Container(
                    //       padding: const EdgeInsets.symmetric(
                    //         horizontal: 8,
                    //         vertical: 5,
                    //       ),
                    //       decoration: BoxDecoration(
                    //         color: Colors.white.withValues(alpha: 0.14),
                    //         borderRadius: BorderRadius.circular(999),
                    //         border: Border.all(
                    //           color: Colors.white.withValues(alpha: 0.16),
                    //         ),
                    //       ),
                    //       child: Icon(
                    //         isQuizMode
                    //             ? Icons.arrow_forward_rounded
                    //             : Icons.play_circle_fill_rounded,
                    //         color: Colors.white.withValues(alpha: 0.95),
                    //         size: 16,
                    //       ),
                    //     ),
                    //   ],
                    // ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
