import 'package:dashed_circular_progress_bar/dashed_circular_progress_bar.dart';
import 'package:delta_explorer/constants/point.dart';
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


  @override
  void initState(){
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLoginStatus();
      controller.fetchUserPoint();
    });
    loadData();
  }

  Future<void> loadData() async {
    await controller.loadNumSpotted();
    await controller.loadNumReport();
    await controller.loadNumKM();
    controller.fetchBadge().then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            drawLevelRow(),
            const SizedBox(height: 20),
            drawPersonalNumbers(),
            const SizedBox(height: 20),
            drawBadgeRow(),
          ],
        ),
      ),
    );
  }

  Widget drawPersonalNumbers(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Statistiche personali", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.green)),
        const SizedBox(height: 8),
        drawDoubleTextRow("Punti Guadagnati", controller.getUserPoint().toString()),
        drawDoubleTextRow("Contributi", controller.getNumSpotted().toInt().toString()),
        drawDoubleTextRow("Segnalazioni", controller.getNumReport().toInt().toString()),
        drawDoubleTextRow("KM percorsi", controller.getNumKm().toString().length>4?controller.getNumKm().toString().substring(0,4) : controller.getNumKm().toString() ),

      ],
    );
  }

  Widget drawDoubleTextRow(String text1, String text2) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        title: Text(text1, style: TextStyle(fontSize: 15, color: Colors.black)),
        trailing: Text(text2, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.green)),
      ),
    );
  }

  _checkLoginStatus() async {
    final isLoggedIn = controller.isUserLogged();
    if (!isLoggedIn) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginForm()),
      );
    }
  }

  Widget drawLevelRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Livelli', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _levelItem("Novizio", "assets/level/novizio.png", controller.getUserPoint().toDouble() / ThresholdLevel.level1, controller.getUserPoint() >= ThresholdLevel.level1),
            const SizedBox(width: 10),
            _levelItem("Apprendista", "assets/level/apprendista.png", controller.getUserPoint().toDouble() / ThresholdLevel.level2, controller.getUserPoint() >= ThresholdLevel.level2),
            const SizedBox(width: 10),
            _levelItem("Esperto", "assets/level/esperto.png", controller.getUserPoint().toDouble() / ThresholdLevel.level3, controller.getUserPoint() >= ThresholdLevel.level3),
            const SizedBox(width: 10),
            _levelItem("Master", "assets/level/master.png", controller.getUserPoint().toDouble() / ThresholdLevel.level4, controller.getUserPoint() >= ThresholdLevel.level4),
          ],
        ),
      ],
    );
  }

  Widget _levelItem(String title, String imageAsset, double progress, bool isAchieved) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: DashedCircularProgressBar.aspectRatio(
                aspectRatio: 1,
                valueNotifier: _valueNotifier,
                progress: progress * 100,
                startAngle: 225,
                sweepAngle: 270,
                foregroundColor: isAchieved ? Colors.green : Colors.grey,
                backgroundColor: const Color(0xffeeeeee),
                foregroundStrokeWidth: 4,
                backgroundStrokeWidth: 4,
                animation: true,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(
                    imageAsset,
                    fit: BoxFit.cover,
                    color: isAchieved ? null : Colors.grey[400], // Opacizza se non raggiunto
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isAchieved ? Colors.black87 : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget drawBadgeRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Badge', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 10.0,
            childAspectRatio: 0.85,
          ),
          itemCount: controller.getBadges().length,
          itemBuilder: (BuildContext context, int index) {
            var item = controller.getBadges()[index];
            double? progres;
            int goalBadge = item["threshold"];

            if (item["type"] == "spot") {
              progres = controller.getNumSpotted();
            } else if(item["type"] == "report") {
              progres = controller.getNumReport();
            }else{
              progres = controller.getNumKm();
            }

            return Container(
              alignment: Alignment.center,
              child: badgeWidget(
                item["image_path"] ?? "",
                item["title"] ?? "",
                progres / goalBadge,
                item["description"],
                item["threshold"],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget progressIndicator(String imageAsset, double progress, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 80,
          height: 80,
          child: DashedCircularProgressBar.aspectRatio(
            aspectRatio: 1,
            valueNotifier: _valueNotifier,
            progress: progress*100,
            startAngle: 225,
            sweepAngle: 270,
            foregroundColor: Colors.green,
            backgroundColor: const Color(0xffeeeeee),
            foregroundStrokeWidth: 3,
            backgroundStrokeWidth: 3,
            animation: true,
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: Image.asset(imageAsset, fit: BoxFit.cover),
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black), textAlign: TextAlign.center),
      ],
    );
  }

  Widget badgeWidget(String imageAsset, String badgeName, double progress, String description, int threshold) {
    bool isAchieved = progress >= 1;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: isAchieved
                ? Border.all(color: Colors.amber, width: 4)  // Bordo dorato per badge sbloccato
                : null,
            boxShadow: isAchieved
                ? [BoxShadow(color: Colors.amber.withOpacity(0.7), blurRadius: 10, spreadRadius: 1)]
                : [],
          ),
          child: isAchieved
              ? Padding(
            padding: const EdgeInsets.all(4.0),
            child: Image.asset(imageAsset, fit: BoxFit.cover),
          )
              : DashedCircularProgressBar.aspectRatio(
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
              child: GestureDetector(
                onTap: () {
                  bottomSheetBadge(description, progress * 100, threshold);
                },
                child: Image.asset(imageAsset, fit: BoxFit.cover),
              ),
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          badgeName,
          style: TextStyle(
            fontSize: 10,
            color: isAchieved ? Colors.amber[800] : Colors.black,
            fontWeight: isAchieved ? FontWeight.bold : FontWeight.normal,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }



  Future bottomSheetBadge(String desc, double progres, int obiettivo) {
    return showModalBottomSheet(
      enableDrag: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
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
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
                ),
              ),
              SizedBox(height: 20),
              Text("Dettagli", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              Text(desc, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Icon(Icons.web, color: Colors.blue),
                  SizedBox(width: 10),
                  Text("Obiettivo:", style: TextStyle(fontWeight: FontWeight.w500)),
                  Spacer(),
                  SelectableText(obiettivo.toString()),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.web, color: Colors.blue),
                  SizedBox(width: 10),
                  Text("Progresso:", style: TextStyle(fontWeight: FontWeight.w500)),
                  Spacer(),
                  SelectableText("${progres.toStringAsFixed(2)}%"),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
