import 'package:delta_explorer/lens/lensController.dart';
import 'package:flutter/material.dart';

class Lens extends StatefulWidget {
  const Lens({super.key});

  @override
  State<Lens> createState() => _LensState();
}

class _LensState extends State<Lens> {
  LensController controller = LensController();
  bool isLoading = false;

  final String api =
      "eyJhbGciOiJIUzUxMiJ9.eyJ1c2VyX2lkIjo5MTMyODMwLCJleHAiOjE3NDQ3MzA0ODJ9.nZ3yU-sOMbEGBzHEfqFFzGTgaNvf-UhO8FTEUmB3Wam969q-qbjdoTOpVMXjt9_C6HVkhaM4uSA-bxUwq-Wqig";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scatta e Scopri"),
        backgroundColor: Colors.green[400], // Un colore che richiama la natura
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Pulsante per scattare la foto
              ElevatedButton.icon(
                onPressed: () async {
                  var res = await controller.pickImage();
                  setState(() {});

                  if (res.isNotEmpty) {
                    showSnackbar(res);
                  }
                },
                icon: const Icon(Icons.camera_alt),
                label: const Text("Scatta una Foto"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[400],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  textStyle: const TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Area per mostrare l'immagine selezionata
              if (controller.getImage() != null)
                Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: Image.file(
                        controller.getImage()!,
                        width: 200,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () async {
                        if (isLoading) {
                          return;
                        } else {
                          setState(() {
                            isLoading = true;
                          });

                          var res = await controller.identifySpecies(
                            controller.getImage()!,
                          );

                          setState(() {});

                          if (res.isNotEmpty) {
                            showSnackbar(res);
                          }
                        }

                        setState(() {
                          isLoading = false;
                        });
                      },
                      icon: const Icon(Icons.search),
                      label:
                          isLoading
                              ? const Text("Ricerca in corso...")
                              : const Text("Scopri la Specie"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[400],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        textStyle: const TextStyle(fontSize: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),

              // Area per mostrare i risultati dell'identificazione
              if (controller.getSuggestions().isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Risultati:",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.getSuggestions().length,
                      itemBuilder: (context, index) {
                        final suggestion = controller.getSuggestions()[index];
                        final commonName =
                            suggestion['taxon']?['preferred_common_name']
                                as String?;
                        final score = suggestion['vision_score'] as double?;
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  commonName ?? "Nome non disponibile",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (score != null)
                                  Text(
                                    'Probabilità: ${(score).toStringAsFixed(2)}%',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget showSelectedImage() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: Image.file(
          controller.getImage()!,
          width: 200,
          height: 200,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  void showSnackbar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }
}
