import 'dart:io';

import 'package:delta_explorer/components/login_request.dart';
import 'package:delta_explorer/diary/diary_controller.dart';
import 'package:delta_explorer/diary/trip.dart';
import 'package:flutter/material.dart';

class Diary extends StatefulWidget {
  const Diary({super.key});

  @override
  State<Diary> createState() => _DiaryState();
}

class _DiaryState extends State<Diary> {
  DiaryController controller = DiaryController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (controller.isUserLog()) {
      return Scaffold(
        body: Container(
          // Sfondo leggero
          color: Colors.grey[100],
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      drawTitlePage(),
                      drawForm(),
                      const SizedBox(height: 24),
                      Text(
                        "Foto della tua avventura",
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      _drawImagesGrid(),
                      const SizedBox(height: 24),
                      drawRowButton(),
                      const SizedBox(height: 32),
                      _drawStatusIndicator(),
                      const SizedBox(height: 24),
                      _drawToggleButton(),
                      SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
              _drawMyTripsButton(context),
            ],
          ),
        ),
      );
    } else {
      return RequestLogin(); //se utente non loggato invita a farlo
    }
  }

  Widget drawRowButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _drawAddPhotoButton("Scatta Foto", true),
        _drawAddPhotoButton("Aggiungi Foto", false),
      ],
    );
  }

  Widget drawTitlePage() {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(Icons.flight_takeoff, size: 32, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          "Nuova Avventura",
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget drawForm() {
    return Column(
      children: [
        const SizedBox(height: 32),
        _drawTextField(
          controller.getTitleController(),
          "Titolo dell'avventura",
          Icons.title,
        ),
        const SizedBox(height: 16),
        _drawTextField(
          controller.getDescController(),
          "Racconta la tua avventura...",
          Icons.description,
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _drawTextField(
    TextEditingController controller,
    String labelText,
    IconData icon, {
    int? maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon, color: Colors.grey.shade600),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
      ),
    );
  }

  Widget _drawImagesGrid() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          controller.getImages().map<Widget>((img) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    Image.file(
                      File(img.path),
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      top: -5,
                      right: -5,
                      child: IconButton(
                        icon: const Icon(
                          Icons.close,
                          size: 18,
                          color: Colors.white,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.redAccent.withOpacity(0.8),
                        ),
                        onPressed: () {
                          controller.removeImage(img);
                          setState(() {});
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _drawAddPhotoButton(String labelText, bool camera) {
    return ElevatedButton.icon(
      onPressed: () async {
        if (camera) {
          try {
            await controller.pickImageFromCamera();
          } catch (e) {
            _showSnackbar(e.toString());
          }
        } else {
          try {
            await controller.pickImagesFromGallery();
          } catch (e) {
            showSnackbar(e.toString());
          }
        }
        setState(() {});
      },
      icon: Icon(
        camera ? Icons.camera_alt : Icons.add_photo_alternate,
        size: 20,
      ),
      label: Text(labelText),
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void showSnackbar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Widget _drawStatusIndicator() {
    final isRecording = controller.isRecording();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isRecording ? Colors.greenAccent[100] : Colors.grey[200],
      ),
      child: Row(
        children: [
          Icon(
            isRecording
                ? Icons.radio_button_checked
                : Icons.pause_circle_outline,
            color: isRecording ? Colors.greenAccent[400] : Colors.grey.shade600,
            size: 28,
          ),
          const SizedBox(width: 12),
          Text(
            isRecording
                ? "Registrazione in corso..."
                : "Registrazione in pausa",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color:
                  isRecording ? Colors.greenAccent[700] : Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawToggleButton() {
    final isRecording = controller.isRecording();
    return ElevatedButton.icon(
      onPressed: () async {
        if (controller.getTitleController().text.isEmpty) {
          _showSnackbar("Aggiungi il titolo");
          return;
        }
        setState(() {});

        if (isRecording) {
          controller.stopTracking();
          var idPercorso = await controller.addTrip(
            controller.getTitleController().text,
            controller.getDescController().text,
          );
          controller.uploadImages(idPercorso);
          controller.getTitleController().clear();
          controller.getDescController().clear();
          controller.deleteImages();
          setState(() {});
        } else {
          try {
            await controller.startTracking();
          } catch (e) {
            _showSnackbar(e.toString());
          }
        }

        setState(() {});
      },
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isRecording
                ? Colors.redAccent
                : Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: const TextStyle(fontSize: 18),
        elevation: 3,
      ),
      icon: Icon(isRecording ? Icons.stop : Icons.play_arrow, size: 24),
      label: Text(
        isRecording ? "Termina e Salva Viaggio" : "Avvia Nuovo Viaggio",
      ),
    );
  }

  Widget _drawMyTripsButton(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: ElevatedButton.icon(
          // Usa FilledButton.tonal
          onPressed: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (context) => Trip()));
          },
          icon: const Icon(Icons.history),
          label: const Text("I Miei Viaggi"),
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ),
    );
  }

  void _showSnackbar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
