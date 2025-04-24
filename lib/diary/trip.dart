import 'package:delta_explorer/diary/diaryController.dart';
import 'package:delta_explorer/diary/tripDetails.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Per formattare le date

class Trip extends StatefulWidget {
  const Trip({super.key});

  @override
  State<Trip> createState() => _TripState();
}

class _TripState extends State<Trip> {
  DiaryController controller = DiaryController();

  @override
  void initState() {
    super.initState();
    controller.fetchTrip().then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("I Miei Viaggi"),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 2,

      ),
      body: controller.getTripPassati().isEmpty
          ? Center(
        child: Text(
          "Nessun viaggio ancora registrato.",
          style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: controller.getTripPassati().length,
        itemBuilder: (context, index) {
          var item = controller.getTripPassati()[index];
          return _drawTripCard(item);
        },
      ),
    );
  }

  Widget _drawTripCard(Map<String, dynamic> tripData) {
    final theme = Theme.of(context);
    final DateTime? createdAt = tripData['created_at'] != null
        ? DateTime.parse(tripData['created_at'] as String).toLocal()
        : null;
    final String formattedDate =
    createdAt != null ? DateFormat('dd/MM/yyyy HH:mm').format(createdAt) : 'Data sconosciuta';

    return Card(

      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0), side: BorderSide(color: Colors.grey, width: 1.5)),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => TripDetails(trip: tripData)),
          );
          print("Hai toccato il viaggio: ${tripData['titolo']}");

        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tripData['titolo'] ?? "Nessun titolo",
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              Text(
                tripData['descrizione'] ?? "Nessuna descrizione",
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                maxLines: 2, // Limita il numero di righe per la descrizione
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    formattedDate,
                    style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}