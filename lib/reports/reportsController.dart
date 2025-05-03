import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delta_explorer/constants/point.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

import '../constants/databaseTable.dart';
import '../database/supabase.dart';

class ReportsController {
  final SupabaseDB _db = SupabaseDB();
  bool _canSendReports = true;
  File? _image;
  Position? _position;
  final GoTrueClient _auth = Supabase.instance.client.auth;
  bool _isImagePickerActive = false;
  final ImagePicker _picker = ImagePicker();
  List<Map<String, dynamic>> _categoriesList = [];


  Future<void> loadCategories() async {
      List<Map<String, dynamic>> list = [];
      list = await _db.getData(table: DatabaseTable.reports_category);
      _categoriesList = list;
  }

  Future<String?> uploadImage(File image) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final String fullPath = await _db.supabase.storage
          .from(DatabaseTable.reports)
          .upload(
            '$fileName.png',
            image,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );
      return fullPath;
    } catch (e) {
      return null;
    }
  }  //TODO: spostare nel database???

  Future<Position?> getUserLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _canSendReports = false;

        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse &&
            permission != LocationPermission.always) {
          _canSendReports = false;
          return null;
        }
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      _canSendReports = false;
      return null;
    }
  }

  Future<String?> submitReport(String selectedCategory, File image, TextEditingController commentTextController) async {
    String message ="";

    if (selectedCategory.isNotEmpty) {
      String? imageUrl;

      imageUrl = await uploadImage(image);
      if (imageUrl == null) {
        return ("errore nel caricamento dell'immagine");
      }

      GeoPoint geopoint =
          _position != null
              ? GeoPoint(_position!.latitude, _position!.longitude)
              : GeoPoint(0, 0);
      await _db.addReports(
        imageUrl,
        selectedCategory,
        commentTextController.text,
        geopoint,
        _auth.currentUser?.id
      );

      if(_auth.currentUser!=null){
        addPoints(Points.reports, _auth.currentUser!.id);
        message = "Punti Aggiornati!";
      }



      return ("Segnalazione inviata con successo! $message");
    } else {
      return ("Seleziona una categoria");
    }
  }

  Future<String> updatePosition() async {
    _position = await getUserLocation();
    if (_position == null) {
      return ("GPS disabilitato o permessi non concessi");
    }
    return "";
  }

  bool getCanSendReport() {
    return _canSendReports;
  }

  Future <String> addPoints(int points, String userID) async {
    try {
      await _db.addPoints(points, userID, TypePoints.reports);
      return "Punti Aggiornati";
    }catch(e){
      return "errore: $e";
    }
  }

  File? getImage(){
    return _image;
  }

  Future<String> pickImage() async {
    if (_isImagePickerActive) return ""; // Impedisce duplicazioni

    _isImagePickerActive = true;

    final permissionStatus = await Permission.camera.request();
    if (permissionStatus.isGranted) {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
          _image = File(image.path);
      }
    } else {
      return "Permesso fotocamera negato. Abilitalo nelle impostazioni.";
    }
    _isImagePickerActive = false;
    return "";
  }

  List<Map<String, dynamic>> getCategoryList(){
    return _categoriesList;
  }

}
