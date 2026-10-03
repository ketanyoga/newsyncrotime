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
      version: 5,
      onCreate: (db, _) async {
        await db.execute('''
        CREATE TABLE categories (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          color INTEGER,
          startDate TEXT,
          endDate TEXT,
          configured INTEGER,
          ringtoneDuration INTEGER,
          synced INTEGER DEFAULT 0,
          skippedDays TEXT,
          skippedDates TEXT,
          scheduleConfig TEXT
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
          ringtone TEXT,
          isBreak INTEGER,
          FOREIGN KEY (categoryId) REFERENCES categories(id)
        )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE categories ADD COLUMN ringtoneDuration INTEGER DEFAULT 60');
        }
        if (oldVersion < 3) {
          await db.execute('ALTER TABLE categories ADD COLUMN synced INTEGER DEFAULT 0');
        }
        if (oldVersion < 4) {
          await db.execute('ALTER TABLE categories ADD COLUMN skippedDays TEXT');
          await db.execute('ALTER TABLE categories ADD COLUMN skippedDates TEXT');
        }
        if (oldVersion < 5) {
          await db.execute('ALTER TABLE categories ADD COLUMN scheduleConfig TEXT');
        }
      },
    );
  }

  Future<void> cleanDuplicatePeriods() async {
    final db = await database;
    try {
      await db.rawQuery('''
        DELETE FROM periods WHERE id NOT IN (
          SELECT MIN(id) FROM periods GROUP BY categoryId, UPPER(day), startTime
        )
      ''');
    } catch (_) {}
  }
}
