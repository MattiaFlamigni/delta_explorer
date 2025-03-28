import 'package:cloud_firestore/cloud_firestore.dart';

class Firebase {
  FirebaseFirestore db = FirebaseFirestore.instance;


  // TEST PASSED - NOT USE THIS
  Future<void> addData() async {
    try {
      await db.collection('users').add({
        'name': 'John Doe',
        'age': 30,
      });
      print("Data added successfully!");
    } catch (e) {
      print("Error adding document: $e");
    }

  }



  Future<List<Map<String, dynamic>>> getPOI() async {
    List<Map<String, dynamic>> poiList = [];

    try {
      QuerySnapshot snapshot = await db.collection("POI").get();
      for (var doc in snapshot.docs) {
        poiList.add(doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print("Error reading data: $e");
    }

    return poiList;
  }

  Future<void> addPOIs() async {
    // Crea un elenco di POI del Parco Delta del Po
    List<Map<String, dynamic>> pois = [
      {
        'location': GeoPoint(45.0639, 12.2777), // Delta del Po
        'title': 'Parco Delta del Po',
        'description': 'Un bellissimo parco naturale ricco di fauna e flora.',
      },
      {
        'location': GeoPoint(45.0851, 12.2984), // Centro Visite
        'title': 'Centro Visite del Parco',
        'description': 'Centro di educazione ambientale e punto di riferimento per i visitatori.',
      },
      {
        'location': GeoPoint(45.1200, 12.3200), // Oasi degli Alberoni
        'title': 'Oasi degli Alberoni',
        'description': 'Una riserva naturale importante per l’avifauna e habitat umidi.',
      },
      {
        'location': GeoPoint(45.1050, 12.2850), // Boscone della Mesola
        'title': 'Boscone della Mesola',
        'description': 'Un bosco secolare con fauna e flora tipiche della zona.',
      },
      {
        'location': GeoPoint(45.0800, 12.2610), // Torre Abate
        'title': 'Torre Abate',
        'description': 'Una storica torre di avvistamento nel cuore del parco.',
      },
      {
        'location': GeoPoint(45.0420, 12.2820), // Isola della Cona
        'title': 'Isola della Cona',
        'description': 'Un’isola naturale importante per la fauna migratoria.',
      },
      {
        'location': GeoPoint(45.0670, 12.2785), // Comacchio
        'title': 'Comacchio',
        'description': 'Famosa per i suoi canali e la storica pesca delle anguille.',
      },
      {
        'location': GeoPoint(45.0840, 12.2790), // Valli di Comacchio
        'title': 'Valli di Comacchio',
        'description': 'Le valli sono un ecosistema ricco di biodiversità, specie migratorie e fauna locale.',
      },
      {
        'location': GeoPoint(45.0900, 12.2400), // Punta Alberete
        'title': 'Punta Alberete',
        'description': 'Un punto panoramico che offre una vista unica sulla laguna.',
      },
      {
        'location': GeoPoint(45.1120, 12.2920), // Porto Tolle
        'title': 'Porto Tolle',
        'description': 'Un antico porto nel Delta, ottimo per l’osservazione degli uccelli migratori.',
      },
    ];

    // Aggiungi i POI al database Firestore
    for (var poi in pois) {
      await db.collection('POI').add(poi);
    }
  }



}