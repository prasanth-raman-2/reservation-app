import 'package:reservation_management/models/reservation_model.dart';
import 'package:reservation_management/services/database_service.dart';
import 'package:sqflite/sqflite.dart';

/// Mock implementation of DatabaseService for testing
class MockDatabaseService implements DatabaseService {
  @override
  Future<Database> get database async => throw UnimplementedError('This is a mock');
  final List<Reservation> _reservations = [];
  bool throwOnOperation = false;

  @override
  Future<void> insertReservation(Reservation reservation) async {
    if (throwOnOperation) {
      throw Exception('Mock database error');
    }
    _reservations.add(reservation);
  }

  @override
  Future<void> updateReservation(Reservation reservation) async {
    if (throwOnOperation) {
      throw Exception('Mock database error');
    }
    
    final index = _reservations.indexWhere((r) => r.id == reservation.id);
    if (index != -1) {
      _reservations[index] = reservation;
    } else {
      _reservations.add(reservation);
    }
  }

  @override
  Future<void> deleteReservation(String id) async {
    if (throwOnOperation) {
      throw Exception('Mock database error');
    }
    
    _reservations.removeWhere((r) => r.id == id);
  }

  @override
  Future<List<Reservation>> getReservations() async {
    if (throwOnOperation) {
      throw Exception('Mock database error');
    }
    
    return List.from(_reservations);
  }

  @override
  Future<Reservation?> getReservationById(String id) async {
    if (throwOnOperation) {
      throw Exception('Mock database error');
    }
    
    return _reservations.firstWhere(
      (r) => r.id == id,
      orElse: () => throw Exception('Reservation not found'),
    );
  }

  @override
  Future<List<Reservation>> getReservationsByUserId(String userId) async {
    if (throwOnOperation) {
      throw Exception('Mock database error');
    }
    
    return _reservations.where((r) => r.userId == userId).toList();
  }

  @override
  Future<List<Reservation>> getUpcomingReservations() async {
    if (throwOnOperation) {
      throw Exception('Mock database error');
    }
    
    final now = DateTime.now();
    return _reservations.where((r) => r.startTime.isAfter(now)).toList();
  }

  /// Clear all reservations (for testing purposes)
  void clear() {
    _reservations.clear();
  }

  /// Add multiple reservations at once (for testing purposes)
  void addReservations(List<Reservation> reservations) {
    _reservations.addAll(reservations);
  }
}
