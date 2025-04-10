import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:reservation_management/widgets/location_picker.dart';
import 'test_helpers.dart';

void main() {
  // Register the map plugin
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocationPicker Widget Tests', () {
    testWidgets('renders correctly with initial values', (WidgetTester tester) async {
      const String initialAddress = '123 Test Street, Test City';
      const double initialLatitude = 37.7749;
      const double initialLongitude = -122.4194;
      
      await tester.pumpWidget(
        TestHelpers.createTestableWidget(
          LocationPicker(
            initialAddress: initialAddress,
            initialLatitude: initialLatitude,
            initialLongitude: initialLongitude,
            labelText: 'Test Location',
            onAddressChanged: (_) {},
            onLatitudeChanged: (_) {},
            onLongitudeChanged: (_) {},
          ),
        ),
      );

      // Verify the widget displays correctly
      expect(find.text('Test Location'), findsOneWidget);
      expect(find.text(initialAddress), findsOneWidget);
      expect(find.byType(GoogleMap), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('renders correctly without initial values', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestableWidget(
          LocationPicker(
            labelText: 'Test Location',
            onAddressChanged: (_) {},
            onLatitudeChanged: (_) {},
            onLongitudeChanged: (_) {},
          ),
        ),
      );

      // Verify the widget displays correctly
      expect(find.text('Test Location'), findsOneWidget);
      expect(find.byType(GoogleMap), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('displays helper text when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestableWidget(
          LocationPicker(
            labelText: 'Test Location',
            helperText: 'Select a location',
            onAddressChanged: (_) {},
            onLatitudeChanged: (_) {},
            onLongitudeChanged: (_) {},
          ),
        ),
      );

      // Verify helper text is displayed
      expect(find.text('Select a location'), findsOneWidget);
    });

    testWidgets('displays error text when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestableWidget(
          LocationPicker(
            labelText: 'Test Location',
            errorText: 'Invalid location',
            onAddressChanged: (_) {},
            onLatitudeChanged: (_) {},
            onLongitudeChanged: (_) {},
          ),
        ),
      );

      // Verify error text is displayed
      expect(find.text('Invalid location'), findsOneWidget);
    });

    testWidgets('typing in text field calls onAddressChanged', (WidgetTester tester) async {
      String? changedAddress;
      
      await tester.pumpWidget(
        TestHelpers.createTestableWidget(
          LocationPicker(
            labelText: 'Test Location',
            onAddressChanged: (address) {
              changedAddress = address;
            },
            onLatitudeChanged: (_) {},
            onLongitudeChanged: (_) {},
          ),
        ),
      );

      // Type in the text field
      await tester.enterText(find.byType(TextField), 'New Test Address');
      
      // Verify onAddressChanged was called
      expect(changedAddress, 'New Test Address');
    });

    testWidgets('tapping search button calls search function', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestableWidget(
          LocationPicker(
            labelText: 'Test Location',
            onAddressChanged: (_) {},
            onLatitudeChanged: (_) {},
            onLongitudeChanged: (_) {},
          ),
        ),
      );

      // Enter text and tap search button
      await tester.enterText(find.byType(TextField), 'Search Address');
      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();
      
      // Note: We can't fully test the search functionality because it involves
      // actual geocoding API calls that are mocked in widget tests
    });
  });
}