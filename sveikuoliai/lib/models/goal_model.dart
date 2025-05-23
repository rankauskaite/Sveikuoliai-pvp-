import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sveikuoliai/enums/category_enum.dart';
import 'package:sveikuoliai/models/goal_type_model.dart'; // enumeratorių įtraukimas

class GoalModel {
  String id;
  DateTime startDate;
  DateTime endDate;
  int points;
  bool isCompleted;
  CategoryType category;
  int endPoints;
  String userId;
  String plantId;
  String? goalTypeId; // Dabar nullable
  bool isPlantDead;

  GoalModel({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.points,
    required this.isCompleted,
    required this.category,
    required this.endPoints,
    required this.userId,
    required this.plantId,
    required this.isPlantDead,
    this.goalTypeId, // Nullable nereikia `required`
  });

  /// Konvertavimas į JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'points': points,
      'isCompleted': isCompleted,
      'category': category.toJson(), // Enum į string
      'endPoints': endPoints,
      'userId': userId,
      'plantId': plantId,
      'isPlantDead': isPlantDead,
      if (goalTypeId != null)
        'goalTypeId': goalTypeId, // Neįdeda į JSON, jei `null`
    };
  }

  /// Konvertavimas iš JSON
  factory GoalModel.fromJson(String id, Map<String, dynamic> json) {
    return GoalModel(
      id: id,
      startDate: (json['startDate'] as Timestamp).toDate(),
      endDate: (json['endDate'] as Timestamp).toDate(),
      points: json['points'] ?? 0,
      isCompleted: json['isCompleted'] ?? false,
      category: CategoryTypeExtension.fromJson(
          json['category'] ?? ''), // Enum iš string
      endPoints: json['endPoints'] ?? 0,
      userId: json['userId'] ?? '',
      plantId: json['plantId'] ?? '',
      isPlantDead: json['isPlantDead'] ?? false,
      goalTypeId: json['goalTypeId'], // Jei nėra lauko, liks `null`
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

  /// Konvertavimas iš JSON
  factory GoalInformation.fromJson(GoalModel goalModel, GoalType goalType) {
    return GoalInformation(
      goalModel: goalModel,
      goalType: goalType,
    );
  }
}
