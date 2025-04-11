import 'package:dashed_circular_progress_bar/dashed_circular_progress_bar.dart';
import 'package:delta_explorer/login/login.dart';
import 'package:delta_explorer/profile/profileController.dart';
import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  ProfileController controller = ProfileController();
  final ValueNotifier<double> _valueNotifier = ValueNotifier(0);
  List<Map<String, dynamic>> badge = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLoginStatus();
    });
    loadData();
  }


  Future<void> loadData() async {
    await controller.loadNumSpotted();
    await controller.loadNumReport();
    await loadBadge(); // loadBadge() chiama già setState
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Livelli',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            drawLevelRow(),
            const SizedBox(height: 20),
            const Text(
              'Badge',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            drawBadgeRow(),
          ],
        ),
      ),
    );
  }

  _checkLoginStatus() async {
    final isLoggedIn = controller.isUserLogged();
    print("loggato: $isLoggedIn");
    if (!isLoggedIn) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginForm()),
      );
    }
  }

  // Sezione per i livelli
  Widget drawLevelRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(
          child: progressIndicator("assets/resources/abbandono.png", 0.15, "Livello 1"),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: progressIndicator("assets/resources/abbandono.png", 0.25, "Livello 2"),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: progressIndicator("assets/resources/abbandono.png", 0.35, "Livello 3"),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: progressIndicator("assets/resources/abbandono.png", 0.0, "Livello 4"),
        ),
      ],
    );
  }

  // Sezione per i badge
  Widget drawBadgeRow() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // Ottimizzato per 3 badge per riga su schermi medi
        crossAxisSpacing: 10.0, // Spazio orizzontale tra i badge
        mainAxisSpacing: 10.0, // Spazio verticale tra i badge
        childAspectRatio: 0.85, // Leggermente aumentato per dare più spazio al testo
      ),
      itemCount: badge.length,
      itemBuilder: (BuildContext context, int index) {

        double? progres;
        int goalBadge = badge[index]["threshold"];


        if(badge[index]["type"]=="spot"){
          print("entrato");
          progres = controller.getNumSpotted();
        }else{
          progres=controller.getNumReport();
        }

        print("progress: $progres");

        print("Badge: ${badge[index]['title']} - type: ${badge[index]['type']} - progres: $progres - goal: $goalBadge");


        return Container( // Aggiungi un Container per gestire l'allineamento e il padding degli elementi della griglia
          alignment: Alignment.center, // Allinea il contenuto al centro della cella
          child: badgeWidget(
            badge[index]["image_path"] ?? "",
            badge[index]["title"] ?? "",
            progres/goalBadge
          ),
        );
      },
    );
  }

  // Widget per il progress indicator
  Widget progressIndicator(String imageAsset, double progress, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center, // Allinea verticalmente al centro
      children: [
        SizedBox(
          width: 80, // Riduci la dimensione per un layout più compatto nella riga
          height: 80,
          child: DashedCircularProgressBar.aspectRatio(
            aspectRatio: 1,
            valueNotifier: _valueNotifier,
            progress: progress,
            startAngle: 225,
            sweepAngle: 270,
            foregroundColor: Colors.green,
            backgroundColor: const Color(0xffeeeeee),
            foregroundStrokeWidth: 3,
            backgroundStrokeWidth: 3,
            animation: true,
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: Image.asset(
                imageAsset,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        const SizedBox(height: 5), // Riduci lo spazio sotto il livello
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center, // Assicura che il testo sia centrato
        ),
      ],
    );
  }

  // Widget per i badge
  Widget badgeWidget(String imageAsset, String badgeName, double progress ) {
    print("progress passato: ${progress}");
    return Column(
      mainAxisAlignment: MainAxisAlignment.center, // Allinea verticalmente al centro
      children: [
        SizedBox(
          width: 60, // Riduci la dimensione per un layout più compatto nella griglia
          height: 60,
          child: DashedCircularProgressBar.aspectRatio(
            aspectRatio: 1,
            valueNotifier: _valueNotifier,
            progress: progress*100,
            startAngle: 225,
            sweepAngle: 270,
            foregroundColor: Colors.blue,
            backgroundColor: const Color(0xffeeeeee),
            foregroundStrokeWidth: 2,
            backgroundStrokeWidth: 2,
            animation: true,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(
                imageAsset,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        const SizedBox(height: 5), // Riduci lo spazio sotto il badge
        Text(
          badgeName,
          style: const TextStyle(fontSize: 10),
          textAlign: TextAlign.center,
          maxLines: 2, // Gestisci nomi più lunghi
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  loadBadge() async {
    var list = await controller.getBadge();
    setState(() {
      badge = list;
    });
  }
}