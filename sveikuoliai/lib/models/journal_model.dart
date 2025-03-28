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
      'userId': userId,
      'note': note,
      'mood': mood.toJson(),
      'photoUrl': photoUrl,
      'date': Timestamp.fromDate(DateTime(date.year, date.month, date.day)), //saugau tik datas, be laiko
    };
  }

  factory JournalModel.fromJson(String id, Map<String, dynamic> json) {
    return JournalModel(
      id: id,
      userId: json['userId'] ?? '',
      note: json['note'] ?? '',
      mood: MoodTypeExtension.fromJson(json['mood'] ?? 'neutrali'),
      photoUrl: json['photoUrl'],
      date: (json['date'] as Timestamp).toDate(),
    );
  }
}
