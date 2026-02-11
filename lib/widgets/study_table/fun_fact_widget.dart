import 'package:flutter/material.dart';
import 'package:multy_app/l10n/app_localizations.dart';

import 'package:multy_app/utils/fun_facts.dart';

class FunFactWidget extends StatelessWidget {
  final int table;
  final int multiplier;

  const FunFactWidget({
    super.key,
    required this.table,
    required this.multiplier,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!; // Para textos localizados
    String? fact = FunFacts.getFunFact(
      table,
      multiplier,
      l10n,
    ); // Necesitarías una función que devuelva hechos

    if (fact == null) return const SizedBox(height: 60);

    return Container(
      height: 60, // Altura fija para el contenedor del hecho divertido
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      // margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0), // Se maneja con el Padding exterior
      child: Center(
        // Para centrar el Row si el texto es corto
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize
              .min, // Para que el Row no ocupe todo el ancho si el texto es corto
          children: [
            const Text("💡", style: TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Flexible(
              // Flexible para que el texto se ajuste
              child: Text(
                fact,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis, // Por si el texto es muy largo
                maxLines: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
