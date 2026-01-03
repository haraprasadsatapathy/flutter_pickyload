import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart';
import '../../../utils/constant/AppConstants.dart';

// Model for Google Places Autocomplete predictions
class PlacePrediction {
  final String placeId;
  final String description;
  final String mainText;
  final String secondaryText;

  PlacePrediction({
    required this.placeId,
    required this.description,
    required this.mainText,
    required this.secondaryText,
  });

  factory PlacePrediction.fromJson(Map<String, dynamic> json) {
    return PlacePrediction(
      placeId: json['place_id'] ?? '',
      description: json['description'] ?? '',
      mainText: json['structured_formatting']?['main_text'] ?? '',
      secondaryText: json['structured_formatting']?['secondary_text'] ?? '',
    );
  }
}

class MapLocationPickerScreen extends StatefulWidget {
  final String title;
  final LatLng? initialLocation;

  const MapLocationPickerScreen({
    super.key,
    required this.title,
    this.initialLocation,
  });

  @override
  State<MapLocationPickerScreen> createState() =>
      _MapLocationPickerScreenState();
}

class _MapLocationPickerScreenState extends State<MapLocationPickerScreen> {
  GoogleMapController? _mapController;
  LatLng? _selectedLocation;
  String _selectedAddress = 'Tap on map to select location';
  bool _isLoading = false;
  final Set<Marker> _markers = {};
  final TextEditingController _searchController = TextEditingController();

  // Suggestion-related variables
  List<PlacePrediction> _suggestions = [];
  bool _showSuggestions = false;
  Timer? _debounce;
  final Dio _dio = Dio();

