import 'package:flutter/material.dart';
import 'package:multy_app/core/constants/app_colors.dart';
import '../../data/landing_content.dart';
import '../theme/landing_theme.dart';
import '../widgets/section_layout.dart';
import '../widgets/tactile_button.dart';
import '../widgets/visual_elements.dart';

class DownloadSection extends StatelessWidget {
  const DownloadSection({super.key, required this.onDownload});
  final VoidCallback onDownload;
  @override
  Widget build(BuildContext context) => SectionShell(
    child: Container(
      padding: EdgeInsets.all(MediaQuery.sizeOf(context).width < 600 ? 28 : 56),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(48),
        gradient: const LinearGradient(
          colors: [
            AppColors.primaryContainer,
            AppColors.primary,
            AppColors.secondaryContainer,
          ],
          stops: [0, .55, 1],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x20206D00),
            blurRadius: 30,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, box) {
          final copy = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BadgePill(
                label: 'Start learning in minutes',
                color: Colors.white.withValues(alpha: .18),
                foreground: Colors.white,
              ),
              const SizedBox(height: 20),
              Semantics(
                header: true,
                child: Text(
                  'Ready to Make Multiplication Click?',
                  style: LandingTheme.display(
                    box.maxWidth < 600,
                  ).copyWith(color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Download Multy today and empower your child with the speed, memory skills, and confidence to conquer math with a smile.',
                style: LandingTheme.bodyLarge.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 20),
              Text(
                'Made for iPhone & iPad. Learn at your own pace.',
                style: LandingTheme.body.copyWith(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ],
          );
          final action = Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.asset(
                    LandingContent.icon,
                    width: 100,
                    height: 100,
                    semanticLabel: 'Multy app icon',
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TactileButton(
                label: 'Get Multy on App Store',
                icon: Icons.apple,
                light: true,
                onPressed: onDownload,
              ),
            ],
          );
          if (box.maxWidth < 960 ||
              MediaQuery.textScalerOf(context).scale(15) > 20) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                copy,
                const SizedBox(height: 40),
                Align(alignment: Alignment.centerLeft, child: action),
              ],
            );
          }
          return Row(
            children: [
              Expanded(flex: 6, child: copy),
              const SizedBox(width: 48),
              Expanded(flex: 4, child: action),
            ],
          );
        },
      ),
    ),
  );
}
