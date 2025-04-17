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
    var list = await controller.loadCategories();
    setState(() {
      _categoriesList = list;
    });
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
}
