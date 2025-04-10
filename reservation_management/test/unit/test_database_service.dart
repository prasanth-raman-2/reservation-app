import 'package:flutter_test/flutter_test.dart';
import 'package:reservation_management/models/reservation_model.dart';
import '../mocks/mock_database_service.dart';

void main() {
  group('DatabaseService Tests', () {
    late MockDatabaseService databaseService;
    late Reservation testReservation;
    final String userId = 'test-user-id';
    final DateTime now = DateTime.now();
    final DateTime later = now.add(const Duration(hours: 2));

    setUp(() {
      databaseService = MockDatabaseService();
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

    test('should insert and retrieve a reservation', () async {
      await databaseService.insertReservation(testReservation);
      
      final reservations = await databaseService.getReservations();
      
      expect(reservations.length, 1);
      expect(reservations[0].id, testReservation.id);
      expect(reservations[0].title, testReservation.title);
      expect(reservations[0].description, testReservation.description);
      expect(reservations[0].startTime, testReservation.startTime);
      expect(reservations[0].endTime, testReservation.endTime);
      expect(reservations[0].location, testReservation.location);
      expect(reservations[0].latitude, testReservation.latitude);
      expect(reservations[0].longitude, testReservation.longitude);
      expect(reservations[0].userId, testReservation.userId);
    });

    test('should update a reservation', () async {
      await databaseService.insertReservation(testReservation);
      
      final updatedReservation = testReservation.copyWith(
        title: 'Updated Title',
        description: 'Updated Description',
      );
      
      await databaseService.updateReservation(updatedReservation);
      
      final reservations = await databaseService.getReservations();
      
      expect(reservations.length, 1);
      expect(reservations[0].id, updatedReservation.id);
      expect(reservations[0].title, 'Updated Title');
      expect(reservations[0].description, 'Updated Description');
    });

    test('should delete a reservation', () async {
      await databaseService.insertReservation(testReservation);
      
      await databaseService.deleteReservation(testReservation.id);
      
      final reservations = await databaseService.getReservations();
      
      expect(reservations.length, 0);
    });

    test('should get a reservation by ID', () async {
      await databaseService.insertReservation(testReservation);
      
      final reservation = await databaseService.getReservationById(testReservation.id);
      
      expect(reservation, isNotNull);
      expect(reservation!.id, testReservation.id);
      expect(reservation.title, testReservation.title);
    });

    test('should throw when getting a non-existent reservation by ID', () async {
      expect(
        () => databaseService.getReservationById('non-existent-id'),
        throwsException,
      );
    });

    test('should get reservations by user ID', () async {
      final otherUserReservation = Reservation(
        title: 'Other User Reservation',
        description: 'Other User Description',
        startTime: now,
        endTime: later,
        location: 'Other Location',
        userId: 'other-user-id',
      );
      
      await databaseService.insertReservation(testReservation);
      await databaseService.insertReservation(otherUserReservation);
      
      final userReservations = await databaseService.getReservationsByUserId(userId);
      
      expect(userReservations.length, 1);
      expect(userReservations[0].id, testReservation.id);
      expect(userReservations[0].userId, userId);
    });

    test('should get upcoming reservations', () async {
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
      
      await databaseService.insertReservation(pastReservation);
      await databaseService.insertReservation(futureReservation);
      
      final upcomingReservations = await databaseService.getUpcomingReservations();
      
      expect(upcomingReservations.length, 1);
      expect(upcomingReservations[0].id, futureReservation.id);
      expect(upcomingReservations[0].title, 'Future Reservation');
    });

    test('should handle errors when throwOnOperation is true', () async {
      databaseService.throwOnOperation = true;
      
      expect(
        () => databaseService.insertReservation(testReservation),
        throwsException,
      );
      
      expect(
        () => databaseService.getReservations(),
        throwsException,
      );
      
      expect(
        () => databaseService.updateReservation(testReservation),
        throwsException,
      );
      
      expect(
        () => databaseService.deleteReservation(testReservation.id),
        throwsException,
      );
      
      expect(
        () => databaseService.getReservationById(testReservation.id),
        throwsException,
      );
      
      expect(
        () => databaseService.getReservationsByUserId(userId),
        throwsException,
      );
      
      expect(
        () => databaseService.getUpcomingReservations(),
        throwsException,
      );
    });
  });
}