import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/reservation_model.dart';
import '../utils/logger.dart';

/// Service for handling Firebase Firestore operations
class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'reservations';

  // Singleton pattern
  factory FirebaseService() => _instance;

  FirebaseService._internal();

  /// Add a reservation to Firestore
  Future<void> addReservation(Reservation reservation) async {
    try {
      await _firestore.collection(_collection).doc(reservation.id).set(
            reservation.toMap(),
          );
    } catch (e) {
      Logger.error('Error adding reservation to Firestore: $e');
      rethrow;
    }
  }

  /// Update a reservation in Firestore
  Future<void> updateReservation(Reservation reservation) async {
    try {
      await _firestore.collection(_collection).doc(reservation.id).update(
            reservation.toMap(),
          );
    } catch (e) {
      Logger.error('Error updating reservation in Firestore: $e');
      rethrow;
    }
  }

  /// Delete a reservation from Firestore
  Future<void> deleteReservation(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      Logger.error('Error deleting reservation from Firestore: $e');
      rethrow;
    }
  }

  /// Get all reservations from Firestore
  Stream<List<Reservation>> getReservationsStream() {
    try {
      return _firestore.collection(_collection).snapshots().map(
            (snapshot) => snapshot.docs
                .map((doc) => Reservation.fromMap(doc.data()))
                .toList(),
          );
    } catch (e) {
      Logger.error('Error getting reservations stream from Firestore: $e');
      rethrow;
    }
  }

  /// Get a reservation by ID from Firestore
  Future<Reservation?> getReservationById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (!doc.exists) return null;
      return Reservation.fromMap(doc.data()!);
    } catch (e) {
      Logger.error('Error getting reservation by ID from Firestore: $e');
      rethrow;
    }
  }

  /// Get reservations for a specific user from Firestore
  Stream<List<Reservation>> getUserReservationsStream(String userId) {
    try {
      return _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => Reservation.fromMap(doc.data()))
                .toList(),
          );
    } catch (e) {
      Logger.error('Error getting user reservations stream from Firestore: $e');
      rethrow;
    }
  }

  /// Get upcoming reservations from Firestore
  Stream<List<Reservation>> getUpcomingReservationsStream() {
    try {
      final now = DateTime.now();
      return _firestore
          .collection(_collection)
          .where('startTime', isGreaterThan: now.toIso8601String())
          .orderBy('startTime')
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => Reservation.fromMap(doc.data()))
                .toList(),
          );
    } catch (e) {
      Logger.error('Error getting upcoming reservations stream from Firestore: $e');
      rethrow;
    }
  }

  /// Sync local reservations with Firestore
  Future<void> syncReservations(List<Reservation> localReservations) async {
    try {
      // Get all reservations from Firestore
      final snapshot = await _firestore.collection(_collection).get();
      final firestoreReservations = snapshot.docs
          .map((doc) => Reservation.fromMap(doc.data()))
          .toList();

      // Create a map of Firestore reservations by ID for easy lookup
      final firestoreReservationsMap = {
        for (var reservation in firestoreReservations)
          reservation.id: reservation
      };

      // Create a map of local reservations by ID for easy lookup
      final localReservationsMap = {
        for (var reservation in localReservations) reservation.id: reservation
      };

      // Create a batch for efficient Firestore operations
      final batch = _firestore.batch();

      // Add or update reservations that are in local but not in Firestore
      for (var localReservation in localReservations) {
        final firestoreReservation =
            firestoreReservationsMap[localReservation.id];

        if (firestoreReservation == null ||
            localReservation.updatedAt.isAfter(firestoreReservation.updatedAt)) {
          // Local reservation is newer or doesn't exist in Firestore
          batch.set(
            _firestore.collection(_collection).doc(localReservation.id),
            localReservation.toMap(),
          );
        }
      }

      // Add reservations that are in Firestore but not in local
      for (var firestoreReservation in firestoreReservations) {
        final localReservation =
            localReservationsMap[firestoreReservation.id];

        if (localReservation == null) {
          // Reservation exists in Firestore but not locally
          // This will be handled by the caller to add to local database
        }
      }

      // Commit the batch
      await batch.commit();
    } catch (e) {
      Logger.error('Error syncing reservations with Firestore: $e');
      rethrow;
    }
  }
}
