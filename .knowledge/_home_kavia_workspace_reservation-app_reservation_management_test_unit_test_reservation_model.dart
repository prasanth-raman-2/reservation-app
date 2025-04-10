{"is_source_file": true, "format": "dart", "description": "Unit tests for the Reservation model in the reservation management application, validating various functionalities of the Reservation class.", "external_files": ["package:flutter_test/flutter_test.dart", "package:reservation_management/models/reservation_model.dart", "package:uuid/uuid.dart", "package:intl/intl.dart"], "external_methods": ["Uuid.v4()", "DateFormat.format(DateTime)"], "published": ["Reservation"], "classes": [{"name": "Reservation", "description": "Represents a reservation with attributes such as title, description, start and end times, location, user ID, and confirmation status."}], "methods": [], "calls": ["expect", "Reservation.toMap()", "Reservation.fromMap(Map)", "Reservation.copyWith()", "DateTime.now()", "DateTime.add(Duration)", "DateTime.subtract(Duration)", "DateFormat('MMM d, yyyy - h:mm a').format(DateTime)"], "search-terms": ["Reservation Model Tests", "create a Reservation", "convert Reservation to Map", "copy Reservation", "formatting dates", "calculating duration"], "state": 2, "file_id": 69, "knowledge_revision": 195, "git_revision": "", "filename": "/home/kavia/workspace/reservation-app/reservation_management/test/unit/test_reservation_model.dart", "hash": "8d05cd8b0f8108f9a64b12df2d4e3aae", "format-version": 4, "code-base-name": "default", "revision_history": [{"195": ""}]}