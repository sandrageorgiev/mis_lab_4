import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mis_lab_4/models/exam_event_model.dart';
import 'package:mis_lab_4/services/location_service.dart';

class MapScreen extends StatefulWidget {
  final ExamEvent event;

  const MapScreen({super.key, required this.event});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  Set<Polyline> _polylines = {};
  Set<Marker> _markers = {};
  Position? _currentPosition;
  final LocationService _locationService = LocationService();
  bool _isLoadingRoute = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = position;
        _markers.add(
          Marker(
            markerId: const MarkerId('current_location'),
            position: LatLng(position.latitude, position.longitude),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueAzure),
            infoWindow: const InfoWindow(title: 'Your Location'),
          ),
        );
        _markers.add(
          Marker(
            markerId: const MarkerId('event_location'),
            position: LatLng(widget.event.latitude, widget.event.longitude),
            infoWindow: InfoWindow(
              title: widget.event.title,
              snippet: widget.event.location,
            ),
          ),
        );
      });
      _getDirections();
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  Future<void> _getDirections() async {
    if (_currentPosition == null) return;

    setState(() => _isLoadingRoute = true);
    try {
      Map<String, dynamic> directions = await _locationService.getRouteDetails(
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        LatLng(widget.event.latitude, widget.event.longitude),
      );

      setState(() {
        _polylines = {
          Polyline(
            polylineId: const PolylineId('route'),
            points: directions['polylineCoordinates'],
            color: Colors.blue,
            width: 5,
          ),
        };
      });

      // Adjust the map bounds to include both locations.
      LatLngBounds bounds = LatLngBounds(
        southwest: LatLng(
          _currentPosition!.latitude < widget.event.latitude
              ? _currentPosition!.latitude
              : widget.event.latitude,
          _currentPosition!.longitude < widget.event.longitude
              ? _currentPosition!.longitude
              : widget.event.longitude,
        ),
        northeast: LatLng(
          _currentPosition!.latitude > widget.event.latitude
              ? _currentPosition!.latitude
              : widget.event.latitude,
          _currentPosition!.longitude > widget.event.longitude
              ? _currentPosition!.longitude
              : widget.event.longitude,
        ),
      );
      _mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
    } finally {
      setState(() => _isLoadingRoute = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Navigation')),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(widget.event.latitude, widget.event.longitude),
              zoom: 15,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
              if (_currentPosition != null) {
                _getDirections();
              }
            },
            markers: _markers,
            polylines: _polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),
          if (_isLoadingRoute) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}




// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:mis_lab_4/models/exam_event_model.dart';

// class MapScreen extends StatefulWidget {
//   final ExamEvent event;

//   const MapScreen({super.key, required this.event});

//   @override
//   _MapScreenState createState() => _MapScreenState();
// }

// class _MapScreenState extends State<MapScreen> {
//   GoogleMapController? _mapController;
//   Set<Marker> _markers = {};
//   Position? _currentPosition;

//   @override
//   void initState() {
//     super.initState();
//     _getCurrentLocation();
//     _addEventMarker();
//   }

//   Future<void> _getCurrentLocation() async {
//     try {
//       Position position = await Geolocator.getCurrentPosition();
//       setState(() {
//         _currentPosition = position;
//         _markers.add(
//           Marker(
//             markerId: MarkerId('current_location'),
//             position: LatLng(position.latitude, position.longitude),
//             icon: BitmapDescriptor.defaultMarkerWithHue(
//                 BitmapDescriptor.hueAzure),
//             infoWindow: InfoWindow(title: 'Current Location'),
//           ),
//         );
//       });
//     } catch (e) {
//       print('Error getting current location: $e');
//     }
//   }

//   void _addEventMarker() {
//     _markers.add(
//       Marker(
//         markerId: MarkerId('exam_location'),
//         position: LatLng(widget.event.latitude, widget.event.longitude),
//         infoWindow: InfoWindow(
//           title: widget.event.title,
//           snippet: widget.event.location,
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Exam Location'),
//       ),
//       body: GoogleMap(
//         initialCameraPosition: CameraPosition(
//           target: LatLng(widget.event.latitude, widget.event.longitude),
//           zoom: 15,
//         ),
//         onMapCreated: (controller) => _mapController = controller,
//         markers: _markers,
//         myLocationEnabled: true,
//         myLocationButtonEnabled: true,
//       ),
//     );
//   }
// }
