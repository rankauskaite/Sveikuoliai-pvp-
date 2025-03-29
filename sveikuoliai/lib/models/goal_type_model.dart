import 'package:flutter/material.dart';

class GoalType {
  String id;
  String title;
  String description;
  String type;
  bool isCountable;

  GoalType({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.isCountable,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'type': type,
      'isCountable': isCountable,
    };
  }

  factory GoalType.fromJson(String id, Map<String, dynamic> json) {
    return GoalType(
      id: id,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? '',
      isCountable: json['isCountable'] ?? false,
    );
  }

  static Map<String, IconData> goalIcons = {
    'scholarship': Icons.school,
    'read_books': Icons.book,
    'save_money': Icons.savings,
    'run_marathon': Icons.directions_run,
    'meditate_30_days': Icons.self_improvement,
    'learn_language': Icons.language,
    'weight_loss': Icons.fitness_center,
    'weight_gain': Icons.fitness_center,
    'plant_trees': Icons.local_florist,
    'run_100km': Icons.run_circle_outlined,
    'volunteering': Icons.volunteer_activism,
  };

  /// defaultiniai
  static List<GoalType> defaultGoalTypes = [
    GoalType(
      id: "scholarship",
      title: "Gauti stipendiją",
      description:
          "Pasiekti aukštus akademinius rezultatus ir gauti stipendiją.",
      type: "default",
      isCountable: false,
    ),
    GoalType(
        id: "read_books",
        title: "Perskaityti 10 knygų",
        description: "Perskaityti 10 knygų.",
        type: "default",
        isCountable: true),
    GoalType(
      id: "save_money",
      title: "Sutaupyti 500€",
      description: "Sukaupti tam tikrą pinigų sumą taupymo tikslui.",
      type: "default",
      isCountable: true,
    ),
    GoalType(
      id: "run_marathon",
      title: "Prabėgti maratoną",
      description: "Pasiruošti ir nubėgti pilną maratoną.",
      type: "default",
      isCountable: false,
    ),
    GoalType(
      id: "meditate_30_days",
      title: "Mėnesį medituoti kasdien",
      description: "Įgyvendinti 30 dienų meditacijos iššūkį.",
      type: "default",
      isCountable: true,
    ),
    GoalType(
      id: "learn_language",
      title: "Išmokti naują kalbą",
      description: "Pasiekti tam tikrą lygį naujoje kalboje.",
      type: "default",
      isCountable: false,
    ),
    GoalType(
      id: "weight_loss",
      title: "Pasiekti sveiką svorį",
      description: "Pasiekti sveikesnį svorį numetant svorio.",
      type: "default",
      isCountable: false,
    ),
    GoalType(
      id: "weight_gain",
      title: "Pasiekti sveiką svorį",
      description: "Pasiekti sveikesnį svorį priaugant svorio.",
      type: "default",
      isCountable: false,
    ),
    GoalType(
      id: "plant_trees",
      title: "Pasodinti 20 medžių",
      description: "Prisidėti prie gamtos išsaugojimo pasodinant medžius.",
      type: "default",
      isCountable: true,
    ),
    GoalType(
      id: "run_100km",
      title: "Prabėgti 100 km per mėnesį",
      description: "Įveikti 100 km per mėnesį bėgiojant.",
      type: "default",
      isCountable: true,
    ),
    GoalType(
      id: "volunteering",
      title: "Įsitraukti į savanorystę",
      description: "Skirti savo laiką savanoriškai veiklai.",
      type: "default",
      isCountable: false,
    ),
  ];
}
