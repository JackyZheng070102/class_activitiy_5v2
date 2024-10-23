import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    String path = join(await getDatabasesPath(), 'aquarium.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE settings (
        id INTEGER PRIMARY KEY,
        fishCount INTEGER,
        speed REAL,
        color TEXT
      )
    ''');
  }

  Future<void> saveSettings(int fishCount, double speed, String color) async {
    final db = await database;
    await db.insert('settings', {
      'fishCount': fishCount,
      'speed': speed,
      'color': color,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, dynamic>> loadSettings() async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.query('settings', limit: 1);
    if (result.isNotEmpty) {
      return result.first;
    }
    return {};
  }
}
