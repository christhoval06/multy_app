import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:multy_app/configs/settings.dart';
import 'package:multy_app/l10n/app_localizations.dart';
import 'package:multy_app/services/timer_settings_service.dart';
import 'package:multy_app/widgets/study_table/fun_fact_widget.dart';
import 'package:multy_app/widgets/study_table/multiplication_card.dart';
import 'package:multy_app/widgets/study_table/progress_indicator_widget.dart';
import 'package:provider/provider.dart';

class StudyTableScreenArguments {
  final int tableNumber;
  final int maxMultiplier;

  StudyTableScreenArguments({
    required this.tableNumber,
    this.maxMultiplier = Settings.maxTableNumber,
  });
}

class StudyTableScreen extends StatefulWidget {
  final StudyTableScreenArguments args;

  const StudyTableScreen({super.key, required this.args});

  @override
  State<StudyTableScreen> createState() => _StudyTableScreenState();
}

class _StudyTableScreenState extends State<StudyTableScreen>
    with SingleTickerProviderStateMixin {
  final CardSwiperController _swiperController = CardSwiperController();
  Timer? _autoSwipeTimer;
  Timer? _countdownTimer;
  int _currentIndexForSwiper = 0;
  bool _timerSettingsInitialized = false;

  int _swipeIntervalSeconds = Settings.defaultStudyAutoSwipeSeconds;
  bool _isManualSwipeEnabled = false;
  int _timeRemaining = Settings.defaultStudyAutoSwipeSeconds;

  @override
  void initState() {
    super.initState();
    _isManualSwipeEnabled = false;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_timerSettingsInitialized) {
      return;
    }

    final timerSettings = context.read<TimerSettingsService>();
    _swipeIntervalSeconds = timerSettings.readStudyAutoSwipeSeconds();
    _timeRemaining = _swipeIntervalSeconds;
    _timerSettingsInitialized = true;
    _startAutoSwipeTimer();
    _startCountdownTimer();
  }

  void _startAutoSwipeTimer() {
    _autoSwipeTimer?.cancel();
    setState(() {
      _isManualSwipeEnabled = false;
    });

    _autoSwipeTimer = Timer.periodic(
      Duration(seconds: _swipeIntervalSeconds),
      (timer) {
        _swiperController.swipe(CardSwiperDirection.right);
        _resetCountdown();
      },
    );
  }

  void _startCountdownTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeRemaining > 0) {
        setState(() {
          _timeRemaining--;
        });
      }
    });
  }

  void _resetCountdown() {
    setState(() {
      _timeRemaining = _swipeIntervalSeconds;
    });
  }

  void _toggleAutoSwipe() {
    if (_autoSwipeTimer?.isActive ?? false) {
      _autoSwipeTimer?.cancel();
      _countdownTimer?.cancel();
      setState(() {
        _isManualSwipeEnabled = true;
        _timeRemaining = 0;
      });
    } else {
      _startAutoSwipeTimer();
      _startCountdownTimer();
      _resetCountdown();
    }
  }

  @override
  void dispose() {
    _autoSwipeTimer?.cancel();
    _countdownTimer?.cancel();
    _swiperController.dispose();
    super.dispose();
  }

  List<Widget> _generateCards() {
    return List.generate(widget.args.maxMultiplier, (index) {
      final multiplier = index + 1;
      final result = widget.args.tableNumber * multiplier;
      final equation = '${widget.args.tableNumber} x $multiplier = $result';
      return MultiplicationCard(
        equation: equation,
        result: result,
        accentLabel: 'x${widget.args.tableNumber}',
        isPrimary: index == _currentIndexForSwiper,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final cards = _generateCards();
    final currentStep = _currentIndexForSwiper + 1;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 86,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leadingWidth: 72,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16, top: 10, bottom: 10),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colorScheme.onSurface.withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.24),
              ),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              color: Colors.white,
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ),
        ),
        title: Container(
          key: const Key('study-appbar-title'),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: colorScheme.onSurface.withValues(alpha: 0.22),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.22),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Text(
            l10n.studyTableTitle(widget.args.tableNumber.toString()),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.4,
              shadows: const [
                Shadow(
                  color: Color(0x33000000),
                  offset: Offset(0, 2),
                  blurRadius: 6,
                ),
              ],
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFEAFBFF),
              Color(0xFFF0FFF6),
              Color(0xFFE9F0FF),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -60,
              right: -10,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.primary.withValues(alpha: 0.10),
                ),
              ),
            ),
            Positioned(
              left: -40,
              bottom: 120,
              child: Container(
                width: 170,
                height: 170,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.secondary.withValues(alpha: 0.10),
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
                    child: Container(
                      key: const Key('study-screen-hud'),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.78),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withValues(alpha: 0.10),
                            blurRadius: 18,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Table x${widget.args.tableNumber}',
                                      style: TextStyle(
                                        color: colorScheme.primary,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      l10n.studyTableTitle(
                                        widget.args.tableNumber.toString(),
                                      ),
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w900,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                key: const Key('study-timer-badge'),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary,
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(
                                      color: colorScheme.primary.withValues(
                                        alpha: 0.22,
                                      ),
                                      blurRadius: 14,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${_timeRemaining}s',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 20,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    const Text(
                                      'timer',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Container(
                                key: const Key('study-progress-label'),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.secondary.withValues(
                                    alpha: 0.14,
                                  ),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  '$currentStep of ${cards.length}',
                                  style: TextStyle(
                                    color: colorScheme.onSurface,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              FilledButton.icon(
                                onPressed: _toggleAutoSwipe,
                                icon: Icon(
                                  _isManualSwipeEnabled
                                      ? Icons.play_arrow_rounded
                                      : Icons.pause_rounded,
                                ),
                                label: Text(
                                  _isManualSwipeEnabled ? 'Auto play' : 'Pause',
                                ),
                                style: FilledButton.styleFrom(
                                  backgroundColor: colorScheme.secondary,
                                  foregroundColor: colorScheme.onSecondary,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ProgressIndicatorWidget(
                            currentIndex: _currentIndexForSwiper,
                            totalItems: cards.length,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: cards.isEmpty
                        ? const Center(child: Text('No hay tarjetas para mostrar'))
                        : CardSwiper(
                            controller: _swiperController,
                            isDisabled: !_isManualSwipeEnabled,
                            allowedSwipeDirection:
                                const AllowedSwipeDirection.symmetric(
                                  horizontal: true,
                                ),
                            cardsCount: cards.length,
                            onSwipe: _onSwipe,
                            onUndo: _onUndo,
                            numberOfCardsDisplayed: 3,
                            backCardOffset: const Offset(26, -10),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 18,
                            ),
                            cardBuilder:
                                (
                                  context,
                                  index,
                                  horizontalThresholdPercentage,
                                  verticalThresholdPercentage,
                                ) {
                                  return cards[index];
                                },
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 20),
                    child: FunFactWidget(
                      table: widget.args.tableNumber,
                      multiplier: _currentIndexForSwiper + 1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _onSwipe(
    int previousIndex,
    int? currentIndex,
    CardSwiperDirection direction,
  ) {
    debugPrint(
      'Swiped from $previousIndex to $currentIndex in ${direction.name} direction',
    );
    if (currentIndex != null) {
      setState(() {
        _currentIndexForSwiper = currentIndex;
      });
    }
    return true;
  }

  bool _onUndo(
    int? previousIndex,
    int currentIndex,
    CardSwiperDirection direction,
  ) {
    debugPrint('Undo swipe from $currentIndex');
    setState(() {
      _currentIndexForSwiper = currentIndex;
    });
    return true;
  }
}
