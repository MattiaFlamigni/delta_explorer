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

  final String
  _api = //TODO: questo sarebbe di sessione, andrebbe modificato. ho mandato ticket a inaturalist
      "eyJhbGciOiJIUzUxMiJ9.eyJ1c2VyX2lkIjo5MTMyODMwLCJleHAiOjE3NDYyNTY2ODZ9.3f-CBre3Heoq6ue_NdPUPx3VV8Tc2JDdbSXPBxAAmqqUdk5HbWCDr2u4JyeVyXSj0NRZyPBkgwqVkm2ZyZPY5A";

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

      //request.headers['Authorization'] = 'Bearer $_api';

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

  Future<String> _fetchWikipediaDescription(String title) async {
    // Fai la richiesta a Wikipedia (con exintro per l'introduzione)
    final response = await http.get(
      Uri.parse(
        "https://it.wikipedia.org/w/api.php?action=query&prop=extracts&exintro=1&explaintext=1&format=json&redirects=1&titles=${Uri.encodeComponent(title)}",
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final pages = data['query']['pages'];

      if (pages != null && pages.isNotEmpty) {
        final page = pages.values.first; // Prendi la prima pagina

        // Verifica se esiste un estratto
        String extract = page['extract'] ?? "";
        if (extract.isNotEmpty) {
          // Truncare l'estratto a 500 caratteri
          return extract.length > 500
              ? extract.substring(0, 500) + '...'
              : extract;
        }
      }
      return "Descrizione non disponibile";
    } else {
      return "Errore nella connessione";
    }
  }

  Future<String> getDescription(String title) async {
    String desc = await _fetchWikipediaDescription(title);
    return desc;
  }
}
