import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delta_explorer/constants/point.dart';
import 'package:delta_explorer/database/supabase.dart';
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
  final SupabaseDB _supabase = SupabaseDB();
  final TextEditingController _commentTextController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  List<Map<String, dynamic>> _categoriesList = [];
  String _selectedCategory = "";
  String _selectedSubcategory = "";
  File? _image;
  bool _canSendReports = true;
  bool _isImagePickerActive = false;
  int numSpotted = 1;
  Position? _position;

  @override
  void initState() {
    super.initState();

    loadCategories();
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


  Future<void> loadCategories() async {
    var categories = await _supabase.getData(table: "categorie_animali");
    setState(() => _categoriesList = categories);
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
    await updatePosition();
    var userID = Supabase.instance.client.auth.currentUser?.id;

    GeoPoint geopoint = _position != null
        ? GeoPoint(_position!.latitude, _position!.longitude)
        : GeoPoint(0, 0);


    _supabase.addSpotted(imageUrl ?? "", _selectedCategory, _commentTextController.text, _selectedSubcategory, geopoint,userID);
    showSnackbar("Segnalazione inviata con successo!");

    if(_supabase.supabase.auth.currentUser!=null){
      if(_image!=null) {
        _supabase.addPoints(Points.spottedPhoto, _supabase.supabase.auth.currentUser!.id);
      }else{
        _supabase.addPoints(Points.spotted, _supabase.supabase.auth.currentUser!.id);
      }
    }
  }

  Future<String?> uploadImage(File image) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final String fullPath = await _supabase.supabase.storage.from('spotted').upload(
      '$fileName.png',
      image,
      fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
    );

    return fullPath;
  }

  void showSnackbar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Widget buildCategoryGrid() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3 / 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _categoriesList.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedCategory = _categoriesList[index]["nome"];
              showSubcategoryDialog(_categoriesList[index]["sottocategorie"]);
            });
          },
          child: cardCategory(index),
        );
      },
    );
  }

  Widget buildTextFormField() {
    return TextFormField(
      controller: _commentTextController,
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
        updatePosition();
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
          if(!mounted) return;
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
      color: (_selectedCategory == _categoriesList[index]["nome"]) ? Colors.red : Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(_categoriesList[index]["nome"]),
          Image.asset('assets/${_categoriesList[index]["image_path"]}', width: 50, height: 50),
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
    _position = await getUserLocation();
  }

  Future<Position?> getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Controlla se il GPS è attivo
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _canSendReports = false;
      return null;
    }

    // Controlla i permessi
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _canSendReports = false;
        showSnackbar("permessi disabilitati. Consenti per inviare la segnalazione");
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _canSendReports = false;
      return null;
    }

    // Ottieni la posizione corrente
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

  }
}
