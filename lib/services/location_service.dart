import 'package:geolocator/geolocator.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mis_lab_4/models/exam_event_model.dart';

class LocationService {
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notifications.initialize(initializationSettings);
  }

  Future<void> startLocationTracking(ExamEvent event) async {
    Geolocator.getPositionStream().listen((Position position) {
      _checkDistanceAndNotify(position, event);
    });
  }

  Future<void> _checkDistanceAndNotify(
      Position currentPosition, ExamEvent event) async {
    double distance = Geolocator.distanceBetween(
      currentPosition.latitude,
      currentPosition.longitude,
      event.latitude,
      event.longitude,
    );

    if (distance <= 1000) {
      await _showLocationBasedReminder(event);
    }
  }

  Future<Map<String, dynamic>> getRouteDetails(
      LatLng origin, LatLng destination) async {
    try {
      // For demo purposes, create a simple straight line between points
      // In a real app, you'd want to use the Directions API or a similar service
      List<LatLng> polylineCoordinates = [
        origin,
        destination,
      ];

      double distance = Geolocator.distanceBetween(
        origin.latitude,
        origin.longitude,
        destination.latitude,
        destination.longitude,
      );

      return {
        'polylineCoordinates': polylineCoordinates,
        'distance': distance,
        'duration': (distance / 83.3)
            .round(), // Assuming average walking speed of 5km/h
      };
    } catch (e) {
      print('Error getting route: $e');
      return {};
    }
  }

  Future<void> _showLocationBasedReminder(ExamEvent event) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'location_reminders',
      'Location Reminders',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _notifications.show(
      event.hashCode,
      'Nearby Exam Location',
      'You are near the location for ${event.title}',
      notificationDetails,
    );
  }
}
