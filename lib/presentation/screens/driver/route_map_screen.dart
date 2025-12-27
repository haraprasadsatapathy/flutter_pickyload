import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import '../../../utils/constant/AppConstants.dart';

class RouteMapScreen extends StatefulWidget {
  final double originLat;
  final double originLng;
  final double destinationLat;
  final double destinationLng;
  final String originAddress;
  final String destinationAddress;

  const RouteMapScreen({
    super.key,
    required this.originLat,
    required this.originLng,
    required this.destinationLat,
    required this.destinationLng,
    required this.originAddress,
    required this.destinationAddress,
  });

  @override
  State<RouteMapScreen> createState() => _RouteMapScreenState();
}

class _RouteMapScreenState extends State<RouteMapScreen> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  double? _distanceInKm;
  double? _roadDistanceInKm;
  String? _duration;
  bool _isLoading = true;
  bool _isFetchingRoute = false;
  List<LatLng> _polylinePoints = [];
  String? _errorMessage;
  int _numberOfRoutes = 0;
  int _selectedRouteIndex = 0; // Track selected route (default to primary route)
  List<Map<String, dynamic>> _routesData = []; // Store all route data

  // List of colors for different routes
  final List<Color> _routeColors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.red,
  ];

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  void _initializeMap() async {
    // Create markers for origin and destination
    _markers.add(
      Marker(
        markerId: const MarkerId('origin'),
        position: LatLng(widget.originLat, widget.originLng),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(
          title: 'Origin',
          snippet: widget.originAddress,
        ),
      ),
    );

    _markers.add(
      Marker(
        markerId: const MarkerId('destination'),
        position: LatLng(widget.destinationLat, widget.destinationLng),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(
          title: 'Destination',
          snippet: widget.destinationAddress,
        ),
      ),
    );

    // Calculate straight-line distance
    _calculateDistance();

    setState(() {
      _isLoading = false;
    });

    // Fetch actual route from Google Directions API
    await _fetchDirections();
  }

  void _printPolylinePointsAsJson() {
    // Print as string array format
    final List<String> stringArray = _polylinePoints.map((point) {
      return '${point.latitude},${point.longitude}';
    }).toList();
    developer.log('==================================', name: 'RouteMapScreen');
    developer.log('=== STRING ARRAY FORMAT ===', name: 'RouteMapScreen');
    developer.log(stringArray.toString(), name: 'RouteMapScreen');
    developer.log('===========================', name: 'RouteMapScreen');
  }

  void _calculateDistance() {
    // Calculate distance using Geolocator's distanceBetween method
    final distanceInMeters = Geolocator.distanceBetween(
      widget.originLat,
      widget.originLng,
      widget.destinationLat,
      widget.destinationLng,
    );

    setState(() {
      _distanceInKm = distanceInMeters / 1000; // Convert to kilometers
    });
  }

  Future<void> _fetchDirections() async {
    setState(() {
      _isFetchingRoute = true;
      _errorMessage = null;
    });

    try {
      final dio = Dio();
      final String origin = '${widget.originLat},${widget.originLng}';
      final String destination = '${widget.destinationLat},${widget.destinationLng}';

      final response = await dio.get(
        'https://maps.googleapis.com/maps/api/directions/json',
        queryParameters: {
          'origin': origin,
          'destination': destination,
          'key': AppConstants.googleApiKey,
          'mode': 'driving',
          'alternatives': 'true', // Request alternative routes
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data['status'] == 'OK') {
          final routes = data['routes'] as List;
          if (routes.isNotEmpty) {
            // Get data from the first (primary) route for display
            final primaryRoute = routes[0];
            final leg = primaryRoute['legs'][0];
            final distanceText = leg['distance']['text'] as String;
            final distanceValue = leg['distance']['value'] as int; // in meters
            final durationText = leg['duration']['text'] as String;

            // Decode the polyline for the primary route
            final primaryEncodedPolyline = primaryRoute['overview_polyline']['points'] as String;
            _polylinePoints = _decodePolyline(primaryEncodedPolyline);

            setState(() {
              _roadDistanceInKm = distanceValue / 1000; // Convert to km
              _duration = durationText;
              _numberOfRoutes = routes.length;

              // Clear existing data
              _polylines.clear();
              _routesData.clear();

              // Add all route polylines with different colors
              for (int i = 0; i < routes.length; i++) {
                final route = routes[i];
                final encodedPolyline = route['overview_polyline']['points'] as String;
                final polylinePoints = _decodePolyline(encodedPolyline);

                // Store route data
                final routeLeg = route['legs'][0];
                _routesData.add({
                  'index': i,
                  'distance_text': routeLeg['distance']['text'],
                  'distance_value': routeLeg['distance']['value'],
                  'duration_text': routeLeg['duration']['text'],
                  'duration_value': routeLeg['duration']['value'],
                  'polyline_points': polylinePoints,
                  'encoded_polyline': encodedPolyline,
                });

                // Use different colors for each route
                final color = _routeColors[i % _routeColors.length];

                // Selected route should be thicker
                final width = i == _selectedRouteIndex ? 7 : 4;

                _polylines.add(
                  Polyline(
                    polylineId: PolylineId('route_$i'),
                    points: polylinePoints,
                    color: color,
                    width: width,
                    consumeTapEvents: true,
                    onTap: () => _onPolylineTapped(i),
                  ),
                );

                developer.log('Route $i: ${routeLeg['distance']['text']}, Color: ${color.toString()}', name: 'RouteMapScreen');
              }
            });

            // Print the polyline points for primary route
            _printPolylinePointsAsJson();

            // Fit bounds to show entire route
            Future.delayed(const Duration(milliseconds: 500), () {
              _fitBounds();
            });

            // Convert polyline points to JSON array
            final List<Map<String, dynamic>> polylinePointsJson = _polylinePoints.map((point) {
              return {
                'latitude': point.latitude,
                'longitude': point.longitude,
              };
            }).toList();
            final String polylineJsonString = jsonEncode(polylinePointsJson);

            developer.log('=== GOOGLE DIRECTIONS API RESPONSE ===', name: 'RouteMapScreen');
            developer.log('Number of routes: ${routes.length}', name: 'RouteMapScreen');
            developer.log('Primary Route Distance: $distanceText', name: 'RouteMapScreen');
            developer.log('Primary Route Duration: $durationText', name: 'RouteMapScreen');
            developer.log('Polyline Points: $polylineJsonString', name: 'RouteMapScreen');
            developer.log('=====================================', name: 'RouteMapScreen');
          } else {
            setState(() {
              _errorMessage = 'No routes found';
            });
          }
        } else if (data['status'] == 'REQUEST_DENIED') {
          setState(() {
            _errorMessage = 'API Key error: ${data['error_message'] ?? 'Please check your API key'}';
          });
        } else {
          setState(() {
            _errorMessage = 'Error: ${data['status']}';
          });
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to fetch route: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isFetchingRoute = false;
      });
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0;
    int len = encoded.length;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      int b;
      int shift = 0;
      int result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return points;
  }

  // Calculate bounds to fit both markers
  LatLngBounds _getBounds() {
    final southwest = LatLng(
      widget.originLat < widget.destinationLat
          ? widget.originLat
          : widget.destinationLat,
      widget.originLng < widget.destinationLng
          ? widget.originLng
          : widget.destinationLng,
    );

    final northeast = LatLng(
      widget.originLat > widget.destinationLat
          ? widget.originLat
          : widget.destinationLat,
      widget.originLng > widget.destinationLng
          ? widget.originLng
          : widget.destinationLng,
    );

    return LatLngBounds(southwest: southwest, northeast: northeast);
  }

  void _fitBounds() {
    if (_mapController != null) {
      final bounds = _getBounds();
      _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 100),
      );
    }
  }

  void _onPolylineTapped(int routeIndex) {
    setState(() {
      _selectedRouteIndex = routeIndex;

      // Update selected route data for display
      if (_routesData.isNotEmpty && routeIndex < _routesData.length) {
        final selectedRoute = _routesData[routeIndex];
        _roadDistanceInKm = selectedRoute['distance_value'] / 1000;
        _duration = selectedRoute['duration_text'];
        _polylinePoints = selectedRoute['polyline_points'];
      }

      // Rebuild polylines with updated widths
      _polylines.clear();
      for (int i = 0; i < _routesData.length; i++) {
        final routeData = _routesData[i];
        final color = _routeColors[i % _routeColors.length];
        final width = i == _selectedRouteIndex ? 7 : 4;

        _polylines.add(
          Polyline(
            polylineId: PolylineId('route_$i'),
            points: routeData['polyline_points'],
            color: color,
            width: width,
            consumeTapEvents: true,
            onTap: () => _onPolylineTapped(i),
          ),
        );
      }
    });

    developer.log('Route $routeIndex selected', name: 'RouteMapScreen');
  }

  Map<String, dynamic> getSelectedRouteData() {
    if (_routesData.isEmpty || _selectedRouteIndex >= _routesData.length) {
      return {};
    }

    final selectedRoute = _routesData[_selectedRouteIndex];
    return {
      'route_index': _selectedRouteIndex,
      'distance_text': selectedRoute['distance_text'],
      'distance_value': selectedRoute['distance_value'],
      'duration_text': selectedRoute['duration_text'],
      'duration_value': selectedRoute['duration_value'],
      'polyline_points': selectedRoute['polyline_points'].map((point) {
        return {
          'latitude': point.latitude,
          'longitude': point.longitude,
        };
      }).toList(),
      'encoded_polyline': selectedRoute['encoded_polyline'],
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Route Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.fit_screen),
            onPressed: _fitBounds,
            tooltip: 'Fit to screen',
          ),
          if (_routesData.isNotEmpty)
            TextButton.icon(
              onPressed: () {
                final selectedData = getSelectedRouteData();
                developer.log('Selected Route Data: ${jsonEncode(selectedData)}', name: 'RouteMapScreen');
                // Return the selected route data
                Navigator.of(context).pop(selectedData);
              },
              icon: const Icon(Icons.check, color: Colors.white),
              label: const Text(
                'Confirm',
                style: TextStyle(color: Colors.white),
              ),
              style: TextButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // Google Map
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                      (widget.originLat + widget.destinationLat) / 2,
                      (widget.originLng + widget.destinationLng) / 2,
                    ),
                    zoom: 10,
                  ),
                  onMapCreated: (controller) {
                    _mapController = controller;
                    // Fit bounds after map is created
                    Future.delayed(const Duration(milliseconds: 500), () {
                      _fitBounds();
                    });
                  },
                  markers: _markers,
                  polylines: _polylines,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: true,
                  mapToolbarEnabled: false,
                ),

                // Distance info card
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Card(
                    elevation: 8,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Instruction for route selection
                          if (_numberOfRoutes > 1 && !_isFetchingRoute)
                            Container(
                              padding: const EdgeInsets.all(12),
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.blue.shade200,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.touch_app,
                                    color: Colors.blue.shade700,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Tap on any route line or legend below to select. Tap "Confirm" to use selected route.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.blue.shade700,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Loading indicator
                          if (_isFetchingRoute)
                            Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Fetching route...',
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                              ],
                            ),

                          // Error message
                          if (_errorMessage != null)
                            Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.warning, color: Colors.orange.shade700, size: 20),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _errorMessage!,
                                          style: TextStyle(
                                            color: Colors.orange.shade700,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                            ),

                          // Road Distance and Duration
                          if (_roadDistanceInKm != null)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Selected route indicator
                                if (_numberOfRoutes > 1)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 4,
                                          height: 20,
                                          decoration: BoxDecoration(
                                            color: _routeColors[_selectedRouteIndex % _routeColors.length],
                                            borderRadius: BorderRadius.circular(2),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Selected Route: ${_selectedRouteIndex == 0 ? "Primary" : "Alternative $_selectedRouteIndex"}',
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: _routeColors[_selectedRouteIndex % _routeColors.length],
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildStatItem(
                                        context,
                                        'Road Distance',
                                        '${_roadDistanceInKm!.toStringAsFixed(2)} km',
                                        Icons.route,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildStatItem(
                                        context,
                                        'Duration',
                                        _duration ?? 'N/A',
                                        Icons.access_time,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          else
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.route,
                                    color: Theme.of(context).colorScheme.primary,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Straight-Line Distance',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: Colors.grey[600],
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _distanceInKm != null
                                          ? '${_distanceInKm!.toStringAsFixed(2)} km'
                                          : 'Calculating...',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                          const Divider(height: 24),
                          _buildLocationInfo(
                            context,
                            'Origin',
                            widget.originAddress,
                            Colors.green,
                            Icons.location_on,
                          ),
                          const SizedBox(height: 12),
                          _buildLocationInfo(
                            context,
                            'Destination',
                            widget.destinationAddress,
                            Colors.red,
                            Icons.flag,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Info note at bottom - Route Legend
                if (_roadDistanceInKm != null)
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.route,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '$_numberOfRoutes Alternative Route${_numberOfRoutes > 1 ? "s" : ""} Found',
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 12,
                              runSpacing: 8,
                              children: List.generate(_numberOfRoutes, (index) {
                                final isSelected = index == _selectedRouteIndex;
                                return GestureDetector(
                                  onTap: () => _onPolylineTapped(index),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? _routeColors[index % _routeColors.length].withValues(alpha: 0.2)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isSelected
                                            ? _routeColors[index % _routeColors.length]
                                            : Colors.transparent,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: isSelected ? 24 : 20,
                                          height: isSelected ? 7 : 4,
                                          decoration: BoxDecoration(
                                            color: _routeColors[index % _routeColors.length],
                                            borderRadius: BorderRadius.circular(2),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          index == 0 ? 'Primary' : 'Alt $index',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: isSelected ? Colors.black : Colors.grey[700],
                                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                          ),
                                        ),
                                        if (isSelected) ...[
                                          const SizedBox(width: 4),
                                          Icon(
                                            Icons.check_circle,
                                            size: 14,
                                            color: _routeColors[index % _routeColors.length],
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else if (!_isFetchingRoute)
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Card(
                      elevation: 4,
                      color: Colors.blue.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.blue.shade700,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Showing straight-line distance. ${_errorMessage != null ? "Could not fetch route data." : ""}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                      fontSize: 11,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationInfo(
    BuildContext context,
    String label,
    String address,
    Color iconColor,
    IconData icon,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                address,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
