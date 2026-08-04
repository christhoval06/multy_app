import 'package:flutter_test/flutter_test.dart';
import 'package:multy_app/configs/settings.dart';
import 'package:multy_app/services/timer_settings_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('timer settings service returns defaults and rejects invalid values', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'studyAutoSwipeSeconds': 99,
      'quizDurationSeconds': 99,
    });

    final prefs = await SharedPreferences.getInstance();
    final service = TimerSettingsService(prefs);

    expect(
      service.readStudyAutoSwipeSeconds(),
      Settings.defaultStudyAutoSwipeSeconds,
    );
    expect(
      service.readQuizDurationSeconds(),
      Settings.defaultQuizDurationSeconds,
    );
  });
}
