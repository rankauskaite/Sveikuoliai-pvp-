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
    return JournalModel.fromJson(doc.data() as Map<String, dynamic>);
  }

  //read user's journal entry selected day
  Future<JournalModel?> getJournalEntryByDay(
      String username, DateTime selectedDate) async {
    String id =
        "${username}_${selectedDate.year}-${selectedDate.month}-${selectedDate.day}";
    DocumentSnapshot doc = await journalCollection.doc(id).get();
    if (!doc.exists) return null;
    return JournalModel.fromJson(doc.data() as Map<String, dynamic>);
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

  Future<List<JournalModel>> getAllUsersJournalEntries(String username) async {
    try {
      QuerySnapshot snapshot =
          await journalCollection.where('userId', isEqualTo: username).get();

      List<JournalModel> journalEntries = [];
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
          // Pridedame id į JSON duomenis
          convertedData['id'] = doc.id;
          final journalEntry = JournalModel.fromJson(convertedData);
          journalEntries.add(journalEntry);
        } catch (e) {
          continue;
        }
      }

      print('Journal entries loaded: ${journalEntries.length}');
      return journalEntries;
    } catch (e) {
      print('Klaida gaunant žurnalo įrašus: $e');
      return []; // Grąžiname tuščią sąrašą, jei įvyksta klaida
    }
  }

  //update
  Future<void> updateJournalEntry(JournalModel journal) async {
    await journalCollection.doc(journal.id).update(journal.toJson());
  }

  //delete
  Future<void> deleteJournalEntry(String id) async {
    await journalCollection.doc(id).delete();
  }

// show all photos from journal for a specific day
  Future<List<JournalModel>> getJournalEntriesByDay(
      String userId, DateTime selectedDate) async {
    QuerySnapshot snapshot = await journalCollection
        .where('userId', isEqualTo: userId)
        .where('date',
            isGreaterThanOrEqualTo: DateTime(
                selectedDate.year, selectedDate.month, selectedDate.day))
        .where('date',
            isLessThan: DateTime(
                selectedDate.year, selectedDate.month, selectedDate.day + 1))
        .get();

    return snapshot.docs.map((doc) {
      return JournalModel.fromJson(doc.data() as Map<String, dynamic>);
    }).toList();
  }
}
