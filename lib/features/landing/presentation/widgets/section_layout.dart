import 'package:flutter/material.dart';
import 'package:multy_app/core/constants/app_colors.dart';
import '../theme/landing_theme.dart';
import 'visual_elements.dart';

class SectionShell extends StatelessWidget {
  const SectionShell({
    super.key,
    required this.child,
    this.color = AppColors.surface,
    this.maxWidth = LandingTheme.maxWidth,
    this.verticalPadding = 88,
  });
  final Widget child;
  final Color color;
  final double maxWidth;
  final double verticalPadding;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: color,
    child: LayoutBuilder(
      builder: (context, constraints) => Padding(
        padding: EdgeInsets.symmetric(
          horizontal: constraints.maxWidth < 600 ? 20 : 48,
          vertical: constraints.maxWidth < 600
              ? verticalPadding * .7
              : verticalPadding,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: child,
          ),
        ),
      ),
    ),
  );
}

class SectionHeading extends StatelessWidget {
  const SectionHeading({
    super.key,
    this.badge,
    required this.title,
    this.description,
    this.centered = true,
    this.large = true,
    this.badgeColor = AppColors.primaryFixed,
  });
  final String? badge;
  final String title;
  final String? description;
  final bool centered;
  final bool large;
  final Color badgeColor;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 600;
    return Column(
      crossAxisAlignment: centered
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        if (badge != null) ...[
          BadgePill(label: badge!, color: badgeColor),
          const SizedBox(height: 16),
        ],
        Semantics(
          header: true,
          child: Text(
            title,
            textAlign: centered ? TextAlign.center : TextAlign.start,
            style: large
                ? LandingTheme.display(compact)
                : LandingTheme.heading(compact),
          ),
        ),
        if (description != null) ...[
          const SizedBox(height: 16),
          Text(
            description!,
            style: LandingTheme.bodyLarge,
            textAlign: centered ? TextAlign.center : TextAlign.start,
          ),
        ],
      ],
    );
  }
}

/// Wrap gives cards intrinsic height, including at large accessibility text sizes.
class ResponsiveCards extends StatelessWidget {
  const ResponsiveCards({
    super.key,
    required this.children,
    this.maxColumns = 3,
    this.minCardWidth = 260,
    this.spacing = 24,
  });
  final List<Widget> children;
  final int maxColumns;
  final double minCardWidth;
  final double spacing;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      final scale = MediaQuery.textScalerOf(context).scale(15) / 15;
      final columns =
          ((box.maxWidth + spacing) / (minCardWidth * scale + spacing))
              .floor()
              .clamp(1, maxColumns);
      final width = (box.maxWidth - spacing * (columns - 1)) / columns;
      return Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: [
          for (final child in children) SizedBox(width: width, child: child),
        ],
      );
    },
  );
}
