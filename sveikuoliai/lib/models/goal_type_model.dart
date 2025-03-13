import 'package:cloud_firestore/cloud_firestore.dart';

class GoalType {
  String id;
  String title;
  String description;
  String type;

  GoalType({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'type': type,
    };
  }

  factory GoalType.fromJson(String id, Map<String, dynamic> json) {
    return GoalType(
      id: id,
      title: json['title'] ?? '', 
      description: json['description'] ?? '',
      type: json['type'] ?? '',
    );
  }

  /// defaultiniai
  static List<GoalType> defaultGoalTypes = [
    GoalType(
      id: "scholarship",
      title: "Gauti stipendiją",
      description: "Pasiekti aukštus akademinius rezultatus ir gauti stipendiją.",
      type: "kokybinis",
    ),
    GoalType(
      id: "read_books",
      title: "Perskaityti 10 knygų",
      description: "Perskaityti 10 knygų.",
      type: "kiekybinis",
    ),
    GoalType(
      id: "save_money",
      title: "Sutaupyti 500€",
      description: "Sukaupti tam tikrą pinigų sumą taupymo tikslui.",
      type: "kiekybinis",
    ),
    GoalType(
      id: "run_marathon",
      title: "Prabėgti maratoną",
      description: "Pasiruošti ir nubėgti pilną maratoną.",
      type: "kokybinis",
    ),
    GoalType(
      id: "meditate_30_days",
      title: "Mėnesį medituoti kasdien",
      description: "Įgyvendinti 30 dienų meditacijos iššūkį.",
      type: "kiekybinis",
    ),
    GoalType(
      id: "learn_language",
      title: "Išmokti naują kalbą",
      description: "Pasiekti tam tikrą lygį naujoje kalboje.",
      type: "kokybinis",
    ),
    GoalType(
      id: "weight_loss",
      title: "Pasiekti sveiką svorį",
      description: "Pasiekti sveikesnį svorį numetant svorio.",
      type: "kokybinis",
    ),

    GoalType(
      id: "weight_gain",
      title: "Pasiekti sveiką svorį",
      description: "Pasiekti sveikesnį svorį priaugant svorio.",
      type: "kokybinis",
    ),

    GoalType(
      id: "plant_trees",
      title: "Pasodinti 20 medžių",
      description: "Prisidėti prie gamtos išsaugojimo pasodinant medžius.",
      type: "kiekybinis",
    ),
    GoalType(
      id: "run_100km",
      title: "Prabėgti 100 km per mėnesį",
      description: "Įveikti 100 km per mėnesį bėgiojant.",
      type: "kiekybinis",
    ),
    GoalType(
      id: "volunteering",
      title: "Įsitraukti į savanorystę",
      description: "Skirti savo laiką savanoriškai veiklai.",
      type: "kokybinis",
    ),
  ];
}
