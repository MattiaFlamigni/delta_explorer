import 'package:cloud_firestore/cloud_firestore.dart';

class Firebase {
  FirebaseFirestore _db = FirebaseFirestore.instance;

  /*SEEDER*/
  Future<void> addPOIs() async {
    List<Map<String, dynamic>> pois = [
      // Punti panoramici
      {
        'location': GeoPoint(45.0900, 12.2400),
        'title': 'Punta Alberete',
        'description': 'Vista unica sulla laguna.',
        'category': 'Punto Panoramico'
      },
      {
        'location': GeoPoint(45.1100, 12.2600),
        'title': 'Belvedere del Delta',
        'description': 'Punto panoramico con vista su tutto il delta.',
        'category': 'Punto Panoramico'
      },

      // Oasi e riserve naturali
      {
        'location': GeoPoint(45.1200, 12.3200),
        'title': 'Oasi degli Alberoni',
        'description': 'Importante riserva naturale.',
        'category': 'Oasi Naturale'
      },
      {
        'location': GeoPoint(45.1300, 12.3100),
        'title': 'Oasi di Punte Alberete',
        'description': 'Zona umida protetta, perfetta per la fauna.',
        'category': 'Oasi Naturale'
      },

      // Luoghi storici
      {
        'location': GeoPoint(45.0800, 12.2610),
        'title': 'Torre Abate',
        'description': 'Storica torre di avvistamento.',
        'category': 'Luogo Storico'
      },
      {
        'location': GeoPoint(45.0670, 12.2785),
        'title': 'Comacchio Antico',
        'description': 'Centro storico con canali e ponti caratteristici.',
        'category': 'Luogo Storico'
      },

      // Centri visita e musei
      {
        'location': GeoPoint(45.0851, 12.2984),
        'title': 'Centro Visite del Parco',
        'description': 'Educazione ambientale e punto informativo.',
        'category': 'Centro Visite'
      },
      {
        'location': GeoPoint(45.1000, 12.2900),
        'title': 'Museo Delta Antico',
        'description': 'Museo dedicato alla storia del Delta del Po.',
        'category': 'Centro Visite'
      },

      // Aree di birdwatching
      {
        'location': GeoPoint(45.1050, 12.2850),
        'title': 'Boscone della Mesola',
        'description': 'Zona ricca di avifauna.',
        'category': 'Birdwatching'
      },
      {
        'location': GeoPoint(45.1120, 12.2920),
        'title': 'Porto Tolle Birdwatch',
        'description': 'Perfetto per osservare uccelli migratori.',
        'category': 'Birdwatching'
      },

      // Spiagge e zone umide
      {
        'location': GeoPoint(45.0420, 12.2820),
        'title': 'Isola della Cona',
        'description': 'Importante per la fauna migratoria.',
        'category': 'Spiaggia/Zona Umida'
      },
      {
        'location': GeoPoint(45.0840, 12.2790),
        'title': 'Valli di Comacchio',
        'description': 'Ecosistema ricco di biodiversità.',
        'category': 'Spiaggia/Zona Umida'
      },

      // Porti e villaggi di pescatori
      {
        'location': GeoPoint(45.0670, 12.2785),
        'title': 'Villaggio dei Pescatori',
        'description': 'Tradizione ittica e gastronomia locale.',
        'category': 'Porto/Villaggio Pescatori'
      },
      {
        'location': GeoPoint(45.1120, 12.2920),
        'title': 'Porto di Goro',
        'description': 'Uno dei principali porti pescherecci.',
        'category': 'Porto/Villaggio Pescatori'
      },
    ];


    for (var poi in pois) {
      await _db.collection('POI').add(poi);
    }
  }
  void inserisciCategorie() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Dati delle categorie e sottocategorie
    Map<String, dynamic> categorie = {
      "uccelli": {
        "image_path":"resources/uccelli.png",
        "nome": "Uccelli",
        "sottocategorie": ["Uccelli acquatici", "Rapaci", "Uccelli migratori", "Altri uccelli"]
      },
      "mammiferi": {
        "image_path":"resources/mammiferi.png",
        "nome": "Mammiferi",
        "sottocategorie": ["Mammiferi acquatici", "Cervi e caprioli", "Volpi e cinghiali", "Lupi"]
      },
      "pesci": {
        "image_path":"resources/pesci.png",
        "nome": "Pesci",
        "sottocategorie": ["Pesci d'acqua dolce", "Pesci marini"]
      },
      "rettili": {
        "image_path":"resources/rettili.png",
        "nome": "Rettili",
        "sottocategorie": ["Serpenti", "Lucertole", "Tartarughe"]
      },
      "anfibi": {
        "image_path":"resources/anfibi.png",
        "nome": "Anfibi",
        "sottocategorie": ["Rane", "Salamandre", "Tritoni"]
      },
      "insetti": {
        "image_path":"resources/insetti.png",
        "nome": "Insetti",
        "sottocategorie": ["Farfalline e falene", "Api e impollinatori", "Insetti acquatici"]
      },
      "altro": {
        "image_path":"resources/altro.png",
        "nome": "Altri Animali",
        "sottocategorie": ["Animali invertebrati", "Animali marini", "Specie protette"]
      }
    };

    // Inserisce i dati in Firestore
    categorie.forEach((key, value) async {
      await firestore.collection("categorie_animali").doc(key).set(value);
    });

    print("✅ Categorie inserite con successo!");
  }
  /*END_SEEDERS*/


  Future<List<Map<String, dynamic>>> getPOI() async {
    List<Map<String, dynamic>> poiList = [];

    try {
      QuerySnapshot snapshot = await _db.collection("POI").get();
      for (var doc in snapshot.docs) {
        poiList.add(doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print("Error reading data: $e");
    }

    return poiList;
  }

  Future<List<Map<String, dynamic>>> getData({String collection = "POI"}) async {
    List<Map<String, dynamic>> poiList = [];

    try {
      QuerySnapshot snapshot = await _db.collection(collection).get();
      for (var doc in snapshot.docs) {
        poiList.add(doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print("Error reading data: $e");
    }

    return poiList;
  }

  Future<void> addReports(String image_path, String type, String comment, GeoPoint geopoint) async{
    try {
      await _db.collection('reports').add({
        'data': DateTime.now(),
        'image_path': image_path,
        'comment':comment,
        'type':type,
        'position':geopoint
      });
      print("Data added successfully!");
    } catch (e) {
      print("Error adding document: $e");
    }
  }

  Future<void> addSpotted(String image_path, String type, String comment, String sub, GeoPoint geopoint) async{
    try {
      await _db.collection('spotted').add({
        'data': DateTime.now(),
        'image_path': image_path,
        'comment':comment,
        'category':type,
        'subCategory':sub,
        'location':geopoint

      });
      print("Data added successfully!");
    } catch (e) {
      print("Error adding document: $e");
    }
  }
}


