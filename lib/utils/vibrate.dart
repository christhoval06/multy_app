import 'package:haptic_feedback/haptic_feedback.dart';

import 'package:multiplication_app/utils/debug.dart';

class Vibrate {
  static Future<void> vibrate({bool correct = true}) async {
    try {
      final canVibrate = await Haptics.canVibrate();
      if (canVibrate) {
        if (correct) {
          await Haptics.vibrate(HapticsType.success);
        } else {
          await Haptics.vibrate(HapticsType.error);
        }
      } else {
        Debug.print("El dispositivo no soporta vibración.");
      }
    } catch (e) {
      Debug.print("Error al intentar vibrar: $e");
    }
  }
}
