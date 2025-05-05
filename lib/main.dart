import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:multiplication_app/configs/route_paths.dart';
import 'package:multiplication_app/routes.dart';

import 'package:multiplication_app/theme/theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MultiplicationApp());
}

class MultiplicationApp extends StatelessWidget {
  const MultiplicationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      initialRoute: RoutePaths.multiplicationSelection,
      onGenerateRoute: Routes.generateRoute,
      debugShowCheckedModeBanner: false, // Opcional: oculta el banner de debug
    );
  }
}
