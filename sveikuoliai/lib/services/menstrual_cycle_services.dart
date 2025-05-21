import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sveikuoliai/models/menstrual_cycle_model.dart';

class MenstrualCycleService {
  final CollectionReference menstrualCycleCollection =
      FirebaseFirestore.instance.collection(
          'menstrualCycles'); // firestore kolekcijoj taip vadinsis (butinai dgs.)

  // create
  Future<void> createMenstrualCycleEntry(MenstrualCycle menstrualCycle) async {
    final docRef = menstrualCycle.id.isNotEmpty
        ? menstrualCycleCollection.doc(menstrualCycle.id)
        : menstrualCycleCollection.doc(); // Jei id tuščias kuriam naują
    await docRef.set(
        menstrualCycle.toJson()..['id'] = docRef.id); // Išsaugom id firestore
  }

  // read
  Future<MenstrualCycle?> getMenstrualCycleEntry(String id) async {
    DocumentSnapshot doc = await menstrualCycleCollection.doc(id).get();
    if (!doc.exists) return null;
    return MenstrualCycle.fromJson(doc.id, doc.data() as Map<String, dynamic>);
  }

  // read all user's menstrual cycles
  Future<List<MenstrualCycle>> getUserMenstrualCycles(String userId) async {
    // Gaukime vartotojo menstruacijas
    QuerySnapshot snapshot =
        await menstrualCycleCollection.where('userId', isEqualTo: userId).get();

    // Pirmiausia sukuriame sąrašą MenstrualCycle iš visų duomenų
    List<MenstrualCycle> menstrualCycles = snapshot.docs
        .map((doc) =>
            MenstrualCycle.fromJson(doc.id, doc.data() as Map<String, dynamic>))
        .toList();

    // Grąžiname pirmą menstruacijų ciklą
    return menstrualCycles;
  }

  // update
  Future<void> updateMenstrualCycleEntry(MenstrualCycle menstrualCycle) async {
    await menstrualCycleCollection
        .doc(menstrualCycle.id)
        .update(menstrualCycle.toJson());
  }

  // delete (pagal id)
  Future<void> deleteMenstrualCycleEntry(String id) async {
    await menstrualCycleCollection.doc(id).delete();
  }
}
