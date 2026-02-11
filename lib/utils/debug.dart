import 'package:flutter/foundation.dart';

class Debug {
  static void print(String? message, {int? wrapWidth}) {
    if (kDebugMode) {
      debugPrint(message, wrapWidth: wrapWidth);
    }
  }
}
