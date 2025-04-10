import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:reservation_management/models/reservation_model.dart';
import 'package:reservation_management/providers/reservation_provider.dart';
import 'package:reservation_management/screens/reservation_detail_screen.dart';
import '../mocks/mock_database_service.dart';
import '../mocks/mock_firebase_service.dart';

void main() {
  // Register the map plugin
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('ReservationDetailScreen Tests', () {
    late MockDatabaseService mockDatabaseService;
    late MockFirebaseService mockFirebaseService;
    late Reservation testReservation;
    
    setUp(() {
      mockDatabaseService = MockDatabaseService();
      mockFirebaseService = MockFirebaseService();
      
      final now = DateTime.now();
      testReservation = Reservation(
        id: '1',
        title: 'Test Reservation',
        description: 'This is a test reservation description',
        startTime: now.add(const Duration(hours: 1)),
        endTime: now.add(const Duration(hours: 3)),
        location: '123 Test Street, Test City',
        latitude: 37.7749,
        longitude: -122.4194,
        userId: 'user1',
        isConfirmed: true,
      );
    });

    testWidgets('renders reservation details correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseServiceProvider.overrideWithValue(mockDatabaseService),
            firebaseServiceProvider.overrideWithValue(mockFirebaseService),
          ],
          child: MaterialApp(
            home: ReservationDetailScreen(reservation: testReservation),
          ),
        ),
      );

      // Verify the details are displayed correctly
      expect(find.text('Reservation Details'), findsOneWidget);
      expect(find.text('Test Reservation'), findsOneWidget);
      expect(find.text('This is a test reservation description'), findsOneWidget);
      expect(find.text('123 Test Street, Test City'), findsOneWidget);
      expect(find.text('Start: ${testReservation.formattedStartTime}'), findsOneWidget);
      expect(find.text('End: ${testReservation.formattedEndTime}'), findsOneWidget);
      expect(find.text('Duration: ${testReservation.formattedDuration}'), findsOneWidget);
      expect(find.text('Confirmed'), findsOneWidget);
      expect(find.byType(GoogleMap), findsOneWidget);
    });

    testWidgets('shows pending status when reservation is not confirmed', (WidgetTester tester) async {
      final unconfirmedReservation = testReservation.copyWith(isConfirmed: false);
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseServiceProvider.overrideWithValue(mockDatabaseService),
            firebaseServiceProvider.overrideWithValue(mockFirebaseService),
          ],
          child: MaterialApp(
            home: ReservationDetailScreen(reservation: unconfirmedReservation),
          ),
        ),
      );

      // Verify pending status is displayed
      expect(find.text('Pending'), findsOneWidget);
      expect(find.text('Confirmed'), findsNothing);
    });

    testWidgets('tapping edit button navigates to edit screen', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseServiceProvider.overrideWithValue(mockDatabaseService),
            firebaseServiceProvider.overrideWithValue(mockFirebaseService),
          ],
          child: MaterialApp(
            home: ReservationDetailScreen(reservation: testReservation),
          ),
        ),
      );

      // Tap on the edit button
      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();
      
      // Should navigate to edit screen
      expect(find.text('Edit Reservation'), findsOneWidget);
    });

    testWidgets('tapping delete button shows confirmation dialog', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseServiceProvider.overrideWithValue(mockDatabaseService),
            firebaseServiceProvider.overrideWithValue(mockFirebaseService),
          ],
          child: MaterialApp(
            home: ReservationDetailScreen(reservation: testReservation),
          ),
        ),
      );

      // Tap on the delete button
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();
      
      // Should show confirmation dialog
      expect(find.text('Delete Reservation'), findsOneWidget);
      expect(find.text('Are you sure you want to delete this reservation?'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('confirming delete removes reservation and navigates back', (WidgetTester tester) async {
      // Add the test reservation to the mock database
      mockDatabaseService.addReservations([testReservation]);
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseServiceProvider.overrideWithValue(mockDatabaseService),
            firebaseServiceProvider.overrideWithValue(mockFirebaseService),
          ],
          child: MaterialApp(
            home: ReservationDetailScreen(reservation: testReservation),
          ),
        ),
      );

      // Tap on the delete button
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();
      
      // Tap on the Delete button in the dialog
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      
      // Verify the reservation was deleted
      final reservations = await mockDatabaseService.getReservations();
      expect(reservations, isEmpty);
      
      // Should show success message
      expect(find.text('Reservation deleted successfully'), findsOneWidget);
    });

    testWidgets('shows error message when delete operation fails', (WidgetTester tester) async {
      // Make the mock database throw an error
      mockDatabaseService.throwOnOperation = true;
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseServiceProvider.overrideWithValue(mockDatabaseService),
            firebaseServiceProvider.overrideWithValue(mockFirebaseService),
          ],
          child: MaterialApp(
            home: ReservationDetailScreen(reservation: testReservation),
          ),
        ),
      );

      // Tap on the delete button
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();
      
      // Tap on the Delete button in the dialog
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      
      // Should show error message
      expect(find.textContaining('Error:'), findsOneWidget);
    });
  });
}