import 'dart:io';

import 'package:delta_explorer/database/firebase.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

/*TODO: GESTIRE CARICAMENTO FOTO*/

class Spotted extends StatefulWidget {
  const Spotted({super.key});

  @override
  State<Spotted> createState() => _SpottedState();
}

class _SpottedState extends State<Spotted> {
  Firebase db = Firebase();
  List<Map<String, dynamic>> categoriesList = List.empty();
  TextEditingController commentText = TextEditingController();
  bool _isImagePickerActive = false;
  String _selectedCategory = "";
  String _selectedSubcategory = "";
  File? _image; // Variabile per immagazzinare l'immagine selezionata

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    setState(() {
      // seeder: db.inserisciCategorie();
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
                      _selectedCategory = categoriesList[index]["nome"];

                      List<dynamic> sottocategorie =
                          categoriesList[index]["sottocategorie"];
                      this.showSubcategoryDialog(sottocategorie);
                    });
                  },
                  child: cardCategory(index),
                );
              },
            ),
          ),
          Padding(padding: EdgeInsets.all(8), child: buildTextFormField()),

          // Button per selezionare un'immagine dalla galleria
          Padding(
            padding: EdgeInsets.all(8),
            child: ElevatedButton(
              onPressed: _pickImage,
              child: Text("Carica una foto"),
            ),
          ),

          // Mostra l'immagine selezionata (se presente)
          if (_image != null) showSelectedImage(),

          Spacer(),

          Padding(
            padding: EdgeInsets.only(bottom: 50),
            child: ElevatedButton(
              onPressed: () async {
                await uploadSpot();
              },
              child: Text("invia Avvistamento"),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> uploadSpot() async {
    if (_selectedCategory.isNotEmpty) {
      String? imageUrl;

      // Se l'utente ha selezionato un'immagine, la carica su Firebase Storage
      if (_image != null) {
        imageUrl = await uploadImage(_image!);
      }

      // Salva il report nel database con l'URL dell'immagine (o stringa vuota se non c'è)
      db.addSpotted(
        imageUrl ?? "",
        _selectedCategory,
        commentText.text,
        _selectedSubcategory,
      );

      showSnackbar("Segnalazione inviata con successo!");
    } else {
      showSnackbar("Seleziona una categoria");
    }
  }

  Padding showSelectedImage() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ClipRect(
        child: Image.file(_image!, width: 150, height: 150, fit: BoxFit.cover),
      ),
    );
  }

  TextFormField buildTextFormField() {
    return TextFormField(
      controller: commentText,
      decoration: const InputDecoration(
        border: UnderlineInputBorder(),
        labelText: 'Commenti',
      ),
    );
  }

  Card cardCategory(int index) {
    return Card(
      color:
          (_selectedCategory == categoriesList[index]["nome"])
              ? Colors.red
              : Colors.white,
      child: Column(
        children: [
          Text(categoriesList[index]["nome"]),
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
    var categories = await db.getData(collection: "categorie_animali");
    setState(() {
      this.categoriesList = categories;
      print(categoriesList);
    });
  }

  void showSubcategoryDialog(List<dynamic> subcategories) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Seleziona sottocategoria"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children:
                subcategories.map((sub) {
                  return ListTile(
                    title: Text(sub),
                    onTap: () {
                      setState(() {
                        _selectedSubcategory = sub;
                        print(_selectedSubcategory);
                      });
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
          ),
        );
      },
    );
  }

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
        "spotted/$fileName.jpg",
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
}
