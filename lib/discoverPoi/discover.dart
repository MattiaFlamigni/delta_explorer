import 'package:delta_explorer/discoverPoi/discoverController.dart';
import 'package:flutter/material.dart';

class Discover extends StatefulWidget {
  const Discover({super.key});

  @override
  State<Discover> createState() => _DiscoverState();
}

class _DiscoverState extends State<Discover> {
  DiscoverController controller = DiscoverController();
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadNearbyPois();
  }

  Future<void> _loadNearbyPois() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await controller.getNearPoi();
      print("POI VICINI: ${controller.getNearPoiList()}");
    } catch (e) {
      print("Errore nel caricamento dei POI: $e");
      _errorMessage = "Impossibile caricare i POI vicini. $e";
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Esplora i Dintorni"),
        backgroundColor: Colors.green,
      ),
      body: _isLoading
          ? showLoadingCircle()
          : _errorMessage != null
          ? showError()
          : controller.getNearPoiList().isEmpty
          ? showEmpty()
          : RefreshIndicator( // Permette all'utente di ricaricare la lista  scorrendo verso il basso
        onRefresh: _loadNearbyPois,
        child: showNearPOI()
      ),
    );
  }

  Widget showNearPOI(){
    return ListView.separated(
      itemCount: controller.getNearPoiList().length,
      separatorBuilder: (context, index) => const Divider(height: 1, color: Colors.grey), // Separatore visivo tra gli elementi
      padding: const EdgeInsets.all(8.0),
      itemBuilder: (BuildContext context, int index) {
        final poi = controller.getNearPoiList()[index];
        final String title = poi['title'] ?? 'Nome non disponibile';
        final String description = poi['description'] ?? 'Nessuna descrizione disponibile';
        final String? imageUrl = poi['image_url']; // Assumi che ci sia un URL dell'immagine

        return InkWell( // Rende l'elemento tappabile
          onTap: () {
            _showPoiDetails(context, poi); // Mostra i dettagli in un modal
          },
          child: drawCard(title, description, imageUrl)
        );
      },
    );
  }

  Widget showImage(String? imageUrl){
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: imageUrl != null
          ? Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.image_not_supported_outlined, size: 40, color: Colors.grey);
        },
      )
          : const Icon(Icons.image_outlined, size: 40, color: Colors.grey),
    );
  }

  Widget drawCard(String title, String description, String? imageUrl){
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: showImage(imageUrl)
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget showEmpty(){
    return  Center(
      child: Text(
        "Nessun luogo interessante trovato nelle vicinanze.",
        style: TextStyle(fontSize: 16, color: Colors.grey),
      ),
    );
  }

  Widget showError(){
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red, fontSize: 16),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _loadNearbyPois,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text("Riprova", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showPoiDetails(BuildContext context, dynamic poi) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 20),
              Text(poi['title'] ?? 'Nome non disponibile', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green)),
              const SizedBox(height: 10),
              if (poi['image_url'] != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: showImage(poi["image_url"])
                  ),
                ),
              Text('Descrizione:', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(poi['description'] ?? 'Nessuna descrizione disponibile', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 16),
              if (poi['location'].toString().isEmpty)
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(child: Text(poi['address'], style: const TextStyle(fontSize: 16))),
                  ],
                ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void loadPois() async {
    await controller.getNearPoi();
    print("POI VICINI: ${controller.getNearPoiList()}");
    setState(() {});
  }

  Widget showLoadingCircle(){
    return Center(child: CircularProgressIndicator(color: Colors.green));
  }
}