import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sveikuoliai/services/auth_services.dart';
import 'package:sveikuoliai/services/backblaze_service.dart';
import 'package:sveikuoliai/services/journal_services.dart';
import 'package:sveikuoliai/models/journal_model.dart';
import 'package:sveikuoliai/enums/mood_enum.dart';

Future<String?> uploadJournalEntry({
  required String id,
  required String username,
  required DateTime date,
  required String note,
  required MoodType mood,
  File? photoFile,
}) async {
  final AuthService _authService = AuthService();
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    print('Vartotojas neprisijungęs.');
    return null;
  }

  String? photoUrl;
  if (photoFile != null) {
    photoUrl =
        await BackblazeService().uploadImageAndGetUrl(photoFile, username);
    if (photoUrl == null) {
      print('Nepavyko įkelti nuotraukos.');
      return null;
    }
  }

  final journalEntry = JournalModel(
    id: id,
    userId: user.uid,
    note: note,
    mood: mood,
    photoUrl: photoUrl ?? '',
    date: date,
  );

  await JournalService().createJournalEntry(journalEntry);
  await _authService.addJournalentryToSession(journalEntry);
  print('Įrašas sukurtas su nuotrauka: $photoUrl');
  return photoUrl; // Grąžiname photoUrl
}
