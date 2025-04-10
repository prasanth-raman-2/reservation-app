import 'package:flutter_test/flutter_test.dart';
import 'package:reservation_management/models/reservation_model.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

void main() {
  group('Reservation Model Tests', () {
    final DateTime now = DateTime.now();
    final DateTime later = now.add(const Duration(hours: 2));
    final String userId = 'test-user-id';
    
    test('should create a Reservation with all required fields', () {
      final reservation = Reservation(
        title: 'Test Reservation',
        description: 'Test Description',
        startTime: now,
        endTime: later,
        location: 'Test Location',
        userId: userId,
      );
      
      expect(reservation.title, 'Test Reservation');
      expect(reservation.description, 'Test Description');
      expect(reservation.startTime, now);
      expect(reservation.endTime, later);
      expect(reservation.location, 'Test Location');
      expect(reservation.userId, userId);
      expect(reservation.isConfirmed, false);
      expect(reservation.id.isNotEmpty, true);
    });
    
    test('should create a Reservation with all fields', () {
      final String id = const Uuid().v4();
      final DateTime createdAt = now.subtract(const Duration(days: 1));
      final DateTime updatedAt = now.subtract(const Duration(hours: 1));
      
      final reservation = Reservation(
        id: id,
        title: 'Test Reservation',
        description: 'Test Description',
        startTime: now,
        endTime: later,
        location: 'Test Location',
        latitude: 37.7749,
        longitude: -122.4194,
        userId: userId,
        isConfirmed: true,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
      
      expect(reservation.id, id);
      expect(reservation.title, 'Test Reservation');
      expect(reservation.description, 'Test Description');
      expect(reservation.startTime, now);
      expect(reservation.endTime, later);
      expect(reservation.location, 'Test Location');
      expect(reservation.latitude, 37.7749);
      expect(reservation.longitude, -122.4194);
      expect(reservation.userId, userId);
      expect(reservation.isConfirmed, true);
      expect(reservation.createdAt, createdAt);
      expect(reservation.updatedAt, updatedAt);
    });
    
    test('should convert Reservation to Map correctly', () {
      final String id = const Uuid().v4();
      final DateTime createdAt = now.subtract(const Duration(days: 1));
      final DateTime updatedAt = now.subtract(const Duration(hours: 1));
      
      final reservation = Reservation(
        id: id,
        title: 'Test Reservation',
        description: 'Test Description',
        startTime: now,
        endTime: later,
        location: 'Test Location',
        latitude: 37.7749,
        longitude: -122.4194,
        userId: userId,
        isConfirmed: true,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
      
      final map = reservation.toMap();
      
      expect(map['id'], id);
      expect(map['title'], 'Test Reservation');
      expect(map['description'], 'Test Description');
      expect(map['startTime'], now.toIso8601String());
      expect(map['endTime'], later.toIso8601String());
      expect(map['location'], 'Test Location');
      expect(map['latitude'], 37.7749);
      expect(map['longitude'], -122.4194);
      expect(map['userId'], userId);
      expect(map['isConfirmed'], true);
      expect(map['createdAt'], createdAt.toIso8601String());
      expect(map['updatedAt'], updatedAt.toIso8601String());
    });
    
    test('should create Reservation from Map correctly', () {
      final String id = const Uuid().v4();
      final String startTimeStr = now.toIso8601String();
      final String endTimeStr = later.toIso8601String();
      final String createdAtStr = now.subtract(const Duration(days: 1)).toIso8601String();
      final String updatedAtStr = now.subtract(const Duration(hours: 1)).toIso8601String();
      
      final map = {
        'id': id,
        'title': 'Test Reservation',
        'description': 'Test Description',
        'startTime': startTimeStr,
        'endTime': endTimeStr,
        'location': 'Test Location',
        'latitude': 37.7749,
        'longitude': -122.4194,
        'userId': userId,
        'isConfirmed': true,
        'createdAt': createdAtStr,
        'updatedAt': updatedAtStr,
      };
      
      final reservation = Reservation.fromMap(map);
      
      expect(reservation.id, id);
      expect(reservation.title, 'Test Reservation');
      expect(reservation.description, 'Test Description');
      expect(reservation.startTime.toIso8601String(), startTimeStr);
      expect(reservation.endTime.toIso8601String(), endTimeStr);
      expect(reservation.location, 'Test Location');
      expect(reservation.latitude, 37.7749);
      expect(reservation.longitude, -122.4194);
      expect(reservation.userId, userId);
      expect(reservation.isConfirmed, true);
      expect(reservation.createdAt.toIso8601String(), createdAtStr);
      expect(reservation.updatedAt.toIso8601String(), updatedAtStr);
    });
    
    test('should create Reservation from Map with DateTime objects', () {
      final String id = const Uuid().v4();
      
      final map = {
        'id': id,
        'title': 'Test Reservation',
        'description': 'Test Description',
        'startTime': now,
        'endTime': later,
        'location': 'Test Location',
        'latitude': 37.7749,
        'longitude': -122.4194,
        'userId': userId,
        'isConfirmed': true,
        'createdAt': now.subtract(const Duration(days: 1)),
        'updatedAt': now.subtract(const Duration(hours: 1)),
      };
      
      final reservation = Reservation.fromMap(map);
      
      expect(reservation.id, id);
      expect(reservation.startTime, map['startTime']);
      expect(reservation.endTime, map['endTime']);
      expect(reservation.createdAt, map['createdAt']);
      expect(reservation.updatedAt, map['updatedAt']);
    });
    
    test('should copy Reservation with new values correctly', () {
      final reservation = Reservation(
        title: 'Test Reservation',
        description: 'Test Description',
        startTime: now,
        endTime: later,
        location: 'Test Location',
        latitude: 37.7749,
        longitude: -122.4194,
        userId: userId,
      );
      
      final newStartTime = now.add(const Duration(hours: 1));
      final newEndTime = later.add(const Duration(hours: 1));
      
      final updatedReservation = reservation.copyWith(
        title: 'Updated Title',
        description: 'Updated Description',
        startTime: newStartTime,
        endTime: newEndTime,
        location: 'Updated Location',
        latitude: 38.7749,
        longitude: -123.4194,
        isConfirmed: true,
      );
      
      // Original reservation should remain unchanged
      expect(reservation.title, 'Test Reservation');
      expect(reservation.description, 'Test Description');
      expect(reservation.startTime, now);
      expect(reservation.endTime, later);
      expect(reservation.location, 'Test Location');
      expect(reservation.latitude, 37.7749);
      expect(reservation.longitude, -122.4194);
      expect(reservation.isConfirmed, false);
      
      // Updated reservation should have new values
      expect(updatedReservation.id, reservation.id); // ID should remain the same
      expect(updatedReservation.title, 'Updated Title');
      expect(updatedReservation.description, 'Updated Description');
      expect(updatedReservation.startTime, newStartTime);
      expect(updatedReservation.endTime, newEndTime);
      expect(updatedReservation.location, 'Updated Location');
      expect(updatedReservation.latitude, 38.7749);
      expect(updatedReservation.longitude, -123.4194);
      expect(updatedReservation.userId, userId); // userId should remain the same
      expect(updatedReservation.isConfirmed, true);
      expect(updatedReservation.createdAt, reservation.createdAt); // createdAt should remain the same
      expect(updatedReservation.updatedAt.isAfter(reservation.updatedAt), true); // updatedAt should be updated
    });
    
    test('should format start and end times correctly', () {
      final DateTime startTime = DateTime(2023, 5, 15, 10, 30);
      final DateTime endTime = DateTime(2023, 5, 15, 12, 45);
      
      final reservation = Reservation(
        title: 'Test Reservation',
        description: 'Test Description',
        startTime: startTime,
        endTime: endTime,
        location: 'Test Location',
        userId: userId,
      );
      
      final expectedStartTimeFormat = DateFormat('MMM d, yyyy - h:mm a').format(startTime);
      final expectedEndTimeFormat = DateFormat('MMM d, yyyy - h:mm a').format(endTime);
      
      expect(reservation.formattedStartTime, expectedStartTimeFormat);
      expect(reservation.formattedEndTime, expectedEndTimeFormat);
    });
    
    test('should calculate duration correctly', () {
      final DateTime startTime = DateTime(2023, 5, 15, 10, 30);
      final DateTime endTime = DateTime(2023, 5, 15, 12, 45);
      
      final reservation = Reservation(
        title: 'Test Reservation',
        description: 'Test Description',
        startTime: startTime,
        endTime: endTime,
        location: 'Test Location',
        userId: userId,
      );
      
      final expectedDuration = endTime.difference(startTime);
      
      expect(reservation.duration, expectedDuration);
      expect(reservation.duration.inHours, 2);
      expect(reservation.duration.inMinutes % 60, 15);
    });
    
    test('should format duration correctly', () {
      final DateTime startTime = DateTime(2023, 5, 15, 10, 30);
      final DateTime endTime = DateTime(2023, 5, 15, 12, 45);
      
      final reservation = Reservation(
        title: 'Test Reservation',
        description: 'Test Description',
        startTime: startTime,
        endTime: endTime,
        location: 'Test Location',
        userId: userId,
      );
      
      expect(reservation.formattedDuration, '2 hrs 15 mins');
      
      // Test singular form
      final reservationSingular = Reservation(
        title: 'Test Reservation',
        description: 'Test Description',
        startTime: startTime,
        endTime: startTime.add(const Duration(hours: 1, minutes: 1)),
        location: 'Test Location',
        userId: userId,
      );
      
      expect(reservationSingular.formattedDuration, '1 hr 1 min');
    });
  });
}