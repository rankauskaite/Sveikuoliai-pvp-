import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sveikuoliai/models/habit_type_model.dart';
import 'package:sveikuoliai/services/habit_type_services.dart';
import '../models/habit_model.dart';

class HabitService {
  final CollectionReference habitCollection =
      FirebaseFirestore.instance.collection('habits');
  final HabitTypeService _habitTypeService = HabitTypeService();

  // create
  Future<void> createHabitEntry(HabitModel habit) async {
    await habitCollection.doc(habit.id).set(habit.toJson());
  }

  // read
  Future<HabitModel?> getHabitEntry(String id) async {
    DocumentSnapshot doc = await habitCollection.doc(id).get();
    if (!doc.exists || doc.data() == null) return null;
    return HabitModel.fromJson(doc.id, doc.data() as Map<String, dynamic>);
  }

  // read user's all habits
  Future<List<HabitInformation>> getUserHabits(String username) async {
    // Gaukime vartotojo įpročius
    QuerySnapshot snapshot =
        await habitCollection.where('userId', isEqualTo: username).get();

    // Pirmiausia sukuriame sąrašą HabitModel iš visų duomenų
    List<HabitModel> habits = snapshot.docs
        .map((doc) =>
            HabitModel.fromJson(doc.id, doc.data() as Map<String, dynamic>))
        .toList();

    // Sukuriame sąrašą HabitInformation, užpildytą HabitType duomenimis
    List<HabitInformation> habitsWithTypes = [];

    // Dabar pereiname per kiekvieną HabitModel
    for (var habitModel in habits) {
      final habitTypeId = habitModel.habitTypeId;

      // Gaukime HabitType pagal habitTypeId
      HabitType? habitType =
          await _habitTypeService.getHabitTypeById(habitTypeId);

      // Galite pridėti patikrinimą, jei habitType yra null
      if (habitType == null) {
        // Galite užfiksuoti klaidą arba atlikti kitą veiksmą
        continue; // Tęsiame su kitais įpročiais
      }

      // Sukurkime HabitInformation su sujungtu HabitType
      var habitInfo = HabitInformation.fromJson(
          habitModel.id, habitModel.toJson(), habitType);

      habitsWithTypes.add(habitInfo);
    }

    return habitsWithTypes;
  }

  // update
  Future<void> updateHabitEntry(HabitModel habit) async {
    Map<String, dynamic> data = habit.toJson();
    data.removeWhere((key, value) => value == null); // Pašalinam null laukus
    await habitCollection.doc(habit.id).update(data);
  }

  // delete
  Future<void> deleteHabitEntry(String id) async {
    await habitCollection.doc(id).delete();
  }
}
