import 'package:flutter/material.dart';
import 'package:multy_app/theme/app_fonts.dart';

class MultiplicationCard extends StatelessWidget {
  final String equation;
  final int result;
  final String? accentLabel;
  final bool isPrimary;

  const MultiplicationCard({
    super.key,
    required this.equation,
    required this.result,
    this.accentLabel,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final expression = equation.split('=').first.trim();

    return Container(
      key: isPrimary ? const Key('study-hero-card') : null,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.98),
            const Color(0xFFF4FBFF),
            const Color(0xFFE5FFF3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.78)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.18),
            blurRadius: 28,
            offset: const Offset(0, 18),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact =
              constraints.maxHeight < 340 || constraints.maxWidth < 340;
          final expressionFontSize = 46.0;
          final resultFontSize = 102.0;
          final badgeFontSize = 12.0;
          final chromeSpacing = 8.0;
          final outerPadding = 14.0;

          return Stack(
            children: [
              Positioned(
                top: -24,
                right: -12,
                child: Container(
                  width: compact ? 72 : 120,
                  height: compact ? 72 : 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colorScheme.primary.withValues(alpha: 0.08),
                  ),
                ),
              ),
              Positioned(
                bottom: -40,
                left: -14,
                child: Container(
                  width: compact ? 88 : 140,
                  height: compact ? 88 : 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colorScheme.secondary.withValues(alpha: 0.08),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  outerPadding,
                  compact ? 14 : 26,
                  outerPadding,
                  compact ? 16 : 30,
                ),
                child: compact
                    ? Column(
                        children: [
                          Align(
                            alignment: Alignment.topRight,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.primary.withValues(
                                  alpha: 0.12,
                                ),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                accentLabel ?? '',
                                style: TextStyle(
                                  fontFamily: AppFonts.display,
                                  fontSize: badgeFontSize,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      expression,
                                      style: TextStyle(
                                        fontFamily: AppFonts.display,
                                        fontSize: expressionFontSize,
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.onSurface,
                                        letterSpacing: 0.4,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      result.toString(),
                                      style: TextStyle(
                                        fontFamily: AppFonts.display,
                                        fontSize: resultFontSize,
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.primary,
                                        height: 1,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          Align(
                            alignment: Alignment.topRight,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: compact ? 8 : 12,
                                vertical: compact ? 5 : 7,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.primary.withValues(
                                  alpha: 0.12,
                                ),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                accentLabel ?? '',
                                style: TextStyle(
                                  fontFamily: AppFonts.display,
                                  fontSize: badgeFontSize,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: Center(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      expression,
                                      style: TextStyle(
                                        fontFamily: AppFonts.display,
                                        fontSize: expressionFontSize,
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.onSurface,
                                        letterSpacing: compact ? 0.5 : 1.2,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: chromeSpacing),
                                    Container(
                                      width: compact ? 56 : 88,
                                      height: compact ? 8 : 10,
                                      decoration: BoxDecoration(
                                        color: colorScheme.secondary.withValues(
                                          alpha: 0.18,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                      ),
                                      child: Center(
                                        child: Container(
                                          width: compact ? 18 : 30,
                                          height: compact ? 8 : 10,
                                          decoration: BoxDecoration(
                                            color: colorScheme.secondary,
                                            borderRadius: BorderRadius.circular(
                                              999,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: chromeSpacing),
                                    Text(
                                      '=',
                                      style: TextStyle(
                                        fontFamily: AppFonts.display,
                                        fontSize: compact ? 24 : 34,
                                        color: colorScheme.secondary,
                                      ),
                                    ),
                                    SizedBox(height: compact ? 4 : 8),
                                    Text(
                                      result.toString(),
                                      style: TextStyle(
                                        fontFamily: AppFonts.display,
                                        fontSize: resultFontSize,
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.primary,
                                        height: 1,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'Answer',
                                      style: TextStyle(
                                        color: colorScheme.onSurfaceVariant,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.6,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
