import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static Database? _db;

  static Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), "newsyncrotime.db");
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, _) async {
        await db.execute('''
        CREATE TABLE schedules (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          data TEXT
        )
        ''');
      },
    );
  }

  static Future<bool> hasSchedule() async {
    final d = await db;
    final res = await d.query("schedules");
    return res.isNotEmpty;
  }

  static Future<Map<String, dynamic>?> getTodaySchedule() async {
    final d = await db;
    final res = await d.query("schedules", limit: 1);
    if (res.isEmpty) return null;
    return res.first;
  }
}
