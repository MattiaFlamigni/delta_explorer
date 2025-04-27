import 'package:delta_explorer/diary/detailsController.dart';
import 'package:delta_explorer/diary/diaryController.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


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
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final String titolo = widget.trip["titolo"] ?? "Nessun titolo";
    final String descrizione = widget.trip["descrizione"] ?? "Nessuna descrizione";
    final DateTime dataCreazione = DateTime.tryParse(widget.trip["created_at"] ?? "") ?? DateTime.now();


    /*final List<String> imageUrls = [ //TODO GESTIONE GALLERIA
      'https://via.placeholder.com/300/FFC107/000000?Text=Foto+1',
      'https://via.placeholder.com/300/4CAF50/FFFFFF?Text=Foto+2',
      'https://via.placeholder.com/300/2196F3/FFFFFF?Text=Foto+3',
    ];*/

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

          ],
        ),
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

