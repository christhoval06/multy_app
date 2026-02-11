import 'package:flutter/material.dart';
import 'package:multy_app/theme/app_fonts.dart';

class MultiplicationCard extends StatelessWidget {
  final String equation;
  final int result;

  const MultiplicationCard({
    super.key,
    required this.equation,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(51),
            spreadRadius: 3,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center, // Centrar contenido en la tarjeta
        mainAxisSize:
            MainAxisSize
                .min, // Para que la tarjeta no se expanda innecesariamente si no está en Expanded
        children: [
          Text(
            equation.split('=')[0].trim(),
            style: TextStyle(
              fontFamily: AppFonts.display,
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            "=",
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            result.toString(),
            style: TextStyle(
              fontFamily: AppFonts.display,
              fontSize: 84,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
