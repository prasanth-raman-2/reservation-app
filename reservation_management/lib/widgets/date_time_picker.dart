import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// A custom widget for picking date and time
class DateTimePicker extends StatelessWidget {
  final DateTime? initialValue;
  final String labelText;
  final String? helperText;
  final String? errorText;
  final bool isStartTime;
  final DateTime? minTime;
  final DateTime? maxTime;
  final ValueChanged<DateTime> onChanged;

  const DateTimePicker({
    super.key,
    this.initialValue,
    required this.labelText,
    this.helperText,
    this.errorText,
    this.isStartTime = true,
    this.minTime,
    this.maxTime,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final DateTime value = initialValue ?? DateTime.now();
    final String formattedDateTime = DateFormat('MMM d, yyyy - h:mm a').format(value);

    return FormField<DateTime>(
      initialValue: value,
      validator: (value) {
        if (value == null) {
          return 'Please select a date and time';
        }
        if (minTime != null && value.isBefore(minTime!)) {
          return isStartTime
              ? 'Start time cannot be before ${DateFormat('MMM d, yyyy - h:mm a').format(minTime!)}'
              : 'End time cannot be before ${DateFormat('MMM d, yyyy - h:mm a').format(minTime!)}';
        }
        if (maxTime != null && value.isAfter(maxTime!)) {
          return isStartTime
              ? 'Start time cannot be after ${DateFormat('MMM d, yyyy - h:mm a').format(maxTime!)}'
              : 'End time cannot be after ${DateFormat('MMM d, yyyy - h:mm a').format(maxTime!)}';
        }
        return null;
      },
      builder: (FormFieldState<DateTime> state) {
        return InkWell(
          onTap: () async {
            final DateTime now = DateTime.now();
            final DateTime currentValue = state.value ?? value;
            final BuildContext currentContext = context;
            
            final DateTime? pickedDate = await showDatePicker(
              context: currentContext,
              initialDate: currentValue,
              firstDate: minTime ?? now.subtract(const Duration(days: 365)),
              lastDate: maxTime ?? now.add(const Duration(days: 365 * 5)),
            );

            if (pickedDate == null) return;
            
            final TimeOfDay? pickedTime = await showTimePicker(
              context: currentContext,
              initialTime: TimeOfDay.fromDateTime(currentValue),
            );

            if (pickedTime == null) return;
            
            final newDateTime = DateTime(
              pickedDate.year,
              pickedDate.month,
              pickedDate.day,
              pickedTime.hour,
              pickedTime.minute,
            );

            state.didChange(newDateTime);
            onChanged(newDateTime);
          },
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: labelText,
              helperText: helperText,
              errorText: errorText ?? state.errorText,
              border: const OutlineInputBorder(),
              suffixIcon: const Icon(Icons.calendar_today),
            ),
            child: Text(
              formattedDateTime,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        );
      },
    );
  }
}
