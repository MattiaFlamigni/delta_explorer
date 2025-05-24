import 'dart:async';
import 'dart:io';

import 'package:delta_explorer/constants/point.dart';
import 'package:delta_explorer/database/supabase.dart';
import 'package:delta_explorer/diary/TrackPosition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../util.dart';

class DiaryController {
  final _tracker = TrackPosition(); // singleton

  final List<XFile> _images = []; // immagini caricate durante la registrazione
  List<String?> _image_paths = []; // path salvati nello storage

  final SupabaseDB _db = SupabaseDB();

  bool isUserLog() {
    return _db.supabase.auth.currentUser != null;
  }

  void deleteImages() {
    _images.clear();
  }

  bool isRecording() {
    return _tracker.isRecording();
  }

  getTitleController() {
    return _tracker.getTitleController();
  }

  getDescController() {
    return _tracker.getDescController();
  }

  Future<String> pickImagesFromGallery() async {
    final ImagePicker picker = ImagePicker();

    if(await Permission.photos.isGranted) {
      final List<XFile> selectedImages = await picker.pickMultiImage();

      if (selectedImages.isNotEmpty) {
        _images.addAll(selectedImages);
      }
    }else{
      return Future.error("permessi non abilitati");
    }

    return "";
  }

  Future<String> pickImageFromCamera() async {
    final ImagePicker picker = ImagePicker();

    if (await Permission.camera.isGranted) {
      final XFile? image = await picker.pickImage(source: ImageSource.camera);

      if (image != null) {
        _images.add(image);
      }
    }else{
      return Future.error("Permessi fotocamera non abilitati");
    }
    return "";
  }

  List<XFile> getImages() {
    return _images;
  }

  void removeImage(XFile image) {
    _images.remove(image);
  }

  Future<void> startTracking() async {
    try {
      await _tracker.startTracking();
    } catch (_) {}
  }

  void stopTracking() {
    _tracker.stopTracking();
  }

  Future<int> addTrip(String titolo, String descrizione) async {
    final percorso = _tracker.getPercorso(); // preleva posizioni tracciate
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

        _image_paths.add(fullPath);
        _db.addTripImages(idPercorso, fullPath);
      } catch (e) {
        print("Errore durante l'upload di ${image.name}: $e");
        _image_paths.add(null);
      }
    }

    return _image_paths;
  }

  List<String?> getImagesPaths() {
    return _image_paths;
  }
}
