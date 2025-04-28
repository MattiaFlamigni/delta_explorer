import 'package:delta_explorer/diary/detailsController.dart';
import 'package:delta_explorer/diary/diaryController.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

class TripDetails extends StatefulWidget {
  final Map<String, dynamic> trip;

  const TripDetails({super.key, required this.trip});

  @override
  State<TripDetails> createState() => _TripDetailsState();
}

class _TripDetailsState extends State<TripDetails> {
  DetailsController controller = DetailsController();

  @override
  void initState() {
    super.initState();
    controller.fetchImagesPaths(widget.trip["titolo"]).then((_) {
      setState(() {});
    });
    controller.fetchCoord(widget.trip["id"]).then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final String titolo = widget.trip["titolo"] ?? "Nessun titolo";
    final String descrizione = widget.trip["descrizione"] ?? "Nessuna descrizione";
    final DateTime dataCreazione = DateTime.tryParse(widget.trip["created_at"] ?? "") ?? DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: Text(titolo),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0), // Margini laterali
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16.0),
            Text(
              titolo,
              style: theme.textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.grey[600], size: 16),
                const SizedBox(width: 4.0),
                Text(
                  DateFormat('dd MMMM yyyy HH:mm').format(dataCreazione),
                  style: theme.textTheme.bodySmall!.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Descrizione", style: theme.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8.0),
                    Text(descrizione, style: theme.textTheme.bodyLarge!),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24.0),
            if (controller.getImages().isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Galleria", style: theme.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8.0),
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: controller.getImages().length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: InkWell( // Rendi le immagini tappabili
                            onTap: () {
                              // Implementa qui la logica per visualizzare l'immagine a schermo intero
                              print("Tapped on image ${controller.getImages()[index]["image_path"]}");
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.network(
                                "https://cvperzyahqhkdcjjtqvm.supabase.co/storage/v1/object/public/${controller.getImages()[index]["image_path"]}",
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const SizedBox(
                                    width: 120,
                                    height: 120,
                                    child: Center(child: Icon(Icons.broken_image)),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24.0),
                ],
              ),
            Text("Il tuo percorso", style: theme.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8.0),
            Card( // Usa una Card per la mappa
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: drawTripMap(controller.getCoord()),
              ),
            ),
            const SizedBox(height: 16.0),
            Text("I tuoi dati", style: theme.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8.0),
            Row(
              children: [
                Icon(Icons.directions_run, color: theme.colorScheme.secondary),
                const SizedBox(width: 8.0),
                Text("${controller.calculateTotalDistance(controller.getCoord()).toStringAsFixed(2)} km", style: theme.textTheme.bodyLarge),
              ],
            ),
            const SizedBox(height: 32.0),
          ],
        ),
      ),
    );
  }

  Widget drawTripMap(List<Map<String, dynamic>> coords) {
    if (coords.isEmpty) {
      return const Center(child: Text("Nessun percorso disponibile."));
    }

    List<LatLng> points = coords.map((coord) {
      return LatLng(coord["lat"], coord["lon"]);
    }).toList();

    // Calcola i limiti per centrare e zoomare la mappa
    final bounds = LatLngBounds.fromPoints(points);
    final center = bounds.center;
    double zoom = 13.0; // Valore di zoom di default, potrebbe essere necessario calcolarlo dinamicamente

    return SizedBox(
      height: 300,
      child: FlutterMap(
        options: MapOptions(
          center: center,
          zoom: zoom,
          bounds: bounds, // Passa i limiti per un miglior adattamento
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
          ),
          PolylineLayer(
            polylines: [
              Polyline(
                points: points,
                strokeWidth: 4.0,
                color: Colors.blueAccent,
              ),
            ],
          ),
          MarkerLayer(
            markers: [
              Marker(
                width: 40,
                height: 40,
                point: points.first,
                child: Icon(Icons.flag, color: Colors.green[600], size: 30),
              ),
              Marker(
                width: 40,
                height: 40,
                point: points.last,
                child: Icon(Icons.flag, color: Colors.red[600], size: 30),
              ),
            ],
          ),
        ],
      ),
    );
  }
}