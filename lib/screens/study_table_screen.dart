import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';

import 'package:multy_app/l10n/app_localizations.dart';
import 'package:multy_app/configs/settings.dart';
import 'package:multy_app/widgets/study_table/fun_fact_widget.dart';
import 'package:multy_app/widgets/study_table/multiplication_card.dart';
import 'package:multy_app/widgets/study_table/progress_indicator_widget.dart'; // Para localizaciones

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

  static const int _swipeIntervalSeconds = 5;
  bool _isManualSwipeEnabled = false;
  int _timeRemaining = _swipeIntervalSeconds;

  @override
  void initState() {
    super.initState();
    _isManualSwipeEnabled = false;
    _startAutoSwipeTimer();
    _startCountdownTimer();
  }

  void _startAutoSwipeTimer() {
    setState(() {
      _isManualSwipeEnabled = false;
    });

    _autoSwipeTimer = Timer.periodic(
      const Duration(seconds: _swipeIntervalSeconds),
      (timer) {
        _swiperController.swipe(CardSwiperDirection.right);
        _resetCountdown();
      },
    );
  }

  void _startCountdownTimer() {
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
      final equation = "${widget.args.tableNumber} x $multiplier = $result";
      // Devuelve el widget de tu tarjeta de multiplicación
      return MultiplicationCard(equation: equation, result: result);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!; // Para textos localizados
    List<Widget> cards = _generateCards();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.studyTableTitle(widget.args.tableNumber.toString()),
        ), // Ej: "Estudiando la Tabla del 7"
        // centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_isManualSwipeEnabled ? Icons.pause : Icons.play_arrow),
            onPressed: _toggleAutoSwipe,
            tooltip: !_isManualSwipeEnabled
                ? 'Activar Auto-Swipe'
                : 'Desactivar Auto-Swipe',
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Center(
              child: Text(
                '${_timeRemaining}s',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            // --- Indicador de Progreso ---
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: ProgressIndicatorWidget(
                currentIndex: _currentIndexForSwiper,
                totalItems: cards.length,
              ),
            ),

            // --- Área Principal de la Multiplicación ---
            Expanded(
              child: cards.isEmpty
                  ? const Center(child: Text("No hay tarjetas para mostrar"))
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
                      numberOfCardsDisplayed: 3, // Cuántas se ven en el stack
                      backCardOffset: const Offset(
                        30,
                        -10,
                      ), // Ajusta para el efecto de stack
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 25,
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

            // --- (Opcional) Hecho Divertido ---
            Padding(
              padding: const EdgeInsets.only(
                bottom: 20.0,
                top: 10.0,
              ), // Ajustar padding
              child: FunFactWidget(
                table: widget.args.tableNumber,
                multiplier: _currentIndexForSwiper + 1,
              ), // Se actualiza con _currentPageIndex
            ),
          ],
        ),
      ),
    );
  }

  // Callback para el paquete
  bool _onSwipe(
    int previousIndex,
    int? currentIndex,
    CardSwiperDirection direction,
  ) {
    // direction.name te dirá "left" o "right"
    debugPrint(
      'Swiped from $previousIndex to $currentIndex in ${direction.name} direction',
    );
    if (currentIndex != null) {
      setState(() {
        _currentIndexForSwiper = currentIndex;
      });
    }
    return true; // Retorna true para permitir el swipe
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
