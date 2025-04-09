import 'package:delta_explorer/gallery/galleryController.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({Key? key}) : super(key: key);

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  List<Map<String, dynamic>> reportsList = [];
  galleryController controller = galleryController();

  @override
  void initState() {
    super.initState();
    fetchReports(); // fetch appena avvii
  }

  Future<void> fetchReports() async {
    var list = await controller.getReports();
    setState(() {
      reportsList = list;
    });


    print("reports: $list");
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Galleria')),
      body: reportsList.isEmpty
          ? const Center(child: Text("No Images"))
          : GridView.builder(
        itemCount: reportsList.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // due immagini per riga
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemBuilder: (context, index) {
          return Image.network(
            "https://cvperzyahqhkdcjjtqvm.supabase.co/storage/v1/object/public/${reportsList[index]["image_path"]}",
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(),
              );
            },
          );
        },
      ),
    );
  }
}
