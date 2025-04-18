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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Classifica"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          rowChip(),
          const SizedBox(height: 10),
          Expanded(child: drawStanding()),
        ],
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
