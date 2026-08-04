import 'package:flutter/material.dart';
import 'package:multy_app/l10n/app_localizations.dart';
import 'package:multy_app/configs/route_paths.dart';
import 'package:multy_app/providers/profile_provider.dart';
import 'package:multy_app/theme/app_fonts.dart';
import 'package:multy_app/widgets/home/profile_selector.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final profileProvider = context.watch<ProfileProvider>();
    final hasSelection = profileProvider.hasSelection;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.settingsAppName,
        ), // Ej: "Tabla del 7: ¿Qué quieres hacer?"
        centerTitle: true,
        actions: [
          IconButton(
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),
            const ProfileSelector(),
            const SizedBox(height: 18),
            _SelectionStatusCard(profileProvider: profileProvider),
            const SizedBox(height: 24),
            _HomeHeroCard(
              greeting: l10n.homeGreeting,
              hasSelection: hasSelection,
            ),
            const SizedBox(height: 24),
            _HomeActionCard(
              containerKey: const Key('home-study-card'),
              buttonKey: const Key('home-study-button'),
              title: l10n.studyAction,
              icon: Icons.menu_book_rounded,
              colors: [
                Colors.lightBlue.shade200,
                Colors.cyan.shade100,
              ],
              foregroundColor: Colors.blue.shade900,
              onPressed: hasSelection
                  ? () {
                      Navigator.pushNamed(
                        context,
                        RoutePaths.multiplication,
                        arguments: RoutePaths.study,
                      );
                    }
                  : null,
            ),
            const SizedBox(height: 24),
            _HomeActionCard(
              containerKey: const Key('home-quiz-card'),
              buttonKey: const Key('home-quiz-button'),
              title: l10n.quizAction,
              icon: Icons.quiz_rounded,
              colors: [
                Colors.lightGreen.shade200,
                Colors.amber.shade100,
              ],
              foregroundColor: Colors.green.shade900,
              onPressed: hasSelection
                  ? () {
                      Navigator.pushNamed(
                        context,
                        RoutePaths.multiplication,
                        arguments: RoutePaths.multiplicationQuiz,
                      );
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeHeroCard extends StatelessWidget {
  const _HomeHeroCard({
    required this.greeting,
    required this.hasSelection,
  });

  final String greeting;
  final bool hasSelection;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.96, end: 1),
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: Container(
        key: const Key('home-hero-card'),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.deepOrange.shade300,
              Colors.orange.shade200,
              Colors.amber.shade100,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.shade200.withValues(alpha: 0.5),
              blurRadius: 26,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                size: 38,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    greeting,
                    style: const TextStyle(
                      fontFamily: AppFonts.display,
                      fontSize: 28,
                      color: Colors.white,
                      height: 1.05,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _HeroTag(
                        label: hasSelection ? 'Listo para jugar' : 'Elige un perfil',
                        icon: hasSelection
                            ? Icons.check_circle_outline_rounded
                            : Icons.touch_app_rounded,
                      ),
                      const _HeroTag(
                        label: 'Sesiones cortas',
                        icon: Icons.timer_outlined,
                      ),
                    ],
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

class _HeroTag extends StatelessWidget {
  const _HeroTag({
    required this.label,
    required this.icon,
  });

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontFamily: AppFonts.body,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeActionCard extends StatelessWidget {
  const _HomeActionCard({
    required this.containerKey,
    required this.buttonKey,
    required this.title,
    required this.icon,
    required this.colors,
    required this.foregroundColor,
    required this.onPressed,
  });

  final Key containerKey;
  final Key buttonKey;
  final String title;
  final IconData icon;
  final List<Color> colors;
  final Color foregroundColor;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: isEnabled ? 1 : 0.72,
      child: Container(
        key: containerKey,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: colors.first.withValues(alpha: 0.28),
              blurRadius: 22,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: ElevatedButton(
          key: buttonKey,
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: foregroundColor,
            disabledBackgroundColor: Colors.transparent,
            disabledForegroundColor: foregroundColor.withValues(alpha: 0.75),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 26),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.72),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(icon, size: 34),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_rounded,
                size: 28,
                color: foregroundColor.withValues(alpha: 0.85),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectionStatusCard extends StatelessWidget {
  const _SelectionStatusCard({required this.profileProvider});

  final ProfileProvider profileProvider;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    final bool hasPersistentSelection = profileProvider.hasPersistentSelection;
    final bool isGuestSelected = profileProvider.isGuestSelected;

    final title = hasPersistentSelection
        ? l10n.homeProfileActiveSummary(profileProvider.activeProfile!.name)
        : isGuestSelected
        ? l10n.homeProfileGuestSummary
        : l10n.homeProfileSelectionRequired;
    final subtitle = hasPersistentSelection
        ? l10n.homeProfileActiveHelper
        : isGuestSelected
        ? l10n.homeProfileGuestHelper
        : l10n.homeProfileNoSelectionHelper;
    final icon = hasPersistentSelection
        ? Icons.verified_user_rounded
        : isGuestSelected
        ? Icons.flash_on_rounded
        : Icons.touch_app_rounded;
    final backgroundColor = hasPersistentSelection
        ? colorScheme.primaryContainer
        : isGuestSelected
        ? colorScheme.tertiaryContainer
        : colorScheme.surfaceContainerHighest;
    final foregroundColor = hasPersistentSelection
        ? colorScheme.onPrimaryContainer
        : isGuestSelected
        ? colorScheme.onTertiaryContainer
        : colorScheme.onSurfaceVariant;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: foregroundColor.withValues(alpha: 0.12),
            foregroundColor: foregroundColor,
            child: Icon(icon),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: foregroundColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: foregroundColor.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
