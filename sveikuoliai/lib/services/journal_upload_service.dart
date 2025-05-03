import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sveikuoliai/services/firebase_storage_service.dart';
import 'package:sveikuoliai/services/journal_services.dart';
import 'package:sveikuoliai/models/journal_model.dart';
import 'package:sveikuoliai/enums/mood_enum.dart';
import 'package:sveikuoliai/services/drive_services.dart';
//import 'package:sveikuoliai/services/firebase_storage_service.dart';

// Future<void> uploadJournalEntry() async {
//   final user = FirebaseAuth.instance.currentUser;
//   if (user == null) {
//     print('Vartotojas neprisijungęs.');
//     return;
//   }

//   String? photoUrl;

//   final providers = user.providerData.map((e) => e.providerId).toList();
//   if (providers.contains('google.com')) {
//     final fileId = await DriveService().uploadImageAndGetFileId();
//     if (fileId != null) {
//       photoUrl = 'https://drive.google.com/uc?export=view&id=$fileId';
//     }
//   } else {
//     photoUrl = await FirebaseStorageService().uploadImageAndGetUrl();
//   }

//   if (photoUrl == null) {
//     print('Nepavyko įkelti nuotraukos.');
//     return;
//   }

//   final journalEntry = JournalModel(
//     id: FirebaseFirestore.instance.collection('journal').doc().id,
//     userId: user.uid,
//     note: '', // gali keisti pagal UI
//     mood: MoodType.neutrali, // keisi pagal vartotojo pasirinkimą
//     photoUrl: photoUrl,
//     date: DateTime.now(),
//   );

//   await JournalService().createJournalEntry(journalEntry);
//   print('Įrašas sukurtas su nuotrauka.');
// }
Future<void> uploadJournalEntry({
  required DateTime date,
  required String note,
  required MoodType mood,
}) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    print('Vartotojas neprisijungęs.');
    return;
  }

  String? photoUrl;

  final providers = user.providerData.map((e) => e.providerId).toList();
  if (providers.contains('google.com')) {
    final fileId = await DriveService().uploadImageAndGetFileId();
    if (fileId != null) {
      photoUrl = 'https://drive.google.com/uc?export=view&id=$fileId';
    }
  } else {
    photoUrl = await FirebaseStorageService().uploadImageAndGetUrl();
  }

  if (photoUrl == null) {
    print('Nepavyko įkelti nuotraukos.');
    return;
  }

  final journalEntry = JournalModel(
    id: FirebaseFirestore.instance.collection('journal').doc().id,
    userId: user.uid,
    note: note,
    mood: mood,
    photoUrl: photoUrl,
    date: date,
  );

  await JournalService().createJournalEntry(journalEntry);
  print('Įrašas sukurtas su nuotrauka.');
}
