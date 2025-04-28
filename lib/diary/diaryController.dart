import 'dart:async';
import 'dart:io';

import 'package:delta_explorer/database/supabase.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../util.dart';

class DiaryController {
  bool _registrando = false;
  final List<XFile> _images =
      []; //lista di immagini che l'utente carica mentre registra viaggio
  final List<Position> _percorso =
      []; //vengono inserite le coordinate in fase di registazione per poi essere salvate sul db

  List<String?> image_paths = []; //lista dei path salvati sullo storage
  Timer? _timer;
  final SupabaseDB _db = SupabaseDB();

  bool isUserLog(){
    return _db.supabase.auth.currentUser!=null;
  }

  void deleteImages() {
    _images.clear();
  }

  bool isRecording() {
    return _registrando;
  }

  void changeStatus() {
    _registrando = !_registrando;
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

  getImages() {
    return _images;
  }

  removeImage(XFile image) {
    _images.remove(image);
  }

  void startTracking() async {
    final permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      print("Permessi non concessi");
      return;
    }

    _timer = Timer.periodic(Duration(seconds: 5), (timer) async {
      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _percorso.add(pos);
      print("Nuova posizione: ${pos.latitude}, ${pos.longitude}");
    });
  }

  void stopTracking() {
    print("stop posizione");
    print(_percorso);
    _timer?.cancel();
  }

  Future<int> addTrip(String titolo, String descrizione) async {
    var distanza = calculateTotalDistanceFromPositions(_percorso);
    try {
      var idPercorso = await _db.addPercorso(
        titolo,
        descrizione,
        _db.supabase.auth.currentUser!.id,
        distanza,
      );
      await _db.addCoord(_percorso, idPercorso);

      return idPercorso;
    } catch (e) {
      print("errore: $e");
      return 0;
    }
  }

  Future<List<String?>> uploadImages(int idPercorso) async {
    for (var image in _images) {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      try {
        // Converti XFile in File usando il suo percorso
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
