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
              drawImageButton(),
              const SizedBox(height: 20),

              // Area per mostrare l'immagine selezionata
              if (controller.getImage() != null)
                Column(
                  children: [
                    showImage(),

                    const SizedBox(height: 16),

                    drawSearchButton(),

                    const SizedBox(height: 20),
                  ],
                ),

              // Area per mostrare i risultati dell'identificazione
              if (controller.getSuggestions().isNotEmpty)
                showResult(),
            ],
          ),
        ),
      ),
    );
  }



  void showSnackbar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Widget showImage(){
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.0),
      child: Image.file(
        controller.getImage()!,
        width: 200,
        height: 200,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget drawSearchButton(){
    return ElevatedButton.icon(
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
    );
  }
  Widget drawImageButton(){
    return ElevatedButton.icon(
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
    );
  }

  Widget showResult(){
    return Column(
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
            suggestion['taxon']?['preferred_common_name'];
            final originalName = suggestion['taxon']?['name'];
            final imagePath = suggestion['taxon']?['default_photo']?['url'] as String?;
            final score = suggestion['vision_score'] as double?;
            return drawCard(commonName??"N/A",originalName, score??0.00, imagePath??"");
          },
        ),
      ],
    );
  }


  Widget drawCard(String commonName,String originalName, double score, String image_path){
    print("original name $originalName");
    if(commonName!="N/A") {
      return GestureDetector(
        onTap: () async {
          String desc = await controller.getDescription(originalName);
          drawBottomSheet(image_path, desc);
        },


        child: Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if(commonName != "N/A")
                  Text(
                    commonName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                if(commonName != "N/A")
                  Text(
                    'Probabilità: ${(score).toStringAsFixed(2)}%',
                    style: const TextStyle(color: Colors.grey),
                  ),
              ],
            ),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Future drawBottomSheet(String url, String desc){
    return showModalBottomSheet(

      isScrollControlled: true,
      enableDrag: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      context: context,
      builder: (BuildContext context) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Barra centrale visibile
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Immagine",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Image.network(url),
              SizedBox(height: 20),
              Text(
                "Descrizione",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              Text(desc)

            ],
          ),
        );
      },
    );
  }
}
