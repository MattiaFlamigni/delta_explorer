import 'package:delta_explorer/reports/reportsController.dart';
import 'package:flutter/material.dart';

class Reports extends StatefulWidget {
  const Reports({super.key});

  @override
  State<Reports> createState() => _ReportsState();
}

class _ReportsState extends State<Reports> {
  final ReportsController controller = ReportsController();

  final TextEditingController _commentTextController = TextEditingController();
  String _selectedCategory = "";

  @override
  void initState() {
    super.initState();
    controller.loadCategories().then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Segnala problema")),
      body: Column(
        children: [
          buildGridView(),
          Padding(padding: const EdgeInsets.all(8), child: showTextFormField()),
          Padding(
            padding: const EdgeInsets.all(8),
            child: ElevatedButton(
              onPressed: () async {
                try {
                  await controller.pickImage();
                  setState(() {});
                }catch(e){
                  showSnackbar(e.toString());
                }
              },
              child: const Text("Scatta una foto"),
            ),
          ),

          if (controller.getImage() != null) showSelectedImage(),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: 50),
            child: drawReportButton(),
          ),
        ],
      ),
    );
  }

  Widget buildGridView() {
    return Expanded(
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
        ),
        itemCount: controller.getCategoryList().length,
        itemBuilder: (context, index) {
          var cat = controller.getCategoryList()[index];
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = cat["title"];
              });
            },
            child: cardCategory(index),
          );
        },
      ),
    );
  }

  drawReportButton() {
    return ElevatedButton(
      onPressed: () async {
        if (controller.getImage() == null) {
          showSnackbar("Scatta una foto prima di inviare la segnalazione.");
          return;
        }

        await controller.updatePosition();
        if (controller.getCanSendReport()) {
          showLoadingDialog();
          var response = await controller.submitReport(
            _selectedCategory,
            controller.getImage()!,
            _commentTextController,
          );
          showSnackbar(response!);

          if (!mounted) return;
          Navigator.pop(context); // Chiude il dialogo di caricamento
          Navigator.pop(context); //torna alla mappa
        } else {
          showSnackbar(
            "Permessi non abilitati - attivali per inviare la segnalazione",
          );
        }
      },
      child: const Text("invia segnalazione"),
    );
  }

  Widget showSelectedImage() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ClipRect(
        child: Image.file(
          controller.getImage()!,
          width: 150,
          height: 150,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  TextFormField showTextFormField() {
    return TextFormField(
      controller: _commentTextController,
      decoration: const InputDecoration(
        border: UnderlineInputBorder(),
        labelText: 'Commenti',
      ),
    );
  }

  Card cardCategory(int index) {
    var cat = controller.getCategoryList()[index];
    return Card(
      color: (_selectedCategory == cat["title"]) ? Colors.red : Colors.white,
      child: Column(
        children: [
          Text(cat["title"]),
          Image.asset(
            'assets/${cat["image_path"]}',
            fit: BoxFit.cover,
            width: 70,
            height: 70,
          ),
        ],
      ),
    );
  }

  void showSnackbar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 10),
              Text("Invio in corso..."),
            ],
          ),
        );
      },
    );
  }
}
