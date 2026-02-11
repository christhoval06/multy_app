// lib/screens/table_action_screen.dart
import 'package:flutter/material.dart';
import 'package:multy_app/l10n/app_localizations.dart';
import 'package:multy_app/configs/route_paths.dart';
import 'package:multy_app/theme/app_fonts.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.settingsAppName,
        ), // Ej: "Tabla del 7: ¿Qué quieres hacer?"
        centerTitle: true,
        actions: [
          IconButton(
            // Botón para Estadísticas
            icon: const Icon(Icons.bar_chart),
            tooltip: l10n.menuStats,
            onPressed: () {
              Navigator.of(context).pushNamed(RoutePaths.stats);
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: l10n.menuSettings,
            onPressed: () {
              Navigator.of(context).pushNamed(RoutePaths.settings);
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.homeGreeting,
                style: const TextStyle(
                  fontFamily: AppFonts.body,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              // Botón Estudiar
              ElevatedButton.icon(
                icon: const Icon(Icons.menu_book_rounded, size: 40),
                label: Text(
                  l10n.studyAction,
                  style: const TextStyle(fontSize: 22),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  backgroundColor: Colors.blue.shade100, // Color distintivo
                  foregroundColor: Colors.blue.shade800,
                ),
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    RoutePaths.multiplication,
                    arguments: RoutePaths.study,
                  );
                },
              ),
              const SizedBox(height: 30),

              // Botón Hacer Quiz
              ElevatedButton.icon(
                icon: const Icon(Icons.quiz_rounded, size: 40),
                label: Text(
                  l10n.quizAction,
                  style: const TextStyle(fontSize: 22),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  backgroundColor: Colors.green.shade100, // Color distintivo
                  foregroundColor: Colors.green.shade800,
                ),
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    RoutePaths.multiplication,
                    arguments: RoutePaths.multiplicationQuiz,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
