import 'dart:io';

import 'package:delta_explorer/database/supabase.dart';
import 'package:delta_explorer/reports/reportsController.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class Reports extends StatefulWidget {
  const Reports({super.key});

  @override
  State<Reports> createState() => _ReportsState();
}

class _ReportsState extends State<Reports> {
  final ReportsController controller = ReportsController();
  final SupabaseDB _supabase = SupabaseDB();
  bool _isImagePickerActive = false;
  List<Map<String, dynamic>> _categoriesList = [];
  final TextEditingController _commentTextController = TextEditingController();
  String _selectedCategory = "";
  File? _image;

  //bool _canSendReports = true; // Stato che indica se il bottone invia è abilitato

  final ImagePicker _picker = ImagePicker();

  //Position? _position;

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Segnala problema")),
      body: Column(
        children: [
          buildGridView(),
          Padding(padding: const EdgeInsets.all(8), child: showTextFormField()),
          Padding(
            padding: const EdgeInsets.all(8),
            child: ElevatedButton(
              onPressed: _pickImage,
              child: const Text("Scatta una foto"),
            ),
          ),
          if (_image != null) showSelectedImage(),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: 50),
            child: drawReportButton(),
          ),
        ],
      ),
    );
  }

  Widget buildGridView() {
    return Expanded(
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
        ),
        itemCount: _categoriesList.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = _categoriesList[index]["title"];
              });
            },
            child: cardCategory(index),
          );
        },
      ),
    );
  }

  drawReportButton() {
    return ElevatedButton(
      onPressed: () async {
        if (_image == null) {
          showSnackbar("Scatta una foto prima di inviare la segnalazione.");
          return;
        }

        await controller.updatePosition();
        if (controller.getCanSendReport()) {
          showLoadingDialog();
          var response = await controller.submitReport(
            _selectedCategory,
            _image!,
            _commentTextController,
          );
          showSnackbar(response!);
          if (!mounted) return;
          Navigator.pop(context); // Chiude il dialogo di caricamento
          Navigator.pop(context); //torna alla mappa
        } else {
          showSnackbar(
            "Permessi non abilitati - attivali per inviare la segnalazione",
          );
        }
      },
      child: const Text("invia segnalazione"),
    );
  }

  Widget showSelectedImage() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ClipRect(
        child: Image.file(_image!, width: 150, height: 150, fit: BoxFit.cover),
      ),
    );
  }

  TextFormField showTextFormField() {
    return TextFormField(
      controller: _commentTextController,
      decoration: const InputDecoration(
        border: UnderlineInputBorder(),
        labelText: 'Commenti',
      ),
    );
  }

  Card cardCategory(int index) {
    return Card(
      color:
          (_selectedCategory == _categoriesList[index]["title"])
              ? Colors.red
              : Colors.white,
      child: Column(
        children: [
          Text(_categoriesList[index]["title"]),
          Image.asset(
            'assets/${_categoriesList[index]["image_path"]}',
            fit: BoxFit.cover,
            width: 70,
            height: 70,
          ),
        ],
      ),
    );
  }

  Future<void> loadCategories() async {
    try {
      var categories = await _supabase.getData(table: "reports_category");
      setState(() {
        _categoriesList = categories;
      });
    } catch (e) {
      showSnackbar("Errore nel caricamento delle categorie");
    }
  }

  Future<void> _pickImage() async {
    if (_isImagePickerActive) return; // Impedisce duplicazioni

    _isImagePickerActive = true;

    final permissionStatus = await Permission.camera.request();
    if (permissionStatus.isGranted) {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        setState(() {
          _image = File(image.path);
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

  showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 10),
              Text("Invio in corso..."),
            ],
          ),
        );
      },
    );
  }

  /*Future<void> updatePosition() async {
    _position = await controller.getUserLocation();
    if(_position==null) {
      showSnackbar("GPS disabilitato o permessi non concessi");
    }
  }*/

  /*Future<void> submitReport() async {
    if (_selectedCategory.isNotEmpty) {
      String? imageUrl;

      if (_image != null) {
        imageUrl = await controller.uploadImage(_image!);
        if(imageUrl==null){
          showSnackbar("errore nel caricamento dell'immagine");
        }
      }

      GeoPoint geopoint = _position != null ? GeoPoint(_position!.latitude, _position!.longitude) : GeoPoint(0, 0);
      await _supabase.addReports(imageUrl ?? "", _selectedCategory, _commentTextController.text, geopoint);

      showSnackbar("Segnalazione inviata con successo!");
    } else {
      showSnackbar("Seleziona una categoria");
    }
  }*/

  /*Future<String?> uploadImage(File image) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final String fullPath = await _supabase.supabase.storage.from('reports').upload(
        '$fileName.png',
        image,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
      );
      return fullPath;
    } catch (e) {
      showSnackbar("Errore nel caricamento dell'immagine");
      print("errore nel caricamento: $e");
      return null;
    }
  }*/

  /*Future<Position?> getUserLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _canSendReports = false;
        showSnackbar("GPS disabilitato");
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse && permission!=LocationPermission.always) {
          _canSendReports = false;
          showSnackbar("Permessi di localizzazione negati. Consenti per inviare");
          return null;
        }
      }

      return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    } catch (e) {
      _canSendReports = false;
      showSnackbar("Errore nel recupero della posizione");
      return null;
    }
  }*/
}
