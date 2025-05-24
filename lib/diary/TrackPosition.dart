import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';

class TrackPosition {
  // Singleton
  static final TrackPosition _instance = TrackPosition._internal();
  factory TrackPosition() => _instance;
  TrackPosition._internal();

  final List<Position> _percorso = [];
  StreamSubscription<Position>? _positionStream;
  bool _registrando = false;
  final TextEditingController titoloController = TextEditingController();
  final TextEditingController descrizioneController = TextEditingController();


  getTitleController(){
    return titoloController;
  }
  getDescController(){
    return descrizioneController;
  }

  Future<void> startTracking() async {
    if (_registrando) return;
    _percorso.clear();
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print("Servizi di localizzazione disabilitati");
      return Future.error("GPS disattivato");

      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        print("Permessi di localizzazione non concessi");
        return Future.error("Permessi di localizzazione non concessi");
      }
    }

    _registrando = true;

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // metri
    );

    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        //distanceFilter: 5, // aggiorna solo se ci si sposta di almeno 5 metri
      ),
    ).listen((Position position) {
      print('Posizione: ${position.latitude}, ${position.longitude}');
      _percorso.add(position); // salva le posizioni
    });
  }

  Future<void> stopTracking() async {
    if (!_registrando) return;

    await _positionStream?.cancel();
    _positionStream = null;
    _registrando = false;
    print("Tracking interrotto. Percorso registrato: $_percorso");
  }

  bool isRecording() => _registrando;

  List<Position> getPercorso() => List.unmodifiable(_percorso);
}
