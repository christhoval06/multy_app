import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:multy_app/utils/debug.dart';

class Player {
  final AudioPlayer audioPlayer = AudioPlayer();

  Player() {
    audioPlayer.setReleaseMode(ReleaseMode.stop);
  }

  Future<void> playSound(String soundAsset) async {
    try {
      // Usamos AssetSource para cargar desde la carpeta assets
      await audioPlayer.play(
        AssetSource(soundAsset),
        mode: PlayerMode.lowLatency,
      );

      Future.delayed(Duration(seconds: 1), () {
        audioPlayer.stop();
      });
    } catch (e) {
      // Manejar errores si el archivo no se encuentra o no se puede reproducir
      Debug.print("Error al reproducir sonido: $e");
    }
  }

  void close() {
    audioPlayer.dispose();
  }
}
