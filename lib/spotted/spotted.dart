import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delta_explorer/database/firebase.dart';
import 'package:delta_explorer/database/supabase.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Spotted extends StatefulWidget {
  const Spotted({super.key});

  @override
  State<Spotted> createState() => _SpottedState();
}

class _SpottedState extends State<Spotted> {
  //final Firebase db = Firebase();
  SupabaseDB supabase = SupabaseDB();
  final TextEditingController commentText = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  List<Map<String, dynamic>> categoriesList = [];
  String _selectedCategory = "";
  String _selectedSubcategory = "";
  File? _image;
  bool _canSendReports = true;
  bool _isImagePickerActive = false;
  int numSpotted = 1;
  Position? position;
  SupabaseDB sup = SupabaseDB();

  @override
  void initState() {
    super.initState();

    loadCategories();
  }

  Future<void> loadCategories() async {
    var categories = await supabase.getData(table: "categorie_animali");
    setState(() => categoriesList = categories);
  }

  Future<void> _pickImage() async {
    if (_isImagePickerActive) return;
    _isImagePickerActive = true;

    Permission.camera.request();
    await Permission.camera.onGrantedCallback(() async {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) setState(() => _image = File(image.path));
    }).onPermanentlyDeniedCallback(() => showSnackbar("Devi concedere i permessi per selezionare una immagine")).request();

    _isImagePickerActive = false;
  }

  Future<void> uploadSpot() async {
    if (_selectedCategory.isEmpty) {
      showSnackbar("Seleziona una categoria");

      return;
    }

    String? imageUrl;
    if (_image != null) imageUrl = await uploadImage(_image!);
    await this.updatePosition();

    GeoPoint geopoint = position != null
        ? GeoPoint(position!.latitude, position!.longitude)
        : GeoPoint(0, 0);


    supabase.addSpotted(imageUrl ?? "", _selectedCategory, commentText.text, _selectedSubcategory, geopoint);
    showSnackbar("Segnalazione inviata con successo!");
  }

  Future<String?> uploadImage(File image) async {


    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final String fullPath = await supabase.supabase.storage.from('spotted').upload(
      '$fileName.png',
      image,
      fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
    );

    return fullPath;



    /*try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageRef = FirebaseStorage.instance.ref().child("spotted/$fileName.jpg");
      UploadTask uploadTask = storageRef.putFile(image);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("Errore nel caricamento: $e");
      return null;
    }*/
  }

  void showSnackbar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Segnala Avvistamento")),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: buildCategoryGrid()),
            const SizedBox(height: 10),
            buildTextFormField(),
            const SizedBox(height: 10),
            buildImagePicker(),
            const SizedBox(height: 10),
            buildCounterRow(),
            const SizedBox(height: 10),
            buildSendButton(),
          ],
        ),
      ),
    );
  }

  Widget buildCategoryGrid() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3 / 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: categoriesList.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedCategory = categoriesList[index]["nome"];
              showSubcategoryDialog(categoriesList[index]["sottocategorie"]);
            });
          },
          child: cardCategory(index),
        );
      },
    );
  }

  Widget buildTextFormField() {
    return TextFormField(
      controller: commentText,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Commenti',
      ),
    );
  }

  Widget buildImagePicker() {
    return Column(
      children: [
        ElevatedButton(onPressed: _pickImage, child: const Text("Scatta una foto")),
        if (_image != null) showSelectedImage(),
      ],
    );
  }

  Widget buildCounterRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(onPressed: () => setState(() => numSpotted = (numSpotted > 1) ? numSpotted - 1 : 1), icon: const Icon(Icons.remove)),
        Text(numSpotted.toString(), style: const TextStyle(fontSize: 24)),
        IconButton(onPressed: () => setState(() => numSpotted++), icon: const Icon(Icons.add)),
      ],
    );
  }

  Widget buildSendButton() {
    return ElevatedButton(
      onPressed: () async {
        this.updatePosition();
        if (_canSendReports) {
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

          await uploadSpot();
          Navigator.pop(context); // Chiude il dialogo di caricamento
          Navigator.pop(context);//torna alla mappa
        } else {
          showSnackbar("Permessi non abilitati - Attivali per inviare");
        }



      },
      child: const Text("Invia Avvistamento"),
    );
  }

  Widget showSelectedImage() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.file(_image!, width: 150, height: 150, fit: BoxFit.cover),
      ),
    );
  }

  Widget cardCategory(int index) {
    return Card(
      color: (_selectedCategory == categoriesList[index]["nome"]) ? Colors.red : Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(categoriesList[index]["nome"]),
          Image.asset('assets/${categoriesList[index]["image_path"]}', width: 50, height: 50),
        ],
      ),
    );
  }

  void showSubcategoryDialog(List<dynamic> subcategories) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Seleziona sottocategoria"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: subcategories.map((sub) => ListTile(
              title: Text(sub),
              onTap: () {
                setState(() => _selectedSubcategory = sub);
                Navigator.pop(context);
              },
            )).toList(),
          ),
        );
      },
    );
  }



  Future<void> updatePosition() async {
    this.position = await this.getUserLocation();
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
