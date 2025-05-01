import 'dart:io';
import 'package:delta_explorer/spotted/spottedController.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';


class Spotted extends StatefulWidget {
  const Spotted({super.key});

  @override
  State<Spotted> createState() => _SpottedState();
}

class _SpottedState extends State<Spotted> {
  final SpottedController controller = SpottedController();

  @override
  void initState() {
    super.initState();
    controller.loadCategories((categories) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Segnala Avvistamento")),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: buildCategoryGrid()),
            const SizedBox(height: 10),
            buildTextFormField(),
            const SizedBox(height: 10),
            buildImagePicker(),
            const SizedBox(height: 10),
            buildCounterRow(),
            const SizedBox(height: 10),
            buildSendButton(),
          ],
        ),
      ),
    );
  }

  Widget buildCategoryGrid() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3 / 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: controller.categoriesList.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            setState(() {
              controller.selectedCategory = controller.categoriesList[index]["nome"];
              showSubcategoryDialog(controller.categoriesList[index]["sottocategorie"]);
            });
          },
          child: cardCategory(index),
        );
      },
    );
  }

  Widget buildTextFormField() {
    return TextFormField(
      controller: controller.commentTextController,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Commenti',
      ),
    );
  }

  Widget buildImagePicker() {
    return Column(
      children: [
        ElevatedButton(
          onPressed: _pickImage,
          child: const Text("Scatta una foto"),
        ),
        if (controller.image != null) showSelectedImage(),
      ],
    );
  }

  Widget buildCounterRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: () => setState(() => controller.numSpotted = (controller.numSpotted > 1) ? controller.numSpotted - 1 : 1),
          icon: const Icon(Icons.remove),
        ),
        Text(controller.numSpotted.toString(), style: const TextStyle(fontSize: 24)),
        IconButton(
          onPressed: () => setState(() => controller.numSpotted++),
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }

  Widget buildSendButton() {
    return ElevatedButton(
      onPressed: () async {
        await controller.updatePosition(context);

        if (controller.canSendReports) {

          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 10),
                  Text("Invio in corso..."),
                ],
              ),
            ),
          );


          await controller.uploadSpot(context);
          if (!mounted) return;
          Navigator.pop(context); // Chiude il dialogo di caricamento
          Navigator.pop(context); // Torna alla mappa
        } else {

          controller.showSnackbar(context, "Permessi non abilitati - Attivali per inviare");
        }
      },
      child: const Text("Invia Avvistamento"),
    );
  }

  Widget showSelectedImage() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.file(controller.image!, width: 150, height: 150, fit: BoxFit.cover),
      ),
    );
  }

  Widget cardCategory(int index) {
    return Card(
      color: (controller.selectedCategory == controller.categoriesList[index]["nome"]) ? Colors.red : Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(controller.categoriesList[index]["nome"]),
          Image.asset('assets/${controller.categoriesList[index]["image_path"]}', width: 50, height: 50),
        ],
      ),
    );
  }

  void showSubcategoryDialog(List<dynamic> subcategories) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Seleziona sottocategoria"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: subcategories.map((sub) => ListTile(
              title: Text(sub),
              onTap: () {
                setState(() => controller.selectedSubcategory = sub);
                Navigator.pop(context);
              },
            )).toList(),
          ),
        );
      },
    );
  }

  Future<void> _pickImage() async {
    final pickedFile = await controller.picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        controller.image = File(pickedFile.path);
      });
    }
  }
}