  @override
  void initState() {
    super.initState();
    if (widget.initialLocation != null) {
      _selectedLocation = widget.initialLocation;
      _updateMarker(_selectedLocation!);
      _getAddressFromLatLng(_selectedLocation!);
    } else {
      _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);

    try {
      // Check location permission
      var status = await Permission.location.status;
      if (!status.isGranted) {
        status = await Permission.location.request();
        if (!status.isGranted) {
          setState(() {
            _isLoading = false;
            _selectedAddress = 'Location permission denied';
          });
          return;
        }
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final currentLocation = LatLng(position.latitude, position.longitude);

      setState(() {
        _selectedLocation = currentLocation;
      });

      _updateMarker(currentLocation);
      _getAddressFromLatLng(currentLocation);

      // Animate camera to current location
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: currentLocation,
            zoom: 15.0,
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _selectedAddress = 'Error getting location: ${e.toString()}';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _updateMarker(LatLng location) {
    setState(() {
      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId('selected_location'),
          position: location,
          draggable: true,
          onDragEnd: (newPosition) {
            setState(() {
              _selectedLocation = newPosition;
            });
            _getAddressFromLatLng(newPosition);
          },
        ),
      );
    });
  }

  Future<void> _getAddressFromLatLng(LatLng location) async {
    setState(() => _isLoading = true);

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _selectedAddress = [
            place.name,
            place.subLocality,
            place.locality,
            place.administrativeArea,
            place.postalCode,
            place.country,
          ].where((element) => element != null && element.isNotEmpty).join(', ');
        });
      }
    } catch (e) {
      setState(() {
        _selectedAddress = 'Error getting address: ${e.toString()}';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onMapTapped(LatLng location) {
    setState(() {
      _selectedLocation = location;
    });
    _updateMarker(location);
    _getAddressFromLatLng(location);
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.isEmpty) {
        setState(() {
          _suggestions = [];
          _showSuggestions = false;
        });
        return;
      }

      _fetchPlacePredictions(query);
    });
  }

  Future<void> _fetchPlacePredictions(String input) async {
    final apiKey = AppConstants.googleApiKey;

    if (apiKey.isEmpty) {
      debugPrint('Google API Key is missing');
      return;
    }

    try {
      final response = await _dio.get(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json',
        queryParameters: {
          'input': input,
          'key': apiKey,
          'components': 'country:in', // Restrict to India
          'language': 'en',
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == 'OK') {
          final predictions = (data['predictions'] as List)
              .map((prediction) => PlacePrediction.fromJson(prediction))
              .toList();

          setState(() {
            _suggestions = predictions;
            _showSuggestions = predictions.isNotEmpty;
          });
        } else {
          setState(() {
            _suggestions = [];
            _showSuggestions = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching place predictions: $e');
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
      });
    }
  }

  Future<void> _selectSuggestion(PlacePrediction prediction) async {
    _searchController.text = prediction.description;
    setState(() {
      _showSuggestions = false;
      _isLoading = true;
    });

    final apiKey = AppConstants.googleApiKey;

    try {
      // Get place details to retrieve lat/lng
      final response = await _dio.get(
        'https://maps.googleapis.com/maps/api/place/details/json',
        queryParameters: {
          'place_id': prediction.placeId,
          'key': apiKey,
          'fields': 'geometry,formatted_address',
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == 'OK') {
          final result = data['result'];
          final location = result['geometry']['location'];
          final lat = location['lat'];
          final lng = location['lng'];
          final address = result['formatted_address'] ?? prediction.description;

          final selectedLocation = LatLng(lat, lng);

          setState(() {
            _selectedLocation = selectedLocation;
            _selectedAddress = address;
          });

          _updateMarker(selectedLocation);

          // Animate camera to selected location
          _mapController?.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: selectedLocation,
                zoom: 15.0,
              ),
            ),
          );

          // Hide keyboard
          FocusScope.of(context).unfocus();

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location selected!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error getting place details: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _searchAddress() async {
    final searchQuery = _searchController.text.trim();

    if (searchQuery.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter an address to search'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _showSuggestions = false;
    });

    try {
      List<Location> locations = await locationFromAddress(searchQuery);

      if (!mounted) return;

      if (locations.isNotEmpty) {
        final location = locations.first;
        final searchedLocation = LatLng(location.latitude, location.longitude);

        setState(() {
          _selectedLocation = searchedLocation;
        });

        _updateMarker(searchedLocation);
        _getAddressFromLatLng(searchedLocation);

        // Animate camera to searched location
        _mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: searchedLocation,
              zoom: 15.0,
            ),
          ),
        );

        // Hide keyboard after search
        FocusScope.of(context).unfocus();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location found!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No location found for this address'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error searching address: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _confirmSelection() {
    if (_selectedLocation != null) {
      Navigator.pop(context, {
        'address': _selectedAddress,
        'latitude': _selectedLocation!.latitude,
        'longitude': _selectedLocation!.longitude,
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a location on the map'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _getCurrentLocation,
            tooltip: 'Get current location',
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: widget.initialLocation ?? const LatLng(20.5937, 78.9629), // India center
              zoom: 5.0,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
              if (widget.initialLocation == null) {
                _getCurrentLocation();
              }
            },
            onTap: _onMapTapped,
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: true,
            mapToolbarEnabled: false,
          ),

          // Search bar with suggestions
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search address...',
                        border: InputBorder.none,
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _suggestions = [];
                                    _showSuggestions = false;
                                  });
                                },
                              )
                            : null,
                      ),
                      onChanged: (value) {
                        _onSearchChanged(value);
                        setState(() {}); // Rebuild to show/hide clear button
                      },
                      onSubmitted: (_) => _searchAddress(),
                      textInputAction: TextInputAction.search,
                    ),
                  ),
                ),

                // Suggestions dropdown
                if (_showSuggestions && _suggestions.isNotEmpty)
                  Card(
                    elevation: 4,
                    margin: const EdgeInsets.only(top: 4),
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 300),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: _suggestions.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final prediction = _suggestions[index];
                          return ListTile(
                            dense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.location_on,
                                size: 20,
                                color: Colors.red,
                              ),
                            ),
                            title: Text(
                              prediction.mainText,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: prediction.secondaryText.isNotEmpty
                                ? Text(
                                    prediction.secondaryText,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[600],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  )
                                : null,
                            onTap: () => _selectSuggestion(prediction),
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Address display card
          if (!_showSuggestions)
            Positioned(
              top: 90,
              left: 16,
              right: 16,
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Selected Location',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (_isLoading)
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          else
                            const Icon(Icons.location_on, color: Colors.red, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _selectedAddress,
                              style: Theme.of(context).textTheme.bodyMedium,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Confirm button
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: ElevatedButton(
              onPressed: _selectedLocation != null && !_isLoading
                  ? _confirmSelection
                  : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
              child: const Text(
                'Confirm Location',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _mapController?.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
