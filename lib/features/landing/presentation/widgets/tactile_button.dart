import 'package:flutter/material.dart';
import 'package:multy_app/core/constants/app_colors.dart';
import '../theme/landing_theme.dart';

class TactileButton extends StatefulWidget {
  const TactileButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.light = false,
    this.compact = false,
  });
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool light;
  final bool compact;
  @override
  State<TactileButton> createState() => _TactileButtonState();
}

class _TactileButtonState extends State<TactileButton> {
  bool _pressed = false;
  @override
  Widget build(BuildContext context) {
    final foreground = widget.light
        ? AppColors.onSurface
        : AppColors.onPrimaryContainer;
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: AnimatedContainer(
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 100),
        transform: Matrix4.translationValues(0, _pressed ? 4 : 0, 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: widget.light ? const Color(0x33000000) : AppColors.primary,
              offset: Offset(0, _pressed ? 0 : 5),
            ),
          ],
        ),
        child: Material(
          borderRadius: BorderRadius.circular(999),
          color: widget.light ? Colors.white : AppColors.primaryContainer,
          child: InkWell(
            onTap: widget.onPressed,
            onHighlightChanged: (value) => setState(() => _pressed = value),
            borderRadius: BorderRadius.circular(999),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: widget.compact ? 18 : 26,
                  vertical: 14,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(widget.icon, size: 24, color: foreground),
                      const SizedBox(width: 10),
                    ],
                    Flexible(
                      child: Text(
                        widget.label,
                        textAlign: TextAlign.center,
                        style: LandingTheme.label.copyWith(
                          color: foreground,
                          fontSize: widget.compact ? 14 : 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
