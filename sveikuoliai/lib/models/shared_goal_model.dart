import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sveikuoliai/enums/category_enum.dart';
import 'package:sveikuoliai/models/goal_type_model.dart'; // Enum įtraukimas

class SharedGoal {
  String id;
  DateTime startDate;
  DateTime endDate;
  int points;
  bool isCompletedUser1;
  bool isCompletedUser2;
  CategoryType category;
  int endPoints;
  String user1Id;
  String user2Id;
  bool isPlantDeadUser1;
  bool isPlantDeadUser2;
  String plantId;
  String goalTypeId;
  bool isApproved = false; // Pridėta nauja savybė

  SharedGoal({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.points,
    required this.isCompletedUser1,
    required this.isCompletedUser2,
    required this.category,
    required this.endPoints,
    required this.user1Id,
    required this.user2Id,
    required this.plantId,
    required this.goalTypeId,
    required this.isApproved,
    required this.isPlantDeadUser1,
    required this.isPlantDeadUser2,
  });

  /// Konvertavimas į JSON
  Map<String, dynamic> toJson() {
    return {
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'points': points,
      'isCompletedUser1': isCompletedUser1,
      'isCompletedUser2': isCompletedUser2,
      'category': category.toJson(), // Enum į string
      'endPoints': endPoints,
      'user1Id': user1Id,
      'user2Id': user2Id,
      'plantId': plantId,
      'goalTypeId': goalTypeId,
      'isApproved': isApproved, // Pridėta nauja savybė
      'isPlantDeadUser1': isPlantDeadUser1,
      'isPlantDeadUser2': isPlantDeadUser2,
    };
  }

  /// Konvertavimas iš JSON
  factory SharedGoal.fromJson(String id, Map<String, dynamic> json) {
    return SharedGoal(
      id: id,
      startDate: (json['startDate'] as Timestamp).toDate(),
      endDate: (json['endDate'] as Timestamp).toDate(),
      points: json['points'] ?? 0,
      isCompletedUser1: json['isCompletedUser1'] ?? false,
      isCompletedUser2: json['isCompletedUser2'] ?? false,
      category: CategoryTypeExtension.fromJson(json['category'] ?? ''),
      endPoints: json['endPoints'] ?? 0,
      user1Id: json['user1Id'] ?? '',
      user2Id: json['user2Id'] ?? '',
      plantId: json['plantId'] ?? '',
      goalTypeId: json['goalTypeId'] ?? '',
      isApproved: json['isApproved'] ?? false, // Pridėta nauja savybė
      isPlantDeadUser1: json['isPlantDeadUser1'] ?? false,
      isPlantDeadUser2: json['isPlantDeadUser2'] ?? false,
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
