import 'dart:async';
import 'dart:io';

import 'package:delta_explorer/constants/point.dart';
import 'package:delta_explorer/database/supabase.dart';
import 'package:delta_explorer/diary/TrackPosition.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../util.dart';

class DiaryController {
  final tracker = TrackPosition(); // singleton


  final List<XFile> _images = []; // immagini caricate durante la registrazione
  List<String?> image_paths = []; // path salvati nello storage

  final SupabaseDB _db = SupabaseDB();

  bool isUserLog() {
    return _db.supabase.auth.currentUser != null;
  }

  void deleteImages() {
    _images.clear();
  }

  bool isRecording() {
    return tracker.isRecording();
  }

  getTitleController(){
    return tracker.getTitleController();
  }
  getDescController(){
    return tracker.getDescController();
  }



  Future<void> pickImagesFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> selectedImages = await picker.pickMultiImage();

    if (selectedImages.isNotEmpty) {
      _images.addAll(selectedImages);
    }
  }

  Future<void> pickImageFromCamera() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      _images.add(image);
    }
  }

  List<XFile> getImages() {
    return _images;
  }

  void removeImage(XFile image) {
    _images.remove(image);
  }

  Future<void> startTracking()async {
    await tracker.startTracking();

  }

  void stopTracking() {
    tracker.stopTracking();

  }

  Future<int> addTrip(String titolo, String descrizione) async {
    final percorso = tracker.getPercorso(); // preleva posizioni tracciate
    final distanza = calculateTotalDistanceFromPositions(percorso);

    try {
      final userId = _db.supabase.auth.currentUser!.id;

      final idPercorso = await _db.addPercorso(
        titolo,
        descrizione,
        userId,
        distanza,
      );

      await _db.addCoord(percorso, idPercorso);

      _db.addPoints(
        distanza.toInt() * Points.tripPerKm,
        userId,
        TypePoints.trip,
      );

      return idPercorso;
    } catch (e) {
      print("Errore durante l'aggiunta del viaggio: $e");
      return 0;
    }
  }

  Future<List<String?>> uploadImages(int idPercorso) async {
    for (var image in _images) {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      try {
        File file = File(image.path);
        final String fullPath = await _db.supabase.storage
            .from('trip')
            .upload(
          '$fileName.png',
          file,
          fileOptions: const FileOptions(
            cacheControl: '3600',
            upsert: false,
          ),
        );

        image_paths.add(fullPath);
        _db.addTripImages(idPercorso, fullPath);
      } catch (e) {
        print("Errore durante l'upload di ${image.name}: $e");
        image_paths.add(null);
      }
    }

    return image_paths;
  }

  List<String?> getImagesPaths() {
    return image_paths;
  }
}
