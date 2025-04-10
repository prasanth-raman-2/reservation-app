import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reservation_management/models/reservation_model.dart';
import 'package:reservation_management/providers/reservation_provider.dart';
import 'package:reservation_management/screens/reservation_list_screen.dart';
import 'package:reservation_management/widgets/reservation_card.dart';
import '../mocks/mock_database_service.dart';
import '../mocks/mock_firebase_service.dart';
import 'test_helpers.dart';

void main() {
  group('ReservationListScreen Tests', () {
    late List<Reservation> testReservations;
    late MockDatabaseService mockDatabaseService;
    late MockFirebaseService mockFirebaseService;
    
    setUp(() {
      testReservations = TestHelpers.createSampleReservations();
      mockDatabaseService = MockDatabaseService();
      mockFirebaseService = MockFirebaseService();
      
      mockDatabaseService.addReservations(testReservations);
    });

    testWidgets('displays loading indicator initially', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseServiceProvider.overrideWithValue(mockDatabaseService),
            firebaseServiceProvider.overrideWithValue(mockFirebaseService),
          ],
          child: const MaterialApp(
            home: ReservationListScreen(),
          ),
        ),
      );

      // Initially should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      // Wait for async operations to complete
      await tester.pumpAndSettle();
      
      // After loading, should show reservation cards
      expect(find.byType(ReservationCard), findsNWidgets(testReservations.length));
    });

    testWidgets('displays empty state when no reservations', (WidgetTester tester) async {
      // Clear the mock database
      mockDatabaseService.clear();
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseServiceProvider.overrideWithValue(mockDatabaseService),
            firebaseServiceProvider.overrideWithValue(mockFirebaseService),
          ],
          child: const MaterialApp(
            home: ReservationListScreen(),
          ),
        ),
      );

      // Wait for async operations to complete
      await tester.pumpAndSettle();
      
      // Should show empty state
      expect(find.text('No Reservations'), findsOneWidget);
      expect(find.text('Tap the + button to create a new reservation'), findsOneWidget);
    });

    testWidgets('displays error state when database throws error', (WidgetTester tester) async {
      // Make the mock database throw an error
      mockDatabaseService.throwOnOperation = true;
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseServiceProvider.overrideWithValue(mockDatabaseService),
            firebaseServiceProvider.overrideWithValue(mockFirebaseService),
          ],
          child: const MaterialApp(
            home: ReservationListScreen(),
          ),
        ),
      );

      // Wait for async operations to complete
      await tester.pumpAndSettle();
      
      // Should show error state
      expect(find.textContaining('Error:'), findsOneWidget);
    });

    testWidgets('tapping on a reservation card navigates to detail screen', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseServiceProvider.overrideWithValue(mockDatabaseService),
            firebaseServiceProvider.overrideWithValue(mockFirebaseService),
          ],
          child: const MaterialApp(
            home: ReservationListScreen(),
          ),
        ),
      );

      // Wait for async operations to complete
      await tester.pumpAndSettle();
      
      // Tap on the first reservation card
      await tester.tap(find.byType(ReservationCard).first);
      await tester.pumpAndSettle();
      
      // Should navigate to detail screen
      expect(find.text('Reservation Details'), findsOneWidget);
    });

    testWidgets('tapping on edit button navigates to form screen', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseServiceProvider.overrideWithValue(mockDatabaseService),
            firebaseServiceProvider.overrideWithValue(mockFirebaseService),
          ],
          child: const MaterialApp(
            home: ReservationListScreen(),
          ),
        ),
      );

      // Wait for async operations to complete
      await tester.pumpAndSettle();
      
      // Tap on the edit button of the first reservation card
      await tester.tap(find.byIcon(Icons.edit).first);
      await tester.pumpAndSettle();
      
      // Should navigate to form screen with "Edit Reservation" title
      expect(find.text('Edit Reservation'), findsOneWidget);
    });

    testWidgets('tapping on delete button shows confirmation dialog', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseServiceProvider.overrideWithValue(mockDatabaseService),
            firebaseServiceProvider.overrideWithValue(mockFirebaseService),
          ],
          child: const MaterialApp(
            home: ReservationListScreen(),
          ),
        ),
      );

      // Wait for async operations to complete
      await tester.pumpAndSettle();
      
      // Tap on the delete button of the first reservation card
      await tester.tap(find.byIcon(Icons.delete).first);
      await tester.pumpAndSettle();
      
      // Should show confirmation dialog
      expect(find.text('Delete Reservation'), findsOneWidget);
      expect(find.text('Are you sure you want to delete this reservation?'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('tapping on floating action button navigates to form screen', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseServiceProvider.overrideWithValue(mockDatabaseService),
            firebaseServiceProvider.overrideWithValue(mockFirebaseService),
          ],
          child: const MaterialApp(
            home: ReservationListScreen(),
          ),
        ),
      );

      // Wait for async operations to complete
      await tester.pumpAndSettle();
      
      // Tap on the floating action button
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      
      // Should navigate to form screen with "Create Reservation" title
      expect(find.text('Create Reservation'), findsOneWidget);
    });
  });
}