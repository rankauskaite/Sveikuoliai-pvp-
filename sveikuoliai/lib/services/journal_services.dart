import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sveikuoliai/models/journal_model.dart';

class JournalService {
  final CollectionReference journalCollection =
      FirebaseFirestore.instance.collection('journals'); // journals - issisaugo firestore, dgs saugom

    // create
  Future<void> createJournalEntry(JournalModel goal) async {
    await journalCollection.doc(goal.id).set(goal.toJson()); //  priskiriu ID
  }
    //read
  Future<JournalModel?> getJournalEntry(String id) async {
    DocumentSnapshot doc = await journalCollection.doc(id).get();
    if (!doc.exists) return null;
    return JournalModel.fromJson(doc.id, doc.data() as Map<String, dynamic>);
  }
    //update
  Future<void> updateJournalEntry(JournalModel journal) async {
    await journalCollection.doc(journal.id).update(journal.toJson());
  }
    //delete
  Future<void> deleteJournalEntry(String id) async {
    await journalCollection.doc(id).delete();
  }
}
