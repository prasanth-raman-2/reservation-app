import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reservation_management/models/reservation_model.dart';
import 'package:reservation_management/providers/auth_provider.dart';
import 'package:reservation_management/providers/reservation_provider.dart';
import 'package:reservation_management/screens/reservation_form_screen.dart';
import 'package:reservation_management/widgets/date_time_picker.dart';
import 'package:reservation_management/widgets/location_picker.dart';
import '../mocks/mock_database_service.dart';
import '../mocks/mock_firebase_service.dart';

void main() {
  group('ReservationFormScreen Tests', () {
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

    testWidgets('renders create form correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseServiceProvider.overrideWithValue(mockDatabaseService),
            firebaseServiceProvider.overrideWithValue(mockFirebaseService),
            userIdProvider.overrideWithValue('test-user'),
          ],
          child: const MaterialApp(
            home: ReservationFormScreen(),
          ),
        ),
      );

      // Verify the form elements are displayed
      expect(find.text('Create Reservation'), findsOneWidget);
      expect(find.byType(TextFormField), findsAtLeastNWidgets(2)); // Title and description fields
      expect(find.byType(DateTimePicker), findsAtLeastNWidgets(2)); // Start and end time pickers
      expect(find.byType(LocationPicker), findsOneWidget);
      expect(find.text('Create Reservation'), findsAtLeastNWidgets(2)); // Title and button
    });

    testWidgets('renders edit form correctly with reservation data', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseServiceProvider.overrideWithValue(mockDatabaseService),
            firebaseServiceProvider.overrideWithValue(mockFirebaseService),
            userIdProvider.overrideWithValue('test-user'),
          ],
          child: MaterialApp(
            home: ReservationFormScreen(reservation: testReservation),
          ),
        ),
      );

      // Verify the form elements are displayed with reservation data
      expect(find.text('Edit Reservation'), findsOneWidget);
      expect(find.text('Test Reservation'), findsOneWidget); // Title field
      expect(find.text('This is a test reservation description'), findsOneWidget); // Description field
      expect(find.text('123 Test Street, Test City'), findsOneWidget); // Location field
      expect(find.text('Update Reservation'), findsOneWidget); // Button
    });

    testWidgets('validates form fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseServiceProvider.overrideWithValue(mockDatabaseService),
            firebaseServiceProvider.overrideWithValue(mockFirebaseService),
            userIdProvider.overrideWithValue('test-user'),
          ],
          child: const MaterialApp(
            home: ReservationFormScreen(),
          ),
        ),
      );

      // Try to submit the form without filling in required fields
      await tester.tap(find.text('Create Reservation').last);
      await tester.pumpAndSettle();
      
      // Should show validation errors
      expect(find.text('Title is required'), findsOneWidget);
      expect(find.text('Description must be at least 10 characters'), findsOneWidget);
    });

    testWidgets('submits form and creates reservation', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseServiceProvider.overrideWithValue(mockDatabaseService),
            firebaseServiceProvider.overrideWithValue(mockFirebaseService),
            userIdProvider.overrideWithValue('test-user'),
          ],
          child: const MaterialApp(
            home: ReservationFormScreen(),
          ),
        ),
      );

      // Fill in the form fields
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Title'), 
        'New Test Reservation'
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Description'), 
        'This is a new test reservation description'
      );
      
      // Submit the form
      await tester.tap(find.text('Create Reservation').last);
      await tester.pumpAndSettle();
      
      // Verify the reservation was created
      expect(mockDatabaseService.getReservations(), completion(isNotEmpty));
      
      // Should show success message and navigate back
      expect(find.text('Reservation created successfully'), findsOneWidget);
    });

    testWidgets('updates existing reservation', (WidgetTester tester) async {
      // Add the test reservation to the mock database
      mockDatabaseService.addReservations([testReservation]);
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseServiceProvider.overrideWithValue(mockDatabaseService),
            firebaseServiceProvider.overrideWithValue(mockFirebaseService),
            userIdProvider.overrideWithValue('test-user'),
          ],
          child: MaterialApp(
            home: ReservationFormScreen(reservation: testReservation),
          ),
        ),
      );

      // Update the title
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Test Reservation'), 
        'Updated Test Reservation'
      );
      
      // Submit the form
      await tester.tap(find.text('Update Reservation'));
      await tester.pumpAndSettle();
      
      // Verify the reservation was updated
      final updatedReservations = await mockDatabaseService.getReservations();
      expect(updatedReservations.first.title, 'Updated Test Reservation');
      
      // Should show success message and navigate back
      expect(find.text('Reservation updated successfully'), findsOneWidget);
    });

    testWidgets('shows loading indicator during form submission', (WidgetTester tester) async {
      // Create a delayed mock database service
      final delayedMockDatabaseService = MockDatabaseService();
      delayedMockDatabaseService.throwOnOperation = false;
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseServiceProvider.overrideWithValue(delayedMockDatabaseService),
            firebaseServiceProvider.overrideWithValue(mockFirebaseService),
            userIdProvider.overrideWithValue('test-user'),
          ],
          child: const MaterialApp(
            home: ReservationFormScreen(),
          ),
        ),
      );

      // Fill in the form fields
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Title'), 
        'New Test Reservation'
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Description'), 
        'This is a new test reservation description'
      );
      
      // Submit the form
      await tester.tap(find.text('Create Reservation').last);
      await tester.pump(); // Pump once to start the async operation
      
      // Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error message when database operation fails', (WidgetTester tester) async {
      // Make the mock database throw an error
      mockDatabaseService.throwOnOperation = true;
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseServiceProvider.overrideWithValue(mockDatabaseService),
            firebaseServiceProvider.overrideWithValue(mockFirebaseService),
            userIdProvider.overrideWithValue('test-user'),
          ],
          child: const MaterialApp(
            home: ReservationFormScreen(),
          ),
        ),
      );

      // Fill in the form fields
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Title'), 
        'New Test Reservation'
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Description'), 
        'This is a new test reservation description'
      );
      
      // Submit the form
      await tester.tap(find.text('Create Reservation').last);
      await tester.pumpAndSettle();
      
      // Should show error message
      expect(find.textContaining('Error:'), findsOneWidget);
    });
  });
}
