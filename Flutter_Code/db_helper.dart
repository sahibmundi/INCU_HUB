import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

class DBHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'sensors.db');
    return openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE SensorData (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          time TEXT,
          temperature REAL,
          water_level REAL
        )
      ''');
    });
  }

  Future<void> insertSensorData(Map<String, dynamic> data) async {
    final db = await database;
    await db.insert('SensorData', data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getSensorData() async {
    final db = await database;
    return db.query('SensorData');
  }
}
