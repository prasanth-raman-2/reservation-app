import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/reservation_model.dart';
import '../providers/auth_provider.dart';
import '../providers/reservation_provider.dart';
import '../utils/form_validators.dart';
import '../widgets/date_time_picker.dart';
import '../widgets/location_picker.dart';

/// Screen for creating or editing a reservation
class ReservationFormScreen extends ConsumerStatefulWidget {
  final Reservation? reservation;

  const ReservationFormScreen({super.key, this.reservation});

  @override
  ConsumerState<ReservationFormScreen> createState() => _ReservationFormScreenState();
}

class _ReservationFormScreenState extends ConsumerState<ReservationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  DateTime _startTime = DateTime.now();
  DateTime _endTime = DateTime.now().add(const Duration(hours: 1));
  String _location = '';
  double? _latitude;
  double? _longitude;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.reservation?.title ?? '');
    _descriptionController = TextEditingController(text: widget.reservation?.description ?? '');
    
    if (widget.reservation != null) {
      _startTime = widget.reservation!.startTime;
      _endTime = widget.reservation!.endTime;
      _location = widget.reservation!.location;
      _latitude = widget.reservation!.latitude;
      _longitude = widget.reservation!.longitude;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveReservation() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userId = ref.read(userIdProvider) ?? 'unknown';

      final reservationNotifier = ref.read(reservationNotifierProvider.notifier);

      if (widget.reservation == null) {
        // Create new reservation
        final newReservation = Reservation(
          title: _titleController.text,
          description: _descriptionController.text,
          startTime: _startTime,
          endTime: _endTime,
          location: _location,
          latitude: _latitude,
          longitude: _longitude,
          userId: userId,
        );

        await reservationNotifier.addReservation(newReservation);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Reservation created successfully')),
          );
          Navigator.of(context).pop();
        }
      } else {
        // Update existing reservation
        final updatedReservation = widget.reservation!.copyWith(
          title: _titleController.text,
          description: _descriptionController.text,
          startTime: _startTime,
          endTime: _endTime,
          location: _location,
          latitude: _latitude,
          longitude: _longitude,
        );

        await reservationNotifier.updateReservation(updatedReservation);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Reservation updated successfully')),
          );
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.reservation == null ? 'Create Reservation' : 'Edit Reservation'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => FormValidators.validateRequired(value, 'Title'),
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => FormValidators.validateMinLength(value, 10, 'Description'),
                      maxLines: 3,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                    DateTimePicker(
                      initialValue: _startTime,
                      labelText: 'Start Time',
                      isStartTime: true,
                      minTime: DateTime.now(),
                      onChanged: (dateTime) {
                        setState(() {
                          _startTime = dateTime;
                          // If end time is before start time, update it
                          if (_endTime.isBefore(_startTime) || _endTime.isAtSameMomentAs(_startTime)) {
                            _endTime = _startTime.add(const Duration(hours: 1));
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DateTimePicker(
                      initialValue: _endTime,
                      labelText: 'End Time',
                      isStartTime: false,
                      minTime: _startTime.add(const Duration(minutes: 15)),
                      onChanged: (dateTime) {
                        setState(() {
                          _endTime = dateTime;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    FormField<String>(
                      initialValue: _location,
                      validator: (value) => FormValidators.validateLocation(
                        value, _latitude, _longitude),
                      builder: (FormFieldState<String> state) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            LocationPicker(
                              initialAddress: _location,
                              initialLatitude: _latitude,
                              initialLongitude: _longitude,
                              labelText: 'Location',
                              errorText: state.errorText,
                              onAddressChanged: (address) {
                                setState(() {
                                  _location = address;
                                  state.didChange(address);
                                });
                              },
                              onLatitudeChanged: (latitude) {
                                setState(() {
                                  _latitude = latitude;
                                });
                              },
                              onLongitudeChanged: (longitude) {
                                setState(() {
                                  _longitude = longitude;
                                });
                              },
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _saveReservation,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        widget.reservation == null ? 'Create Reservation' : 'Update Reservation',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
