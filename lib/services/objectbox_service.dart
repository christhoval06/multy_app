import 'dart:io';
import 'package:multy_app/models/table_overall_stats.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'package:multy_app/objectbox.g.dart'; // Will be generated

import 'package:multy_app/models/quiz_attemp.dart';

class ObjectBoxService {
  late final Store _store;
  static ObjectBoxService? _instance;
  static final String dbName = 'multy_db';

  ObjectBoxService._create(this._store);

  static Future<ObjectBoxService> init() async {
    if (_instance == null) {
      final appDir = await getApplicationDocumentsDirectory();
      // Future<Store> openStore() {...} is defined in the generated objectbox.g.dart
      final store = await openStore(
        directory: p.join(appDir.path, ObjectBoxService.dbName),
      );
      _instance = ObjectBoxService._create(store);
    }
    return _instance!;
  }

  static Future<void> clear() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(docsDir.path, ObjectBoxService.dbName);
    final dbDirectory = Directory(dbPath);
    final isExists = await dbDirectory.exists();
    if (isExists) {
      await dbDirectory.delete(recursive: true);
      print("Todos los datos de ObjectBox han sido eliminados.");
    }
  }

  Store get store => _store;

  // Optional: Add getters for boxes if you use them frequently
  Box<QuizAttemp> get quizAttempBox => _store.box<QuizAttemp>();
  Box<TableOverallStats> get tableOverallStats =>
      _store.box<TableOverallStats>();

  Future<void> deleteAllData() async {
    // CUIDADO: Esto borra TODO.
    // Una forma es borrar todos los objetos de cada Box.
    // Es más seguro si ObjectBox ofreciera un store.deleteAllData() o similar,
    // pero usualmente es por Box.
    // O puedes cerrar el store, borrar el archivo de la DB y reabrirlo.

    // Opción 1: Borrar todos los objetos de cada Box conocida
    // Esto es más seguro que borrar el archivo directamente.
    _store.runInTransaction(TxMode.write, () {
      // Asegúrate de tener todas tus boxes aquí
      _store.box<QuizAttemp>().removeAll();
      // ... cualquier otra entidad que tengas ...
    });
    print("Todos los datos de ObjectBox han sido eliminados.");

    // Opción 2: Borrar el archivo de la base de datos (MÁS RIESGOSO, requiere reinicio de la app o reabrir store)
    // final dbPath = _store.directoryPath;
    // await _store.close();
    // final dbDir = Directory(dbPath);
    // if (await dbDir.exists()) {
    //   await dbDir.delete(recursive: true);
    // }
    // print("Archivo de base de datos eliminado. Necesitas reiniciar el servicio ObjectBox.");
    // // Luego tendrías que llamar a ObjectBoxService.init() de nuevo.
  }
}
