import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';

class BackblazeService {
  final String keyId = '003086315fe53060000000001';
  final String applicationKey = 'K003uhqL+sPDw4wpIz/C7COFeSnF1Q4';
  final String bucketId = '6088b6a321250f8e95730016';
  final String bucketName = 'Gija-prohos';

  String? _apiUrl;
  String? _authToken;
  String? _uploadUrl;
  String? _uploadToken;

  Future<bool> authenticate() async {
    try {
      final String credentials =
          base64Encode(utf8.encode('$keyId:$applicationKey'));
      final response = await http.get(
        Uri.parse('https://api.backblazeb2.com/b2api/v2/b2_authorize_account'),
        headers: {
          'Authorization': 'Basic $credentials',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _authToken = data['authorizationToken'];
        _apiUrl = data['apiUrl'];
        print('Autentifikacija sėkminga: $_authToken');
        return true;
      } else {
        print('Autentifikacijos klaida: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Autentifikacijos klaida: $e');
      return false;
    }
  }

  Future<Map<String, String>?> getUploadUrl() async {
    if (_authToken == null || _apiUrl == null) {
      final success = await authenticate();
      if (!success) {
        print('Nepavyko autentifikuotis.');
        return null;
      }
    }

    try {
      final response = await http.post(
        Uri.parse('$_apiUrl/b2api/v2/b2_get_upload_url'),
        headers: {
          'Authorization': _authToken!,
        },
        body: jsonEncode({
          'bucketId': bucketId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _uploadUrl = data['uploadUrl'];
        _uploadToken = data['authorizationToken'];
        print('Įkėlimo URL gautas: $_uploadUrl');
        return {
          'uploadUrl': _uploadUrl!,
          'uploadToken': _uploadToken!,
        };
      } else if (response.statusCode == 401) {
        print('Žetonas negalioja, bandoma autentifikuotis iš naujo...');
        final success = await authenticate();
        if (success) {
          return getUploadUrl();
        } else {
          print('Nepavyko autentifikuotis po klaidos.');
          return null;
        }
      } else {
        print('Klaida gaunant įkėlimo URL: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Klaida gaunant įkėlimo URL: $e');
      return null;
    }
  }

  // Naujas metodas autorizuotam URL gavimui
  Future<String?> getAuthorizedDownloadUrl(String filePath) async {
    if (_authToken == null || _apiUrl == null) {
      final success = await authenticate();
      if (!success) {
        print('Nepavyko autentifikuotis.');
        return null;
      }
    }

    try {
      final response = await http.post(
        Uri.parse('$_apiUrl/b2api/v2/b2_get_download_authorization'),
        headers: {
          'Authorization': _authToken!,
        },
        body: jsonEncode({
          'bucketId': bucketId,
          'fileNamePrefix': filePath,
          'validDurationInSeconds': 3600, // 1 valanda
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final authToken = data['authorizationToken'];
        final downloadUrl =
            '$_apiUrl/file/$bucketName/$filePath?Authorization=$authToken';
        print('Autorizuotas URL: $downloadUrl');
        return downloadUrl;
      } else {
        print('Klaida gaunant autorizuotą URL: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Klaida gaunant autorizuotą URL: $e');
      return null;
    }
  }

  Future<String?> uploadImageAndGetUrl(File imageFile, String username) async {
    try {
      final userId = username;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'journal_images/$userId/$timestamp.jpg';

      final uploadData = await getUploadUrl();
      if (uploadData == null) {
        print('Nepavyko gauti įkėlimo URL arba žetono.');
        return null;
      }

      final uploadUrl = uploadData['uploadUrl']!;
      final uploadToken = uploadData['uploadToken']!;

      final fileContent = await imageFile.readAsBytes();
      final sha1Hash = sha1.convert(fileContent).toString();

      final response = await http.post(
        Uri.parse(uploadUrl),
        headers: {
          'Authorization': uploadToken,
          'X-Bz-File-Name': fileName,
          'Content-Type': 'image/jpeg',
          'X-Bz-Content-Sha1': sha1Hash,
        },
        body: fileContent,
      );

      if (response.statusCode == 200) {
        // Generuojame autorizuotą URL, nes kibirėlis privatus
        final authorizedUrl = await getAuthorizedDownloadUrl(fileName);
        if (authorizedUrl != null) {
          print('Nuotrauka įkelta: $authorizedUrl');
          return authorizedUrl;
        } else {
          print('Nepavyko gauti autorizuoto URL.');
          return null;
        }
      } else {
        print('Įkėlimo klaida: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Klaida įkeliant nuotrauką: $e');
      return null;
    }
  }
}
