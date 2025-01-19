class ExamEvent {
  final String id;
  final String title;
  final DateTime dateTime;
  final String location;
  final double latitude;
  final double longitude;

  ExamEvent({
    required this.id,
    required this.title,
    required this.dateTime,
    required this.location,
    required this.latitude,
    required this.longitude,
  });

  factory ExamEvent.fromJson(Map<String, dynamic> json) {
    return ExamEvent(
      id: json['id'],
      title: json['title'],
      dateTime: json['dateTime'],
      location: json['location'],
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'dateTime': dateTime.toIso8601String(),
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
