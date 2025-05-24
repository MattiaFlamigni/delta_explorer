
import 'package:delta_explorer/database/supabase.dart';
import 'package:delta_explorer/discoverPoi/discover.dart';
import 'package:delta_explorer/lens/lens.dart';
import 'package:delta_explorer/reports/reports.dart';
import 'package:delta_explorer/spotted/spotted.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:permission_handler/permission_handler.dart';

import '../ar.dart';

//TODO: AGGIUNGERE IMMAGINI AI BOTTOMSHEET => IMMAGINI RELATIVI POI

class Maps extends StatefulWidget {
  const Maps({super.key});

  @override
  State<Maps> createState() => _MapsState();
}

class _MapsState extends State<Maps> {
  late MapController _mapController;
  final SupabaseDB _supabaseDB = SupabaseDB();
  bool _isReportConfirmationPressed = false;
  List<Map<String, dynamic>> _poiList = [];
  List<Map<String, dynamic>> _reportList = [];
  Set<String> _selectedCategories = {};
  Set<String> _allCategories = {};
  bool canLocate = false;

  @override
  void initState() {
    super.initState();


    _initializeMapController();
    _loadInitialData();
    _setupMapTapListener();
    initPosition().then((_){setState(() {

    });});

  }

  @override
  Widget build(BuildContext context) {

    return
      Scaffold(
      appBar: AppBar(title: const Text("Mappa Delta del Po")),
      body: Stack(
        children: [




          Positioned.fill(child: _buildMap()),
          if(canLocate)
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: _buildFilterRow(),
          ),
        ],
      ),
      floatingActionButton: Wrap(
        alignment: WrapAlignment.center,
        spacing: 20,
        children: [
          if(canLocate)_buildFloatingActionButton(Icons.pets, "avvistamento!", const Spotted()),
          if(canLocate)_buildFloatingActionButton(Icons.report, "segnalazione", const Reports()),
          if(canLocate)_buildFloatingActionButton(Icons.report, "scopri", const Lens()),
          if(canLocate)_buildFloatingActionButton(Icons.place_rounded, "POI", const Discover()),
        ],
      ),
    );
  }







  
  
  Future<bool>initPosition() async {
    if(await Permission.location.isGranted){
      canLocate = true;
      return true;
    }else{
     return false;
    }
  }


  void _initializeMapController() {
    _mapController = MapController(
      initPosition:  GeoPoint(latitude: 45.0639, longitude: 12.2777),
      areaLimit: const BoundingBox(east: 12.5, north: 45.3, south: 44.8, west: 11.8),
    );
  }

  void _loadInitialData() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(seconds: 1));
      await _loadPOIAndReports();
      _selectedCategories.addAll(_allCategories);
      await _addPOIsAndReportsToMap();
    });
  }

  void _setupMapTapListener() {
    _mapController.listenerMapSingleTapping.addListener(() async {
      final tappedPoint = _mapController.listenerMapSingleTapping.value;
      if (tappedPoint != null) {
        _handleMapTap(tappedPoint);
      }
    });
  }

  Future<void> _loadPOIAndReports() async {
    final poiData = await _supabaseDB.getData();
    final reportData = await _supabaseDB.getTodaySpotted();
    setState(() {
      _poiList = poiData;
      _allCategories = _poiList.map((poi) => poi["category"] as String).toSet();
      _reportList = reportData;
    });
  }

  Future<void> _addPOIsAndReportsToMap() async {
    await _mapController.removeMarkers(await _mapController.geopoints);

    for (final poi in _poiList) {
      if (poi.containsKey("location") && _selectedCategories.contains(poi["category"])) {
        final geoPoint = GeoPoint(
          latitude: poi["location"]["latitude"] as double,
          longitude: poi["location"]["longitude"] as double,
        );
        await _mapController.addMarker(
          geoPoint,
          markerIcon: const MarkerIcon(
            iconWidget: Icon(Icons.place_outlined, color: Colors.red, size: 30),
          ),
        );
      }
    }

    for (final report in _reportList) {
      if (report.containsKey("position") && report["position"] is Map) {
        final position = report["position"] as Map;
        if (position.containsKey("lat") && position.containsKey("lng")) {
          final latitude = position["lat"] as double?;
          final longitude = position["lng"] as double?;
          if (latitude != null && longitude != null) {
            final geoPoint = GeoPoint(latitude: latitude, longitude: longitude);
            try {
              await _mapController.addMarker(
                geoPoint,
                markerIcon: const MarkerIcon(
                  iconWidget: Icon(Icons.place_outlined, color: Colors.blue, size: 30),
                ),
              );
            } catch (e) {
              print("Errore durante l'aggiunta del marker: $e");
            }
          } else {
            print("Errore: Coordinate nulle per la segnalazione: $report");
          }
        } else {
          print("Errore: Formato coordinate errato per la segnalazione: $report");
        }
      } else {
        print("Errore: Posizione non trovata per la segnalazione: $report");
      }
    }
    setState(() {});
  }

  void _handleMapTap(GeoPoint tappedPoint) {
    for (final poi in _poiList) {
      final poiLocation = poi["location"];
      if (poiLocation != null) {
        final geoPoint = GeoPoint(
          latitude: poiLocation["latitude"] as double,
          longitude: poiLocation["longitude"] as double,
        );
        if (_isSameLocation(geoPoint, tappedPoint)) {
          _showPoiDetailsBottomSheet(poi, geoPoint);
          return;
        }
      }
    }

    for (final report in _reportList) {
      if (report.containsKey("position") && report["position"] is Map) {
        final position = report["position"] as Map;
        final latitude = position["lat"] as double?;
        final longitude = position["lng"] as double?;
        if (latitude != null && longitude != null) {
          final geoPoint = GeoPoint(latitude: latitude, longitude: longitude);
          if (_isSameLocation(geoPoint, tappedPoint)) {
            _showReportDetailsBottomSheet(report);
            return;
          }
        }
      }
    }
  }

  void _showPoiDetailsBottomSheet(Map<String, dynamic> poi, GeoPoint geoPoint) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CompassArrowScreen(
                        targetLat: geoPoint.latitude,
                        targetLon: geoPoint.longitude,
                      ),
                    ),
                  );
                },
                child: const Text("naviga in AR"),
              ),
              Text(
                poi["title"] as String,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(poi["description"] as String),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Chiudi"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showReportDetailsBottomSheet(Map<String, dynamic> report) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          maxChildSize: 0.9,
          builder: (_, controller) => Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SingleChildScrollView(
              controller: controller,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  Text(
                    "Dettagli Segnalazione",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey[800],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      "https://cvperzyahqhkdcjjtqvm.supabase.co/storage/v1/object/public/${report["image_path"]}",
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 200,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text("Tipologia"),
                    subtitle: Text(
                      report["type"] as String? ?? "N/A",
                      style: const TextStyle(fontSize: 16),
                    ),
                    leading: const Icon(Icons.category, color: Colors.blueGrey),
                  ),
                  const Divider(height: 32),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text("Commento"),
                    subtitle: Text(
                      report["comment"] as String? ?? "Nessun commento disponibile",
                      style: const TextStyle(fontSize: 16),
                    ),
                    leading: const Icon(Icons.comment, color: Colors.blueGrey),
                  ),
                  const Divider(height: 32),
                  Row(
                    children: [
                      const Icon(Icons.verified, color: Colors.green),
                      const SizedBox(width: 8),
                      const Text(
                        "Stato verifica:",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "${report["verified"]}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  _buildConfirmReportButton(report["id"] as int),
                  const SizedBox(height: 16),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      label: const Text("Chiudi"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey[600],
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }


  Widget _buildConfirmReportButton(int reportID) {

    return Center(
      child: ElevatedButton.icon(
        onPressed: () {
          setState(() {
            _isReportConfirmationPressed = !_isReportConfirmationPressed;
          });
          _supabaseDB.incrementVerifiedReport(reportID);
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Segnalazione confermata con successo"),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );

        },
        icon: const Icon(Icons.check_circle, color: Colors.white),
        label: Text(
          _isReportConfirmationPressed ? "segnalazione inviata" : "Conferma segnalazione",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          shadowColor: Colors.green.withOpacity(0.3),
          elevation: 5,
        ),
      ),
    );
  }

  bool _isSameLocation(GeoPoint p1, GeoPoint p2) {
    const double threshold = 0.01;
    return (p1.latitude - p2.latitude).abs() < threshold &&
        (p1.longitude - p2.longitude).abs() < threshold;
  }

  Widget _buildFilterRow() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _allCategories.length,
        itemBuilder: (BuildContext context, int index) {
          final category = _allCategories.elementAt(index);
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              label: Text(category),
              selected: _selectedCategories.contains(category),
              onSelected: (bool value) {
                setState(() {
                  if (value) {
                    _selectedCategories.add(category);
                  } else {
                    _selectedCategories.remove(category);
                  }
                  _addPOIsAndReportsToMap();
                });
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildFloatingActionButton(IconData iconData, String label, Widget pageToNav) {
    return FloatingActionButton.extended(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => pageToNav),
        );
      },
      icon: Icon(iconData, size: 24),
      label: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /*Widget _buildMap() {

    return canLocate ?
     OSMFlutter(
      controller: _mapController,
      osmOption: OSMOption(
        userTrackingOption: const UserTrackingOption(
          enableTracking: true,
          unFollowUser: true,
        ),
        zoomOption: const ZoomOption(
          initZoom: 10,
          minZoomLevel: 8,
          maxZoomLevel: 16,
          stepZoom: 1.0,
        ),
        userLocationMarker: UserLocationMaker(
          personMarker: MarkerIcon(
            icon: Icon(
              Icons.location_history_rounded,
              color: Colors.blue,
              size: 48,
            ),
          ),
          directionArrowMarker: MarkerIcon(
            icon: Icon(Icons.gps_fixed, size: 48),
          ),
        ),
        roadConfiguration: const RoadOption(roadColor: Colors.yellowAccent),
      ),
    ): Text("No");
  }*/


  Widget _buildMap() {
    if (canLocate) {
      return OSMFlutter(
        controller: _mapController,
        osmOption: OSMOption(
          userTrackingOption: const UserTrackingOption(
            enableTracking: true,
            unFollowUser: true,
          ),
          zoomOption: const ZoomOption(
            initZoom: 10,
            minZoomLevel: 8,
            maxZoomLevel: 16,
            stepZoom: 1.0,
          ),
          userLocationMarker: UserLocationMaker(
            personMarker: MarkerIcon(
              icon: Icon(
                Icons.location_history_rounded,
                color: Colors.blue,
                size: 48,
              ),
            ),
            directionArrowMarker: MarkerIcon(
              icon: Icon(Icons.gps_fixed, size: 48),
            ),
          ),
          roadConfiguration: const RoadOption(roadColor: Colors.yellowAccent),
        ),
      );
    } else {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off, size: 80, color: Colors.redAccent),
            SizedBox(height: 16),
            Text(
              "Permessi di localizzazione disabilitati",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              "Abilita la localizzazione per usare la mappa.",
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),

            SizedBox(height: 10),
            OutlinedButton(
              child: Text("Riprova"),
              onPressed: () async {
                // Richiama i permessi o ricontrolla
                if(await Permission.location.isGranted){
                  setState(() {
                    canLocate=true;
                  });
                }
              },
            ),
          ],
        ),
      );
    }
  }




}