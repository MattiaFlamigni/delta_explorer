import 'dart:io';
import 'package:delta_explorer/diary/diaryController.dart';
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Nuova Avventura", style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  _drawTextField(titoloController, "Titolo dell'avventura", Icons.title),
                  const SizedBox(height: 16),
                  _drawTextField(descrizioneController, "Racconta la tua avventura...", Icons.description, maxLines: 3),
                  const SizedBox(height: 24),
                  Text("Foto della tua avventura", style: theme.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  _drawImagesGrid(),
                  const SizedBox(height: 24),
                  _drawAddPhotoButton(),
                  const SizedBox(height: 32),
                  _drawStatusIndicator(),
                  const SizedBox(height: 24),
                  _drawToggleButton(),
                  SizedBox(height: 80), // spazio per il bottone in basso
                ],
              ),
            ),
          ),
          _drawMyTripsButton(context),
        ],
      ),
    );
  }

  Widget _drawTextField(TextEditingController controller, String labelText, IconData icon, {int? maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon, color: Colors.grey.shade600),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
        ),
      ),
    );
  }

  Widget _drawImagesGrid() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: controller.getImages().map<Widget>((img) {
        return ClipRRect(
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
                  icon: const Icon(Icons.close, size: 18, color: Colors.white),
                  style: IconButton.styleFrom(backgroundColor: Colors.redAccent.withOpacity(0.8)),
                  onPressed: () {
                    controller.removeImage(img);
                    setState(() {

                    });
                  },
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _drawAddPhotoButton() {
    return ElevatedButton.icon(
      onPressed: () async {
        await controller.pickImagesFromGallery();
        setState(() {});
      },
      icon: const Icon(Icons.add_photo_alternate),
      label: const Text("Aggiungi Foto"),
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _drawStatusIndicator() {
    final isRecording = controller.isRecording();
    return Row(
      children: [
        Icon(isRecording ? Icons.radio_button_checked : Icons.pause_circle_outline,
            color: isRecording ? Colors.greenAccent[400] : Colors.grey.shade600, size: 28),
        const SizedBox(width: 8),
        Text(
          isRecording ? "Registrazione in corso..." : "Registrazione in pausa",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isRecording ? Colors.greenAccent[400] : Colors.grey.shade800,
          ),
        ),
      ],
    );
  }

  Widget _drawToggleButton() {
    final isRecording = controller.isRecording();
    return ElevatedButton(
      onPressed: () {
        if (titoloController.text.isEmpty) {
          _showSnackbar("Aggiungi il titolo");
          return;
        }
        setState(() {
          if (isRecording) {
            controller.stopTracking();
            controller.addTrip(titoloController.text, descrizioneController.text);
          } else {
            controller.startTracking();
          }
          controller.changeStatus();
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isRecording ? Colors.redAccent : Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: const TextStyle(fontSize: 18),
      ),
      child: Text(isRecording ? "Termina e Salva Viaggio" : "Avvia Nuovo Viaggio"),
    );
  }

  Widget _drawMyTripsButton(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: OutlinedButton.icon(
          onPressed: () {
            // Vai alla pagina dei viaggi passati
            print("Vai alla pagina dei miei viaggi");
          },
          icon: const Icon(Icons.history),
          label: const Text("I Miei Viaggi"),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Theme.of(context).colorScheme.primary),
            foregroundColor: Theme.of(context).colorScheme.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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