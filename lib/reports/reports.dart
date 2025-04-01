import 'dart:ffi';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delta_explorer/database/firebase.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class Reports extends StatefulWidget {
  const Reports({super.key});

  @override
  State<Reports> createState() => _ReportsState();
}

class _ReportsState extends State<Reports> {
  //final supabase = Supabase.instance.client;
  final Firebase _db = Firebase();
  bool _isImagePickerActive = false;
  List<Map<String, dynamic>> _categoriesList = List.empty();
  final TextEditingController _commentText = TextEditingController();
  String _selectedCategory = "";
  File? _image;
  bool _canSendReports = true ; //se utente consente i permessi il bottone invia è abilitato


  final ImagePicker _picker = ImagePicker();
  Position? position;


  @override
  void initState() {

    super.initState();
    setState(() {
      this.loadCategories();
    });
  }


  Future<void> updatePosition() async {
    this.position = await this.getUserLocation();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Segnala problema")),
      body: Column(
        children: [
          Expanded(
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
          ),
          Padding(padding: EdgeInsets.all(8), child: buildTextFormField()),

          Padding(
            padding: EdgeInsets.all(8),
            child: ElevatedButton(
              onPressed: _pickImage,
              child: Text("Scatta una foto"),
            ),
          ),

          // Mostra l'immagine selezionata (se presente)
          if (_image != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: showSelectedImage(),
            ),

          const Spacer(),

          Padding(
            padding: EdgeInsets.only(bottom: 50),
            child: ElevatedButton(
              onPressed: () async {
                await this.updatePosition();
                if(_canSendReports){
                  await submitReport();
                }else{
                  this.showSnackbar("Permessi non abilitati - attivali per inviare la segnalazione");
                }

                print("posso inviare? $_canSendReports");
              },
              child: Text("invia segnalazione"),
            ),
          ),
        ],
      ),
    );
  }

  ClipRect showSelectedImage() {
    return ClipRect(
              child: Image.file(
                _image!,
                width: 150,
                height: 150,
                fit: BoxFit.cover,
              ),
            );
  }

  Future<void> submitReport() async {
    if (_selectedCategory.isNotEmpty) {
      String? imageUrl;



      // Se l'utente ha selezionato un'immagine, la carica su Firebase Storage
      if (_image != null) {
        imageUrl = await uploadImage(_image!);
      }


      GeoPoint geopoint = position!=null?GeoPoint(position!.latitude, position!.longitude):GeoPoint(0, 0);
      // Salva il report nel database con l'URL dell'immagine (o stringa vuota se non c'è)
      _db.addReports(imageUrl ?? "", _selectedCategory, _commentText.text, geopoint);

      showSnackbar("Segnalazione inviata con successo!");
    } else {
      showSnackbar("Seleziona una categoria");
    }
  }

  TextFormField buildTextFormField() {
    return TextFormField(
      controller: _commentText,
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
          ), //resources/prova.png
        ],
      ),
    );
  }

  loadCategories() async {
    var categories = await _db.getData(collection: "reports_category");
    setState(() {
      this._categoriesList = categories;
    });
  }

  // Funzione per selezionare l'immagine
  Future<void> _pickImage() async {
    if (_isImagePickerActive) {
      return; // Impedisci l'esecuzione se è già attivo
    }

    _isImagePickerActive = true; // Imposta a true prima di avviare

    Permission.camera.request();
    await Permission.camera
        .onDeniedCallback(() {})
        .onGrantedCallback(() async {
          final XFile? image = await _picker.pickImage(
            source: ImageSource.camera,
          );
          if (image != null) {
            setState(() {
              _image = File(image.path);
            });
          }
          _isImagePickerActive = false; // Imposta a false dopo il completamento
        })
        .onPermanentlyDeniedCallback(() {
          showSnackbar(
            "Devi concedere i permessi per selezionare una immagine",
          );
          _isImagePickerActive = false; // Imposta a false in caso di errore
        })
        .request();
  }

  Future<String?> uploadImage(File image) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageRef = FirebaseStorage.instance.ref().child(
        "reports/$fileName.jpg",
      );

      UploadTask uploadTask = storageRef.putFile(image);

      uploadTask.snapshotEvents.listen((event) {
        print("Upload: ${event.bytesTransferred}/${event.totalBytes}");
      });

      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      print("Immagine caricata: $downloadUrl");
      return downloadUrl;
    } catch (e, stacktrace) {
      print("Errore nel caricamento: $e");
      return null;
    }
  }

  showSnackbar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }




  Future<Position?> getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Controlla se il GPS è attivo
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print("GPS disabilitato");
      _canSendReports = false;
      return null;
    }

    // Controlla i permessi
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _canSendReports = false;
        this.showSnackbar("permessi disabilitati. Consenti per inviare la segnalazione");
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print("Permessi negati permanentemente");
      _canSendReports = false;
      return null;
    }

    // Ottieni la posizione corrente
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

  }



}
