import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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

  static Map<String, IconData> habitIcons = {
    'exercise': Icons.fitness_center,
    'reading': Icons.book,
    'meditation': Icons.self_improvement,
    'hydration': Icons.local_drink,
    'journaling': Icons.library_books_outlined,
    'breathingExercise': Icons.air,
    'outdoorwalk': Icons.directions_walk,
    'languageLearning': Icons.language,
    'planning': Icons.calendar_month_outlined,
    'gratitude': Icons.favorite,
    'decluttering': Icons.cleaning_services,
    'budgeting': Icons.monetization_on,
    'music': Icons.music_note,
  };

  /// **Numatytieji įpročiai** – tai pagrindiniai įpročiai, kuriuos vartotojai gali pasirinkti.
  static List<HabitType> defaultHabitTypes = [
    HabitType(
      id: "exercise",
      title: "Sportas",
      description: "Praktikuok fizinius pratimus kiekvieną dieną.",
      type: "default",
    ),
    HabitType(
      id: "reading",
      title: "Skaitymas",
      description: "Skaityk bent 10 minučių.",
      type: "default",
    ),
    HabitType(
      id: "meditation",
      title: "Meditacija",
      description: "Medituok 5 min.",
      type: "default",
    ),
    HabitType(
      id: "hydration",
      title: "Gerti daugiau vandens",
      description: "Gerk bent 2L vandens per dieną.",
      type: "default",
    ),
    HabitType(
      id: "journaling",
      title: "Rašyti dienoraštį",
      description: "Užrašyk 3 dalykus, už kuriuos esi dėkingas.",
      type: "default",
    ),
    HabitType(
      id: "breathingExercise",
      title: "Kvėpavimo pratimas",
      description: "Nuramink savo mintis ir kūną sąmoningu kvėpavimu.",
      type: "default",
    ),
    HabitType(
      id: "outdoorwalk",
      title: "Išeiti pasivaikščioti",
      description: "Praleisk 10 min. gryname ore.",
      type: "default",
    ),
    HabitType(
      id: "languageLearning",
      title: "Mokytis naujos kalbos",
      description: "Išmok 3 naujus žodžius ar frazes užsienio kalba.",
      type: "default",
    ),
    HabitType(
      id: "planning",
      title: "Planuoti dieną",
      description: "Surašyk svarbiausius dienos darbus ir tikslus.",
      type: "default",
    ),
    HabitType(
      id: "gratitude",
      title: "Išreikšti dėkingumą",
      description: "Pasakyk „ačiū“ ar parodyk dėkingumą kitam žmogui.",
      type: "default",
    ),
    HabitType(
      id: "decluttering",
      title: "Susitvarkyti erdvę",
      description: "Susitvarkyk darbo vietą.",
      type: "default",
    ),
    HabitType(
      id: "budgeting",
      title: "Tvarkyti finansus",
      description: "Pasižymėk šiandienos išlaidas.",
      type: "default",
    ),
    HabitType(
      id: "music",
      title: "Groti muzikos instrumentu",
      description: "Pasipraktikuok 15 min. grojimą muzikos instrumentu.",
      type: "default",
    ),
  ];
}
