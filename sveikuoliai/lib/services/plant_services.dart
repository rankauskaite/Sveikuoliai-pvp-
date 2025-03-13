import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/plant_model.dart';

class PlantService {
  final CollectionReference plantCollection =
      FirebaseFirestore.instance.collection('plants');

  // does exist
  Future<bool> doesPlantExist(String id) async {
    DocumentSnapshot doc = await plantCollection.doc(id).get();
    return doc.exists;
  }

  // create
  Future<void> createPlantEntry(PlantModel plant) async {
    await plantCollection.doc(plant.id).set(plant.toJson());
  }

  // read
  Future<PlantModel?> getPlantEntry(String id) async {
    DocumentSnapshot doc = await plantCollection.doc(id).get();
    if (!doc.exists || doc.data() == null) return null;
    return PlantModel.fromJson(doc.id, doc.data() as Map<String, dynamic>);
  }

  // get all
  Future<List<PlantModel>> getAllPlants() async {
    QuerySnapshot snapshot = await plantCollection.get();
    return snapshot.docs.map((doc) {
      return PlantModel.fromJson(doc.id, doc.data() as Map<String, dynamic>);
    }).toList();
  }

  // update
  Future<void> updatePlantEntry(PlantModel plant) async {
    Map<String, dynamic> data = plant.toJson();
    data.removeWhere((key, value) => value == null); // Remove null values

    await plantCollection.doc(plant.id).update(data);
    print("augalas atnaujintas: ${plant.name}");
  }

  // dlete
  Future<void> deletePlantEntry(String id) async {
    await plantCollection.doc(id).delete();
    print("augalas ištrintas: $id");
  }

  // defaultiniai
  Future<void> fillDefaultPlants() async {
    for (var plant in PlantModel.defaultPlants) {
      bool exists = await doesPlantExist(plant.id);
      if (!exists) {
        await createPlantEntry(plant);
        print("pridėtas augalas: ${plant.name}");
      }
    }
    print("Visi default augalai prid4ti");
  }
}
