import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDB {
  static final AppDB instance = AppDB._();
  static Database? _db;

  AppDB._();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'schedule.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, _) async {
        await db.execute('''
        CREATE TABLE categories (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          color INTEGER,
          startDate TEXT,
          endDate TEXT,
          configured INTEGER
        )
        ''');

        await db.execute('''
        CREATE TABLE periods (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          categoryId INTEGER,
          day TEXT,
          title TEXT,
          startTime TEXT,
          endTime TEXT,
          isBreak INTEGER
        )
        ''');
      },
    );
  }
}
