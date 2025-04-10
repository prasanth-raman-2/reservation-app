import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:reservation_management/widgets/date_time_picker.dart';
import 'test_helpers.dart';

void main() {
  group('DateTimePicker Widget Tests', () {
    testWidgets('renders correctly with initial value', (WidgetTester tester) async {
      final DateTime initialValue = DateTime(2023, 5, 15, 10, 30);
      final String formattedDateTime = DateFormat('MMM d, yyyy - h:mm a').format(initialValue);
      
      await tester.pumpWidget(
        TestHelpers.createTestableWidget(
          DateTimePicker(
            initialValue: initialValue,
            labelText: 'Test Date',
            onChanged: (_) {},
          ),
        ),
      );

      // Verify the widget displays correctly
      expect(find.text('Test Date'), findsOneWidget);
      expect(find.text(formattedDateTime), findsOneWidget);
      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
    });

    testWidgets('renders correctly without initial value', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestableWidget(
          DateTimePicker(
            labelText: 'Test Date',
            onChanged: (_) {},
          ),
        ),
      );

      // Verify the widget displays correctly
      expect(find.text('Test Date'), findsOneWidget);
      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
    });

    testWidgets('displays helper text when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestableWidget(
          DateTimePicker(
            labelText: 'Test Date',
            helperText: 'Select a date and time',
            onChanged: (_) {},
          ),
        ),
      );

      // Verify helper text is displayed
      expect(find.text('Select a date and time'), findsOneWidget);
    });

    testWidgets('displays error text when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestableWidget(
          DateTimePicker(
            labelText: 'Test Date',
            errorText: 'Invalid date',
            onChanged: (_) {},
          ),
        ),
      );

      // Verify error text is displayed
      expect(find.text('Invalid date'), findsOneWidget);
    });

    testWidgets('tapping opens date picker', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DateTimePicker(
              labelText: 'Test Date',
              onChanged: (_) {},
            ),
          ),
        ),
      );

      // Tap on the date picker
      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();

      // Verify date picker dialog is shown
      expect(find.byType(DatePickerDialog), findsOneWidget);
      
      // Note: We can't fully test the date selection flow because it involves
      // native date picker dialogs that are difficult to interact with in widget tests
    });
  });
}
