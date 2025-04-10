import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/reservation_model.dart';

/// Service for handling local SQLite database operations
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  // Singleton pattern
  factory DatabaseService() => _instance;

  DatabaseService._internal();

  /// Get the database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize the database
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'reservations.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDb,
    );
  }

  /// Create the database tables
  Future<void> _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE reservations(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        startTime TEXT NOT NULL,
        endTime TEXT NOT NULL,
        location TEXT NOT NULL,
        latitude REAL,
        longitude REAL,
        userId TEXT NOT NULL,
        isConfirmed INTEGER NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');
  }

  /// Insert a reservation into the database
  Future<void> insertReservation(Reservation reservation) async {
    final db = await database;
    await db.insert(
      'reservations',
      reservation.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Update a reservation in the database
  Future<void> updateReservation(Reservation reservation) async {
    final db = await database;
    await db.update(
      'reservations',
      reservation.toMap(),
      where: 'id = ?',
      whereArgs: [reservation.id],
    );
  }

  /// Delete a reservation from the database
  Future<void> deleteReservation(String id) async {
    final db = await database;
    await db.delete(
      'reservations',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Get all reservations from the database
  Future<List<Reservation>> getReservations() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('reservations');

    return List.generate(maps.length, (i) {
      return Reservation.fromMap(maps[i]);
    });
  }

  /// Get a reservation by ID
  Future<Reservation?> getReservationById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'reservations',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return Reservation.fromMap(maps.first);
  }

  /// Get reservations for a specific user
  Future<List<Reservation>> getReservationsByUserId(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'reservations',
      where: 'userId = ?',
      whereArgs: [userId],
    );

    return List.generate(maps.length, (i) {
      return Reservation.fromMap(maps[i]);
    });
  }

  /// Get upcoming reservations
  Future<List<Reservation>> getUpcomingReservations() async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    final List<Map<String, dynamic>> maps = await db.query(
      'reservations',
      where: 'startTime > ?',
      whereArgs: [now],
      orderBy: 'startTime ASC',
    );

    return List.generate(maps.length, (i) {
      return Reservation.fromMap(maps[i]);
    });
  }
}
