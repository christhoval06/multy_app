import 'package:flutter/material.dart';

class ContentUnavailableView extends StatelessWidget {
  final IconData? icon;
  final String? imageAsset;
  final String? title;
  final String? message;
  final String? actionText;
  final VoidCallback? onAction;

  const ContentUnavailableView({
    Key? key,
    this.icon,
    this.imageAsset,
    this.title,
    this.message,
    this.actionText,
    this.onAction,
  }) : assert(
         icon != null || imageAsset != null,
         'You must provide an icon or image',
       ),
       super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.onSurface.withValues(alpha: 0.6);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) Icon(icon, size: 64, color: color),
            if (imageAsset != null)
              Image.asset(
                imageAsset!,
                height: 120,
                color: color,
                fit: BoxFit.contain,
              ),
            if (title != null) ...[
              const SizedBox(height: 8),
              Text(
                title!,
                style: theme.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
            ],
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                style: theme.textTheme.bodyMedium?.copyWith(color: color),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: 20),
              ElevatedButton(onPressed: onAction, child: Text(actionText!)),
            ],
          ],
        ),
      ),
    );
  }
}
