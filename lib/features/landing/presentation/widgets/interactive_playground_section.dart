import 'package:flutter/material.dart';
import 'package:multy_app/core/constants/app_colors.dart';
import '../../controllers/quiz_controller.dart';
import '../theme/landing_theme.dart';
import 'section_layout.dart';
import 'tactile_button.dart';
import 'visual_elements.dart';

class InteractivePlaygroundSection extends StatefulWidget {
  const InteractivePlaygroundSection({super.key, this.controller});
  final QuizController? controller;
  @override
  State<InteractivePlaygroundSection> createState() =>
      _InteractivePlaygroundSectionState();
}

class _InteractivePlaygroundSectionState
    extends State<InteractivePlaygroundSection> {
  late QuizController _controller;
  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? QuizController();
  }

  @override
  void didUpdateWidget(covariant InteractivePlaygroundSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      if (oldWidget.controller == null) _controller.dispose();
      _controller = widget.controller ?? QuizController();
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SectionShell(
    color: AppColors.surfaceContainerLow,
    maxWidth: 800,
    child: Column(
      children: [
        const SectionHeading(
          title: 'Try a Mini Multy Challenge',
          large: false,
          description:
              'Tap the correct product below. A little practice goes a long way!',
        ),
        const SizedBox(height: 40),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(
              MediaQuery.sizeOf(context).width < 400 ? 20 : 36,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(40),
              border: Border.all(color: AppColors.surfaceContainerHigh),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x06000000),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: ListenableBuilder(
              listenable: _controller,
              builder: (context, _) => Column(
                children: [
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    runSpacing: 12,
                    spacing: 16,
                    children: [
                      Text(
                        'PRACTICE PREVIEW',
                        style: LandingTheme.badge.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      BadgePill(
                        label: 'Score: ${_controller.score}',
                        color: AppColors.surfaceContainer,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      _controller.question.question,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Rubik',
                        fontSize: 64,
                        height: 1.1,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.9,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ResponsiveCards(
                    maxColumns: 2,
                    minCardWidth: 70,
                    spacing: 16,
                    children: [
                      for (final option in _controller.question.options)
                        _AnswerTile(
                          value: option.value,
                          solved: _controller.solved,
                          correct: option.isCorrect,
                          onTap: () => _controller.submit(option.value),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      _controller.feedback,
                      textAlign: TextAlign.center,
                      style: LandingTheme.label.copyWith(
                        color: _controller.solved
                            ? AppColors.primary
                            : AppColors.secondary,
                      ),
                    ),
                  ),
                  if (_controller.solved) ...[
                    const SizedBox(height: 16),
                    TactileButton(
                      label: _controller.isLast
                          ? 'Play again'
                          : 'Next challenge',
                      icon: Icons.arrow_forward_rounded,
                      onPressed: _controller.next,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class _AnswerTile extends StatelessWidget {
  const _AnswerTile({
    required this.value,
    required this.solved,
    required this.correct,
    required this.onTap,
  });
  final int value;
  final bool solved;
  final bool correct;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 4),
            color: solved && correct ? AppColors.primary : AppColors.surfaceDim,
          ),
        ],
      ),
      child: Material(
        color: solved && correct
            ? AppColors.primaryFixed
            : AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: solved ? null : onTap,
          borderRadius: BorderRadius.circular(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 64),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text('$value', style: LandingTheme.cardTitle),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
