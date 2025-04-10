import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reservation_management/models/reservation_model.dart';
import 'package:reservation_management/providers/reservation_provider.dart';
import '../mocks/mock_database_service.dart';
import '../mocks/mock_firebase_service.dart';

/// Helper class for widget tests
class TestHelpers {
  /// Create a test wrapper with providers
  static Widget createTestableWidget(Widget child) {
    return MaterialApp(
      home: ProviderScope(
        overrides: [
          databaseServiceProvider.overrideWithValue(MockDatabaseService()),
          firebaseServiceProvider.overrideWithValue(MockFirebaseService()),
        ],
        child: Material(child: child),
      ),
    );
  }

  /// Create a test wrapper with providers and mock data
  static Widget createTestableWidgetWithMockData(
    Widget child, {
    List<Reservation>? reservations,
    bool throwDatabaseError = false,
    bool throwFirebaseError = false,
  }) {
    final mockDatabaseService = MockDatabaseService();
    final mockFirebaseService = MockFirebaseService();

    if (reservations != null) {
      mockDatabaseService.addReservations(reservations);
      mockFirebaseService.addReservations(reservations);
    }

    mockDatabaseService.throwOnOperation = throwDatabaseError;
    mockFirebaseService.throwOnOperation = throwFirebaseError;

    return MaterialApp(
      home: ProviderScope(
        overrides: [
          databaseServiceProvider.overrideWithValue(mockDatabaseService),
          firebaseServiceProvider.overrideWithValue(mockFirebaseService),
        ],
        child: Material(child: child),
      ),
    );
  }

  /// Create sample reservation data for testing
  static List<Reservation> createSampleReservations() {
    final now = DateTime.now();
    return [
      Reservation(
        id: '1',
        title: 'Meeting with Team',
        description: 'Discuss project progress and next steps',
        startTime: now.add(const Duration(hours: 1)),
        endTime: now.add(const Duration(hours: 2)),
        location: '123 Main St, City',
        latitude: 37.7749,
        longitude: -122.4194,
        userId: 'user1',
        isConfirmed: true,
      ),
      Reservation(
        id: '2',
        title: 'Lunch with Client',
        description: 'Discuss new project requirements',
        startTime: now.add(const Duration(days: 1)),
        endTime: now.add(const Duration(days: 1, hours: 1)),
        location: '456 Market St, City',
        latitude: 37.7899,
        longitude: -122.4000,
        userId: 'user1',
        isConfirmed: false,
      ),
      Reservation(
        id: '3',
        title: 'Conference Call',
        description: 'International team sync-up',
        startTime: now.add(const Duration(days: 2)),
        endTime: now.add(const Duration(days: 2, hours: 2)),
        location: 'Online',
        userId: 'user2',
        isConfirmed: true,
      ),
    ];
  }
}
