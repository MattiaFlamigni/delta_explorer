import 'package:delta_explorer/database/firebase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';

import '../../reports/reports.dart';
import '../spotted/spotted.dart';

/*TODO: AGGIUNGERE IMMAGINI AI BOTTOMSHEET => IMMAGINI RELATIVI POI*/

class Maps extends StatefulWidget {
  const Maps({super.key});

  @override
  State<Maps> createState() => _MapsState();
}

class _MapsState extends State<Maps> {
  late MapController controller;
  Firebase firebase = Firebase();

  List<Map<String, dynamic>> poiListD = List.empty();
  List<Map<String, dynamic>> spottedList = List.empty();
  Set<String> selectedCategories = {};
  Set<String> categories = {};

  @override
  void initState() {
    super.initState();

    //firebase.addPOIs();

    controller = MapController(
      initPosition: GeoPoint(latitude: 45.0639, longitude: 12.2777),
      // Delta del Po
      areaLimit: BoundingBox(east: 12.5, north: 45.3, south: 44.8, west: 11.8),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(
        Duration(seconds: 1),
      ); // Aspetta che la mappa sia caricata
      await this.loadPOI(); //load poi
      selectedCategories.addAll(categories);
      await addPOIs(); // Aggiunge i POI
      print(poiListD);

      // 🔥 Verifica se il listener è stato correttamente impostato
      controller.listenerMapSingleTapping.addListener(() async {
        var tappedPoint = controller.listenerMapSingleTapping.value;
        if (tappedPoint != null) {
          print(
            "Hai toccato: ${tappedPoint.latitude}, ${tappedPoint.longitude}",
          );
          _handleMarkerTap(tappedPoint);
        }
      });

      print("Listener attivato");
    });
  }

  void _handleMarkerTap(GeoPoint tappedPoint) {

    for (var poi in poiListD) {
      GeoPoint geoPoint = GeoPoint(
        latitude: poi["location"].latitude,
        longitude: poi["location"].longitude,
      );

      if (_isSameLocation(geoPoint, tappedPoint)) {


        showModalBottomSheet(
          context: context,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (context) {
            return Container(
              width: double.infinity, // Occupa tutta la larghezza disponibile
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                // Allinea il testo a sinistra
                children: [
                  Text(
                    poi["title"],
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(poi["description"]),
                  SizedBox(height: 20),
                  Center(
                    // Per centrare il pulsante
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("Chiudi"),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }
    }


    for (var poi in spottedList) {
      GeoPoint geoPoint = GeoPoint(
        latitude: poi["location"].latitude,
        longitude: poi["location"].longitude,
      );

      if (_isSameLocation(geoPoint, tappedPoint)) {


        showModalBottomSheet(
          context: context,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (context) {
            return Container(
              width: double.infinity, // Occupa tutta la larghezza disponibile
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                // Allinea il testo a sinistra
                children: [
                  Text(
                    poi["category"],
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(poi["subCategory"]),
                  SizedBox(height: 20),
                  Center(
                    // Per centrare il pulsante
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("Chiudi"),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }
    }
  }

  // Controlla se due punti sono molto vicini
  bool _isSameLocation(GeoPoint p1, GeoPoint p2) {
    //const double threshold = 0.0001; // Soglia per considerare due punti uguali
    const double threshold = 0.01;
    return (p1.latitude - p2.latitude).abs() < threshold &&
        (p1.longitude - p2.longitude).abs() < threshold;
  }

  Future<void> addPOIs() async {
    controller.removeMarkers(await controller.geopoints);

    /*List<GeoPoint> poiList = [
      GeoPoint(latitude: 45.08, longitude: 12.29), // Esempio POI 1
      GeoPoint(latitude: 45.02, longitude: 12.25), // Esempio POI 2
    ];*/

    for (var poi in poiListD) {
      if (poi.containsKey("location")) {
        if (selectedCategories.contains(poi["category"])) {
          GeoPoint geoPoint = GeoPoint(
            latitude: poi["location"].latitude,
            longitude: poi["location"].longitude,
          );

          await controller.addMarker(
            geoPoint,

            markerIcon: MarkerIcon(
              iconWidget: Transform.rotate(
                angle: 3.1416,
                // 180 gradi in radianti, altrimenti viene capovolta....
                child: Icon(Icons.place_outlined, color: Colors.red, size: 30),
              ),
            ),
          );

          setState(() {});
        }
      } else {
        print("Errore: il POI non contiene coordinate valide.");
      }
    }


    for (var spotted in spottedList) {
      if (spotted.containsKey("category")) {
        if (true) {
          GeoPoint geoPoint = GeoPoint(
            latitude: spotted["location"].latitude,
            longitude: spotted["location"].longitude,
          );

          await controller.addMarker(
            geoPoint,

            markerIcon: MarkerIcon(
              iconWidget: Transform.rotate(
                angle: 3.1416,
                // 180 gradi in radianti, altrimenti viene capovolta....
                child: Icon(Icons.place_outlined, color: Colors.blue, size: 30),
              ),
            ),
          );

          setState(() {});
        }
      } else {
        print("Errore: il POI non contiene coordinate valide.");
      }
    }




    // Forza l'aggiornamento della UI per vedere i marker
    setState(() {});
  }

  /*
    FUNZIONANTE UTILIZZANDO DUE CAMPI LAT E LONG INVECE DEL GEOPOINT

  Future<void> addPOIs() async {


    print("poilist $poiListD");

    for (var poi in poiListD) {
      print("poi $poi");
      if (poi.containsKey("lat") && poi.containsKey("long")) {
        double latitude = poi["lat"];
        double longitude = poi["long"];

        // Aggiungi il marker con le coordinate ottenute
        await controller.addMarker(
          GeoPoint(latitude: latitude, longitude: longitude),
          markerIcon: MarkerIcon(
            icon: Icon(Icons.place, color: Colors.red, size: 48),
          ),
        );
      } else {
        print("Errore: il POI non contiene coordinate valide.");
      }
    }

    // Forza l'aggiornamento della UI per vedere i marker
    setState(() {});
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mappa Delta del Po")),
      body: Stack(
        children: [
          // La mappa
          Positioned.fill(child: loadMap()),
          // Filtri sopra la mappa
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: SizedBox(
              height: 50, // Imposta un'altezza per evitare errori
              child: ListView.builder(
                scrollDirection: Axis.horizontal, // Scorrimento orizzontale
                itemCount: categories.length,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: Text(categories.elementAt(index)),
                      selected: selectedCategories.contains(
                        categories.elementAt(index),
                      ),
                      onSelected: (bool value) {
                        setState(() {
                          if (value) {
                            selectedCategories.add(categories.elementAt(index));
                          } else {
                            selectedCategories.remove(
                              categories.elementAt(index),
                            );
                          }

                          addPOIs();
                        });

                        print("categorie abilitate $selectedCategories");
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),

      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 20,
        children: [
          FloatingActionButton(
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (context) => const Spotted()));
            },
            child: Icon(Icons.find_in_page_outlined),
          ),
          FloatingActionButton(
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (context) => const Reports()));
            },
            child: Icon(Icons.abc_outlined),
          ),
        ],
      ),
    );
  }

  loadMap() {
    return OSMFlutter(
      controller: controller,
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
            icon: const Icon(
              Icons.location_history_rounded,
              color: Colors.blue,
              size: 48,
            ),
          ),
          directionArrowMarker: MarkerIcon(
            icon: const Icon(Icons.gps_fixed, size: 48),
          ),
        ),
        roadConfiguration: const RoadOption(roadColor: Colors.yellowAccent),
      ),
    );
  }

  Future<void> loadPOI() async {
    List<Map<String, dynamic>> list = await firebase.getData();
    List<Map<String, dynamic>> list2 = await firebase.getData(
      collection: "spotted",
    );

    setState(() {
      poiListD = list;
      categories = poiListD.map((poi) => poi["category"] as String).toSet();
      spottedList = list2;
    });
  }
}
