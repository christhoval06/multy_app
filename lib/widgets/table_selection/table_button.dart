import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:multiplication_app/configs/route_paths.dart';

class TableButton extends StatelessWidget {
  final int tableNumber;
  const TableButton({super.key, required this.tableNumber});

  void _navigateToPracticeScreen(BuildContext context, int tableNumber) {
    Navigator.pushNamed(
      context,
      RoutePaths.multiplicationQuiz, // Usa el nombre de la ruta definida
      arguments: tableNumber, // Pasa el número de la tabla como argumento
    );
  }

  @override
  Widget build(BuildContext context) {

    return ElevatedButton(
      onPressed: () {
        _navigateToPracticeScreen(context, tableNumber);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        padding: const EdgeInsets.all(10),
        elevation: 5,
      ),
      child: Text(
        '$tableNumber',
        // ¡Aplica la fuente aquí!
        style: GoogleFonts.luckiestGuy(
          // O .luckiestGuy(), .baloo2(), etc.
          fontSize: 38, // Quizás ajustar un poco el tamaño
          // fontWeight: FontWeight.bold, // Muchas de estas fuentes ya son bold
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
