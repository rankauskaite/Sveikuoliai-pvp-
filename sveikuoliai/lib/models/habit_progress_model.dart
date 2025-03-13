import 'package:cloud_firestore/cloud_firestore.dart';

class HabitProgress {
  String id;
  String habitId; 
  String description;
  int points;
  int streak;
  String plantUrl;
  DateTime date;
  bool isCompleted;

  HabitProgress({
    required this.id,
    required this.habitId,
    required this.description,
    required this.points,
    this.streak = 0, // default reikšmė = 0
    required this.plantUrl,
    required this.date,
    required this.isCompleted,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id, 
      'habitId': habitId, 
      'description': description,
      'points': points,
      'streak': streak,
      'plantUrl': plantUrl,
      'date': Timestamp.fromDate(date),
      'isCompleted':isCompleted,
    };
  }

  factory HabitProgress.fromJson(String id, Map<String, dynamic> json) {
    return HabitProgress(
      id: id,
      habitId: json['habitId'] ?? '',
      description: json['description'] ?? '',
      points: json['points'] ?? 0,
      streak: (json['streak'] as int?) ?? 0,
      plantUrl: json['plantUrl'] ?? '',
      date: (json['date'] as Timestamp).toDate(), 
      isCompleted: json['isCompleted'] ?? false,    
    );
  }

  /// Streak atnaujinimas pagal paskutinę datą
  static Future<int> updateStreak(String goalId) async {
    final firestore = FirebaseFirestore.instance;

    final snapshot = await firestore
        .collection('habitprogress')
        .where('habitId', isEqualTo: goalId)
        .orderBy('date', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      return 1; // pirmas streak = 1
    }

    // VEIKS TIK KASDIENIAMS 
    final lastProgress = snapshot.docs.first;
    final lastDate = (lastProgress['date'] as Timestamp).toDate();
    final today = DateTime.now();

    if (_isYesterday(lastDate, today)) {
      return ((lastProgress['streak'] as int?) ?? 0) + 1; // streak +1
    } else if (!_isSameDay(lastDate, today)) {
      return 0; // jei buvo pertrauka – reset į 0
    }

    return (lastProgress['streak'] as int?) ?? 1; // jei šiandien jau atlikta – streak nesikeičia
  }

  /// ar paskutinė užduotis buvo vakar
  static bool _isYesterday(DateTime lastDate, DateTime today) {
    final yesterday = today.subtract(const Duration(days: 1));
    return lastDate.year == yesterday.year &&
        lastDate.month == yesterday.month &&
        lastDate.day == yesterday.day;
  }

  /// ar ta pati diena
  static bool _isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }
}
