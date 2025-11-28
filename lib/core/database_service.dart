import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../data/local/entities/reading_progress.dart';
import '../data/local/entities/user_settings.dart';

class DatabaseService {
  late Future<Isar> db;

  DatabaseService() {
    db = _initDb();
  }

  Future<Isar> _initDb() async {
    final dir = await getApplicationDocumentsDirectory();
    if (Isar.instanceNames.isEmpty) {
      return await Isar.open(
        [
          ReadingProgressSchema,
          UserSettingsSchema,
        ], // register schema here
        directory: dir.path,
        inspector: true, // Allows inspect DB
      );
    }
    return Future.value(Isar.getInstance());
  }
}