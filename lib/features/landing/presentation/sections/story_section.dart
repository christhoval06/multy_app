import 'package:flutter/material.dart';
import 'package:multy_app/core/constants/app_colors.dart';
import '../theme/landing_theme.dart';
import '../widgets/section_layout.dart';
import '../widgets/visual_elements.dart';

class StorySection extends StatelessWidget {
  const StorySection({super.key, required this.onDeveloper});
  final VoidCallback onDeveloper;
  @override
  Widget build(BuildContext context) => SectionShell(
    color: AppColors.surfaceContainerLow,
    maxWidth: 1040,
    child: Container(
      padding: EdgeInsets.all(MediaQuery.sizeOf(context).width < 600 ? 28 : 56),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(48),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Colors.white, Color(0xFFFFF1E1)],
        ),
        border: Border.all(color: AppColors.surfaceContainerHigh),
      ),
      child: LayoutBuilder(
        builder: (context, box) {
          final emblem = Container(
            width: 144,
            height: 144,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
                colors: [AppColors.primary, AppColors.primaryFixed],
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0x26206D00),
                  blurRadius: 24,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.favorite_border_rounded,
              color: Colors.white,
              size: 56,
            ),
          );
          final copy = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BadgePill(
                label: 'The story behind Multy',
                color: AppColors.secondaryFixed,
              ),
              const SizedBox(height: 16),
              Semantics(
                header: true,
                child: Text(
                  '“Built with love for my son Dion Barba”',
                  style: LandingTheme.heading(box.maxWidth < 600),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '“Multy was born at our kitchen table. Watching my son Dion navigate his first times tables, I noticed traditional flashcards felt repetitive and digital alternatives were filled with noisy ads and endless logins. We needed something clean, fast, delightfully tactile, and completely private.”',
                style: LandingTheme.bodyLarge.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 24),
              const Text('Christhoval Barba', style: LandingTheme.label),
              const SizedBox(height: 4),
              const Text(
                'Father & Independent Software Engineer',
                style: LandingTheme.body,
              ),
              TextButton(
                onPressed: onDeveloper,
                child: const Text('s.christhoval.dev ↗'),
              ),
            ],
          );
          if (box.maxWidth < 700) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [emblem, const SizedBox(height: 32), copy],
            );
          }
          return Row(
            children: [
              emblem,
              const SizedBox(width: 40),
              Expanded(child: copy),
            ],
          );
        },
      ),
    ),
  );
}
