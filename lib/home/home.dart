import 'package:delta_explorer/gallery/gallery.dart';
import 'package:delta_explorer/home/homeController.dart';
import 'package:delta_explorer/maps/maps.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Map<String, dynamic>> curiosity = [];
  List<Map<String, dynamic>> currentMeteo = [];
  List<Map<String, dynamic>> spottedList = [];
  HomeController controller = HomeController();

  @override
  void initState() {
    super.initState();
    fetchMeteo();
    fetchCuriosity();
    fetchSpotted();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Home")),
      floatingActionButton: Container(
        alignment: Alignment.bottomCenter,
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => Maps()),
            );
          },
          label: Text("MAP")
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            drawHeaderImageWithText(),

            //mostra un immagine con testo in sovraimpressione
            Padding(
              padding: EdgeInsets.only(top: 15, left: 16, right: 16),
              child: drawDoubleTextRow("ALCUNI AVVISTAMENTI", "gallery >"),
            ),

            const SizedBox(height: 10),

            /*carica immagini casuali da db*/
            showSpottedImages(),

            Row(children: const []),

            /*Disegna una riga scrollabile di card contente curiosita e dati*/
            drawRowTitle("CURIOSITA E DATI"),
            const SizedBox(height: 10),
            SizedBox(height: 150, child: drawRowWithCard()),

            /*Sezione informazioni con chip e bottomsheet*/
            drawRowTitle("INFORMAZIONI"),
            drawRowChip(),


            Padding(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              // Aggiunta una spaziatura più bilanciata
              child: drawInfoSection(
                Icons.place_rounded,
                "Indirizzo",
                "Provincia di Ferrara",
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              // Aggiunta una spaziatura più bilanciata
              child: drawInfoSection(
                Icons.access_time_rounded,
                "Orari",
                "24 ore su 24",
              ),
            ),
            SizedBox(height: 100,)
          ],
        ),
      ),
    );
  }

  Future<void> fetchMeteo() async {
    final meteoData = await controller.getMeteo();
    setState(() {
      currentMeteo = meteoData;
    });
  }

  Widget showSpottedImages() {

    if(spottedList.isEmpty){
      return Text("no data avaiable");
    }

    return SizedBox(
      height: 200, // imposta un'altezza fissa altrimenti non si vede
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: spottedList.length,
        itemBuilder: (BuildContext context, int index) {
          var current = spottedList[index];
          if(current["image_path"]!="") {
            print("Image URL: https://cvperzyahqhkdcjjtqvm.supabase.co/storage/v1/object/public/${current["image_path"]}");

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  "https://cvperzyahqhkdcjjtqvm.supabase.co/storage/v1/object/public/${current["image_path"]}",
                  width: 200,
                  height: 200,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(Icons.error),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Future<void> fetchSpotted() async {
    final list = await controller.getSpotted();
    setState(() {
      spottedList = list;
    });
    print("Lista spotted: $list");
  }

  Widget drawRowTitle(String text) {
    return Padding(
      padding: EdgeInsets.only(top: 20, left: 16),
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
    );
  }

  Widget drawCard(Map<String, dynamic> current) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
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
                    "Descrizione",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Text(current["description"]),
                ],
              ),
            );
          },
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Container(
          width: 220,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.lightBlueAccent.shade100,
                Colors.lightBlue.shade200,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                current["title"] ?? "Senza titolo",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                current["subtitle"] ?? "Sottotitolo mancante",
                style: const TextStyle(fontSize: 14, color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> fetchCuriosity() async {
    final List<Map<String, dynamic>> fetchedCuriosity =
        await controller.getCuriosity();
    setState(() {
      curiosity = fetchedCuriosity;
    });
  }

  Widget drawChip(String text, Function(bool) function) {
    return FilterChip(label: Text(text), onSelected: function);
  }

  Widget drawHeaderImageWithText() {
    return GestureDetector(
      onTap: () {
        print("tappato");
      }, // TODO: BOTTOM SHEET
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/resources/pesci.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: const Center(
          child: Text(
            "testo di prova",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              backgroundColor: Colors.black45,
            ),
          ),
        ),
      ),
    );
  }

  Widget drawDoubleTextRow(String text1, String text2) {
    return Row(
      children: [
        Text(
          text1,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        const Spacer(),
        text2.toLowerCase() == "gallery >"
            ? GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => GalleryScreen()),
            );
          },
          child: Text(
            text2,
            style: const TextStyle(
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ),
          ),
        )
            : Text(text2),
      ],
    );
  }

