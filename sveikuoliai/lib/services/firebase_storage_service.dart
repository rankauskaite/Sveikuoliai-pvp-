import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';


/// This class handles image uploading to Firebase Storage and returns the download URL.
class FirebaseStorageService {
  Future<String?> uploadImageAndGetUrl() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked == null) return null;

      final file = File(picked.path);
      final fileName = 'journal_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = FirebaseStorage.instance.ref().child('journal_images/$fileName');

      await ref.putFile(file);

      final url = await ref.getDownloadURL();
      print('Įkelta į Firebase Storage: $url');
      return url;
    } catch (e) {
      print('Klaida įkeliant į Firebase Storage: $e');
      return null;
    }
  }
}
