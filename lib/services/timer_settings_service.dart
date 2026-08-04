import 'package:multy_app/configs/app_prefs.dart';
import 'package:multy_app/configs/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TimerSettingsService {
  TimerSettingsService(this._prefs);

  final SharedPreferences _prefs;

  int readStudyAutoSwipeSeconds() {
    final value = _prefs.getInt(AppPrefs.studyAutoSwipeSeconds);
    if (value != null && Settings.studyAutoSwipeOptions.contains(value)) {
      return value;
    }
    return Settings.defaultStudyAutoSwipeSeconds;
  }

  int readQuizDurationSeconds() {
    final value = _prefs.getInt(AppPrefs.quizDurationSeconds);
    if (value != null && Settings.quizDurationOptions.contains(value)) {
      return value;
    }
    return Settings.defaultQuizDurationSeconds;
  }

  Future<void> updateStudyAutoSwipeSeconds(int value) async {
    if (!Settings.studyAutoSwipeOptions.contains(value)) {
      return;
    }
    await _prefs.setInt(AppPrefs.studyAutoSwipeSeconds, value);
  }

  Future<void> updateQuizDurationSeconds(int value) async {
    if (!Settings.quizDurationOptions.contains(value)) {
      return;
    }
    await _prefs.setInt(AppPrefs.quizDurationSeconds, value);
  }

  Future<void> restoreDefaults() async {
    await _prefs.setInt(
      AppPrefs.studyAutoSwipeSeconds,
      Settings.defaultStudyAutoSwipeSeconds,
    );
    await _prefs.setInt(
      AppPrefs.quizDurationSeconds,
      Settings.defaultQuizDurationSeconds,
    );
  }
}
