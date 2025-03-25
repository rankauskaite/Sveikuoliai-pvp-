import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sveikuoliai/enums/category_enum.dart'; // enumeratorių įtraukimas

class GoalModel {
  String id;
  DateTime startDate;
  DateTime endDate;
  int points;
  bool isCountable;
  CategoryType category;
  int endPoints;
  String userId;
  String plantId;
  String? goalTypeId; // Dabar nullable

  GoalModel({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.points,
    required this.isCountable,
    required this.category,
    required this.endPoints,
    required this.userId,
    required this.plantId,
    this.goalTypeId, // Nullable nereikia `required`
  });

  /// Konvertavimas į JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id, 
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'points': points,
      'isCountable': isCountable,
      'category': category.toJson(), // Enum į string
      'endPoints': endPoints,
      'userId': userId,
      'plantId': plantId,
      if (goalTypeId != null) 'goalTypeId': goalTypeId, // Neįdeda į JSON, jei `null`
    };
  }

  /// Konvertavimas iš JSON
  factory GoalModel.fromJson(String id, Map<String, dynamic> json) {
    return GoalModel(
      id: id,
      startDate: (json['startDate'] as Timestamp).toDate(),
      endDate: (json['endDate'] as Timestamp).toDate(),
      points: json['points'] ?? 0,
      isCountable: json['isCountable'] ?? false,
      category: CategoryTypeExtension.fromJson(json['category'] ?? ''), // Enum iš string
      endPoints: json['endPoints'] ?? 0,
      userId: json['userId'] ?? '',
      plantId: json['plantId'] ?? '',
      goalTypeId: json['goalTypeId'], // Jei nėra lauko, liks `null`
    );
  }
}
