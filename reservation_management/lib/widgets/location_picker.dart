import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

/// A custom widget for picking a location using Google Maps
class LocationPicker extends StatefulWidget {
  final String? initialAddress;
  final double? initialLatitude;
  final double? initialLongitude;
  final String labelText;
  final String? helperText;
  final String? errorText;
  final ValueChanged<String> onAddressChanged;
  final ValueChanged<double> onLatitudeChanged;
  final ValueChanged<double> onLongitudeChanged;

  const LocationPicker({
    super.key,
    this.initialAddress,
    this.initialLatitude,
    this.initialLongitude,
    required this.labelText,
    this.helperText,
    this.errorText,
    required this.onAddressChanged,
    required this.onLatitudeChanged,
    required this.onLongitudeChanged,
  });

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  late TextEditingController _addressController;
  GoogleMapController? _mapController;
  LatLng _center = const LatLng(37.42796133580664, -122.085749655962);
  final Map<MarkerId, Marker> _markers = {};
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _addressController = TextEditingController(text: widget.initialAddress ?? '');

    if (widget.initialLatitude != null && widget.initialLongitude != null) {
      _center = LatLng(widget.initialLatitude!, widget.initialLongitude!);
      _addMarker(_center);
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  void _addMarker(LatLng position) {
    final MarkerId markerId = const MarkerId('selected_location');
    final Marker marker = Marker(
      markerId: markerId,
      position: position,
      draggable: true,
      onDragEnd: (LatLng newPosition) {
        _updateLocationFromLatLng(newPosition);
      },
    );

    setState(() {
      _markers[markerId] = marker;
      _center = position;
    });

    widget.onLatitudeChanged(position.latitude);
    widget.onLongitudeChanged(position.longitude);
  }

  Future<void> _searchLocation(String address) async {
    if (address.isEmpty) return;

    setState(() {
      _isSearching = true;
    });

    try {
      if (!mounted) return;
      List<Location> locations = await locationFromAddress(address);
      if (!mounted) return;
      
      if (locations.isNotEmpty) {
        final location = locations.first;
        final position = LatLng(location.latitude, location.longitude);
        
        _mapController?.animateCamera(CameraUpdate.newLatLngZoom(position, 15));
        _addMarker(position);
        
        List<Placemark> placemarks = await placemarkFromCoordinates(
          location.latitude, 
          location.longitude
        );
        
        if (!mounted) return;
        
        if (placemarks.isNotEmpty) {
          final placemark = placemarks.first;
          final formattedAddress = _formatAddress(placemark);
          _addressController.text = formattedAddress;
          widget.onAddressChanged(formattedAddress);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error searching location: $e')),
        );
      }
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  Future<void> _updateLocationFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude, 
        position.longitude
      );
      
      if (!mounted) return;
      
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        final formattedAddress = _formatAddress(placemark);
        setState(() {
          _addressController.text = formattedAddress;
        });
        widget.onAddressChanged(formattedAddress);
        widget.onLatitudeChanged(position.latitude);
        widget.onLongitudeChanged(position.longitude);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error getting address: $e')),
        );
      }
    }
  }

  String _formatAddress(Placemark placemark) {
    List<String> addressParts = [
      placemark.street ?? '',
      placemark.subLocality ?? '',
      placemark.locality ?? '',
      placemark.administrativeArea ?? '',
      placemark.postalCode ?? '',
      placemark.country ?? '',
    ];
    
    // Filter out empty parts and join with commas
    return addressParts.where((part) => part.isNotEmpty).join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _addressController,
          decoration: InputDecoration(
            labelText: widget.labelText,
            helperText: widget.helperText,
            errorText: widget.errorText,
            border: const OutlineInputBorder(),
            suffixIcon: _isSearching
                ? const CircularProgressIndicator(strokeWidth: 2)
                : IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () => _searchLocation(_addressController.text),
                  ),
          ),
          onSubmitted: _searchLocation,
          onChanged: widget.onAddressChanged,
        ),
        const SizedBox(height: 16),
        Container(
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
              },
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: 15,
              ),
              markers: Set<Marker>.of(_markers.values),
              onTap: (LatLng position) {
                _addMarker(position);
                _updateLocationFromLatLng(position);
              },
            ),
          ),
        ),
      ],
    );
  }
}
