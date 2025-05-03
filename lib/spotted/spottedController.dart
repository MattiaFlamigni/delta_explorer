import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delta_explorer/constants/point.dart';
import 'package:delta_explorer/database/supabase.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SpottedController {
  final SupabaseDB _supabase = SupabaseDB();
  final TextEditingController _commentTextController = TextEditingController();

  final GoTrueClient _auth = Supabase.instance.client.auth;

  List<Map<String, dynamic>> categoriesList = [];
  String selectedCategory = "";
  String selectedSubcategory = "";
  File? image;
  bool canSendReports = true;
  bool isImagePickerActive = false;
  int numSpotted = 1;
  Position? position;

  TextEditingController getCommentTextController(){
    return _commentTextController;
  }

  Future<void> loadCategories(
    Function(List<Map<String, dynamic>>) onLoaded,
  ) async {
    var categories = await _supabase.getData(table: "categorie_animali");
    categoriesList = categories;
    onLoaded(categoriesList);
  }

  Future<void> uploadSpot(BuildContext context) async {
    String message = "";
    if (selectedCategory.isEmpty) {
      showSnackbar(context, "Seleziona una categoria");
      return;
    }

    String? imageUrl;
    if (image != null) imageUrl = await uploadImage(image!);
    await updatePosition(context);

    var userID = Supabase.instance.client.auth.currentUser?.id;
    GeoPoint geopoint =
        position != null
            ? GeoPoint(position!.latitude, position!.longitude)
            : GeoPoint(0, 0);

    await _supabase.addSpotted(
      imageUrl ?? "",
      selectedCategory,
      _commentTextController.text,
      selectedSubcategory,
      geopoint,
      userID,
    );

    if (_auth.currentUser != null) {
      message = "Punti Aggiornati!";
      if (image != null) {
        addPoints(
          Points.spottedPhoto,
          _supabase.supabase.auth.currentUser!.id,
        );
      } else {
        addPoints(
          Points.spotted,
          _supabase.supabase.auth.currentUser!.id,
        );
      }
    }

    showSnackbar(context, "Segnalazione inviata con successo! $message");
  }

  Future<String?> uploadImage(File image) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final String fullPath = await _supabase.supabase.storage
        .from('spotted')
        .upload(
          '$fileName.png',
          image,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
        );
    return fullPath;
  }

  Future<void> updatePosition(BuildContext context) async {
    position = await getUserLocation(context);
  }

  Future<Position?> getUserLocation(BuildContext context) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      canSendReports = false;
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        canSendReports = false;
        showSnackbar(
          context,
          "Permessi disabilitati. Consenti per inviare la segnalazione",
        );
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      canSendReports = false;
      return null;
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  void showSnackbar(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  void addPoints(int points, String userID) async {
    await _supabase.addPoints(points, userID, TypePoints.spotted);
  }
}
