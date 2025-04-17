import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delta_explorer/constants/point.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../database/supabase.dart';

class ReportsController {
  final SupabaseDB _supabase = SupabaseDB();
  bool _canSendReports = true;
  Position? _position;
  final GoTrueClient _auth = Supabase.instance.client.auth;


  Future<List<Map<String, dynamic>>> loadCategories() async {

      return await _supabase.getData(table: "reports_category");
  }

  Future<String?> uploadImage(File image) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final String fullPath = await _supabase.supabase.storage
          .from('reports')
          .upload(
            '$fileName.png',
            image,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );
      return fullPath;
    } catch (e) {
      return null;
    }
  }

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
      await _supabase.addReports(
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
      await _supabase.addPoints(points, userID, TypePoints.reports);
      return "Punti Aggiornati";
    }catch(e){
      return "errore: $e";
    }
  }
}
