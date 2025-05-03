import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sveikuoliai/enums/category_enum.dart';
import 'package:sveikuoliai/models/goal_type_model.dart'; // Enum įtraukimas

class SharedGoal {
  String id;
  DateTime startDate;
  DateTime endDate;
  int points;
  bool isCountable;
  CategoryType category;
  int endPoints;
  String user1Id;
  String user2Id;
  String plantId;
  String goalTypeId;
  bool isApproved = false; // Pridėta nauja savybė

  SharedGoal({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.points,
    required this.isCountable,
    required this.category,
    required this.endPoints,
    required this.user1Id,
    required this.user2Id,
    required this.plantId,
    required this.goalTypeId,
    required this.isApproved,
  });

  /// Konvertavimas į JSON
  Map<String, dynamic> toJson() {
    return {
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'points': points,
      'isCountable': isCountable,
      'category': category.toJson(), // Enum į string
      'endPoints': endPoints,
      'user1Id': user1Id,
      'user2Id': user2Id,
      'plantId': plantId,
      'goalTypeId': goalTypeId,
      'isApproved': isApproved, // Pridėta nauja savybė
    };
  }

  /// Konvertavimas iš JSON
  factory SharedGoal.fromJson(String id, Map<String, dynamic> json) {
    return SharedGoal(
      id: id,
      startDate: (json['startDate'] as Timestamp).toDate(),
      endDate: (json['endDate'] as Timestamp).toDate(),
      points: json['points'] ?? 0,
      isCountable: json['isCountable'] ?? false,
      category: CategoryTypeExtension.fromJson(json['category'] ?? ''),
      endPoints: json['endPoints'] ?? 0,
      user1Id: json['user1Id'] ?? '',
      user2Id: json['user2Id'] ?? '',
      plantId: json['plantId'] ?? '',
      goalTypeId: json['goalTypeId'] ?? '',
      isApproved: json['isApproved'] ?? false, // Pridėta nauja savybė
    );
  }
}

class SharedGoalInformation {
  SharedGoal sharedGoalModel;
  GoalType goalType;

  SharedGoalInformation({
    required this.sharedGoalModel,
    required this.goalType,
  });

  /// Konvertavimas iš JSON
  factory SharedGoalInformation.fromJson(
      SharedGoal goalModel, GoalType goalType) {
    return SharedGoalInformation(
      sharedGoalModel: goalModel,
      goalType: goalType,
    );
  }
}
