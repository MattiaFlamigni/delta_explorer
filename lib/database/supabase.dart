import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseDB {
  final supabase = Supabase.instance.client;

  void inserisciCategorie() async {

    print("inserimento");

    Map<String, dynamic> categorie = {
      "uccelli": {
        "image_path": "resources/uccelli.png",
        "nome": "Uccelli",
        "sottocategorie": ["Uccelli acquatici", "Rapaci", "Uccelli migratori", "Altri uccelli"]
      },
      "mammiferi": {
        "image_path": "resources/mammiferi.png",
        "nome": "Mammiferi",
        "sottocategorie": ["Mammiferi acquatici", "Cervi e caprioli", "Volpi e cinghiali", "Lupi"]
      },
      "pesci": {
        "image_path": "resources/pesci.png",
        "nome": "Pesci",
        "sottocategorie": ["Pesci d'acqua dolce", "Pesci marini"]
      },
      "rettili": {
        "image_path": "resources/rettili.png",
        "nome": "Rettili",
        "sottocategorie": ["Serpenti", "Lucertole", "Tartarughe"]
      },
      "anfibi": {
        "image_path": "resources/anfibi.png",
        "nome": "Anfibi",
        "sottocategorie": ["Rane", "Salamandre", "Tritoni"]
      },
      "insetti": {
        "image_path": "resources/insetti.png",
        "nome": "Insetti",
        "sottocategorie": ["Farfalline e falene", "Api e impollinatori", "Insetti acquatici"]
      },
      "altro": {
        "image_path": "resources/altro.png",
        "nome": "Altri Animali",
        "sottocategorie": ["Animali invertebrati", "Animali marini", "Specie protette"]
      }
    };

    for (var entry in categorie.entries) {
      await supabase.from("categorie").insert({
        //"categoria": entry.key, // Nome della categoria
        "image_path": entry.value["image_path"],
        "nome": entry.value["nome"],
        "sottocategorie": entry.value["sottocategorie"],
      }).then((response) {
        print("✅ Inserita categoria: ${entry.key}");
      }).catchError((error) {
        print("❌ Errore nell'inserimento di ${entry.key}: $error");
      });
    }
  }

  Future<void> addReports(String image_path, String type, String comment, GeoPoint geopoint, String? userID) async{
    try {
      await supabase.from("reports").insert({
        'data': DateTime.now().toIso8601String(),
        'image_path': image_path,
        'comment':comment,
        'type':type,
        'position': [geopoint.latitude, geopoint.longitude],
        'user':userID
      });
      print("Data added successfully!");
    } catch (e) {
      print("Error adding document: $e");
    }
  }

  Future<void> addSpotted(String image_path, String type, String comment, String sub, GeoPoint geopoint, String? userID) async {
    try {
      await supabase.from('spotted').insert({
        'data': DateTime.now().toLocal().copyWith(
            hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0).toIso8601String(),

        'image_path': image_path,
        'comment': comment,
        'category': type,
        'subCategory': sub,
        'location': jsonEncode({
          'latitude': geopoint.latitude,
          'longitude': geopoint.longitude
        }),
        'user' : userID,
      });

      print("Data added successfully!");
    } catch (e) {
      print("Error adding document: $e");
    }
  }

  Future<void> addPOIs() async {
    final supabaseClient = Supabase.instance.client;

    List<Map<String, dynamic>> pois = [
      // Punti panoramici
      {
        'location': {
          'latitude': 45.0900,
          'longitude': 12.2400
        },
        'title': 'Punta Alberete',
        'description': 'Vista unica sulla laguna.',
        'category': 'Punto Panoramico'
      },
      {
        'location': {
          'latitude': 45.1100,
          'longitude': 12.2600
        },
        'title': 'Belvedere del Delta',
        'description': 'Punto panoramico con vista su tutto il delta.',
        'category': 'Punto Panoramico'
      },

      // Oasi e riserve naturali
      {
        'location': {
          'latitude': 45.1200,
          'longitude': 12.3200
        },
        'title': 'Oasi degli Alberoni',
        'description': 'Importante riserva naturale.',
        'category': 'Oasi Naturale'
      },
      {
        'location': {
          'latitude': 45.1300,
          'longitude': 12.3100
        },
        'title': 'Oasi di Punte Alberete',
        'description': 'Zona umida protetta, perfetta per la fauna.',
        'category': 'Oasi Naturale'
      },

      // Altri POI...
    ];

    // Inserisci ogni POI nel database
    for (var poi in pois) {
      try {
        final response = await supabaseClient.from('poi').insert({
          'location': poi['location'],
          'title': poi['title'],
          'description': poi['description'],
          'category': poi['category'],
        });

        if (response.error != null) {
          print("Errore nell'inserimento POI: ${response.error?.message}");
        } else {
          print("POI inserito correttamente: ${poi['title']}");
        }
      } catch (e) {
        print("Errore nell'inserimento: $e");
      }
    }
  }

  Future<void> addUser(User user) async{
    try {
      await supabase.from("users").insert({"id": user.id});
    }catch(e){
      print("ERRORE: $e");
    }
  }

  Future<String> addPoints(int points, String userID) async{

    int partialPoints = await getUserPoints(userID);
    int finalPoints = partialPoints+points;

    try{
      await supabase.from("users").update({"points":finalPoints}).eq("id", userID);
      print("PUNTI AGGIORNATI: $finalPoints");
      return "punti aggiornati";
    }catch(e){
      print("errore: $e");
    }
    return "errore nell'aggiornamento dei punti";

  }

  Future<int> getUserPoints(String userID) async {
    try {
      final response = await supabase.from("users").select("points").eq("id", userID).single();
      final points = response["points"];
      print("PUNTI ATTUALI: $points");
      return points;

    }catch(e){
      print("errore $e");
    }
    return -1;
  }

  Future<List<Map<String, dynamic>>> getPOI() async {
    final supabaseClient = Supabase.instance.client;
    List<Map<String, dynamic>> poiList = [];

    try {
      final response = await supabaseClient.from('poi').select();
      poiList =response;
    } catch (e) {
      print("Errore nella lettura dei dati: $e");
    }

    return poiList;
  }

  Future<List<Map<String, dynamic>>> getData({String table = "poi", int limit = 0}) async {
    List<Map<String, dynamic>> poiList = [];

    try {


      PostgrestTransformBuilder<PostgrestList> query = supabase.from(table).select();

      if(limit!=0) {
        query = query.limit(limit);
      }

      final response = await query;




      if (response == null || response.isEmpty) {
        print("No data found in table: $table");
        return [];
      }

      // Supabase returns a List<Map<String, dynamic>> directly
      poiList = List<Map<String, dynamic>>.from(response);
      print("eccola $poiList");

    } catch (e) {
      print("Error reading data from Supabase: $e");
    }
    return poiList;
  }

  Future<List<Map<String, dynamic>>> getTodaySpotted() async {
    List<Map<String, dynamic>> spottedList = [];
    DateTime todayStart = DateTime.now().toLocal().copyWith(
        hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0
    );
    DateTime todayEnd = todayStart.add(Duration(days: 1));

    print("Inizio ricerca 'spotted' per oggi: ${todayStart} - ${todayEnd}");

    try {
      final response = await Supabase.instance.client
          .from('spotted')
          .select('*')
          .gte('data', todayStart.toIso8601String())
          .lt('data', todayEnd.toIso8601String());

      if (response == null) {
        print("Nessun dato trovato per oggi.");
        return [];
      }

      print("Dati 'spotted' recuperati. Documenti trovati: ${response.length}");

      for (var item in response) {
        Map<String, dynamic> spottedData = Map<String, dynamic>.from(item); // Converti dynamic in Map<String, dynamic>

        // Decodifica il campo 'location'
        if (spottedData.containsKey('location') && spottedData['location'] != null) {
          try {
            Map<String, dynamic> location = jsonDecode(spottedData['location']);
            spottedData['location'] = location; // Sostituisci la stringa JSON con la mappa decodificata
          } catch (e) {
            print("Errore durante la decodifica di 'location': $e");
          }
        }

        print("Documento trovato: ${spottedData}");
        spottedList.add(spottedData);
      }
    } catch (e) {
      print("Errore durante la lettura dei dati: $e");
    }

    print("Fine ricerca 'spotted'. Documenti restituiti: ${spottedList.length}");
    print(spottedList);
    return spottedList;
  }

  Future<int?> countRowFromTableWhereUser(String table, String userid) async{
    try{
      final response = await supabase.from(table).select().eq("user", userid).count();
      print("conteggio: ${response.count}");
      return response.count ;
    }catch(e){
      print("Errore durante il conteggio delle righe: $e");
      return null;
    }
  }


}
