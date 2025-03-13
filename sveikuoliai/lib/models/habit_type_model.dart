import 'package:cloud_firestore/cloud_firestore.dart';

class HabitType {
  String id;
  String title;
  String description;
  String type;

  HabitType({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
  });

  // Konvertuoja objektą į JSON Firestore saugojimui
  Map<String, dynamic> toJson() {
    return {
      'id': id, 
      'title': title,
      'description': description,
      'type': type,
    };
  }

  // Sukuria objektą iš Firestore JSON
  factory HabitType.fromJson(String id, Map<String, dynamic> json) {
    return HabitType(
      id: id,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? '',
    );
  }

  /// **Numatytieji įpročiai** – tai pagrindiniai įpročiai, kuriuos vartotojai gali pasirinkti.
  static List<HabitType> defaultHabitTypes = [
    HabitType(
      id: "exercise",
      title: "Sportas",
      description: "Praktikuok fizinius pratimus kiekvieną dieną.",
      type: "health",
    ),
    HabitType(
      id: "reading",
      title: "Skaitymas",
      description: "Skaityk bent 10 minučių.",
      type: "personal_growth",
    ),
    HabitType(
      id: "meditation",
      title: "Meditacija",
      description: "Medituok 5 min.",
      type: "mindfulness",
    ),
    HabitType(
      id: "hydration",
      title: "Gerti daugiau vandens",
      description: "Gerk bent 2L vandens per dieną.",
      type: "health",
    ),
    HabitType(
      id: "journaling",
      title: "Rašyti dienoraštį",
      description: "Užrašyk 3 dalykus, už kuriuos esi dėkingas.",
      type: "mental_health",
    ),
    HabitType(
      id: "breathingExercise",
      title: "Kvėpavimo pratimas",
      description: "Nuramink savo mintis ir kūną sąmoningu kvėpavimu.",
      type: "mental_health",
    ),
    HabitType(
      id: "outdoorwalk",
      title: "Išeiti pasivaikščioti",
      description: "Praleisk 10 min. gryname ore.",
      type: "mental_health",
    ),
    HabitType(
      id: "languageLearning",
      title: "Mokytis naujos kalbos",
      description: "Išmok 3 naujus žodžius ar frazes užsienio kalba.",
     type: "personal_growth",
    ),
    HabitType(
      id: "planning",
      title: "Planuoti dieną",
     description: "Surašyk svarbiausius dienos darbus ir tikslus.",
     type: "personal_growth",
    ),
    HabitType(
      id: "gratitude",
      title: "Išreikšti dėkingumą",
      description: "Pasakyk „ačiū“ ar parodyk dėkingumą kitam žmogui.",
      type: "social",
    ),
    HabitType(
      id: "decluttering",
      title: "Susitvarkyti erdvę",
      description: "Susitvarkyk darbo vietą.",
      type: "productivity",
    ),
    HabitType(
      id: "budgeting",
      title: "Tvarkyti finansus",
      description: "Pasižymėk šiandienos išlaidas.",
      type: "productivity",
    ),
    HabitType(
      id: "music",
      title: "Groti muzikos instrumentu",
      description: "Pasipraktikuok 15 min. grojimą muzikos instrumentu.",
      type: "creativity",
      ),
  ];
}
