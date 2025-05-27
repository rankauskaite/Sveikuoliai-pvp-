import 'package:flutter/material.dart';

class GoalType {
  String id;
  String title;
  String description;
  String type;
  bool isCountable;
  bool tikUser;
  bool tikFriends;

  GoalType({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.isCountable,
    this.tikUser = true,
    this.tikFriends = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'isCountable': isCountable,
      'tikUser': tikUser,
      'tikFriends': tikFriends,
    };
  }

  factory GoalType.fromJson(String id, Map<String, dynamic> json) {
    return GoalType(
      id: id,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? '',
      isCountable: json['isCountable'] ?? false,
      tikUser: json['tikUser'] ?? true,
      tikFriends: json['tikFriends'] ?? false,
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
    'group_challenge_steps': Icons.group,
    'teamwork_book': Icons.book_rounded,
    'photo_challenge': Icons.photo,
    'hydrate_together': Icons.water_drop,
    'mindfulness_group': Icons.self_improvement,
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
      tikUser: true,
      tikFriends: false,
    ),
    GoalType(
      id: "read_books",
      title: "Perskaityti 10 knygų",
      description: "Perskaityti 10 knygų.",
      type: "default",
      isCountable: true,
      tikUser: true,
      tikFriends: true,
    ),
    GoalType(
      id: "save_money",
      title: "Sutaupyti 500€",
      description: "Sukaupti tam tikrą pinigų sumą taupymo tikslui.",
      type: "default",
      isCountable: true,
      tikUser: true,
      tikFriends: false,
    ),
    GoalType(
      id: "run_marathon",
      title: "Prabėgti maratoną",
      description: "Pasiruošti ir nubėgti pilną maratoną.",
      type: "default",
      isCountable: true,
      tikUser: true,
      tikFriends: true,
    ),
    GoalType(
      id: "meditate_30_days",
      title: "Mėnesį medituoti kasdien",
      description: "Įgyvendinti 30 dienų meditacijos iššūkį.",
      type: "default",
      isCountable: true,
      tikUser: true,
      tikFriends: false,
    ),
    GoalType(
      id: "learn_language",
      title: "Išmokti naują kalbą",
      description: "Pasiekti tam tikrą lygį naujoje kalboje.",
      type: "default",
      isCountable: false,
      tikUser: true,
      tikFriends: false,
    ),
    GoalType(
      id: "weight_loss",
      title: "Pasiekti sveiką svorį",
      description: "Pasiekti sveikesnį svorį numetant svorio.",
      type: "default",
      isCountable: false,
      tikUser: true,
      tikFriends: false,
    ),
    GoalType(
      id: "weight_gain",
      title: "Pasiekti sveiką svorį",
      description: "Pasiekti sveikesnį svorį priaugant svorio.",
      type: "default",
      isCountable: false,
      tikUser: true,
      tikFriends: false,
    ),
    GoalType(
      id: "plant_trees",
      title: "Pasodinti 20 medžių",
      description: "Prisidėti prie gamtos išsaugojimo pasodinant medžius.",
      type: "default",
      isCountable: true,
      tikUser: true,
      tikFriends: false,
    ),
    GoalType(
      id: "run_100km",
      title: "Prabėgti 100 km per mėnesį",
      description: "Įveikti 100 km per mėnesį bėgiojant.",
      type: "default",
      isCountable: true,
      tikUser: true,
      tikFriends: true,
    ),
    GoalType(
      id: "volunteering",
      title: "Įsitraukti į savanorystę",
      description: "Skirti savo laiką savanoriškai veiklai.",
      type: "default",
      isCountable: false,
      tikUser: true,
      tikFriends: true,
    ),
    GoalType(
      id: "group_challenge_steps",
      title: "Žingsnių iššūkis",
      description: "Surinkite bendrą 100 000 žingsnių skaičių.",
      type: "default",
      isCountable: true,
      tikUser: false,
      tikFriends: true,
    ),
    GoalType(
      id: "teamwork_book",
      title: "Skaityti knygą kartu",
      description: "Perskaitykite pasirinktą knygą su draugu.",
      type: "default",
      isCountable: false,
      tikUser: false,
      tikFriends: true,
    ),
    GoalType(
      id: "photo_challenge",
      title: "Nuotraukų karuselė",
      description: "Dalinkitės nuotraukomis pagal temą.",
      type: "default",
      isCountable: false,
      tikUser: false,
      tikFriends: true,
    ),
    GoalType(
      id: "hydrate_together",
      title: "Gerti vandenį kartu",
      description: "Stebėkite vieni kitų vandens suvartojimą ir palaikykite.",
      type: "default",
      isCountable: true,
      tikUser: false,
      tikFriends: true,
    ),
    GoalType(
      id: "mindfulness_group",
      title: "Bendras sąmoningumo iššūkis",
      description: "Atlikite sąmoningumo praktikas.",
      type: "default",
      isCountable: false,
      tikUser: false,
      tikFriends: true,
    ),
  ];
}
