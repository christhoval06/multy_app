import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:multy_app/configs/app_prefs.dart';
import 'package:multy_app/configs/route_paths.dart';
import 'package:multy_app/l10n/app_localizations.dart';
import 'package:multy_app/widgets/onboarding/onboarding_item.dart';
import 'package:multy_app/widgets/onboarding/onboarding_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const int _slideCount = 3;
  final PageController _pageController = PageController();
  double _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppPrefs.onboardingComplete, true);

    if (mounted) {
      Navigator.of(context).pushReplacementNamed(RoutePaths.main);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final slides = <OnboardingItem>[
      OnboardingItem(
        icon: Icons.calculate_rounded,
        title: l10n.onboardingSlide1Title,
        description: l10n.onboardingSlide1Description,
        color: const Color(0xFFFFAB40),
      ),
      OnboardingItem(
        icon: Icons.flash_on_rounded,
        title: l10n.onboardingSlide2Title,
        description: l10n.onboardingSlide2Description,
        color: const Color(0xFF2E7D32),
      ),
      OnboardingItem(
        icon: Icons.emoji_events_rounded,
        title: l10n.onboardingSlide3Title,
        description: l10n.onboardingSlide3Description,
        color: const Color(0xFF1565C0),
      ),
    ];

    final isLastPage = _currentPage == slides.length - 1;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface.withValues(alpha: 0),
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _completeOnboarding,
            child: Text(l10n.onboardingSkip),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: slides.length,
                itemBuilder: (context, index) {
                  final item = slides[index];
                  return OnboardingPage(slide: item);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 20.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DotsIndicator(
                    dotsCount: slides.length,
                    position: _currentPage,
                    decorator: DotsDecorator(
                      color: theme.colorScheme.outlineVariant,
                      activeColor: theme.colorScheme.primary,
                      size: const Size.square(9.0),
                      activeSize: const Size(
                        24.0,
                        9.0,
                      ), // Hace que el punto activo sea más ancho
                      activeShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                  ),

                  FilledButton(
                    onPressed: () {
                      if (isLastPage) {
                        _completeOnboarding();
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    style: FilledButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(16),
                    ),
                    child: Icon(isLastPage ? Icons.check : Icons.arrow_forward),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
