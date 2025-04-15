import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class Lens extends StatefulWidget {
  const Lens({super.key});

  @override
  State<Lens> createState() => _LensState();
}

class _LensState extends State<Lens> {
  bool _isImagePickerActive = false;
  File? _image;
  final ImagePicker _picker = ImagePicker();
  final String api = "eyJhbGciOiJIUzUxMiJ9.eyJ1c2VyX2lkIjo5MTMyODMwLCJleHAiOjE3NDQ3MzA0ODJ9.nZ3yU-sOMbEGBzHEfqFFzGTgaNvf-UhO8FTEUmB3Wam969q-qbjdoTOpVMXjt9_C6HVkhaM4uSA-bxUwq-Wqig";
  bool _isLoading = false;
  List<Map<String, dynamic>> _suggestions = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scatta e Scopri"),
        backgroundColor: Colors.green[400], // Un colore che richiama la natura
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Pulsante per scattare la foto
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.camera_alt),
                label: const Text("Scatta una Foto"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[400],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  textStyle: const TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Area per mostrare l'immagine selezionata
              if (_image != null)
                Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: Image.file(
                        _image!,
                        width: 200,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : () => identifySpecies(_image!),
                      icon: const Icon(Icons.search),
                      label: _isLoading ? const Text("Ricerca in corso...") : const Text("Scopri la Specie"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[400],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        textStyle: const TextStyle(fontSize: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),

              // Area per mostrare i risultati dell'identificazione
              if (_suggestions.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Risultati:",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _suggestions.length,
                      itemBuilder: (context, index) {
                        final suggestion = _suggestions[index];
                        final commonName = suggestion['taxon']?['preferred_common_name'] as String?;
                        final score = suggestion['vision_score'] as double?;
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  commonName ?? "Nome non disponibile",
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                if (score != null)
                                  Text(
                                    'Probabilità: ${(score).toStringAsFixed(2)}%',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> identifySpecies(File image) async {
    setState(() {
      _isLoading = true;
      _suggestions.clear(); // Pulisci i risultati precedenti
    });

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.inaturalist.org/v1/computervision/score_image'),
      );
      request.headers['Authorization'] = api;

      request.files.add(
        await http.MultipartFile.fromPath('image', image.path),
      );

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();


      if (response.statusCode == 200) {
        var jsonData = json.decode(responseBody);
        var suggestionsData = jsonData['results'] as List<dynamic>?;
        if (suggestionsData != null) {
          setState(() {
            _suggestions = suggestionsData.cast<Map<String, dynamic>>();
          });
        }
      } else {
        showSnackbar('Errore nella richiesta: ${response.statusCode}');

      }
    } catch (e) {
      showSnackbar('Si è verificato un errore: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
    }

  Widget showSelectedImage() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: Image.file(_image!, width: 200, height: 200, fit: BoxFit.cover),
      ),
    );
  }

  Future<void> _pickImage() async {
    if (_isImagePickerActive) return;
    _isImagePickerActive = true;
    final permissionStatus = await Permission.camera.request();
    if (permissionStatus.isGranted) {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera, imageQuality: 40);
      if (image != null) {
        setState(() {
          _image = File(image.path);
          _suggestions.clear(); // Pulisci i risultati quando si scatta una nuova foto
        });
      }
    } else {
      showSnackbar("Permesso fotocamera negato. Abilitalo nelle impostazioni.");
    }
    _isImagePickerActive = false;
  }

  void showSnackbar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }
}