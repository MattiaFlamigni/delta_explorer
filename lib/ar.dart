
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:vector_math/vector_math_64.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final camera = cameras.firstWhere((c) => c.lensDirection == CameraLensDirection.back);

  runApp(MyApp(camera: camera));
}

class MyApp extends StatelessWidget {
  final CameraDescription camera;

  const MyApp({super.key, required this.camera});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CompassArrowScreen(camera: camera),
    );
  }
}

class CompassArrowScreen extends StatefulWidget {
  final CameraDescription camera;

  const CompassArrowScreen({super.key, required this.camera});

  @override
  State<CompassArrowScreen> createState() => _CompassArrowScreenState();
}

class _CompassArrowScreenState extends State<CompassArrowScreen> {
  CameraController? _cameraController;
  double heading = 0;
  double bearing = 0;

  // Coordinate destinazione (es. un punto nel Delta del Po)
  final double targetLat = 40.1171;
  final double targetLon = -4.8718;

  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _initCamera();
    _initLocation();
    _initCompass();
  }

  Future<void> _initCamera() async {
    _cameraController = CameraController(widget.camera, ResolutionPreset.low);
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
          bearing = _calculateBearing(_currentPosition!.latitude, _currentPosition!.longitude, targetLat, targetLon);
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
              child: Icon(
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