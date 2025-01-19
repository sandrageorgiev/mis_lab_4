import 'package:flutter/material.dart';
import 'package:mis_lab_4/models/exam_event_model.dart';
import 'package:mis_lab_4/screens/event_details_screen.dart';
import 'package:mis_lab_4/services/exam_data_services.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<ExamEvent> _allEvents = [];

  @override
  void initState() {
    super.initState();
    _allEvents = ExamDataService.getExams();
    _selectedDay = _focusedDay;
  }

  List<ExamEvent> _getEventsForDay(DateTime day) {
    return ExamDataService.getEventsForDay(day);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam Schedule'),
      ),
      body: Column(
        children: [
          TableCalendar<ExamEvent>(
            firstDay: DateTime.utc(2024, 1, 1),
            lastDay: DateTime.utc(2034, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            eventLoader: _getEventsForDay,
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _buildEventList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEventList() {
    if (_selectedDay == null) return Container();

    final events = _getEventsForDay(_selectedDay!);

    return events.isEmpty
        ? const Center(child: Text('No exams scheduled for this day'))
        : ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  title: Text(
                    event.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${event.location}\n${event.dateTime.toString()}',
                  ),
                  onTap: () => _showEventDetails(event),
                ),
              );
            },
          );
  }

  void _showEventDetails(ExamEvent event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventDetailsScreen(event: event),
      ),
    );
  }
}
