import 'dart:io';

import 'package:delta_explorer/database/firebase.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

/*TODO: GESTIRE CARICAMENTO FOTO*/


class Reports extends StatefulWidget {
  const Reports({super.key});

  @override
  State<Reports> createState() => _ReportsState();
}

class _ReportsState extends State<Reports> {
  //final supabase = Supabase.instance.client;
  Firebase db = Firebase();
  List<Map<String, dynamic>> categoriesList = List.empty();
  TextEditingController commentText = TextEditingController();
  String selectedCategory = ""; //contiene la categoria selezionata
  File? _image; // Variabile per immagazzinare l'immagine selezionata

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
                if (selectedCategory.isNotEmpty) {


                  db.addReports("", selectedCategory,
                    commentText.text,);
                } else {
                  this.showSnackbar("Seleziona una categoria");
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
    Permission.camera.request();
    await Permission.camera
        .onDeniedCallback(() {})
        .onGrantedCallback(() async {
          final XFile? image = await _picker.pickImage(
            source: ImageSource.gallery,
          );
          if (image != null) {
            setState(() {
              _image = File(image.path); // Salva il file immagine
            });
          }
        })
        .onPermanentlyDeniedCallback(() {
          this.showSnackbar("Devi concedere i permessi per selezionare una immagine");
        })
        .request();
  }













  showSnackbar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
      ),
    );
  }
}
