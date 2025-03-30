import 'dart:io';

import 'package:delta_explorer/database/firebase.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class Reports extends StatefulWidget {
  const Reports({super.key});

  @override
  State<Reports> createState() => _ReportsState();
}

class _ReportsState extends State<Reports> {
  //final supabase = Supabase.instance.client;
  Firebase db = Firebase();
  bool _isImagePickerActive = false;
  List<Map<String, dynamic>> categoriesList = List.empty();
  TextEditingController commentText = TextEditingController();
  String selectedCategory = "";
  File? _image;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    setState(() {
      this.loadCategories();
    });
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
              itemCount: categoriesList.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategory = categoriesList[index]["title"];
                    });
                  },
                  child: cardCategory(index),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8),
            child: TextFormField(
              controller: commentText,
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Commenti',
              ),
            ),
          ),


          // Button per selezionare un'immagine dalla galleria
          Padding(padding: EdgeInsets.all(8),
              child: ElevatedButton(
                  onPressed: _pickImage, child: Text("Carica una foto"))),

          // Mostra l'immagine selezionata (se presente)
          if (_image != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipRect(
                child: Image.file(
                  _image!,
                  width: 150,
                  height: 150,
                  fit: BoxFit.cover,
                ),
              ),
            ),

          Spacer(),

          Padding(
            padding: EdgeInsets.only(bottom: 50),
            child: ElevatedButton(
              onPressed: () async {
                /*if (selectedCategory.isNotEmpty) {


                  db.addReports("", selectedCategory,
                    commentText.text,);
                } else {
                  this.showSnackbar("Seleziona una categoria");
                }*/



                if (selectedCategory.isNotEmpty) {
                  String? imageUrl;

                  // Se l'utente ha selezionato un'immagine, la carica su Firebase Storage
                  if (_image != null) {
                    imageUrl = await uploadImage(_image!);
                  }

                  // Salva il report nel database con l'URL dell'immagine (o stringa vuota se non c'è)
                  db.addReports(imageUrl ?? "", selectedCategory, commentText.text);

                  showSnackbar("Segnalazione inviata con successo!");
                } else {
                  showSnackbar("Seleziona una categoria");
                }
              },
              child: Text("invia segnalazione"),
            ),
          ),


        ],
      ),
    );
  }

  Card cardCategory(int index) {
    return Card(
      color:
      (selectedCategory == categoriesList[index]["title"])
          ? Colors.red
          : Colors.white,
      child: Column(
        children: [
          Text(categoriesList[index]["title"]),
          Image.asset(
            'assets/${categoriesList[index]["image_path"]}',
            fit: BoxFit.cover,
            width: 70,
            height: 70,
          ), //resources/prova.png
        ],
      ),
    );
  }

  loadCategories() async {
    var categories = await db.getData(collection: "reports_category");
    setState(() {
      this.categoriesList = categories;
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
        source: ImageSource.gallery,
      );
      if (image != null) {
        setState(() {
          _image = File(image.path);
        });
      }
      _isImagePickerActive = false; // Imposta a false dopo il completamento
    })
        .onPermanentlyDeniedCallback(() {
      showSnackbar("Devi concedere i permessi per selezionare una immagine");
      _isImagePickerActive = false; // Imposta a false in caso di errore
    })
        .request();
  }




  Future<String?> uploadImage(File image) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageRef = FirebaseStorage.instance.ref().child("reports/$fileName.jpg");

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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
      ),
    );
  }
}
