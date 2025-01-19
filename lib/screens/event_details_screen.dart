import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mis_lab_4/models/exam_event_model.dart';
import 'package:mis_lab_4/screens/map_screen.dart';
import 'package:mis_lab_4/services/location_service.dart';

class EventDetailsScreen extends StatefulWidget {
  final ExamEvent event;
  const EventDetailsScreen({super.key, required this.event});

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  final LocationService _locationService = LocationService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam Details'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.event.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildInfoRow(
                              Icons.location_on, widget.event.location),
                          const SizedBox(height: 8),
                          _buildInfoRow(Icons.access_time,
                              widget.event.dateTime.toString()),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _enableLocationReminder(),
                          icon: const Icon(Icons.notifications_active),
                          label: const Text('Enable Location Reminder'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  MapScreen(event: widget.event),
                            ),
                          );
                        },
                        icon: const Icon(Icons.directions),
                        label: const Text('Navigate'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 300,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: LatLng(
                              widget.event.latitude, widget.event.longitude),
                          zoom: 15,
                        ),
                        markers: {
                          Marker(
                            markerId: const MarkerId('exam_location'),
                            position: LatLng(
                                widget.event.latitude, widget.event.longitude),
                            infoWindow: InfoWindow(
                              title: widget.event.title,
                              snippet: widget.event.location,
                            ),
                          ),
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    );
  }

  void _enableLocationReminder() async {
    await _locationService.initialize();
    await _locationService.startLocationTracking(widget.event);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Location reminder enabled for ${widget.event.title}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
