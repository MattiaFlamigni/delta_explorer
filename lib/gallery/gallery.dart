import 'package:delta_explorer/gallery/galleryController.dart';
import 'package:flutter/material.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  galleryController controller = galleryController();

  @override
  void initState() {
    super.initState();
    controller.fetchSpotted().then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Galleria')),
      body:
          controller.getSpottedList().isEmpty
              ? const Center(child: Text("No Images"))
              : GridView.builder(
                itemCount: controller.getSpottedList().length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // due immagini per riga
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                ),
                itemBuilder: (context, index) {
                  var imagePath =
                      controller.getSpottedList()[index]["image_path"];

                  if (imagePath != null && imagePath.toString().isNotEmpty) {
                    return Image.network(
                      "https://cvperzyahqhkdcjjtqvm.supabase.co/storage/v1/object/public/$imagePath",
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(child: CircularProgressIndicator());
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.broken_image,
                          size: 50,
                          color: Colors.grey,
                        );
                      },
                    );
                  } else {
                    return const Icon(
                      Icons.image_not_supported,
                      size: 50,
                      color: Colors.grey,
                    );
                  }
                },
              ),
    );
  }
}
