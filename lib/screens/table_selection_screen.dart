import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:multiplication_app/configs/settings.dart';
import 'package:multiplication_app/l10n/app_localizations.dart';

import 'package:multiplication_app/widgets/table_selection/table_button.dart';

class TableSelectionScreen extends StatelessWidget {
  final String nextRoute;
  const TableSelectionScreen({super.key, required this.nextRoute});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.selectTableTitle),
        backgroundColor: Colors.orangeAccent,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.selectTablePrompt,
              style: GoogleFonts.baloo2(
                // <-- Puedes usar una fuente bonita aquí también si quieres
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 15.0,
                mainAxisSpacing: 15.0,
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                children: List.generate(Settings.maxTableNumber, (index) {
                  return TableButton(
                    tableNumber: index + 1,
                    nextRoute: nextRoute,
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
