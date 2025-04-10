import 'package:flutter_test/flutter_test.dart';
import 'package:reservation_management/models/reservation_model.dart';
import '../mocks/mock_firebase_service.dart';

void main() {
  group('FirebaseService Tests', () {
    late MockFirebaseService firebaseService;
    late Reservation testReservation;
    final String userId = 'test-user-id';
    final DateTime now = DateTime.now();
    final DateTime later = now.add(const Duration(hours: 2));

    setUp(() {
      firebaseService = MockFirebaseService();
      testReservation = Reservation(
        id: 'test-id',
        title: 'Test Reservation',
        description: 'Test Description',
        startTime: now,
        endTime: later,
        location: 'Test Location',
        latitude: 37.7749,
        longitude: -122.4194,
        userId: userId,
      );
    });

    tearDown(() {
      firebaseService.dispose();
    });

    test('should add and retrieve a reservation', () async {
      await firebaseService.addReservation(testReservation);
      
      final reservation = await firebaseService.getReservationById(testReservation.id);
      
      expect(reservation, isNotNull);
      expect(reservation!.id, testReservation.id);
      expect(reservation.title, testReservation.title);
      expect(reservation.description, testReservation.description);
    });

    test('should update a reservation', () async {
      await firebaseService.addReservation(testReservation);
      
      final updatedReservation = testReservation.copyWith(
        title: 'Updated Title',
        description: 'Updated Description',
      );
      
      await firebaseService.updateReservation(updatedReservation);
      
      final reservation = await firebaseService.getReservationById(testReservation.id);
      
      expect(reservation, isNotNull);
      expect(reservation!.id, updatedReservation.id);
      expect(reservation.title, 'Updated Title');
      expect(reservation.description, 'Updated Description');
    });

    test('should delete a reservation', () async {
      await firebaseService.addReservation(testReservation);
      
      await firebaseService.deleteReservation(testReservation.id);
      
      final reservation = await firebaseService.getReservationById(testReservation.id);
      
      expect(reservation, isNull);
    });

    test('should get reservations stream', () async {
      await firebaseService.addReservation(testReservation);
      
      final reservationsStream = firebaseService.getReservationsStream();
      
      expect(
        reservationsStream,
        emits(predicate<List<Reservation>>((reservations) {
          return reservations.length == 1 && 
                 reservations[0].id == testReservation.id;
        })),
      );
    });

    test('should get user reservations stream', () async {
      final otherUserReservation = Reservation(
        title: 'Other User Reservation',
        description: 'Other User Description',
        startTime: now,
        endTime: later,
        location: 'Other Location',
        userId: 'other-user-id',
      );
      
      await firebaseService.addReservation(testReservation);
      await firebaseService.addReservation(otherUserReservation);
      
      final userReservationsStream = firebaseService.getUserReservationsStream(userId);
      
      expect(
        userReservationsStream,
        emits(predicate<List<Reservation>>((reservations) {
          return reservations.length == 1 && 
                 reservations[0].id == testReservation.id &&
                 reservations[0].userId == userId;
        })),
      );
    });

    test('should get upcoming reservations stream', () async {
      final pastReservation = Reservation(
        title: 'Past Reservation',
        description: 'Past Description',
        startTime: now.subtract(const Duration(days: 2)),
        endTime: now.subtract(const Duration(days: 2)).add(const Duration(hours: 2)),
        location: 'Past Location',
        userId: userId,
      );
      
      final futureReservation = Reservation(
        title: 'Future Reservation',
        description: 'Future Description',
        startTime: now.add(const Duration(days: 2)),
        endTime: now.add(const Duration(days: 2)).add(const Duration(hours: 2)),
        location: 'Future Location',
        userId: userId,
      );
      
      await firebaseService.addReservation(pastReservation);
      await firebaseService.addReservation(futureReservation);
      
      final upcomingReservationsStream = firebaseService.getUpcomingReservationsStream();
      
      expect(
        upcomingReservationsStream,
        emits(predicate<List<Reservation>>((reservations) {
          return reservations.length == 1 && 
                 reservations[0].id == futureReservation.id &&
                 reservations[0].title == 'Future Reservation';
        })),
      );
    });

    test('should sync reservations', () async {
      final reservations = [
        testReservation,
        Reservation(
          title: 'Another Reservation',
          description: 'Another Description',
          startTime: now.add(const Duration(days: 1)),
          endTime: now.add(const Duration(days: 1)).add(const Duration(hours: 2)),
          location: 'Another Location',
          userId: userId,
        ),
      ];
      
      await firebaseService.syncReservations(reservations);
      
      final reservationsStream = firebaseService.getReservationsStream();
      
      expect(
        reservationsStream,
        emits(predicate<List<Reservation>>((syncedReservations) {
          return syncedReservations.length == 2 && 
                 syncedReservations[0].id == reservations[0].id &&
                 syncedReservations[1].id == reservations[1].id;
        })),
      );
    });

    test('should handle errors when throwOnOperation is true', () async {
      firebaseService.throwOnOperation = true;
      
      expect(
        () => firebaseService.addReservation(testReservation),
        throwsException,
      );
      
      expect(
        () => firebaseService.updateReservation(testReservation),
        throwsException,
      );
      
      expect(
        () => firebaseService.deleteReservation(testReservation.id),
        throwsException,
      );
      
      expect(
        () => firebaseService.getReservationById(testReservation.id),
        throwsException,
      );
      
      expect(
        () => firebaseService.syncReservations([testReservation]),
        throwsException,
      );
      
      expect(
        firebaseService.getReservationsStream(),
        emitsError(isA<Exception>()),
      );
      
      expect(
        firebaseService.getUserReservationsStream(userId),
        emitsError(isA<Exception>()),
      );
      
      expect(
        firebaseService.getUpcomingReservationsStream(),
        emitsError(isA<Exception>()),
      );
    });
  });
}