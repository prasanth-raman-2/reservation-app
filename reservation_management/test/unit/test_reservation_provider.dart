import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reservation_management/models/reservation_model.dart';
import 'package:reservation_management/providers/reservation_provider.dart';
import '../mocks/mock_database_service.dart';
import '../mocks/mock_firebase_service.dart';

void main() {
  group('ReservationProvider Tests', () {
    late ProviderContainer container;
    late MockDatabaseService mockDatabaseService;
    late MockFirebaseService mockFirebaseService;
    late Reservation testReservation;
    final String userId = 'test-user-id';
    final DateTime now = DateTime.now();
    final DateTime later = now.add(const Duration(hours: 2));

    setUp(() {
      mockDatabaseService = MockDatabaseService();
      mockFirebaseService = MockFirebaseService();
      
      container = ProviderContainer(
        overrides: [
          databaseServiceProvider.overrideWithValue(mockDatabaseService),
          firebaseServiceProvider.overrideWithValue(mockFirebaseService),
        ],
      );
      
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
      container.dispose();
      mockFirebaseService.dispose();
    });

    test('reservationsProvider should return reservations from database service', () async {
      mockDatabaseService.addReservations([testReservation]);
      
      final reservations = await container.read(reservationsProvider.future);
      
      expect(reservations.length, 1);
      expect(reservations[0].id, testReservation.id);
      expect(reservations[0].title, testReservation.title);
    });

    test('upcomingReservationsProvider should return upcoming reservations', () async {
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
      
      mockDatabaseService.addReservations([pastReservation, futureReservation]);
      
      final upcomingReservations = await container.read(upcomingReservationsProvider.future);
      
      expect(upcomingReservations.length, 1);
      expect(upcomingReservations[0].id, futureReservation.id);
      expect(upcomingReservations[0].title, 'Future Reservation');
    });

    test('userReservationsProvider should return user reservations', () async {
      final otherUserReservation = Reservation(
        title: 'Other User Reservation',
        description: 'Other User Description',
        startTime: now,
        endTime: later,
        location: 'Other Location',
        userId: 'other-user-id',
      );
      
      mockDatabaseService.addReservations([testReservation, otherUserReservation]);
      
      final userReservations = await container.read(userReservationsProvider(userId).future);
      
      expect(userReservations.length, 1);
      expect(userReservations[0].id, testReservation.id);
      expect(userReservations[0].userId, userId);
    });

    test('reservationNotifierProvider should load reservations on initialization', () async {
      mockDatabaseService.addReservations([testReservation]);
      
      // Access the notifier to trigger initialization
      container.read(reservationNotifierProvider.notifier);
      final state = container.read(reservationNotifierProvider);
      
      // Wait for the initial loading to complete
      await Future.delayed(Duration.zero);
      
      expect(state.hasValue, true);
      
      final reservations = state.value!;
      expect(reservations.length, 1);
      expect(reservations[0].id, testReservation.id);
    });

    test('addReservation should add reservation to database and firebase', () async {
      final notifier = container.read(reservationNotifierProvider.notifier);
      
      await notifier.addReservation(testReservation);
      
      // Verify database service was called
      final dbReservations = await mockDatabaseService.getReservations();
      expect(dbReservations.length, 1);
      expect(dbReservations[0].id, testReservation.id);
      
      // Verify firebase service was called
      final fbReservation = await mockFirebaseService.getReservationById(testReservation.id);
      expect(fbReservation, isNotNull);
      expect(fbReservation!.id, testReservation.id);
    });

    test('updateReservation should update reservation in database and firebase', () async {
      mockDatabaseService.addReservations([testReservation]);
      mockFirebaseService.addReservations([testReservation]);
      
      final updatedReservation = testReservation.copyWith(
        title: 'Updated Title',
        description: 'Updated Description',
      );
      
      final notifier = container.read(reservationNotifierProvider.notifier);
      
      await notifier.updateReservation(updatedReservation);
      
      // Verify database service was called
      final dbReservation = await mockDatabaseService.getReservationById(testReservation.id);
      expect(dbReservation!.title, 'Updated Title');
      expect(dbReservation.description, 'Updated Description');
      
      // Verify firebase service was called
      final fbReservation = await mockFirebaseService.getReservationById(testReservation.id);
      expect(fbReservation!.title, 'Updated Title');
      expect(fbReservation.description, 'Updated Description');
    });

    test('deleteReservation should delete reservation from database and firebase', () async {
      mockDatabaseService.addReservations([testReservation]);
      mockFirebaseService.addReservations([testReservation]);
      
      final notifier = container.read(reservationNotifierProvider.notifier);
      
      await notifier.deleteReservation(testReservation.id);
      
      // Verify database service was called
      final dbReservations = await mockDatabaseService.getReservations();
      expect(dbReservations.length, 0);
      
      // Verify firebase service was called
      final fbReservation = await mockFirebaseService.getReservationById(testReservation.id);
      expect(fbReservation, isNull);
    });

    test('syncWithFirebase should sync reservations with firebase', () async {
      mockDatabaseService.addReservations([testReservation]);
      
      final notifier = container.read(reservationNotifierProvider.notifier);
      
      await notifier.syncWithFirebase();
      
      // Verify firebase service was called
      final fbReservation = await mockFirebaseService.getReservationById(testReservation.id);
      expect(fbReservation, isNotNull);
      expect(fbReservation!.id, testReservation.id);
    });

    test('addReservation should handle database errors', () async {
      mockDatabaseService.throwOnOperation = true;
      
      final notifier = container.read(reservationNotifierProvider.notifier);
      
      await notifier.addReservation(testReservation);
      
      final state = container.read(reservationNotifierProvider);
      expect(state.hasError, true);
    });

    test('updateReservation should handle database errors', () async {
      mockDatabaseService.throwOnOperation = true;
      
      final notifier = container.read(reservationNotifierProvider.notifier);
      
      await notifier.updateReservation(testReservation);
      
      final state = container.read(reservationNotifierProvider);
      expect(state.hasError, true);
    });

    test('deleteReservation should handle database errors', () async {
      mockDatabaseService.throwOnOperation = true;
      
      final notifier = container.read(reservationNotifierProvider.notifier);
      
      await notifier.deleteReservation(testReservation.id);
      
      final state = container.read(reservationNotifierProvider);
      expect(state.hasError, true);
    });

    test('syncWithFirebase should handle firebase errors', () async {
      mockDatabaseService.addReservations([testReservation]);
      mockFirebaseService.throwOnOperation = true;
      
      final notifier = container.read(reservationNotifierProvider.notifier);
      
      await notifier.syncWithFirebase();
      
      final state = container.read(reservationNotifierProvider);
      expect(state.hasError, true);
    });

    test('addReservation should continue even if firebase fails', () async {
      mockFirebaseService.throwOnOperation = true;
      
      final notifier = container.read(reservationNotifierProvider.notifier);
      
      await notifier.addReservation(testReservation);
      
      // Verify database service was still called successfully
      final dbReservations = await mockDatabaseService.getReservations();
      expect(dbReservations.length, 1);
      expect(dbReservations[0].id, testReservation.id);
    });
  });
}
