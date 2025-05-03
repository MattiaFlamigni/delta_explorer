
import 'package:delta_explorer/database/supabase.dart';
import 'package:delta_explorer/discoverPoi/discover.dart';
import 'package:delta_explorer/lens/lens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';

import '../../reports/reports.dart';
import '../ar.dart';
import '../spotted/spotted.dart';

/*TODO: AGGIUNGERE IMMAGINI AI BOTTOMSHEET => IMMAGINI RELATIVI POI*/

class Maps extends StatefulWidget {
  const Maps({super.key});

  @override
  State<Maps> createState() => _MapsState();
}

class _MapsState extends State<Maps> {
  late MapController controller;
  //Firebase firebase = Firebase();
  SupabaseDB supabase = SupabaseDB();
  bool isPressed = false;

  List<Map<String, dynamic>> poiListD = List.empty();
  List<Map<String, dynamic>> reportList = List.empty();
  Set<String> selectedCategories = {};
  Set<String> categories = {};

  @override
  void initState() {
    super.initState();

    //supabase.addPOIs();

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
      await loadPOI(); //load poi
      selectedCategories.addAll(categories);
      await addPOIs(); // Aggiunge i POI

      // 🔥 Verifica se il listener è stato correttamente impostato
      controller.listenerMapSingleTapping.addListener(() async {
        var tappedPoint = controller.listenerMapSingleTapping.value;
        if (tappedPoint != null) {
          _handleMarkerTap(tappedPoint);
        }
      });
    });
  }


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
              child: filterRow()
            ),
          ),
        ],
      ),

      floatingActionButton: Wrap(
        alignment: WrapAlignment.center,
        spacing: 20,
        children: [
          drawFloatingButton(Icons.pets, "avvistamento!", Spotted()), //flaoting button per spotted e reports
          drawFloatingButton(Icons.report, "segnalazione", Reports()),
          drawFloatingButton(Icons.report, "scopri", Lens()),
          drawFloatingButton(Icons.place_rounded, "POI", Discover())

        ],
      ),
    );
  }

  Widget filterRow(){
    return ListView.builder(
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
            },
          ),
        );
      },
    );
  }

  Widget drawFloatingButton(IconData iconData, String label, Widget pageToNav) {
    return FloatingActionButton.extended(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => pageToNav),
        );
      },
      icon: Icon(iconData, size: 24),
      label: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget loadMap() {
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

  void _handleMarkerTap(GeoPoint tappedPoint) {
    for (var poi in poiListD) {
      GeoPoint geoPoint = GeoPoint(
        latitude: poi["location"]["latitude"],
        longitude: poi["location"]["longitude"],
      );

      if (_isSameLocation(geoPoint, tappedPoint)) {
        showModalBottomSheet(

          context: context,
          shape: RoundedRectangleBorder(
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
                  ElevatedButton(onPressed: (){
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => CompassArrowScreen(targetLat:geoPoint.latitude, targetLon: geoPoint.longitude,)), //TODO
                    );
                  }, child: Text("naviga in AR")),
                  Text(
                    poi["title"],
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(poi["description"]),
                  SizedBox(height: 20),
                  Center(
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
        break; // Interrompe il ciclo non appena trova una corrispondenza
      }
    }

    for (var report in reportList) {


      // Verifica che 'position' esista ed è un oggetto (Map)
      if (report.containsKey("position") && report["position"] is Map) {
        var latitude = report["position"]["lat"];
        var longitude = report["position"]["lng"];

        // Debugging: stampa i valori di latitude e longitude
        print("Latitudine: $latitude, Longitudine: $longitude");

        // Controlla se latitude e longitude sono effettivamente numeri (double)
        if (latitude != null && longitude != null) {
          if (latitude is double && longitude is double) {
            GeoPoint geoPoint = GeoPoint(
              latitude: latitude,
              longitude: longitude,
            );

            if (_isSameLocation(geoPoint, tappedPoint)) {
              showModalBottomSheet(
                context: context,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) {
                  return Container(    //TODO: mostrare immagine scattata
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 10,
                          offset: Offset(0, 4), // Shadow position
                        ),
                      ],
                    ),
                    child: SingleChildScrollView( // Aggiungi questo per abilitare lo scrolling
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Titolo tipologia
                          Text(
                            "Tipologia",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey,
                            ),
                          ),
                          SizedBox(height: 8),

                          // Immagine con bordo arrotondato e gestione overflow
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12), // Bordo arrotondato
                            child: Image.network(
                              "https://cvperzyahqhkdcjjtqvm.supabase.co/storage/v1/object/public/${report["image_path"]}",
                              fit: BoxFit.cover,
                              width: double.infinity,  // Occupa tutta la larghezza disponibile
                              height: 200,  // Imposta un'altezza fissa per evitare overflow
                            ),
                          ),
                          SizedBox(height: 16),

                          // Tipologia di punto
                          Text(
                            report["type"] ?? "N/A",  // Gestire caso "null"
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 16),

                          // Divider
                          Divider(
                            color: Colors.grey[300],
                            thickness: 1,
                          ),
                          SizedBox(height: 16),

                          // Titolo commento
                          Text(
                            "Commento",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey,
                            ),
                          ),
                          SizedBox(height: 8),

                          // Commento
                          Text(
                            report["comment"] ?? "Nessun commento disponibile",  // Gestire caso "null"
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                          SizedBox(height: 20),

                          confirmReport(report["id"]),
                          SizedBox(height: 12),


                          // Bottone per chiudere
                          Center(
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,  // Colore di sfondo
                                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),  // Bottone arrotondato
                                ),
                                shadowColor: Colors.blue.withOpacity(0.3),
                                elevation: 5,
                              ),
                              child: Text(
                                "Chiudi",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
              // Interrompe il ciclo non appena trova una corrispondenza
            }
          } else {
            print("Errore: La latitudine o longitudine non sono double. Latitudine: $latitude, Longitudine: $longitude");
          }
        } else {
          print("Errore: La latitudine o longitudine sono nulli. Latitudine: $latitude, Longitudine: $longitude");
        }
      } else {
        print("Errore: La posizione non è un oggetto valido con 'lat' e 'lng'. Poi: $report");
      }
    }




  }

  Widget confirmReport(int reportID){

    return Center(
      child: ElevatedButton.icon(
        onPressed: () {

          setState(() {
            isPressed = !isPressed;
          });
          // TODO: logica di conferma (es. invia conferma alla tua API)

          supabase.incrementVerifiedReport(reportID);
        },
        icon: Icon(Icons.check_circle, color: Colors.white),
        label: isPressed ? Text("segnalazione inviata") : Text(
          "Conferma segnalazione",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          shadowColor: Colors.green.withOpacity(0.3),
          elevation: 5,
        ),
      ),
    );


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
            latitude: poi["location"]["latitude"],
            longitude: poi["location"]["longitude"],
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
      }
    }


    for (var report in reportList) {
      print("Analizzando elemento: $report");

      if (report.containsKey("type")) {
        final position = report["position"];

        if (position is Map && position.containsKey("lat") && position.containsKey("lng")) {
          final lat = position["lat"];
          final lng = position["lng"];

          print("Coordinate trovate: lat=$lat, lng=$lng");

          GeoPoint geoPoint = GeoPoint(
            latitude: lat,
            longitude: lng,
          );

          try {
            await controller.addMarker(
              geoPoint,
              markerIcon: MarkerIcon(
                iconWidget: Transform.rotate(
                  angle: 3.1416, // 180 gradi in radianti
                  child: Icon(Icons.place_outlined, color: Colors.blue, size: 30),
                ),
              ),
            );
            print("Marker aggiunto con successo per lat=$lat, lng=$lng");
          } catch (e) {
            print("Errore durante l'aggiunta del marker: $e");
          }

          setState(() {});
        } else {
          print("Coordinate mancanti o formato errato per l'elemento: $report");
        }
      } else {
        print("Categoria mancante per l'elemento: $report");
      }
    }


    // Forza l'aggiornamento della UI per vedere i marker
    setState(() {});
  }


  Future<void> loadPOI() async {
    List<Map<String, dynamic>> list = await supabase.getData();
    List<Map<String, dynamic>> list2 = await supabase.getTodaySpotted();
    setState(() {
      poiListD = list;
      categories = poiListD.map((poi) => poi["category"] as String).toSet();
      reportList = list2;

    });
  }
}
