import 'package:delta_explorer/constants/point.dart';
import 'package:delta_explorer/standings/standingController.dart';
import 'package:flutter/material.dart';

class Standings extends StatefulWidget {
  const Standings({super.key});

  @override
  State<Standings> createState() => _StandingsState();
}

class _StandingsState extends State<Standings> {
  StandingController controller = StandingController();

  @override
  void initState() {
    super.initState();
    controller.fetchGlobal_Week().then((_) {
      setState(() {});
    });
    controller.fetchPoints().then((_){
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Column(
        children: [
          const SizedBox(height: 10),
          rowChip(),
          const SizedBox(height: 10),
          Expanded(child: drawStanding()),
          detailsPoint(TypePoints.spotted),
          detailsPoint(TypePoints.reports)
        ],
      ),
    );
  }

  Widget detailsPoint(String type) {
    IconData icon;
    int points = 0;

    if (type == TypePoints.spotted) {
      icon = Icons.visibility;
      points = controller.spottedPoints;
    } else if (type == TypePoints.reports) {
      icon = Icons.report;
      points = controller.reportPoints;
    } else {
      icon = Icons.help_outline;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.blueAccent,
            child: Icon(icon, color: Colors.white),
          ),
          title: Text(
            type == TypePoints.spotted ? "Punti Avvistamenti" :
            type == TypePoints.reports ? "Punti Segnalazioni" :
            "Punti",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          trailing: Text(
            "$points pts",
            style: const TextStyle(
              fontSize: 18,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  Widget rowChip() {
    String selected="";
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      children: [
        FilterChip(
          label: const Text("Globale"),
          onSelected: (b) async {
            await controller.fetchGlobal_Week();
            setState(() {});
          },
        ),
        FilterChip(

          label: const Text("Settimanale"),
          onSelected: (b) async {
            await controller.fetchGlobal_Week(week:true);
            setState(() {});
          },
        ),
        FilterChip(
          label: const Text("Mensile"),
          onSelected: (b) async {
            await controller.fetchGlobal_Week(month:true);
            setState(() {});
          },
        ),
        FilterChip(
          label: const Text("Amici"),
          onSelected: (b) {},
        ),
      ],
    );
  }

  Widget drawStanding() {
    final standings = controller.getStanding();

    if (standings.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return ListView.builder(
      itemCount: standings.length,
      itemBuilder: (BuildContext context, int index) {
        final item = standings[index];
        final name = item["username"] ?? "Sconosciuto";
        final points = item["total"] ?? 0;

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: index == 0
                ? Colors.amber
                : index == 1
                ? Colors.grey
                : index == 2
                ? Colors.brown
                : Colors.blueGrey,
            child: Text(
              "${index + 1}",
              style: const TextStyle(color: Colors.white),
            ),
          ),
          title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
          trailing: Text(
            "$points pts",
            style: const TextStyle(fontSize: 16),
          ),
        );
      },
    );
  }
}
