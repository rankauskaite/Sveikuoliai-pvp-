import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sveikuoliai/models/goal_type_model.dart'; // Enum įtraukimas

class SharedGoal {
  String id;
  DateTime startDate;
  DateTime endDate;
  int points;
  bool isCompletedUser1;
  bool isCompletedUser2;
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
      'id': id,
      'startDate': startDate.toIso8601String(), // Konvertuojame į String
      'endDate': endDate.toIso8601String(), // Konvertuojame į String
      'points': points,
      'isCompletedUser1': isCompletedUser1,
      'isCompletedUser2': isCompletedUser2,
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
  factory SharedGoal.fromJson(Map<String, dynamic> json) {
    return SharedGoal(
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
      isCompletedUser1: json['isCompletedUser1'] ?? false,
      isCompletedUser2: json['isCompletedUser2'] ?? false,
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

  Map<String, dynamic> toJson() {
    return {
      'sharedGoalModel': sharedGoalModel.toJson(),
      'goalType': goalType.toJson(),
    };
  }

  factory SharedGoalInformation.fromJson(Map<String, dynamic> json) {
    return SharedGoalInformation(
      sharedGoalModel: SharedGoal.fromJson(
          (json['sharedGoalModel'] is Map<String, dynamic>)
              ? json['sharedGoalModel']
              : {} as Map<String, dynamic>),
      goalType: GoalType.fromJson(
          json['goalType']?['id']?.toString() ?? '',
          (json['goalType'] is Map<String, dynamic>)
              ? json['goalType']
              : {} as Map<String, dynamic>),
    );
  }
}
