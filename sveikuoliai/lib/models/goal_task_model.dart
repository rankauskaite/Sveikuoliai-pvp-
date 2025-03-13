import 'package:cloud_firestore/cloud_firestore.dart';

class GoalTask {
  String id;
  String goalId;
  bool isCompleted;
  DateTime date;
  String description;
  int points;

  GoalTask({
    required this.id,
    required this.goalId,
    required this.isCompleted,
    required this.description,
    required this.date,
    required this.points,
  });

  // i json
  Map<String, dynamic> toJson() {
    return {
      'id': id, // Pridedame ID
      'goalId': goalId,
      'isCompleted': isCompleted,
      'description': description,
      'date': Timestamp.fromDate(date),
      'points': points,
    };
  }

  // is json
  factory GoalTask.fromJson(String id, Map<String, dynamic> json) {
    return GoalTask(
      id: id,
      goalId: json['goalId'] ?? '',
      isCompleted: json['isCompleted'] ?? false,
      description: json['description'] ?? '',
      date: json['date'] is Timestamp
          ? (json['date'] as Timestamp).toDate()
          : DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      points: json['points'] ?? 0,
    );
  }
}
