import 'package:cloud_firestore/cloud_firestore.dart';
import '../enums/category_enum.dart'; // enumeratoriu itraukiu

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
  });

  /// i json
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
    };
  }

  /// is json
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
    );
  }
}
