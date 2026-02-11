import 'package:flutter/material.dart';
import 'package:multy_app/theme/app_fonts.dart';

class TableButton extends StatelessWidget {
  final int tableNumber;
  final String nextRoute;
  
  const TableButton({super.key, required this.tableNumber, required this.nextRoute});

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
        style: const TextStyle(
          fontFamily: AppFonts.display,
          fontSize: 38,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
