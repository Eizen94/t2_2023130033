import 'package:flutter/material.dart';

class TaskData {
  static List<Task> tasks = [
    Task(
      title: 'Morning Standup With Team',
      time: '09:30 - 09:50 AM',
      participants: 5,
      link: 'meet link',
      color: Colors.amber,
    ),
    Task(
      title: 'Design Edits',
      time: '09:50 - 10:00 AM',
      tools: ['Trello', 'Figma', 'Miro'],
      color: Colors.amber,
    ),
    Task(
      title: 'Moodboard creation',
      time: '10:00 - 11:00 AM',
      tools: ['Pinterest', 'Miro'],
      color: Colors.amber,
    ),
    Task(
      title: 'Design Meet',
      time: '11:00 - 12:00 PM',
      participants: 3,
      color: Colors.amber,
    ),
    Task(
      title: 'Client edits responses',
      time: '13:00 - 14:00 PM',
      tools: ['Google Docs'],
      color: Colors.amber,
    ),
  ];
}

class Task {
  String title;
  String? time;
  int? participants;
  String? link;
  List<String>? tools;
  Color color;
  bool showCheckButtons;

  Task({
    required this.title,
    this.time,
    this.participants,
    this.link,
    this.tools,
    required this.color,
    this.showCheckButtons = false,
  });
}