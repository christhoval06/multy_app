import 'package:multy_app/configs/app_prefs.dart';
import 'package:multy_app/utils/player.dart';
import 'package:multy_app/utils/vibrate.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FeedbackService {
  FeedbackService._();

  static final FeedbackService instance = FeedbackService._();

  final Player _player = Player();
  SharedPreferences? _prefs;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

  bool get soundEnabled => _soundEnabled;
  bool get vibrationEnabled => _vibrationEnabled;

  Future<void> initialize(SharedPreferences prefs) async {
    _prefs = prefs;
    _soundEnabled = prefs.getBool(AppPrefs.feedbackSoundEnabled) ?? true;
    _vibrationEnabled =
        prefs.getBool(AppPrefs.feedbackVibrationEnabled) ?? true;
  }

  Future<void> setSoundEnabled(bool value) async {
    _soundEnabled = value;
    await _prefs?.setBool(AppPrefs.feedbackSoundEnabled, value);
  }

  Future<void> setVibrationEnabled(bool value) async {
    _vibrationEnabled = value;
    await _prefs?.setBool(AppPrefs.feedbackVibrationEnabled, value);
  }

  Future<void> playProfileSelect() async {
    await _safeRun(() async {
      if (_vibrationEnabled) {
        await Vibrate.vibrate(correct: true);
      }
      if (_soundEnabled) {
        await _player.playSound('sounds/correct-choice.mp3');
      }
    });
  }

  Future<void> playAnswerFeedback({required bool correct}) async {
    await _safeRun(() async {
      if (_vibrationEnabled) {
        await Vibrate.vibrate(correct: correct);
      }
      if (_soundEnabled) {
        await _player.playSound(
          correct ? 'sounds/correct-choice.mp3' : 'sounds/error-choice.mp3',
        );
      }
    });
  }

  Future<void> playResultCelebration({required bool passed}) async {
    await _safeRun(() async {
      if (_vibrationEnabled) {
        await Vibrate.vibrate(correct: passed);
      }
      if (_soundEnabled) {
        await _player.playSound(
          passed ? 'sounds/correct-choice.mp3' : 'sounds/error-choice.mp3',
        );
      }
    });
  }

  Future<void> _safeRun(Future<void> Function() action) async {
    try {
      await action();
    } catch (_) {
      // Silent fallback for tests and unsupported platforms.
    }
  }
}
