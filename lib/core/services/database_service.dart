
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:glucocheck/data/models/models.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'glucocheck.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE glucose_readings(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        value REAL,
        date TEXT,
        type TEXT,
        note TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE medications(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        dosage TEXT,
        schedule TEXT,
        lastTaken TEXT,
        frequency TEXT
      )
    ''');
    
    await db.execute('''
      CREATE TABLE habits(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT,
        name TEXT,
        details TEXT,
        date TEXT
      )
    ''');

    await _createAppointmentsTable(db);
  }

  /// Las instalaciones creadas con la versión 1 no tienen la tabla de citas:
  /// se añade aquí en vez de borrar la base de datos del usuario.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createAppointmentsTable(db);
    }
  }

  Future<void> _createAppointmentsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS appointments(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        type TEXT,
        date TEXT
      )
    ''');
  }

  // Glucose Operations
  Future<int> insertGlucose(GlucoseReading reading) async {
    final db = await database;
    return await db.insert('glucose_readings', reading.toMap());
  }

  Future<List<GlucoseReading>> getGlucoseReadings() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('glucose_readings', orderBy: 'date DESC');
    return List.generate(maps.length, (i) => GlucoseReading.fromMap(maps[i]));
  }
  
  // Medication Operations
  Future<int> insertMedication(Medication medication) async {
    final db = await database;
    return await db.insert('medications', medication.toMap());
  }

  Future<List<Medication>> getMedications() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('medications');
    return List.generate(maps.length, (i) => Medication.fromMap(maps[i]));
  }
  
  Future<void> updateMedication(Medication medication) async {
    final db = await database;
    await db.update(
      'medications',
      medication.toMap(),
      where: 'id = ?',
      whereArgs: [medication.id],
    );
  }
  
  Future<void> deleteMedication(int id) async {
      final db = await database;
      await db.delete('medications', where: 'id = ?', whereArgs: [id]);
  }
  
  // Habit Operations
  Future<int> insertHabit(HabitLog habit) async {
      final db = await database;
      return await db.insert('habits', habit.toMap());
  }
  
  Future<List<HabitLog>> getHabits() async {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query('habits', orderBy: 'date DESC');
      return List.generate(maps.length, (i) => HabitLog.fromMap(maps[i]));
  }

  // Citas y exámenes médicos
  Future<int> insertAppointment(MedicalAppointment appointment) async {
    final db = await database;
    return await db.insert('appointments', appointment.toMap());
  }

  Future<List<MedicalAppointment>> getAppointments() async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query('appointments', orderBy: 'date ASC');
    return List.generate(maps.length, (i) => MedicalAppointment.fromMap(maps[i]));
  }

  Future<void> deleteAppointment(int id) async {
    final db = await database;
    await db.delete('appointments', where: 'id = ?', whereArgs: [id]);
  }
}
