/// Utility class for form validation
class FormValidators {
  /// Validates that a string is not empty
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validates that a string has a minimum length
  static String? validateMinLength(String? value, int minLength, String fieldName) {
    if (value == null || value.trim().length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }
    return null;
  }

  /// Validates that an end time is after a start time
  static String? validateTimeRange(DateTime? startTime, DateTime? endTime) {
    if (startTime == null || endTime == null) {
      return 'Both start and end times are required';
    }
    if (endTime.isBefore(startTime) || endTime.isAtSameMomentAs(startTime)) {
      return 'End time must be after start time';
    }
    return null;
  }

  /// Validates that a location has coordinates
  static String? validateLocation(String? address, double? latitude, double? longitude) {
    if (address == null || address.trim().isEmpty) {
      return 'Location is required';
    }
    if (latitude == null || longitude == null) {
      return 'Please select a valid location on the map';
    }
    return null;
  }
}
