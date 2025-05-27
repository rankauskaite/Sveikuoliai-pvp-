import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sveikuoliai/enums/mood_enum.dart';

class JournalModel {
  String id;
  String userId;
  String note;
  MoodType mood;
  String? photoUrl;
  DateTime date;

  JournalModel({
    required this.id,
    required this.userId,
    required this.note,
    required this.mood,
    this.photoUrl,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'note': note,
      'mood': mood.toJson(),
      'photoUrl': photoUrl,
      'date': date.toIso8601String(), // Konvertuojame į String
    };
  }

  factory JournalModel.fromJson(Map<String, dynamic> json) {
    return JournalModel(
      id: json['id'],
      userId: json['userId'] ?? '',
      note: json['note'] ?? '',
      mood: MoodTypeExtension.fromJson(json['mood'] ?? 'neutrali'),
      photoUrl: json['photoUrl'],
      date: json['date'] is Timestamp
          ? (json['date'] as Timestamp).toDate()
          : DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}
