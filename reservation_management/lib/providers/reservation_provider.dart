import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/reservation_model.dart';
import '../services/database_service.dart';
import '../services/firebase_service.dart';

/// Provider for the database service
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

/// Provider for the Firebase service
final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  return FirebaseService();
});

/// Provider for the list of reservations
final reservationsProvider = FutureProvider<List<Reservation>>((ref) async {
  final databaseService = ref.watch(databaseServiceProvider);
  return databaseService.getReservations();
});

/// Provider for upcoming reservations
final upcomingReservationsProvider = FutureProvider<List<Reservation>>((ref) async {
  final databaseService = ref.watch(databaseServiceProvider);
  return databaseService.getUpcomingReservations();
});

/// Provider for user reservations
final userReservationsProvider = FutureProvider.family<List<Reservation>, String>(
  (ref, userId) async {
    final databaseService = ref.watch(databaseServiceProvider);
    return databaseService.getReservationsByUserId(userId);
  },
);

/// Notifier class for managing reservations
class ReservationNotifier extends StateNotifier<AsyncValue<List<Reservation>>> {
  final DatabaseService _databaseService;
  final FirebaseService _firebaseService;

  ReservationNotifier(this._databaseService, this._firebaseService)
      : super(const AsyncValue.loading()) {
    _loadReservations();
  }

  Future<void> _loadReservations() async {
    try {
      state = const AsyncValue.loading();
      final reservations = await _databaseService.getReservations();
      state = AsyncValue.data(reservations);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Add a new reservation
  Future<void> addReservation(Reservation reservation) async {
    try {
      await _databaseService.insertReservation(reservation);
      try {
        await _firebaseService.addReservation(reservation);
      } catch (e) {
        // Continue even if Firebase fails
      }
      _loadReservations();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// Update an existing reservation
  Future<void> updateReservation(Reservation reservation) async {
    try {
      await _databaseService.updateReservation(reservation);
      try {
        await _firebaseService.updateReservation(reservation);
      } catch (e) {
        // Continue even if Firebase fails
      }
      _loadReservations();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// Delete a reservation
  Future<void> deleteReservation(String id) async {
    try {
      await _databaseService.deleteReservation(id);
      try {
        await _firebaseService.deleteReservation(id);
      } catch (e) {
        // Continue even if Firebase fails
      }
      _loadReservations();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// Sync reservations with Firebase
  Future<void> syncWithFirebase() async {
    try {
      final localReservations = await _databaseService.getReservations();
      await _firebaseService.syncReservations(localReservations);
      _loadReservations();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

/// Provider for the reservation notifier
final reservationNotifierProvider =
    StateNotifierProvider<ReservationNotifier, AsyncValue<List<Reservation>>>(
  (ref) {
    final databaseService = ref.watch(databaseServiceProvider);
    final firebaseService = ref.watch(firebaseServiceProvider);
    return ReservationNotifier(databaseService, firebaseService);
  },
);
