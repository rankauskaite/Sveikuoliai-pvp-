import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sveikuoliai/models/menstrual_cycle_model.dart';

class MenstrualCycleService {
  final CollectionReference menstrualCycleCollection =
      FirebaseFirestore.instance.collection('menstrualCycles'); // firestore kolekcijoj taip vadinsis (butinai dgs.)

  // create
  Future<void> createMenstrualCycleEntry(MenstrualCycle menstrualCycle) async {
    await menstrualCycleCollection.add(menstrualCycle.toJson());
  }

  // read
  Future<MenstrualCycle?> getMenstrualCycleEntry(String id) async {
    DocumentSnapshot doc = await menstrualCycleCollection.doc(id).get();
    if (!doc.exists) return null;
    return MenstrualCycle.fromJson(doc.id, doc.data() as Map<String, dynamic>);
  }

  // update
  Future<void> updateMenstrualCycleEntry(MenstrualCycle menstrualCycle) async {
    await menstrualCycleCollection.doc(menstrualCycle.id).update(menstrualCycle.toJson());
  }

  // delete (pagal id)
  Future<void> deleteMenstrualCycleEntry(String id) async {
    await menstrualCycleCollection.doc(id).delete();
  }
}
