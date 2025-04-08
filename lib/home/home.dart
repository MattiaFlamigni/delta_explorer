import 'package:delta_explorer/database/supabase.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:weatherapi/weatherapi.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final SupabaseDB db = SupabaseDB();
  List<Map<String, dynamic>> curiosity = [];
  WeatherRequest wr = WeatherRequest('9e7aac68e41b4e53877132202250804'); //todo: sistemare per app in produzione
  List<Map<String, dynamic>> currentMeteo = [];

  @override
  void initState() {
    super.initState();
    getMeteo();
    getCuriosity();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Home")),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            drawHeaderImageWithText(),

            //mostra un immagine con testo in sovraimpressione
            Padding(
              padding: EdgeInsets.only(top: 15, left: 16, right: 16),
              child: drawDoubleTextRow("I PIU VISTI", "gallery >"),
            ),

            const SizedBox(height: 10),
            // TODO: CARICARE ALCUNE IMMAGINI
            Row(children: const []),

            /*Disegna una riga scrollabile di card contente curiosita e dati*/
            drawRowTitle("CURIOSITA E DATI"),
            const SizedBox(height: 10),
            SizedBox(height: 150, child: drawRowWithCard()),

            /*Sezione informazioni con chip e bottomsheet*/
            drawRowTitle("INFORMAZIONI"),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 15,
              children: [
                drawChip("Website", (selected) {
                  bottomSheetWebsite();
                }),

                drawChip("Meteo", (selected) {
                  bottomheetMeteo();
                }), // TODO : meteo

                drawChip("Contatti", (selected) {
                  bottomheetContatti();
                }),
              ],
            ),

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
          ],
        ),
      ),
    );
  }

  getMeteo() async {
    List<Map<String, dynamic>> meteoCondition = [];
    var meteo = await wr.getRealtimeWeatherByLocation(44.95, 12.41);

    meteoCondition.add({
      "temp": meteo.current.tempC,
      "humidity": meteo.current.humidity,
      "windSpeed": meteo.current.windMph,
      "rain": meteo.current.precipMm,
      "icona": meteo.current.condition.icon,
      "condition": meteo.current.condition.text,
      "windDirection": meteo.current.windDir,
    });

    setState(() {
      currentMeteo = meteoCondition;
    });
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

  Future<void> getCuriosity() async {
    var cur = await db.getData(table: "curiosity");
    debugPrint(cur.toString());
    setState(() {
      curiosity = cur;
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
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        Spacer(),
        Text(text2),
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
                  Text("${currentMeteo[0]["temp"]}°", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),),
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
