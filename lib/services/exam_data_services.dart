import 'package:mis_lab_4/models/exam_event_model.dart';

class ExamDataService {
  static List<ExamEvent> getExams() {
    return [
      ExamEvent(
        id: '1',
        title: 'Mobile Information Systems',
        dateTime: DateTime(2025, 1, 20, 10, 0),
        location: 'FINKI - Lab 215',
        latitude: 42.004186,
        longitude: 21.409835,
      ),
      ExamEvent(
        id: '2',
        title: 'Web Programming',
        dateTime: DateTime(2025, 1, 25, 12, 30),
        location: 'FINKI - Amphitheater',
        latitude: 41.9849813,
        longitude: 21.409835,
      ),
      ExamEvent(
        id: '3',
        title: 'Artificial Intelligence',
        dateTime: DateTime(2024, 2, 5, 9, 0),
        location: 'FINKI - Lab 2',
        latitude: 42.004186,
        longitude: 21.409835,
      ),
    ];
  }

  static List<ExamEvent> getEventsForDay(DateTime day) {
    return getExams().where((event) {
      return event.dateTime.year == day.year &&
          event.dateTime.month == day.month &&
          event.dateTime.day == day.day;
    }).toList();
  }
}
