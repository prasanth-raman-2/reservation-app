import 'package:flutter_test/flutter_test.dart';
import 'package:reservation_management/utils/form_validators.dart';

void main() {
  group('FormValidators Tests', () {
    group('validateRequired', () {
      test('should return error message when value is null', () {
        final result = FormValidators.validateRequired(null, 'Field');
        expect(result, 'Field is required');
      });

      test('should return error message when value is empty', () {
        final result = FormValidators.validateRequired('', 'Field');
        expect(result, 'Field is required');
      });

      test('should return error message when value is only whitespace', () {
        final result = FormValidators.validateRequired('   ', 'Field');
        expect(result, 'Field is required');
      });

      test('should return null when value is not empty', () {
        final result = FormValidators.validateRequired('Value', 'Field');
        expect(result, null);
      });
    });

    group('validateMinLength', () {
      test('should return error message when value is null', () {
        final result = FormValidators.validateMinLength(null, 5, 'Field');
        expect(result, 'Field must be at least 5 characters');
      });

      test('should return error message when value is too short', () {
        final result = FormValidators.validateMinLength('abc', 5, 'Field');
        expect(result, 'Field must be at least 5 characters');
      });

      test('should return error message when value with whitespace is too short', () {
        final result = FormValidators.validateMinLength('  abc  ', 5, 'Field');
        expect(result, 'Field must be at least 5 characters');
      });

      test('should return null when value is exactly minimum length', () {
        final result = FormValidators.validateMinLength('abcde', 5, 'Field');
        expect(result, null);
      });

      test('should return null when value is longer than minimum length', () {
        final result = FormValidators.validateMinLength('abcdefg', 5, 'Field');
        expect(result, null);
      });
    });

    group('validateTimeRange', () {
      final DateTime now = DateTime.now();
      final DateTime later = now.add(const Duration(hours: 1));
      final DateTime earlier = now.subtract(const Duration(hours: 1));

      test('should return error message when startTime is null', () {
        final result = FormValidators.validateTimeRange(null, later);
        expect(result, 'Both start and end times are required');
      });

      test('should return error message when endTime is null', () {
        final result = FormValidators.validateTimeRange(now, null);
        expect(result, 'Both start and end times are required');
      });

      test('should return error message when endTime is before startTime', () {
        final result = FormValidators.validateTimeRange(now, earlier);
        expect(result, 'End time must be after start time');
      });

      test('should return error message when endTime is same as startTime', () {
        final result = FormValidators.validateTimeRange(now, now);
        expect(result, 'End time must be after start time');
      });

      test('should return null when endTime is after startTime', () {
        final result = FormValidators.validateTimeRange(now, later);
        expect(result, null);
      });
    });

    group('validateLocation', () {
      test('should return error message when address is null', () {
        final result = FormValidators.validateLocation(null, 37.7749, -122.4194);
        expect(result, 'Location is required');
      });

      test('should return error message when address is empty', () {
        final result = FormValidators.validateLocation('', 37.7749, -122.4194);
        expect(result, 'Location is required');
      });

      test('should return error message when address is only whitespace', () {
        final result = FormValidators.validateLocation('   ', 37.7749, -122.4194);
        expect(result, 'Location is required');
      });

      test('should return error message when latitude is null', () {
        final result = FormValidators.validateLocation('San Francisco', null, -122.4194);
        expect(result, 'Please select a valid location on the map');
      });

      test('should return error message when longitude is null', () {
        final result = FormValidators.validateLocation('San Francisco', 37.7749, null);
        expect(result, 'Please select a valid location on the map');
      });

      test('should return null when address, latitude, and longitude are valid', () {
        final result = FormValidators.validateLocation('San Francisco', 37.7749, -122.4194);
        expect(result, null);
      });
    });
  });
}