{"is_source_file": true, "format": "Dart", "description": "Unit tests for the ReservationDetailScreen widget in a reservation management application.", "external_files": ["package:flutter/material.dart", "package:flutter_riverpod/flutter_riverpod.dart", "package:flutter_test/flutter_test.dart", "package:google_maps_flutter/google_maps_flutter.dart", "package:reservation_management/models/reservation_model.dart", "package:reservation_management/providers/reservation_provider.dart", "package:reservation_management/screens/reservation_detail_screen.dart", "../mocks/mock_database_service.dart", "../mocks/mock_firebase_service.dart"], "external_methods": ["databaseServiceProvider.overrideWithValue", "firebaseServiceProvider.overrideWithValue", "MaterialApp", "ProviderScope", "expect.find", "mockDatabaseService.addReservations", "mockDatabaseService.getReservations"], "published": [], "classes": [], "methods": [], "calls": ["expect.find.text", "await tester.pumpWidget", "await tester.tap", "await tester.pumpAndSettle"], "search-terms": ["ReservationDetailScreen", "Unit tests", "Widget tests", "TestWidgetsFlutterBinding"], "state": 2, "file_id": 82, "knowledge_revision": 225, "git_revision": "", "filename": "/home/kavia/workspace/reservation-app/reservation_management/test/widget/test_reservation_detail_screen.dart", "hash": "66a905b8840b400cafe06f044a76f542", "format-version": 4, "code-base-name": "default", "revision_history": [{"225": ""}]}