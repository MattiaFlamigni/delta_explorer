import 'package:delta_explorer/database/supabase.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final SupabaseDB db = SupabaseDB();
  List<Map<String, dynamic>> curiosity = [];

  @override
  void initState() {
    super.initState();
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
            GestureDetector(
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
            ),

            const Padding(
              padding: EdgeInsets.only(top: 15, left: 16, right: 16),
              child: Row(
                children: [
                  Text(
                    'I PIÙ VISTI',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  Spacer(),
                  Text('gallery >'),
                ],
              ),
            ),

            const SizedBox(height: 10),
            // TODO: CARICARE ALCUNE IMMAGINI
            Row(children: const []),

            drawRowTitle("CURIOSITA E DATI"),

            const SizedBox(height: 10),
            SizedBox(
              height: 150,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: curiosity.length,
                itemBuilder: (BuildContext context, int index) {
                  var current = curiosity[index];
                  return GestureDetector(
                    onTap: () {
                      print("tappato ${current['title']}");
                    }, //TODO: BottomSheet da aggiungere
                    child: drawCard(current),
                  );
                },
              ),
            ),

            drawRowTitle("INFORMAZIONI"),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 15,
              children: [
                drawChip("Website", (selected) {
                  return showModalBottomSheet(
                    enableDrag: true,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    context: context,
                    builder: (BuildContext context) {
                      return Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
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
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
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
                }),

                drawChip("Meteo", (selected) {}), // TODO : meteo

                drawChip("Contatti", (selected) {
                  return showModalBottomSheet(
                    enableDrag: true,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    context: context,
                    builder: (BuildContext context) {
                      return Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
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
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
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
                                Text(
                                  "Pec:",
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
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
                }),
                

              ],
            ),

            Padding(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),  // Aggiunta una spaziatura più bilanciata
              child: Row(
                children: [
                  Icon(
                    Icons.place_sharp,
                    color: Colors.orange,
                    size: 24,  // Rende l'icona leggermente più grande
                  ),
                  SizedBox(width: 10),  // Distanza tra icona e testo
                  Text(
                    "Indirizzo",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,  // Colore scuro per contrastare con l'arancione
                    ),
                  ),
                  Spacer(),
                  Text(
                    "Provincia di Ferrara",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,  // Colore grigio per il testo secondario
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    color: Colors.orange,
                    size: 24,
                  ),
                  SizedBox(width: 10),
                  Text(
                    "Orari",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Spacer(),
                  Text(
                    "24 ore su 24",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
      onTap: (){
        showModalBottomSheet(
            enableDrag: true,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            context: context, builder: (BuildContext context){
          return Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(20),
              ),
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
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                Text(current["description"])

              ],
            ),
          );
        });
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
}

Widget drawChip(String text, Function(bool) function) {
  return FilterChip(label: Text(text), onSelected: function);
}
