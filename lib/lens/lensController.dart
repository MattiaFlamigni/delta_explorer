import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class LensController {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool _isImagePickerActive = false;
  List<Map<String, dynamic>> _suggestions = [];

  final String _api =
      "eyJhbGciOiJIUzUxMiJ9.eyJ1c2VyX2lkIjo5MTMyODMwLCJleHAiOjE3NDQ3MzA0ODJ9.nZ3yU-sOMbEGBzHEfqFFzGTgaNvf-UhO8FTEUmB3Wam969q-qbjdoTOpVMXjt9_C6HVkhaM4uSA-bxUwq-Wqig";

  List<Map<String, dynamic>> getSuggestions() {
    return _suggestions;
  }

  Future<String> pickImage() async {
    if (_isImagePickerActive) return "";
    _isImagePickerActive = true;
    final permissionStatus = await Permission.camera.request();
    if (permissionStatus.isGranted) {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 40,
      );
      if (image != null) {
        _image = File(image.path);
        _suggestions
            .clear(); // Pulisci i risultati quando si scatta una nuova foto
        _isImagePickerActive = false;
        return "";
      }
    } else {
      return "Permesso fotocamera negato. Abilitalo nelle impostazioni.";
    }
    _isImagePickerActive = false;
    return "";
  }

  File? getImage() {
    return _image;
  }

  Future<String> identifySpecies(File image) async {
    _suggestions.clear(); // Pulisci i risultati precedenti

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.inaturalist.org/v1/computervision/score_image'),
      );
      request.headers['Authorization'] = _api;

      request.files.add(await http.MultipartFile.fromPath('image', image.path));

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        var jsonData = json.decode(responseBody);
        var suggestionsData = jsonData['results'] as List<dynamic>?;
        if (suggestionsData != null) {
          _suggestions = suggestionsData.cast<Map<String, dynamic>>();
          if (_suggestions.isEmpty) {
            return "Nessuna corrispondenza trovata";
          }

          return "";
        }
      } else {
        return "Errore nella richiesta: ${response.statusCode}";
      }
    } catch (e) {
      return "Si è verificato un errore: $e";
    }
    return "";
  }
}
