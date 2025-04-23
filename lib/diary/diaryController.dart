import 'package:delta_explorer/database/supabase.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';

class DiaryController{
  bool _registrando = false;
  List<XFile> images = [];
  List<Position> percorso = [];
  Timer? _timer;
  SupabaseDB _db = SupabaseDB();




  bool isRecording(){
    return _registrando;
  }

  void changeStatus(){
    _registrando = !_registrando;
  }

  Future<void> pickImagesFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> selectedImages = await picker.pickMultiImage();

    if (selectedImages.isNotEmpty) {
      images.addAll(selectedImages);
    }
  }

  getImages(){
    return images;
  }

  void startTracking() async {
    final permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      print("Permessi non concessi");
      return;
    }

    _timer = Timer.periodic(Duration(seconds: 5), (timer) async {
      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      percorso.add(pos);
      print("Nuova posizione: ${pos.latitude}, ${pos.longitude}");
    });
  }

  void stopTracking() {
    print("stop posizione");
    print(percorso);
    _timer?.cancel();
  }

  Future<String>addTrip(String titolo, String descrizione) async{
    try{
      var idPercorso =  await _db.addPercorso(titolo, descrizione, _db.supabase.auth.currentUser!.id);
      await _db.addCoord(percorso, idPercorso);
      return "ok";
    }catch(e){
      print("errore: $e");
      return "errore $e";
    }

  }




}