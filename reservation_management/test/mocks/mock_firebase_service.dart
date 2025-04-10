import 'dart:async';
import 'package:reservation_management/models/reservation_model.dart';
import 'package:reservation_management/services/firebase_service.dart';

/// Mock implementation of FirebaseService for testing
class MockFirebaseService implements FirebaseService {
  final List<Reservation> _reservations = [];
  final StreamController<List<Reservation>> _reservationsStreamController = 
      StreamController<List<Reservation>>.broadcast();
  bool throwOnOperation = false;

  MockFirebaseService() {
    _reservationsStreamController.add(_reservations);
  }

  @override
  Future<void> addReservation(Reservation reservation) async {
    if (throwOnOperation) {
      throw Exception('Mock Firebase error');
    }
    
    _reservations.add(reservation);
    _reservationsStreamController.add(_reservations);
  }

  @override
  Future<void> updateReservation(Reservation reservation) async {
    if (throwOnOperation) {
      throw Exception('Mock Firebase error');
    }
    
    final index = _reservations.indexWhere((r) => r.id == reservation.id);
    if (index != -1) {
      _reservations[index] = reservation;
    } else {
      _reservations.add(reservation);
    }
    _reservationsStreamController.add(_reservations);
  }

  @override
  Future<void> deleteReservation(String id) async {
    if (throwOnOperation) {
      throw Exception('Mock Firebase error');
    }
    
    _reservations.removeWhere((r) => r.id == id);
    _reservationsStreamController.add(_reservations);
  }

  @override
  Stream<List<Reservation>> getReservationsStream() {
    if (throwOnOperation) {
      return Stream.error(Exception('Mock Firebase error'));
    }
    
    return _reservationsStreamController.stream;
  }

  @override
  Future<Reservation?> getReservationById(String id) async {
    if (throwOnOperation) {
      throw Exception('Mock Firebase error');
    }
    
    try {
      return _reservations.firstWhere((r) => r.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Stream<List<Reservation>> getUserReservationsStream(String userId) {
    if (throwOnOperation) {
      return Stream.error(Exception('Mock Firebase error'));
    }
    
    return _reservationsStreamController.stream
        .map((reservations) => reservations.where((r) => r.userId == userId).toList());
  }

  @override
  Stream<List<Reservation>> getUpcomingReservationsStream() {
    if (throwOnOperation) {
      return Stream.error(Exception('Mock Firebase error'));
    }
    
    final now = DateTime.now();
    return _reservationsStreamController.stream
        .map((reservations) => reservations.where((r) => r.startTime.isAfter(now)).toList());
  }

  @override
  Future<void> syncReservations(List<Reservation> localReservations) async {
    if (throwOnOperation) {
      throw Exception('Mock Firebase error');
    }
    
    // Simple implementation for testing
    _reservations.clear();
    _reservations.addAll(localReservations);
    _reservationsStreamController.add(_reservations);
  }

  /// Clear all reservations (for testing purposes)
  void clear() {
    _reservations.clear();
    _reservationsStreamController.add(_reservations);
  }

  /// Add multiple reservations at once (for testing purposes)
  void addReservations(List<Reservation> reservations) {
    _reservations.addAll(reservations);
    _reservationsStreamController.add(_reservations);
  }

  /// Dispose resources
  void dispose() {
    _reservationsStreamController.close();
  }
}