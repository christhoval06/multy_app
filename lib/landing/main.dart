import 'package:flutter/material.dart';
import 'package:multy_app/features/landing/landing_page.dart';
import 'package:multy_app/features/landing/presentation/theme/landing_theme.dart';

void main() => runApp(const MultyLandingApp());

class MultyLandingApp extends StatelessWidget {
  const MultyLandingApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Multy — Math Made Fun for Kids',
    debugShowCheckedModeBanner: false,
    theme: LandingTheme.data,
    home: const LandingPage(),
  );
}