Widget drawRowChip(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 15,
      children: [
        drawChip("Website", (selected) {
          bottomSheetWebsite();
        }),

        drawChip("Meteo", (selected) {
          bottomheetMeteo();
        }),

        drawChip("Contatti", (selected) {
          bottomheetContatti();
        }),
      ],
    );
}

  Widget drawRowWithCard() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: curiosity.length,
      itemBuilder: (BuildContext context, int index) {
        var current = curiosity[index];
        return drawCard(current);
      },
    );
  }

  Future bottomSheetWebsite() {
    return showModalBottomSheet(
      enableDrag: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                "Website",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Icon(Icons.web, color: Colors.blue),
                  SizedBox(width: 10),
                  Text(
                    "Website:",
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Spacer(),
                  SelectableText("www.parcodeltapo.it"),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future bottomheetContatti() {
    return showModalBottomSheet(
      enableDrag: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                "Contatti",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Icon(Icons.phone, color: Colors.blue),
                  SizedBox(width: 10),
                  Text(
                    "Telefono:",
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Spacer(),
                  SelectableText("0533/314003"),
                ],
              ),
              SizedBox(height: 15),
              Row(
                children: [
                  Icon(Icons.mail, color: Colors.green),
                  SizedBox(width: 10),
                  Text("Pec:", style: TextStyle(fontWeight: FontWeight.w500)),
                  Spacer(),
                  Flexible(
                    child: SelectableText(
                      "parcodeltapo@cert.parcodeltapo.it",
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future bottomheetMeteo() {
    return showModalBottomSheet(
      enableDrag: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              Row(
                children: [
                  Image.network("https:${currentMeteo[0]["icona"]}"),
                  Text(
                    "${currentMeteo[0]["temp"]}°",
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Text(
                "${currentMeteo[0]["condition"]}",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                // Distribuisce lo spazio tra le icone
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    // Centra il testo rispetto all'icona
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      FaIcon(FontAwesomeIcons.wind, color: Colors.blue),
                      SizedBox(height: 5),
                      Text(
                        NumberFormat(
                          "#0",
                        ).format(currentMeteo[0]["windSpeed"] * 1.6),
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.water_drop_outlined, color: Colors.blue),
                      SizedBox(height: 5),
                      Text(
                        "${currentMeteo[0]["humidity"]}%",
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      FaIcon(FontAwesomeIcons.cloudRain, color: Colors.blue),
                      SizedBox(height: 5),
                      Text(
                        "${currentMeteo[0]["rain"]}mm",
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      FaIcon(
                        FontAwesomeIcons.diamondTurnRight,
                        color: Colors.blue,
                      ),
                      SizedBox(height: 5),
                      Text(
                        "${currentMeteo[0]["windDirection"]}",
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget drawInfoSection(IconData icon, String text1, String text2) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.orange,
          size: 24, // Rende l'icona leggermente più grande
        ),
        SizedBox(width: 10), // Distanza tra icona e testo
        Text(
          text1,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color:
                Colors.black87, // Colore scuro per contrastare con l'arancione
          ),
        ),
        Spacer(),
        Text(
          text2,
          style: TextStyle(
            fontSize: 16,
            color: Colors.black54, // Colore grigio per il testo secondario
          ),
        ),
      ],
    );
  }
}
