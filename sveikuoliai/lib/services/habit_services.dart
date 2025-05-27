import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sveikuoliai/models/habit_model.dart';
import 'package:sveikuoliai/models/habit_type_model.dart';
import 'package:sveikuoliai/services/habit_progress_services.dart';
import 'package:sveikuoliai/services/habit_type_services.dart';

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
    return HabitModel.fromJson(doc.data() as Map<String, dynamic>);
  }

  Future<List<HabitInformation>> getUserHabits(String username) async {
    try {
      // Gaukime vartotojo įpročius
      QuerySnapshot snapshot =
          await habitCollection.where('userId', isEqualTo: username).get();

      // Pirmiausia sukuriame sąrašą HabitModel iš visų duomenų
      List<HabitModel> habits = [];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        if (data == null) {
          continue;
        }

        // Konvertuojame Map<dynamic, dynamic> į Map<String, dynamic>
        final Map<String, dynamic> convertedData = data is Map
            ? data.map((key, value) => MapEntry(key.toString(), value))
            : {};

        try {
          final habitModel = HabitModel.fromJson(convertedData);
          habits.add(habitModel);
        } catch (e) {
          continue;
        }
      }

      // Sukuriame sąrašą HabitInformation, užpildytą HabitType duomenimis
      List<HabitInformation> habitsWithTypes = [];

      // Dabar pereiname per kiekvieną HabitModel
      for (var habitModel in habits) {
        final habitTypeId = habitModel.habitTypeId;

        // Gaukime HabitType pagal habitTypeId
        HabitType? habitType =
            await _habitTypeService.getHabitTypeById(habitTypeId);
        if (habitType == null) {
          continue; // Tęsiame su kitais įpročiais
        }

        // Sukurkime HabitInformation su sujungtu HabitType
        var habitInfo = HabitInformation.fromJson({
          'id': habitModel.id, // Aiškiai nurodome id
          'habitModel': habitModel.toJson(),
          'habitType': habitType.toJson(),
        });

        habitsWithTypes.add(habitInfo);
      }

      print('Habits with types loaded: ${habitsWithTypes.length}');
      return habitsWithTypes;
    } catch (e) {
      print('Klaida gaunant įpročius: $e');
      return []; // Grąžiname tuščią sąrašą, jei įvyksta klaida
    }
  }

  // update
  Future<void> updateHabitEntry(HabitModel habit) async {
    Map<String, dynamic> data = habit.toJson();
    data.removeWhere((key, value) => value == null); // Pašalinam null laukus
    await habitCollection.doc(habit.id).update(data);
  }

  // delete
  Future<void> deleteHabitEntry(String id) async {
    HabitModel? model = await getHabitEntry(id);
    HabitType? type =
        await _habitTypeService.getHabitTypeById(model!.habitTypeId);
    if (type?.type == "custom") {
      await _habitTypeService.deleteHabitTypeEntry(type!.id);
    }
    await habitCollection.doc(id).delete();
    final habitProgressService = HabitProgressService();
    await habitProgressService.deleteHabitProgresses(id);
  }
}
