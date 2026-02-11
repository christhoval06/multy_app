import 'package:flutter/material.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:multy_app/configs/app_prefs.dart';
import 'package:multy_app/l10n/app_localizations.dart';
import 'package:multy_app/configs/route_paths.dart';
import 'package:multy_app/providers/quiz_attemp_provider.dart';
import 'package:multy_app/routes.dart';
import 'package:multy_app/services/objectbox_service.dart';
import 'package:multy_app/theme/theme.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

late ObjectBoxService objectBoxService;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  objectBoxService = await ObjectBoxService.init();

  final prefs = await SharedPreferences.getInstance();
  final hasCompletedOnboarding =
      prefs.getBool(AppPrefs.onboardingComplete) ?? false;

  String initialRoute = RoutePaths.onboarding;
  if (hasCompletedOnboarding) {
    initialRoute = RoutePaths.main;
  }

  runApp(MultiplicationApp(initialRoute: initialRoute));
}

class MultiplicationApp extends StatelessWidget {
  final String initialRoute;
  const MultiplicationApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<QuizAttempProvider>(
          create: (_) => QuizAttempProvider(objectboxService: objectBoxService),
        ),
      ],
      child: MaterialApp(
        onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
        theme: customTheme,
        localizationsDelegates: const [
          AppLocalizations.delegate, // Delegado generado para tus traducciones
          GlobalMaterialLocalizations
              .delegate, // Localizaciones por defecto para Material
          GlobalWidgetsLocalizations
              .delegate, // Localizaciones por defecto para widgets base
          GlobalCupertinoLocalizations
              .delegate, // Localizaciones por defecto para Cupertino
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        initialRoute: initialRoute,
        onGenerateRoute: Routes.generateRoute,
        debugShowCheckedModeBanner:
            false, // Opcional: oculta el banner de debug
      ),
    );
  }
}
