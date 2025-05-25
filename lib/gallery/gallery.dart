import 'package:delta_explorer/gallery/galleryController.dart';
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  galleryController controller = galleryController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    controller.fetchSpotted().then((_) {
      setState(() {
        isLoading = false;
      });
    });
  }

  // Funzione per mostrare l'immagine a schermo intero
  void _showFullScreenImage(
    BuildContext context,
    String imageUrl,
    int index,
    List<Map<String, dynamic>> allImages,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => FullScreenGallery(
              initialIndex: index,
              imageUrls:
                  allImages
                      .where((img) => img["image_path"]?.isNotEmpty == true)
                      .map(
                        (img) =>
                            "https://cvperzyahqhkdcjjtqvm.supabase.co/storage/v1/object/public/${img["image_path"]}",
                      )
                      .toList(),
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : Scaffold(
          appBar: AppBar(title: const Text('Galleria')),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child:
                controller.getSpottedList().isEmpty
                    ? const Center(child: Text("Nessuna immagine disponibile."))
                    : drawGridImages(),
          ),
        );
  }

  Widget drawGridImages() {
    return GridView.builder(
      itemCount: controller.getSpottedList().length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        var imagePath = controller.getSpottedList()[index]["image_path"];
        final imageUrl =
            "https://cvperzyahqhkdcjjtqvm.supabase.co/storage/v1/object/public/$imagePath";

        return GestureDetector(
          onTap: () {
            _showFullScreenImage(
              context,
              imageUrl,
              index,
              controller.getSpottedList(),
            );
          },
          child: Stack(
            children: [
              Hero(
                tag: 'image_$index',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: showImage(imageUrl),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget showImage(String imageUrl) {
    return FadeInImage.memoryNetwork(
      placeholder: kTransparentImage,
      // Usa kTransparentImage o un Uint8List vuoto
      image: imageUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      imageErrorBuilder: (context, error, stackTrace) {
        return const Center(
          child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
        );
      },
      placeholderErrorBuilder: (context, error, stackTrace) {
        return const Center(
          child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
        );
      },
    );
  }
}

class FullScreenGallery extends StatefulWidget {
  final int initialIndex;
  final List<String> imageUrls;

  const FullScreenGallery({
    super.key,
    required this.initialIndex,
    required this.imageUrls,
  });

  @override
  State<FullScreenGallery> createState() => _FullScreenGalleryState();
}

class _FullScreenGalleryState extends State<FullScreenGallery> {
  late PageController _pageController;
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentPageIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.7),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.imageUrls.length,
            onPageChanged: (index) {
              setState(() {
                _currentPageIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.pop(
                    context,
                  ); // Chiude la visualizzazione a schermo intero al tap
                },
                child: Hero(
                  tag: 'image_$_currentPageIndex',
                  // Usa l'indice corrente per il tag Hero
                  child: InteractiveViewer(
                    // Permette lo zoom e il pan
                    panEnabled: false,
                    // Disabilita il pan orizzontale se usi PageView
                    boundaryMargin: const EdgeInsets.all(double.infinity),
                    minScale: 0.5,
                    maxScale: 5.0,
                    child: Image.network(
                      widget.imageUrls[index],
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        return loadingProgress == null
                            ? child
                            : const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(
                            Icons.broken_image,
                            size: 80,
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
          if (widget.imageUrls.length > 1)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  '${_currentPageIndex + 1}/${widget.imageUrls.length}',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
