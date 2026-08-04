import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'dart:async';

import 'package:multy_app/configs/profile_avatar_catalog.dart';
import 'package:multy_app/l10n/app_localizations.dart';
import 'package:multy_app/providers/profile_provider.dart';
import 'package:multy_app/providers/quiz_attemp_provider.dart';
import 'package:multy_app/providers/quiz_notifier.dart'; // Importa el Notifier y el QuizResult
import 'package:multy_app/services/feedback_service.dart';
import 'package:multy_app/theme/app_fonts.dart';
import 'package:multy_app/utils/emoji.dart';
import 'package:provider/provider.dart';

import 'package:multy_app/widgets/quiz_result/confetti_animation.dart';
import 'package:multy_app/widgets/quiz_result/main_button.dart';
import 'package:multy_app/widgets/quiz_result/main_outline_button.dart'; // Importa el paquete de confeti

class QuizResultScreenArguments {
  final QuizResult result;
  final int tableNumber;

  QuizResultScreenArguments({required this.result, required this.tableNumber});
}

class QuizResultScreen extends StatefulWidget {
  static const routeName = '/quiz-result';

  // Los argumentos se pasan a través de la ruta
  final QuizResultScreenArguments args;

  const QuizResultScreen({super.key, required this.args});

  @override
  State<QuizResultScreen> createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends State<QuizResultScreen> {
  late ConfettiController _confettiController;
  bool _didLoadPerformanceSnapshot = false;
  int? _bestTimeInSeconds;
  bool _isNewBestTime = false;
  bool _showScoreHighlight = false;
  Timer? _scoreHighlightTimer;

  String _buildPersistenceMessage(QuizResult result) {
    final isSpanish = Localizations.localeOf(context).languageCode == 'es';
    if (result.wasSaved) {
      final profileName = result.savedProfileName;
      if (profileName == null || profileName.isEmpty) {
        return isSpanish ? 'Sesion guardada.' : 'Session saved.';
      }
      return isSpanish
          ? 'Sesion guardada en $profileName.'
          : 'Session saved to $profileName.';
    }

    if (result.isGuestSession) {
      return isSpanish
          ? 'Sesion de invitado: este resultado no se guardo.'
          : 'Guest session: this result was not saved.';
    }

    return isSpanish
        ? 'Este resultado no se guardo.'
        : 'This result was not saved.';
  }

  Color _persistenceColor(QuizResult result) {
    if (result.wasSaved) {
      return Colors.green.shade50;
    }
    if (result.isGuestSession) {
      return Colors.orange.shade50;
    }
    return Colors.grey.shade200;
  }

  Color _persistenceBorderColor(QuizResult result) {
    if (result.wasSaved) {
      return Colors.green.shade200;
    }
    if (result.isGuestSession) {
      return Colors.orange.shade200;
    }
    return Colors.grey.shade400;
  }

  _CelebrationTone _celebrationToneFor(QuizResult result) {
    if (result.percentage >= 90) {
      return const _CelebrationTone(
        backgroundStart: Color(0xFF2E7D32),
        backgroundEnd: Color(0xFF81C784),
        accent: Color(0xFFFFF59D),
      );
    }
    if (result.percentage >= 70) {
      return const _CelebrationTone(
        backgroundStart: Color(0xFF00897B),
        backgroundEnd: Color(0xFF80CBC4),
        accent: Color(0xFFB2DFDB),
      );
    }
    return const _CelebrationTone(
      backgroundStart: Color(0xFFEF6C00),
      backgroundEnd: Color(0xFFFFCC80),
      accent: Color(0xFFFFE082),
    );
  }

  String _celebrationHeadline(QuizResult result) {
    final isSpanish = Localizations.localeOf(context).languageCode == 'es';
    if (result.percentage >= 90) {
      return isSpanish ? 'Increible trabajo' : 'Amazing work';
    }
    if (result.percentage >= 70) {
      return isSpanish ? 'Vas super bien' : 'You are doing great';
    }
    return isSpanish ? 'Buen intento' : 'Nice try';
  }

  String _celebrationSubtitle(QuizResult result) {
    final isSpanish = Localizations.localeOf(context).languageCode == 'es';
    if (result.percentage >= 90) {
      return isSpanish
          ? 'Segui asi y cada tabla sera mas facil.'
          : 'Keep going and every table will feel easier.';
    }
    if (result.percentage >= 70) {
      return isSpanish
          ? 'Ya tienes una buena base. Una ronda mas y subes aun mas.'
          : 'You already have a strong base. One more round and you will climb higher.';
    }
    return isSpanish
        ? 'Cada intento cuenta. Otra practica corta puede marcar la diferencia.'
        : 'Every try counts. One more short practice can make a big difference.';
  }

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 10),
    );
    // Reproducir confeti si el usuario aprobó
    if (widget.args.result.passed) {
      // WidgetsBinding.instance.addPostFrameCallback((_) {
      _confettiController.play();
      // });
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FeedbackService.instance.playResultCelebration(
        passed: widget.args.result.passed,
      );
    });
    _scoreHighlightTimer = Timer(const Duration(milliseconds: 120), () {
      if (!mounted) {
        return;
      }
      setState(() {
        _showScoreHighlight = true;
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didLoadPerformanceSnapshot) {
      return;
    }
    _didLoadPerformanceSnapshot = true;
    _loadPerformanceSnapshot();
  }

  Future<void> _loadPerformanceSnapshot() async {
    final result = widget.args.result;
    final currentDuration = result.durationInSeconds;
    var resolvedBestTime = currentDuration;

    final quizAttemptProvider = Provider.of<QuizAttempProvider?>(
      context,
      listen: false,
    );
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    final activeProfileId = profileProvider.activeProfile?.id;

    if (quizAttemptProvider != null &&
        result.wasSaved &&
        !result.isGuestSession &&
        activeProfileId != null &&
        activeProfileId > 0) {
      final stats = await quizAttemptProvider.getAllTableOverallStats(
        profileId: activeProfileId,
      );
      for (final entry in stats) {
        if (entry.tableNumber == widget.args.tableNumber) {
          resolvedBestTime = entry.bestTimeInSeconds ?? resolvedBestTime;
          break;
        }
      }
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _bestTimeInSeconds = resolvedBestTime;
      _isNewBestTime =
          currentDuration != null &&
          resolvedBestTime != null &&
          currentDuration == resolvedBestTime;
    });
  }

  String _formatDuration(int? totalSeconds) {
    if (totalSeconds == null || totalSeconds < 0) {
      return '--:--';
    }

    final duration = Duration(seconds: totalSeconds);
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _scoreHighlightTimer?.cancel();
    _confettiController.dispose(); // ¡Importante!
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final result = widget.args.result;
    final tableNumber = widget.args.tableNumber;
    final emoji = Emoji.getEmojiForScore(result.percentage);
    final profileProvider = context.read<ProfileProvider>();
    final activeProfile = profileProvider.activeProfile;
    final celebrationTone = _celebrationToneFor(result);
    final accuracyValue = '${result.percentage.toStringAsFixed(0)}%';
    final displayProfileName =
        result.savedProfileName ??
        activeProfile?.name ??
        (result.isGuestSession
            ? (Localizations.localeOf(context).languageCode == 'es'
                ? 'Invitado'
                : 'Guest')
            : '');
    final avatarEmoji = result.isGuestSession
        ? '⚡'
        : ProfileAvatarCatalog.emojiForKey(activeProfile?.avatarKey ?? 'star');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.quizResultScreenTitle(tableNumber),
        ),
        backgroundColor: result.passed
            ? Colors.green.shade600
            : Colors.red.shade400,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false, // Quita el botón de atrás por defecto
        centerTitle: true,
      ),
      body: PopScope(
        canPop: false,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white,
                    celebrationTone.accent.withValues(alpha: 0.12),
                    celebrationTone.backgroundEnd.withValues(alpha: 0.1),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: const SizedBox.expand(),
            ),
            Align(
              alignment: Alignment.center,
              child: ConfettiAnimation(confettiController: _confettiController),
            ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 78)),
                    const SizedBox(height: 16),
                    _CelebrationCard(
                      profileName: displayProfileName,
                      avatarEmoji: avatarEmoji,
                      headline: _celebrationHeadline(result),
                      subtitle: _celebrationSubtitle(result),
                      tone: celebrationTone,
                    ),
                    const SizedBox(height: 18),
                    _ScoreHighlightCard(
                      isVisible: _showScoreHighlight,
                      accuracyValue: accuracyValue,
                      scoreLabel: l10n.quizScoreDetailed(
                        result.score,
                        result.totalQuestions,
                      ),
                      tone: celebrationTone,
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _ResultMetricCard(
                          key: const Key('quiz-result-metric-correct'),
                          width: 150,
                          icon: Icons.check_circle_rounded,
                          label: l10n.quizResultCorrectLabel,
                          value: '${result.score}/${result.totalQuestions}',
                          accent: Colors.green.shade600,
                          background: Colors.green.shade50,
                        ),
                        _ResultMetricCard(
                          key: const Key('quiz-result-metric-time'),
                          width: 150,
                          icon: Icons.timer_outlined,
                          label: l10n.quizResultTimeLabel,
                          value: _formatDuration(result.durationInSeconds),
                          accent: Colors.blue.shade700,
                          background: Colors.blue.shade50,
                        ),
                        _ResultMetricCard(
                          key: const Key('quiz-result-metric-best-time'),
                          width: 312,
                          icon: _isNewBestTime
                              ? Icons.workspace_premium_rounded
                              : Icons.bolt_rounded,
                          label: _isNewBestTime
                              ? l10n.quizResultNewRecord
                              : l10n.quizResultBestTimeLabel,
                          value: _bestTimeInSeconds != null
                              ? l10n.bestTime(_formatDuration(_bestTimeInSeconds))
                              : l10n.quizResultKeepGoing,
                          accent: _isNewBestTime
                              ? Colors.amber.shade800
                              : Colors.deepPurple.shade600,
                          background: _isNewBestTime
                              ? const Color(0xFFFFF7D6)
                              : const Color(0xFFF2EEFF),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: _persistenceColor(result),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _persistenceBorderColor(result),
                        ),
                      ),
                      child: Text(
                        _buildPersistenceMessage(result),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 26),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        MainButton(
                          key: const Key('quiz-result-primary-cta'),
                          onPressed: () {
                            Navigator.pop(
                              context,
                              1,
                            ); // Devuelve 'true' para reintentar
                          },
                          label: l10n.quizRetryButton,
                          icon: const Icon(Icons.refresh),
                          helperText: l10n.quizResultRetryHint,
                        ),
                        MainOutlineButton(
                          onPressed: () {
                            // Volver hasta la pantalla de selección de tabla
                            // Navigator.pushReplacementNamed(context, RoutePaths.multiplicationSelection);
                            Navigator.popUntil(
                              context,
                              ModalRoute.withName('/'),
                            );
                          },
                          label: l10n.quizMainMenuButton,
                          icon: const Icon(Icons.home_outlined),
                        ),
                      ],
                    ),
                    if (result.timedOut) ...[
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Text(
                          l10n.quizResultTimedOutInfo,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.orange.shade900,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CelebrationCard extends StatelessWidget {
  const _CelebrationCard({
    required this.profileName,
    required this.avatarEmoji,
    required this.headline,
    required this.subtitle,
    required this.tone,
  });

  final String profileName;
  final String avatarEmoji;
  final String headline;
  final String subtitle;
  final _CelebrationTone tone;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('quiz-result-celebration-card'),
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [tone.backgroundStart, tone.backgroundEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: tone.backgroundStart.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white.withValues(alpha: 0.18),
            child: Text(avatarEmoji, style: const TextStyle(fontSize: 28)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (profileName.isNotEmpty)
                  Text(
                    profileName,
                    style: TextStyle(
                      color: tone.accent,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                Text(
                  headline,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: AppFonts.display,
                    fontSize: 24,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.92),
                    fontWeight: FontWeight.w600,
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

class _ScoreHighlightCard extends StatelessWidget {
  const _ScoreHighlightCard({
    required this.isVisible,
    required this.accuracyValue,
    required this.scoreLabel,
    required this.tone,
  });

  final bool isVisible;
  final String accuracyValue;
  final String scoreLabel;
  final _CelebrationTone tone;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      key: const Key('quiz-result-score-animated'),
      scale: isVisible ? 1 : 0.92,
      duration: const Duration(milliseconds: 340),
      curve: Curves.easeOutBack,
      child: AnimatedOpacity(
        opacity: isVisible ? 1 : 0,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
        child: Container(
          key: const Key('quiz-result-score-card'),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: tone.accent.withValues(alpha: 0.7),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: tone.backgroundStart.withValues(alpha: 0.12),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                accuracyValue,
                style: TextStyle(
                  fontFamily: AppFonts.display,
                  fontSize: 52,
                  height: 0.95,
                  color: tone.backgroundStart,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                scoreLabel,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: AppFonts.body,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultMetricCard extends StatelessWidget {
  const _ResultMetricCard({
    super.key,
    required this.width,
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
    required this.background,
  });

  final double width;
  final IconData icon;
  final String label;
  final String value;
  final Color accent;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: accent.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: accent),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              color: accent,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontFamily: AppFonts.body,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              height: 1.15,
            ),
          ),
        ],
      ),
    );
  }
}

class _CelebrationTone {
  const _CelebrationTone({
    required this.backgroundStart,
    required this.backgroundEnd,
    required this.accent,
  });

  final Color backgroundStart;
  final Color backgroundEnd;
  final Color accent;
}
