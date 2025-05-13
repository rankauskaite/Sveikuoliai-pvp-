import 'dart:io';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart';
import 'package:image_picker/image_picker.dart';

class DriveService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [drive.DriveApi.driveFileScope],
  );

  Future<String?> uploadImageAndGetFileId() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) return null;

      final authHeaders = await account.authHeaders;
      final client = authenticatedClient(
        http.Client(),
        AccessCredentials.fromJson(authHeaders),
      );

      final driveApi = drive.DriveApi(client);

      // Pick image from gallery
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked == null) return null;

      final file = File(picked.path);
      final media = drive.Media(file.openRead(), file.lengthSync());
      final driveFile = drive.File()..name = "journal_${DateTime.now()}.jpg";

      final uploaded = await driveApi.files.create(driveFile, uploadMedia: media);
      print("Įkelta sėkmingai! File ID: ${uploaded.id}"); //issisaugau fileId kad veliau galeciau pasiekti faila
      return uploaded.id;
    } catch (e) {
      print('Klaida įkeliant į Drive: $e');
      return null;
    }
  }
}
