import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sveikuoliai/enums/category_enum.dart'; // Importuoju enum
import 'package:sveikuoliai/models/habit_type_model.dart';

class HabitModel {
  String id;
  DateTime startDate;
  DateTime endDate;
  int points;
  CategoryType category;
  int endPoints;
  String repetition;
  String userId;
  String habitTypeId;
  String plantId;

  HabitModel({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.points,
    required this.category,
    required this.endPoints,
    required this.repetition,
    required this.userId,
    required this.habitTypeId,
    required this.plantId,
  });

  // i json
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'points': points,
      'category': category.toJson(), // enum į string
      'endPoints': endPoints,
      'repetition': repetition,
      'userId': userId,
      'habitTypeId': habitTypeId,
      'plantId': plantId,
    };
  }

  // is json
  factory HabitModel.fromJson(String id, Map<String, dynamic> json) {
    return HabitModel(
      id: id,
      startDate: json['startDate'] is Timestamp
          ? (json['startDate'] as Timestamp).toDate()
          : DateTime.tryParse(json['startDate'] ?? '') ?? DateTime.now(),
      endDate: json['endDate'] is Timestamp
          ? (json['endDate'] as Timestamp).toDate()
          : DateTime.tryParse(json['endDate'] ?? '') ?? DateTime.now(),
      points: json['points'] ?? 0,
      category: json['category'] != null
          ? CategoryTypeExtension.fromJson(json['category'])
          : CategoryType.bekategorijos, //
      endPoints: json['endPoints'] ?? 0,
      repetition: json['repetition'] ?? '',
      userId: json['userId'] ?? '',
      plantId: json['plantId'] ?? '',
      habitTypeId: json['habitTypeId'] ?? '',
    );
  }
}

class HabitInformation {
  HabitModel habitModel;
  HabitType habitType; // Įtraukta HabitType

  HabitInformation({
    required this.habitModel,
    required this.habitType,
  });

  factory HabitInformation.fromJson(
      HabitModel habitModel, HabitType habitType) {
    return HabitInformation(
      habitModel: habitModel,
      habitType: habitType, // Įtraukta HabitType
    );
  }
}
