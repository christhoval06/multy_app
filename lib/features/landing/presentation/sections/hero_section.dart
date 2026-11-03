import 'package:flutter/material.dart';
import 'package:multy_app/core/constants/app_colors.dart';
import '../theme/landing_theme.dart';
import '../widgets/section_layout.dart';
import '../widgets/tactile_button.dart';
import '../widgets/visual_elements.dart';
import 'hero_showcase.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({
    super.key,
    required this.onDownload,
    required this.onHowItWorks,
  });
  final VoidCallback onDownload;
  final VoidCallback onHowItWorks;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(
      gradient: RadialGradient(
        center: Alignment(.9, -.2),
        radius: 1,
        colors: [Color(0xFFFFEBD2), AppColors.surface],
      ),
    ),
    child: SectionShell(
      color: Colors.transparent,
      verticalPadding: 64,
      child: LayoutBuilder(
        builder: (context, box) {
          final wide =
              box.maxWidth >= 880 &&
              MediaQuery.textScalerOf(context).scale(15) < 24;
          final copy = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BadgePill(
                label: 'Math made fun for curious kids',
                icon: Icons.auto_awesome,
              ),
              const SizedBox(height: 24),
              Semantics(
                header: true,
                child: Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(text: 'Turn Multiplication into an '),
                      TextSpan(
                        text: 'Exciting Adventure',
                        style: TextStyle(color: AppColors.primaryContainer),
                      ),
                    ],
                  ),
                  style: LandingTheme.display(box.maxWidth < 600),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'A fun, fast, and tactile way to master times tables 1 to 12 through bite-sized practice, dynamic flashcards, and 60-second speed challenges.',
                style: LandingTheme.bodyLarge,
              ),
              const SizedBox(height: 28),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  TactileButton(
                    label: 'Download on App Store',
                    icon: Icons.apple,
                    onPressed: onDownload,
                  ),
                  TextButton.icon(
                    onPressed: onHowItWorks,
                    icon: const Icon(Icons.play_circle_outline),
                    label: const Text('See How It Works'),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Wrap(
                spacing: 22,
                runSpacing: 16,
                children: const [
                  _TrustNote(
                    icon: Icons.verified_user_outlined,
                    label: 'Kid safe & ad-free',
                    color: AppColors.primary,
                  ),
                  _TrustNote(
                    icon: Icons.person_off_outlined,
                    label: 'No account required',
                    color: AppColors.secondary,
                  ),
                  _TrustNote(
                    icon: Icons.translate,
                    label: 'English & Spanish',
                    color: AppColors.tertiary,
                  ),
                ],
              ),
            ],
          );
          if (!wide) {
            return Column(
              children: [
                copy,
                const SizedBox(height: 48),
                const HeroShowcase(),
              ],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(flex: 7, child: copy),
              const SizedBox(width: 40),
              const Expanded(flex: 5, child: HeroShowcase()),
            ],
          );
        },
      ),
    ),
  );
}

class _TrustNote extends StatelessWidget {
  const _TrustNote({
    required this.icon,
    required this.label,
    required this.color,
  });
  final IconData icon;
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 20, color: color),
      const SizedBox(width: 8),
      Flexible(
        child: Text(label, style: LandingTheme.label.copyWith(fontSize: 12)),
      ),
    ],
  );
}
