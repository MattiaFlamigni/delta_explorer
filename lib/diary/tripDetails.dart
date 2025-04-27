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
      setState(() {
      });
    });

    controller.fetchCoord(widget.trip["id"]).then((_) {
      setState(() {
      });
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            drawTripInfo(titolo,theme.textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.bold)),

            const SizedBox(height: 8.0),
            drawTripInfo(DateFormat('dd MMMM yyyy HH:mm').format(dataCreazione),theme.textTheme.bodySmall!.copyWith(color: Colors.grey[600])),

            const SizedBox(height: 16.0),
            drawTripInfo(descrizione,theme.textTheme.bodyLarge!),
            const SizedBox(height: 24.0),
            if (controller.getImages().isNotEmpty) ...[
              drawTripInfo("Galleria",theme.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold)),

              const SizedBox(height: 8.0),
              drawGallery(controller.getImages()),
              const SizedBox(height: 24.0),

            ],
            drawTripInfo("Il tuo percorso",theme.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold)),
            drawTripMap(controller.getCoord())

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

    return SizedBox(
      height: 300, // puoi cambiare l'altezza
      child: FlutterMap(
        options: MapOptions(
          center: points.first,
          zoom: 15,
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
                color: Colors.blue,
              ),
            ],
          ),
          MarkerLayer(
            markers: [
              Marker(
                width: 40,
                height: 40,
                point: points.first,
                child: const Icon(Icons.flag, color: Colors.green, size: 40),
              ),
              Marker(
                width: 40,
                height: 40,
                point: points.last,
                child: const Icon(Icons.flag, color: Colors.red, size: 40),
              ),
            ],
          ),
        ],
      ),
    );
  }



  Widget drawTripInfo(String titolo, TextStyle textStyle){
    return Text(
      titolo,
      style: textStyle,
    );
  }

  Widget drawGallery(List<Map<String, dynamic>> imageUrls){
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                "https://cvperzyahqhkdcjjtqvm.supabase.co/storage/v1/object/public/${imageUrls[index]["image_path"]}",

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
          );
        },
      ),
    );
  }
}

