import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reservation_management/models/reservation_model.dart';
import 'package:reservation_management/widgets/reservation_card.dart';
import 'test_helpers.dart';

void main() {
  group('ReservationCard Widget Tests', () {
    late Reservation testReservation;
    
    setUp(() {
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

    testWidgets('renders correctly with all information', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestableWidget(
          ReservationCard(
            reservation: testReservation,
          ),
        ),
      );

      // Verify the widget displays correctly
      expect(find.text('Test Reservation'), findsOneWidget);
      expect(find.text('This is a test reservation description'), findsOneWidget);
      expect(find.text(testReservation.formattedStartTime), findsOneWidget);
      expect(find.text(testReservation.formattedDuration), findsOneWidget);
      expect(find.text('123 Test Street, Test City'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget); // Confirmed icon
    });

    testWidgets('does not show confirmed icon when not confirmed', (WidgetTester tester) async {
      final unconfirmedReservation = testReservation.copyWith(isConfirmed: false);
      
      await tester.pumpWidget(
        TestHelpers.createTestableWidget(
          ReservationCard(
            reservation: unconfirmedReservation,
          ),
        ),
      );

      // Verify the confirmed icon is not shown
      expect(find.byIcon(Icons.check_circle), findsNothing);
    });

    testWidgets('shows edit and delete buttons when callbacks provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestableWidget(
          ReservationCard(
            reservation: testReservation,
            onEdit: () {},
            onDelete: () {},
          ),
        ),
      );

      // Verify edit and delete buttons are shown
      expect(find.byIcon(Icons.edit), findsOneWidget);
      expect(find.byIcon(Icons.delete), findsOneWidget);
    });

    testWidgets('does not show edit and delete buttons when callbacks not provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestableWidget(
          ReservationCard(
            reservation: testReservation,
          ),
        ),
      );

      // Verify edit and delete buttons are not shown
      expect(find.byIcon(Icons.edit), findsNothing);
      expect(find.byIcon(Icons.delete), findsNothing);
    });

    testWidgets('calls onTap when tapped', (WidgetTester tester) async {
      bool tapped = false;
      
      await tester.pumpWidget(
        TestHelpers.createTestableWidget(
          ReservationCard(
            reservation: testReservation,
            onTap: () {
              tapped = true;
            },
          ),
        ),
      );

      // Tap on the card
      await tester.tap(find.byType(InkWell));
      await tester.pump();
      
      // Verify onTap was called
      expect(tapped, true);
    });

    testWidgets('calls onEdit when edit button tapped', (WidgetTester tester) async {
      bool edited = false;
      
      await tester.pumpWidget(
        TestHelpers.createTestableWidget(
          ReservationCard(
            reservation: testReservation,
            onEdit: () {
              edited = true;
            },
            onDelete: () {},
          ),
        ),
      );

      // Tap on the edit button
      await tester.tap(find.byIcon(Icons.edit));
      await tester.pump();
      
      // Verify onEdit was called
      expect(edited, true);
    });

    testWidgets('calls onDelete when delete button tapped', (WidgetTester tester) async {
      bool deleted = false;
      
      await tester.pumpWidget(
        TestHelpers.createTestableWidget(
          ReservationCard(
            reservation: testReservation,
            onEdit: () {},
            onDelete: () {
              deleted = true;
            },
          ),
        ),
      );

      // Tap on the delete button
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pump();
      
      // Verify onDelete was called
      expect(deleted, true);
    });
  });
}