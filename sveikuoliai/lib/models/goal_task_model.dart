import 'package:cloud_firestore/cloud_firestore.dart';

class GoalTask {
  String id;
  String goalId;
  bool isCompleted;
  DateTime date;
  String title;
  String description;
  int points;
  String? userId; // Optional userId field for shared goals

  GoalTask({
    required this.id,
    required this.goalId,
    this.isCompleted = false,
    required this.title,
    required this.description,
    required this.date,
    this.points = 0,
    this.userId,
  });

  // i json
  Map<String, dynamic> toJson() {
    return {
      'id': id, // Pridedame ID
      'goalId': goalId,
      'isCompleted': isCompleted,
      'title': title,
      'description': description,
      'date': Timestamp.fromDate(date),
      'points': points,
      'userId': userId, // Optional userId field for shared goals
    };
  }

  // is json
  factory GoalTask.fromJson(String id, Map<String, dynamic> json) {
    return GoalTask(
      id: id,
      goalId: json['goalId'] ?? '',
      isCompleted: json['isCompleted'] ?? false,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      date: json['date'] is Timestamp
          ? (json['date'] as Timestamp).toDate()
          : DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      points: json['points'] ?? 0,
      userId: json['userId'], // Optional userId field for shared goals
    );
  }
}
