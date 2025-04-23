import 'dart:io';

import 'package:delta_explorer/diary/diaryController.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Diary extends StatefulWidget {
  const Diary({super.key});

  @override
  State<Diary> createState() => _DiaryState();
}

class _DiaryState extends State<Diary> {
  DiaryController controller = DiaryController();
  final TextEditingController titoloController = TextEditingController();
  final TextEditingController descrizioneController = TextEditingController();
  List<String> immagini = [
    'https://upload.wikimedia.org/wikipedia/commons/5/59/Baltimore_Oriole_by_Dan_Pancamo.jpg',
    'https://upload.wikimedia.org/wikipedia/commons/3/33/Picnic_table_and_trash.jpg',
  ];




  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: SingleChildScrollView(
          child: Column(
            children: [
              drawTextBox(titoloController, "Titolo"),
              const SizedBox(height: 16),
              drawTextBox(descrizioneController, "Descrizione"),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: controller.getImages().map<Widget>((img) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(img.path),
                      height: 120,
                      width: 120,
                      fit: BoxFit.cover,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),
              drawElevatedButton(Icons.add_photo_alternate, "Aggiungi foto", () async {await controller.pickImagesFromGallery(); setState(() {

              });}),
              const SizedBox(height: 16),
              drawStatus(),
              const SizedBox(height: 24),
              drawToggleStatus()
            ],
          ),
        ),
      ),
    );
  }


  Widget drawTextBox(TextEditingController controller, String labelText){
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
      ),
    );
  }

  Widget drawElevatedButton(IconData icon, String label, Function() onPressed){
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurple.shade100,
        foregroundColor: Colors.black,
      ),
    );
  }

  Widget drawStatus(){
    return Text(
      controller.isRecording() ? "[Registrando percorso]" : "[In pausa]",
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: controller.isRecording() ? Colors.green : Colors.grey,
      ),
    );
  }

  Widget drawToggleStatus(){
    return ElevatedButton(
      onPressed: () {
        if(titoloController.text.isEmpty){
          showSnackbar("Aggiungi il titolo");
          return;
        }


        setState(() {

          if(controller.isRecording()){ //la registrazione si ferma
            controller.stopTracking();
            controller.addTrip(titoloController.text, descrizioneController.text);
          }else{
            controller.startTracking();
          }

          controller.changeStatus();
        });
      },
      style: ElevatedButton.styleFrom(

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),
      child: Text(
        controller.isRecording() ? "Termina registrazione" : "Avvia registrazione",
        style: const TextStyle(fontSize: 16),
      ),
    );
  }


  void showSnackbar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: Colors.blueAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
