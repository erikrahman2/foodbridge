import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../utils/constants.dart';

class LocationPickerPage extends StatefulWidget {
  final LatLng? initialPosition;
  final String? currentAddress;

  const LocationPickerPage({
    super.key,
    this.initialPosition,
    this.currentAddress,
  });

  @override
  State<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  GoogleMapController? _mapController;
  LatLng _currentPosition = const LatLng(
    -0.947083,
    100.417419,
  ); // Default: Padang
  String _selectedAddress = 'Loading...';
  bool _isLoading = false;
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    if (widget.initialPosition != null) {
      _currentPosition = widget.initialPosition!;
      _selectedAddress = widget.currentAddress ?? 'Selected Location';
    } else {
      _getCurrentLocation();
    }
    _addMarker(_currentPosition);
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showSnackBar('Location services are disabled');
        setState(() => _isLoading = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showSnackBar('Location permissions denied');
          setState(() => _isLoading = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showSnackBar('Location permissions permanently denied');
        setState(() => _isLoading = false);
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _currentPosition = LatLng(position.latitude, position.longitude);
      _addMarker(_currentPosition);
      _getAddressFromLatLng(_currentPosition);

      _mapController?.animateCamera(CameraUpdate.newLatLng(_currentPosition));
    } catch (e) {
      _showSnackBar('Error getting location: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _addMarker(LatLng position) {
    setState(() {
      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId('selected_location'),
          position: position,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueOrange,
          ),
          infoWindow: InfoWindow(
            title: 'Selected Location',
            snippet: _selectedAddress,
          ),
        ),
      );
    });
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _selectedAddress = _formatAddress(place);
        });
        _addMarker(position); // Update marker with new address
      }
    } catch (e) {
      setState(() {
        _selectedAddress =
            'Lat: ${position.latitude.toStringAsFixed(6)}, '
            'Lng: ${position.longitude.toStringAsFixed(6)}';
      });
    }
  }

  String _formatAddress(Placemark place) {
    List<String> addressParts = [];

    if (place.street != null && place.street!.isNotEmpty) {
      addressParts.add(place.street!);
    }
    if (place.subLocality != null && place.subLocality!.isNotEmpty) {
      addressParts.add(place.subLocality!);
    }
    if (place.locality != null && place.locality!.isNotEmpty) {
      addressParts.add(place.locality!);
    }
    if (place.subAdministrativeArea != null &&
        place.subAdministrativeArea!.isNotEmpty) {
      addressParts.add(place.subAdministrativeArea!);
    }

    return addressParts.isEmpty ? 'Selected Location' : addressParts.join(', ');
  }

  void _onMapTapped(LatLng position) {
    _currentPosition = position;
    _addMarker(position);
    _getAddressFromLatLng(position);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  void _confirmLocation() {
    Navigator.pop(context, {
      'address': _selectedAddress,
      'latitude': _currentPosition.latitude,
      'longitude': _currentPosition.longitude,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentPosition,
              zoom: 15.0,
            ),
            markers: _markers,
            onMapCreated: (controller) {
              _mapController = controller;
            },
            onTap: _onMapTapped,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
          ),
          SafeArea(
            child: Column(
              children: [_buildTopBar(), const Spacer(), _buildBottomCard()],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primaryOrange,
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getCurrentLocation,
        backgroundColor: Colors.white,
        child: const Icon(Icons.my_location, color: AppColors.primaryOrange),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text(
              'Select Delivery Location',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.location_on, color: AppColors.primaryOrange, size: 24),
              SizedBox(width: 8),
              Text(
                'Selected Location',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _selectedAddress,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.4,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            'Lat: ${_currentPosition.latitude.toStringAsFixed(6)}, '
            'Lng: ${_currentPosition.longitude.toStringAsFixed(6)}',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _confirmLocation,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrange,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Confirm Location',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
