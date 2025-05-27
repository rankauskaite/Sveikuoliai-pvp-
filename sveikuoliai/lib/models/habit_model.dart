import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sveikuoliai/models/habit_type_model.dart';

class HabitModel {
  String id;
  DateTime startDate;
  DateTime endDate;
  int points;
  int endPoints;
  bool isCompleted = false;
  String userId;
  String habitTypeId;
  String plantId;
  bool isPlantDead;

  HabitModel({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.points,
    required this.endPoints,
    required this.isCompleted,
    required this.userId,
    required this.habitTypeId,
    required this.plantId,
    required this.isPlantDead,
  });

  // i json
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startDate': startDate.toIso8601String(), // Konvertuojame į String
      'endDate': endDate.toIso8601String(), // Konvertuojame į String
      'points': points,
      'endPoints': endPoints,
      'isCompleted': isCompleted,
      'userId': userId,
      'habitTypeId': habitTypeId,
      'plantId': plantId,
      'isPlantDead': isPlantDead,
    };
  }

  // is json
  factory HabitModel.fromJson(Map<String, dynamic> json) {
    return HabitModel(
      id: json['id'],
      startDate: json['startDate'] is Timestamp
          ? (json['startDate'] as Timestamp).toDate()
          : DateTime.tryParse(json['startDate']?.toString() ?? '') ??
              DateTime.now(),
      endDate: json['endDate'] is Timestamp
          ? (json['endDate'] as Timestamp).toDate()
          : DateTime.tryParse(json['endDate']?.toString() ?? '') ??
              DateTime.now(),
      points: (json['points'] as num?)?.toInt() ?? 0,
      endPoints: (json['endPoints'] as num?)?.toInt() ?? 0,
      isCompleted: json['isCompleted'] as bool? ?? false,
      userId: json['userId']?.toString() ?? '',
      plantId: json['plantId']?.toString() ?? '',
      habitTypeId: json['habitTypeId']?.toString() ?? '',
      isPlantDead: json['isPlantDead'] as bool? ?? false,
    );
  }
}

class HabitInformation {
  HabitModel habitModel;
  HabitType habitType;

  HabitInformation({required this.habitModel, required this.habitType});

  factory HabitInformation.fromJson(Map<String, dynamic> json) {
    return HabitInformation(
      habitModel: HabitModel.fromJson(
          (json['habitModel'] is Map<String, dynamic>)
              ? json['habitModel']
              : <String, dynamic>{}),
      habitType: HabitType.fromJson(
          json['habitType']?['id']?.toString() ?? '',
          (json['habitType'] is Map<String, dynamic>)
              ? json['habitType']
              : {} as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'habitModel': habitModel.toJson(),
      'habitType': habitType.toJson(),
    };
  }
}
