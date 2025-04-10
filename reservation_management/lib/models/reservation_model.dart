import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

/// Model class representing a reservation
class Reservation {
  final String id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final String location;
  final double? latitude;
  final double? longitude;
  final String userId;
  final bool isConfirmed;
  final DateTime createdAt;
  final DateTime updatedAt;

  Reservation({
    String? id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.location,
    this.latitude,
    this.longitude,
    required this.userId,
    this.isConfirmed = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Create a Reservation from a map (e.g., from Firestore or SQLite)
  factory Reservation.fromMap(Map<String, dynamic> map) {
    return Reservation(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      startTime: map['startTime'] is DateTime
          ? map['startTime']
          : DateTime.parse(map['startTime']),
      endTime: map['endTime'] is DateTime
          ? map['endTime']
          : DateTime.parse(map['endTime']),
      location: map['location'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      userId: map['userId'],
      isConfirmed: map['isConfirmed'] ?? false,
      createdAt: map['createdAt'] is DateTime
          ? map['createdAt']
          : DateTime.parse(map['createdAt']),
      updatedAt: map['updatedAt'] is DateTime
          ? map['updatedAt']
          : DateTime.parse(map['updatedAt']),
    );
  }

  /// Convert Reservation to a map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'userId': userId,
      'isConfirmed': isConfirmed,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create a copy of this Reservation with modified fields
  Reservation copyWith({
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    String? location,
    double? latitude,
    double? longitude,
    String? userId,
    bool? isConfirmed,
  }) {
    return Reservation(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      userId: userId ?? this.userId,
      isConfirmed: isConfirmed ?? this.isConfirmed,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  /// Format the start time for display
  String get formattedStartTime {
    return DateFormat('MMM d, yyyy - h:mm a').format(startTime);
  }

  /// Format the end time for display
  String get formattedEndTime {
    return DateFormat('MMM d, yyyy - h:mm a').format(endTime);
  }

  /// Get the duration of the reservation
  Duration get duration {
    return endTime.difference(startTime);
  }

  /// Format the duration for display
  String get formattedDuration {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    return '$hours hr${hours != 1 ? 's' : ''} $minutes min${minutes != 1 ? 's' : ''}';
  }
}
