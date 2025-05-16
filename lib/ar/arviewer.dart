import 'package:delta_explorer/ar/ARController.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

class ArViewerScreen extends StatefulWidget {
  const ArViewerScreen({super.key});

  @override
  State<ArViewerScreen> createState() => _ArViewerScreenState();
}

class _ArViewerScreenState extends State<ArViewerScreen> {

  ARController controller = ARController();

  Future<void> openARModel(String modelUrl, String title) async {
    Uri url;

    /*viene aperta la relativa piattaforma di AR: Google vuole una scene viewer, IOS direttamente il file interpretato da QuickLook(?)*/
    if (Platform.isAndroid) {
      url = Uri.parse(
        'https://arvr.google.com/scene-viewer/1.0?file=$modelUrl&mode=ar_only&title=$title',
      );
    } else if (Platform.isIOS) {
      url = Uri.parse(modelUrl); // Deve essere .usdz
    } else {
      throw 'Piattaforma non supportata';
    }

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Non riesco ad aprire il modello AR: $url';
    }
  }

  @override
  void initState() {
    super.initState();
    controller.fetchModels().then((_){setState(() {
      //todo: loading
    });});

  }

  @override
  Widget build(BuildContext context) {
    final objects = controller.getModels();

    return Scaffold(
      appBar: AppBar(title: const Text('AR Viewer')),
      body: Column(
        children: [
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: controller.getModels().length,
              itemBuilder: (context, index) {
                final obj = objects[index];
                return GestureDetector(
                  onTap: () {
                    final modelUrl =
                    Platform.isAndroid ? obj["glb"]! : obj["usdz"]!;
                    openARModel(modelUrl, obj["name"]!);
                  },
                  child: Card(
                    margin: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(obj["name"]!),
                        ),
                        Image.network(
                          obj["preview"]!,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              'assets/default_preview.png', //todo: inserire path corretto
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: () {
                // Puoi usarlo in futuro per aprire un modello selezionato
              },
              child: const Text('Apri modello in AR'),
            ),
          ),
        ],
      ),
    );
  }
}
