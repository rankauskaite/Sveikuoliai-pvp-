import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sveikuoliai/models/plant_model.dart';

class PlantService {
  final CollectionReference plantCollection =
      FirebaseFirestore.instance.collection('plants');

  // does exist
  Future<bool> doesPlantExist(String id) async {
    try {
      DocumentSnapshot doc = await plantCollection.doc(id).get();
      return doc.exists;
    } catch (e) {
      print("klaida: $e");
      return false;
    }
  }

  // create
  Future<void> createPlantEntry(PlantModel plant) async {
    try {
      bool exists = await doesPlantExist(plant.id);
      if (exists) {
        print("Augalas ${plant.name} jau egzistuoja");
        return;
      }
      await plantCollection.doc(plant.id).set(plant.toJson());
      print("Augalas pridėtas: ${plant.name}");
    } catch (e) {
      print("klaida: $e");
    }
  }

  // read
  Future<PlantModel?> getPlantEntry(String id) async {
    try {
      DocumentSnapshot doc = await plantCollection.doc(id).get();
      if (!doc.exists || doc.data() == null) return null;
      return PlantModel.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      print("klaida: $e");
      return null;
    }
  }

  // read/get all
  Future<List<PlantModel>> getAllPlants() async {
    try {
      QuerySnapshot snapshot = await plantCollection.get();
      List<PlantModel> plants = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return PlantModel.fromJson({
          'id': doc.id, // Priskiriame Firestore dokumento ID
          ...data,
        });
      }).toList();

      return plants;
    } catch (e) {
      print("Klaida gaunant augalus: $e");
      return [];
    }
  }

  // update
  Future<void> updatePlantEntry(PlantModel plant) async {
    try {
      bool exists = await doesPlantExist(plant.id);
      if (!exists) {
        print("Augalas ${plant.name} neegzistuoja");
        return;
      }
      Map<String, dynamic> data = plant.toJson();
      data.removeWhere((key, value) => value == null); // Remove null values

      await plantCollection.doc(plant.id).update(data);
      print("Augalas atnaujintas: ${plant.name}");
    } catch (e) {
      print("klaida: $e");
    }
  }

  // delete
  Future<void> deletePlantEntry(String id) async {
    try {
      bool exists = await doesPlantExist(id);
      if (!exists) {
        print("Augalas $id neegzistuoja duombazėj");
        return;
      }
      await plantCollection.doc(id).delete();
      print("Augalas ištrintas: $id");
    } catch (e) {
      print("klaida: $e");
    }
  }

  // Įrašau į database
  // Future<void> fillDefaultPlants() async {
  //   try {
  //     for (var plant in PlantModel.defaultPlants) {
  //       bool exists = await doesPlantExist(plant.id);
  //       if (!exists) {
  //         await createPlantEntry(plant);
  //         print("Pridėtas augalas: ${plant.name}");
  //       }
  //     }
  //     print("augalai pridėti");
  //   } catch (e) {
  //     print("klaida: $e");
  //   }
  // }
}
