import 'package:delta_explorer/constants/point.dart';
import 'package:delta_explorer/standings/standingController.dart';
import 'package:flutter/material.dart';

class Standings extends StatefulWidget {
  const Standings({super.key});

  @override
  State<Standings> createState() => _StandingsState();
}

class _StandingsState extends State<Standings> {
  final StandingController controller = StandingController();

  @override
  void initState() {
    super.initState();
    controller.fetchGlobal_Week().then((_) => setState(() {}));
    controller.fetchPoints().then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 10),
          rowChip(controller, () => setState(() {})),
          const SizedBox(height: 10),
          Expanded(child: drawStanding(controller)),
          detailsPoint(controller, TypePoints.spotted),
          detailsPoint(controller, TypePoints.reports),
          drawAddButton(context)
        ],
      ),
    );
  }


  Widget drawAddButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        showAddFriendModal(context);
      },
      label: const Text("Aggiungi Amico"),
      icon: const Icon(Icons.person_add),
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(   // <-- Rettangolare
          borderRadius: BorderRadius.circular(8),  // se metti 0 è completamente squadrato
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        backgroundColor: Colors.blueAccent, // Colore sfondo
        foregroundColor: Colors.white,      // Colore testo e icona
      ),
    );
  }

  Widget drawStanding(StandingController controller) {
    final standings = controller.getStanding();

    if (standings.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      itemCount: standings.length,
      itemBuilder: (BuildContext context, int index) {

        final item = standings[index];
        print("ID CARICATO: ${item["userID"]}");
        final name =
        item["userID"] == controller.getAuthUser() ? "TU" : item["username"]??"sconosciuto";
        final points = item["total"] ?? item["points"];

        return ListTile(
          leading: CircleAvatar(
            backgroundColor:
            index == 0
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
          trailing: Text("$points pts", style: const TextStyle(fontSize: 16)),
        );
      },
    );
  }

  Widget detailsPoint(StandingController controller, String type) {
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.blueAccent,
            child: Icon(icon, color: Colors.white),
          ),
          title: Text(
            type == TypePoints.spotted
                ? "Punti Avvistamenti"
                : type == TypePoints.reports
                ? "Punti Segnalazioni"
                : "Punti",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          trailing: Text(
            "$points pts",
            style: const TextStyle(fontSize: 18, color: Colors.black87),
          ),
        ),
      ),
    );
  }

  Widget rowChip(StandingController controller, VoidCallback refresh) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      children: [
        FilterChip(
          label: const Text("Globale"),
          onSelected: (b) async {
            await controller.fetchGlobal_Week();
            refresh();
          },
        ),
        FilterChip(
          label: const Text("Settimanale"),
          onSelected: (b) async {
            await controller.fetchGlobal_Week(week: true);
            refresh();
          },
        ),
        FilterChip(
          label: const Text("Mensile"),
          onSelected: (b) async {
            await controller.fetchGlobal_Week(month: true);
            refresh();
          },
        ),
        FilterChip(
          label: const Text("Amici"),
          onSelected: (b) {
            // Logica amici da implementare
            controller.friendStanding();
            refresh();
          },
        ),
      ],
    );
  }

  void showAddFriendModal(BuildContext context) {
    final TextEditingController friendController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "Aggiungi un amico",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: friendController,
                    decoration: const InputDecoration(
                      labelText: 'username',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final friend = friendController.text.trim();
                      if (friend.isNotEmpty) {
                        String res = await controller.addFriend(friendController.text);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(res)),
                        );
                      }
                    },
                    icon: const Icon(Icons.person_add),
                    label: const Text("Aggiungi"),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }


}



