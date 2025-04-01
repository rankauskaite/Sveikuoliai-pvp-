import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sveikuoliai/models/journal_model.dart';

class JournalService {
  final CollectionReference journalCollection = FirebaseFirestore.instance
      .collection('journal'); // journals - issisaugo firestore, dgs saugom

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

  //read user's journal entry selected day
  Future<JournalModel?> getJournalEntryByDay(
      String username, DateTime selectedDate) async {
    String id =
        "${username}_${selectedDate.year}-${selectedDate.month}-${selectedDate.day}";
    DocumentSnapshot doc = await journalCollection.doc(id).get();
    if (!doc.exists) return null;
    return JournalModel.fromJson(doc.id, doc.data() as Map<String, dynamic>);
  }

  Future<List<DateTime>> getSavedJournalEntries(String username) async {
    QuerySnapshot snapshot =
        await journalCollection.where('userId', isEqualTo: username).get();
    // Listė, kurioje saugosime datas
    List<DateTime> dates = [];

    // Apdorojame kiekvieną dokumentą ir ištraukiame datą
    for (var doc in snapshot.docs) {
      // Pavyzdžiui, jei lauko pavadinimas yra 'entryDate', ir jis yra tipo Timestamp
      Timestamp timestamp =
          doc['date']; // Pakeisk su savo duomenų lauko pavadinimu
      DateTime date = timestamp.toDate();
      DateTime formattedDate =
          DateTime.utc(date.year, date.month, date.day); // Pašaliname laiką
      dates.add(formattedDate); // Pridedame į sąrašą
    }

    return dates;
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
