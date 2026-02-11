import 'package:flutter/material.dart';
import 'package:multy_app/configs/route_paths.dart';
import 'package:multy_app/providers/quiz_attemp_provider.dart';
import 'package:multy_app/providers/quiz_notifier.dart';
import 'package:multy_app/screens/home_screen.dart';
import 'package:multy_app/screens/onboarding_screen.dart';
import 'package:multy_app/screens/practice_screen.dart';
import 'package:multy_app/screens/quiz_result_screen.dart';
import 'package:multy_app/screens/quiz_screen.dart';
import 'package:multy_app/screens/settings_screen.dart';
import 'package:multy_app/screens/stats_screen.dart';
import 'package:multy_app/screens/study_table_screen.dart';
import 'package:multy_app/screens/table_selection_screen.dart';
import 'package:provider/provider.dart';

class Routes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RoutePaths.onboarding:
        return MaterialPageRoute(
          builder: (context) => const OnboardingScreen(),
          settings: settings,
        );

      case RoutePaths.main:
        return MaterialPageRoute(
          builder: (context) => const HomeScreen(),
          settings: settings, // Pasa los settings (útil para middleware, etc.)
        );

      case RoutePaths.multiplication:
      case RoutePaths.multiplicationSelection:
        final arguments = settings.arguments;
        if (arguments is String) {
          return MaterialPageRoute(
            builder: (context) => TableSelectionScreen(nextRoute: arguments),
            settings: settings,
          );
        } else {
          // Manejar el caso de argumento inválido o faltante
          // Puedes redirigir a una pantalla de error o a la pantalla de selección
          print(
            'Error: Argumento inválido para TableSelectionScreen. Se esperaba int, se recibió ${arguments.runtimeType}',
          );
          return MaterialPageRoute(
            builder: (context) => const HomeScreen(), // Volver a la selección
            settings: settings,
          );
        }

      case RoutePaths.multiplicationPractice:
        // Extraer el argumento pasado a esta ruta
        final arguments = settings.arguments;
        // Validar que el argumento es del tipo esperado (int)
        if (arguments is int) {
          return MaterialPageRoute(
            builder: (context) => PracticeScreen(tableNumber: arguments),
            settings: settings,
          );
        } else {
          // Manejar el caso de argumento inválido o faltante
          // Puedes redirigir a una pantalla de error o a la pantalla de selección
          print(
            'Error: Argumento inválido para PracticeScreen. Se esperaba int, se recibió ${arguments.runtimeType}',
          );
          return MaterialPageRoute(
            builder: (context) => const HomeScreen(), // Volver a la selección
            settings: settings,
          );
        }

      case RoutePaths.multiplicationQuiz:
        final arguments = settings.arguments;
        if (arguments is int) {
          return MaterialPageRoute(
            builder: (context) => ChangeNotifierProvider(
              // Crea una instancia de QuizNotifier, pasando el número de tabla
              create: (_) =>
                  QuizNotifier(context.read<QuizAttempProvider>(), arguments),
              // El child es la pantalla del Quiz, ya no necesita el argumento tableNumber
              child: const QuizScreen(),
            ),
            settings: settings,
          );
        } else {
          print('Error: Argumento inválido para QuizScreen.');
          // Redirigir a la selección si falta el argumento
          return MaterialPageRoute(
            builder: (context) => const HomeScreen(),
            settings: settings,
          );
        }
      case RoutePaths.multiplicationQuizResults:
        // Esperamos argumentos de tipo QuizResultScreenArguments
        final arguments = settings.arguments;
        if (arguments is QuizResultScreenArguments) {
          return MaterialPageRoute(
            builder: (context) => QuizResultScreen(args: arguments),
            settings: settings,
          );
        } else {
          // Error: argumentos incorrectos
          print('Error: Argumentos inválidos para QuizResultScreen.');
          // Fallback: Ir a la pantalla de selección
          return MaterialPageRoute(
            builder: (context) => const HomeScreen(),
            settings: settings,
          );
        }

      case RoutePaths.stats:
        return MaterialPageRoute(
          builder: (_) => const StatsScreen(),
          settings: settings, // Pasa los settings (útil para middleware, etc.)
        );

      case RoutePaths.settings:
        return MaterialPageRoute(
          builder: (_) => SettingsScreen(),
          settings: settings,
        );

      case RoutePaths.study:
        // Esperamos argumentos de tipo StudyTableScreenArguments
        final arguments = settings.arguments;
        if (arguments is int) {
          return MaterialPageRoute(
            builder: (context) => StudyTableScreen(
              args: StudyTableScreenArguments(tableNumber: arguments),
            ),
            settings: settings,
          );
        } else {
          // Error: argumentos incorrectos
          print('Error: Argumentos inválidos para StudyTableScreen.');
          // Fallback: Ir a la pantalla de selección
          return MaterialPageRoute(
            builder: (context) => const HomeScreen(),
            settings: settings,
          );
        }

      default:
        // Manejar rutas desconocidas
        print('Error: Ruta desconocida ${settings.name}');
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
      // return MaterialPageRoute(
      //   builder: (context) => const TableSelectionScreen(), // Volver a la selección como fallback
      //   settings: settings,
      // );
    }
  }
}
