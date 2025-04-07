import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:vector_math/vector_math_64.dart';

class CompassArrowScreen extends StatefulWidget {
  final double targetLat;
  final double targetLon;

  const CompassArrowScreen({
    super.key,
    required this.targetLat,
    required this.targetLon,
  });

  @override
  State<CompassArrowScreen> createState() => _CompassArrowScreenState();
}

class _CompassArrowScreenState extends State<CompassArrowScreen> {
  CameraController? _cameraController;
  double heading = 0;
  double bearing = 0;
  Position? _currentPosition;
  late CameraDescription _camera; // Aggiunto per memorizzare la camera

  @override
  void initState() {
    super.initState();
    _initCamera(); //inizializzo la camera qui dentro.
    _initLocation();
    _initCompass();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    _camera = cameras.firstWhere((c) => c.lensDirection == CameraLensDirection.back);
    _cameraController = CameraController(_camera, ResolutionPreset.low);
    await _cameraController!.initialize();
    setState(() {});
  }

  Future<void> _initLocation() async {
    await Geolocator.requestPermission();

    // Ascolta gli aggiornamenti della posizione
    Geolocator.getPositionStream().listen((Position position) {
      setState(() {
        _currentPosition = position;
        if (_currentPosition != null) {
          // Calcola e aggiorna il bearing quando la posizione cambia
          bearing = _calculateBearing(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
            widget.targetLat,
            widget.targetLon,
          );
        }
      });
    });
  }

  void _initCompass() {
    FlutterCompass.events?.listen((event) {
      setState(() {
        heading = event.heading ?? 0;
      });
    });
  }

  double _calculateBearing(double lat1, double lon1, double lat2, double lon2) {
    final dLon = radians(lon2 - lon1);
    lat1 = radians(lat1);
    lat2 = radians(lat2);
    final y = sin(dLon) * cos(lat2);
    final x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
    return (degrees(atan2(y, x)) + 360) % 360;
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_currentPosition == null) {
      return const Center(child: CircularProgressIndicator());
    }

    double angle = (bearing - heading + 360) % 360;

    return Scaffold(
      body: Stack(
        children: [
          CameraPreview(_cameraController!),
          Center(
            child: Transform.rotate(
              angle: radians(angle),
              child: const Icon(
                Icons.navigation,
                size: 100,
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 20,
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Text(
                'Destinazione: ${bearing.toStringAsFixed(1)}°\nBussola: ${heading.toStringAsFixed(1)}°',
              ),
            ),
          )
        ],
      ),
    );
  }
}