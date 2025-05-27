import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sveikuoliai/models/goal_type_model.dart'; // enumeratorių įtraukimas

class GoalModel {
  String id;
  DateTime startDate;
  DateTime endDate;
  int points;
  bool isCompleted;
  int endPoints;
  String userId;
  String plantId;
  String goalTypeId;
  bool isPlantDead;

  GoalModel({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.points,
    required this.isCompleted,
    required this.endPoints,
    required this.userId,
    required this.plantId,
    required this.isPlantDead,
    required this.goalTypeId,
  });

  /// Konvertavimas į JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startDate': startDate.toIso8601String(), // Konvertuojame į String
      'endDate': endDate.toIso8601String(), // Konvertuojame į String
      'points': points,
      'isCompleted': isCompleted,
      'endPoints': endPoints,
      'userId': userId,
      'plantId': plantId,
      'isPlantDead': isPlantDead,
      'goalTypeId': goalTypeId,
    };
  }

  /// Konvertavimas iš JSON
  factory GoalModel.fromJson(Map<String, dynamic> json) {
    return GoalModel(
      id: json['id'],
      startDate: json['startDate'] is Timestamp
          ? (json['startDate'] as Timestamp).toDate()
          : DateTime.tryParse(json['startDate']?.toString() ?? '') ??
              DateTime.now(),
      endDate: json['endDate'] is Timestamp
          ? (json['endDate'] as Timestamp).toDate()
          : DateTime.tryParse(json['endDate']?.toString() ?? '') ??
              DateTime.now(),
      points: json['points'] ?? 0,
      isCompleted: json['isCompleted'] ?? false,
      endPoints: json['endPoints'] ?? 0,
      userId: json['userId'] ?? '',
      plantId: json['plantId'] ?? '',
      isPlantDead: json['isPlantDead'] ?? false,
      goalTypeId: json['goalTypeId'],
    );
  }
}

class GoalInformation {
  GoalModel goalModel;
  GoalType goalType;

  GoalInformation({
    required this.goalModel,
    required this.goalType,
  });

  Map<String, dynamic> toJson() {
    return {
      'goalModel': goalModel.toJson(),
      'goalType': goalType.toJson(),
    };
  }

  factory GoalInformation.fromJson(Map<String, dynamic> json) {
    return GoalInformation(
      goalModel: GoalModel.fromJson((json['goalModel'] is Map<String, dynamic>)
          ? json['goalModel']
          : {} as Map<String, dynamic>),
      goalType: GoalType.fromJson(
          json['goalType']?['id']?.toString() ?? '',
          (json['goalType'] is Map<String, dynamic>)
              ? json['goalType']
              : {} as Map<String, dynamic>),
    );
  }
}
