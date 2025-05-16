import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delta_explorer/constants/point.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants/databaseTable.dart';

class SupabaseDB {
  final supabase = Supabase.instance.client;

  void inserisciCategorie() async {
    print("inserimento");

    Map<String, dynamic> categorie = {
      "uccelli": {
        "image_path": "resources/uccelli.png",
        "nome": "Uccelli",
        "sottocategorie": [
          "Uccelli acquatici",
          "Rapaci",
          "Uccelli migratori",
          "Altri uccelli",
        ],
      },
      "mammiferi": {
        "image_path": "resources/mammiferi.png",
        "nome": "Mammiferi",
        "sottocategorie": [
          "Mammiferi acquatici",
          "Cervi e caprioli",
          "Volpi e cinghiali",
          "Lupi",
        ],
      },
      "pesci": {
        "image_path": "resources/pesci.png",
        "nome": "Pesci",
        "sottocategorie": ["Pesci d'acqua dolce", "Pesci marini"],
      },
      "rettili": {
        "image_path": "resources/rettili.png",
        "nome": "Rettili",
        "sottocategorie": ["Serpenti", "Lucertole", "Tartarughe"],
      },
      "anfibi": {
        "image_path": "resources/anfibi.png",
        "nome": "Anfibi",
        "sottocategorie": ["Rane", "Salamandre", "Tritoni"],
      },
      "insetti": {
        "image_path": "resources/insetti.png",
        "nome": "Insetti",
        "sottocategorie": [
          "Farfalline e falene",
          "Api e impollinatori",
          "Insetti acquatici",
        ],
      },
      "altro": {
        "image_path": "resources/altro.png",
        "nome": "Altri Animali",
        "sottocategorie": [
          "Animali invertebrati",
          "Animali marini",
          "Specie protette",
        ],
      },
    };

    for (var entry in categorie.entries) {
      await supabase
          .from("categorie")
          .insert({
            //"categoria": entry.key, // Nome della categoria
            "image_path": entry.value["image_path"],
            "nome": entry.value["nome"],
            "sottocategorie": entry.value["sottocategorie"],
          })
          .then((response) {
            print("✅ Inserita categoria: ${entry.key}");
          })
          .catchError((error) {
            print("❌ Errore nell'inserimento di ${entry.key}: $error");
          });
    }
  }

  Future<void> removeFriend(String friendID) async {
    try {
      await supabase.from(DatabaseTable.friends).delete().eq("friendID", friendID);
    } catch (e) {
      print("error: $e");
    }
  }

  Future<void> addReports(
    String image_path,
    String type,
    String comment,
    GeoPoint geopoint,
    String? userID,
  ) async {
    try {
      await supabase.from(DatabaseTable.reports).insert({
        'data': DateTime.now().toIso8601String(),
        'image_path': image_path,
        'comment': comment,
        'type': type,
        'position': [geopoint.latitude, geopoint.longitude],
        'user': userID,
      });
      print("Data added successfully!");
    } catch (e) {
      print("Error adding document: $e");
    }
  }

  Future<void> addSpotted(
    String image_path,
    String type,
    String comment,
    String sub,
    GeoPoint geopoint,
    String? userID,
  ) async {
    try {
      await supabase.from(DatabaseTable.spotted).insert({
        'data':
            DateTime.now()
                .toLocal()
                .copyWith(
                  hour: 0,
                  minute: 0,
                  second: 0,
                  millisecond: 0,
                  microsecond: 0,
                )
                .toIso8601String(),

        'image_path': image_path,
        'comment': comment,
        'category': type,
        'subCategory': sub,
        'location': jsonEncode({
          'latitude': geopoint.latitude,
          'longitude': geopoint.longitude,
        }),
        'user': userID,
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
        'location': {'latitude': 45.0900, 'longitude': 12.2400},
        'title': 'Punta Alberete',
        'description': 'Vista unica sulla laguna.',
        'category': 'Punto Panoramico',
      },
      {
        'location': {'latitude': 45.1100, 'longitude': 12.2600},
        'title': 'Belvedere del Delta',
        'description': 'Punto panoramico con vista su tutto il delta.',
        'category': 'Punto Panoramico',
      },

      // Oasi e riserve naturali
      {
        'location': {'latitude': 45.1200, 'longitude': 12.3200},
        'title': 'Oasi degli Alberoni',
        'description': 'Importante riserva naturale.',
        'category': 'Oasi Naturale',
      },
      {
        'location': {'latitude': 45.1300, 'longitude': 12.3100},
        'title': 'Oasi di Punte Alberete',
        'description': 'Zona umida protetta, perfetta per la fauna.',
        'category': 'Oasi Naturale',
      },

      // Altri POI...
    ];

    // Inserisci ogni POI nel database
    for (var poi in pois) {
      try {
        final response = await supabaseClient.from(DatabaseTable.poi).insert({
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

  Future<void> addUser(User user, String username) async {
    try {
      await supabase.from(DatabaseTable.users).insert({
        "id": user.id,
        "username": username,
      });
      print("Nuovo utente inserito: $username");
    } catch (e) {
      print("ERRORE: $e");
    }
  }

  Future<bool> isUsernameAvailable(String username) async {
    final response =
        await supabase
            .from(DatabaseTable.users)
            .select("username")
            .eq("username", username)
            .maybeSingle();

    print("RISPOSTA USER: $response");

    return response != null ? false : true;
  }

  Future<String> addPoints(int points, String userID, String type) async {
    /*VENGONO AGGIUNTI SIA A POINTS SIA A USERS (PER CLASSIFICA AMICI RAPIDA)*/
    try {
      await supabase.from(DatabaseTable.points).insert({
        "userID": userID,
        "numPoints": points,
        "type": type,
      });

      int actualPoint = await getUserPoints(supabase.auth.currentUser!.id);
      await supabase
          .from(DatabaseTable.users)
          .update({"points": actualPoint})
          .eq("id", supabase.auth.currentUser!.id);

      return "punti aggiornati";
    } catch (e) {
      print("errore: $e");
    }
    return "errore nell'aggiornamento dei punti";
  }

  Future<int> getUserPoints(String userID) async {
    try {
      final response = await supabase
          .from(DatabaseTable.points)
          .select("numPoints")
          .eq("userID", userID);

      int totalPoints = 0;
      for (var row in response) {
        totalPoints += row["numPoints"] as int;
      }

      print("PUNTI ATTUALI: $totalPoints");
      return totalPoints;
    } catch (e) {
      print("errore $e");
    }
    return -1;
  }

  Future<List<Map<String, dynamic>>> getPOI() async {
    final supabaseClient = Supabase.instance.client;
    List<Map<String, dynamic>> poiList = [];

    try {
      final response = await supabaseClient.from(DatabaseTable.poi).select();
      poiList = response;
    } catch (e) {
      print("Errore nella lettura dei dati: $e");
    }

    return poiList;
  }

  Future<List<Map<String, dynamic>>> getData({
    String table = DatabaseTable.poi,
    int limit = 0,
  }) async {
    List<Map<String, dynamic>> poiList = [];

    try {
      PostgrestTransformBuilder<PostgrestList> query =
          supabase.from(table).select();

      if (limit != 0) {
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
      hour: 0,
      minute: 0,
      second: 0,
      millisecond: 0,
      microsecond: 0,
    );
    DateTime todayEnd = todayStart.add(Duration(days: 1));

    print("Inizio ricerca 'spotted' per oggi: ${todayStart} - ${todayEnd}");

    try {
      final response = await Supabase.instance.client
          .from(DatabaseTable.reports)
          .select('*')
          .gte('data', todayStart.toIso8601String())
          .lt('data', todayEnd.toIso8601String());

      if (response == null) {
        print("Nessun dato trovato per oggi.");
        return [];
      }

      print("Dati 'spotted' recuperati. Documenti trovati: ${response.length}");

      for (var item in response) {
        Map<String, dynamic> spottedData = Map<String, dynamic>.from(
          item,
        ); // Converti dynamic in Map<String, dynamic>

        // Decodifica il campo 'location'
        final pos = spottedData['position'];

        if (pos is String) {
          try {
            final decoded = jsonDecode(pos);
            if (decoded is Map &&
                decoded.containsKey('lat') &&
                decoded.containsKey('lng')) {
              spottedData['position'] = decoded;
            } else {
              print(
                "Stringa JSON valida ma formato non riconosciuto: $decoded",
              );
            }
          } catch (e) {
            print("Errore nel parsing JSON string di 'position': $e");
          }
        } else if (pos is List && pos.length >= 2) {
          spottedData['position'] = {'lat': pos[0], 'lng': pos[1]};

          print("SPOTTATO: $spottedData");
        } else {
          print("Formato 'position' non riconosciuto o incompleto: $pos");
        }

        print("Documento trovato: ${spottedData}");
        spottedList.add(spottedData);
      }
    } catch (e) {
      print("Errore durante la lettura dei dati: $e");
    }

    print(
      "Fine ricerca 'spotted'. Documenti restituiti: ${spottedList.length}",
    );
    print(spottedList);
    return spottedList;
  }

  Future<int?> countRowFromTableWhereUser(String table, String userid) async {
    try {
      final response =
          await supabase.from(table).select().eq("user", userid).count();
      print("conteggio: ${response.count}");
      return response.count;
    } catch (e) {
      print("Errore durante il conteggio delle righe: $e");
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> global_weekStanding({
    bool week = false,
    bool month = false,
  }) async {
    List<Map<String, dynamic>> list = [];
    String table =
        week
            ? "leaderboard_week"
            : month
            ? "leaderboard_month"
            : "leaderboard";
    try {
      print("tabella: $table");
      var response = await supabase.from(table).select().limit(5);
      list = response;
      print("Classifica: $response");
    } catch (e) {
      print("errore: $e");
    }
    return list;
  }

  Future<int> getTypePoints(String type) async {
    var tot = 0;

    try {
      var response = await supabase
          .from(DatabaseTable.points)
          .select("numPoints")
          .eq("userID", supabase.auth.currentUser!.id)
          .eq("type", type);
      for (var row in response) {
        tot += (row["numPoints"] as int);
      }

      print("totale: $tot");
    } catch (e) {
      print("errore: $e");
    }
    return tot;
  }

  Future<void> addFriends(String userID, String friendUsername) async {
    String friendID = await getIDfromUsername(friendUsername);

    try {
      await supabase.from(DatabaseTable.friends).insert({
        "id": userID,
        "friendID": friendID,
      });

      // Aggiungi l'amicizia da B a A (l'amico vede anche A come amico)
      await supabase.from(DatabaseTable.friends).insert({
        "id": friendID,
        "friendID": userID,
      });
    } catch (e) {
      print("errore: $e");
    }
  }

  Future<List<String>> getFriends(String userID) async {
    try {
      var response = await supabase
          .from(DatabaseTable.friends)
          .select("friendID")
          .eq("id", userID);
      print("AMICI: $response");
      // Estrai solo gli ID
      return response
          .map<String>((item) => item["friendID"] as String)
          .toList();
    } catch (e) {
      print("errore: $e");
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> friendsStanding(String userID) async {
    List<String> friendsIDs = await getFriends(userID);
    friendsIDs.add(userID); // Aggiungi anche te stesso

    final response = await supabase
        .from(DatabaseTable.users)
        .select("id, username, points")
        .inFilter("id", friendsIDs)
        .order("points", ascending: false);

    print("CLASSIFICA AMICI: $response");
    return response;
  }

  Future<String> getUsernameFromID(String userID) async {
    try {
      var res =
          await supabase
              .from(DatabaseTable.users)
              .select("username")
              .eq("id", userID)
              .single();
      return res["username"];
    } catch (e) {
      print("errore: $e");
    }
    return "";
  }

  Future<String> getIDfromUsername(String username) async {
    try {
      var response =
          await supabase
              .from(DatabaseTable.users)
              .select("id")
              .eq("username", username)
              .single();
      return response["id"];
    } catch (e) {
      print("error: $e");
      return "";
    }
  }

  Future<bool> existFriend(String username) async {
    try {
      var response = await supabase
          .from(DatabaseTable.users)
          .select()
          .eq("username", username);
      if (response.isNotEmpty) {
        return true;
      }
      return false;
    } catch (e) {
      print("error: $e");
      return false;
    }
  }

  Future<int> addPercorso(
    String titolo,
    String descrizione,
    String userID,
    double distanza,
  ) async {
    var response =
        await supabase
            .from(DatabaseTable.percorsi)
            .insert({
              "titolo": titolo,
              "descrizione": descrizione,
              "userID": userID,
              "distanza": distanza,
            })
            .select("id")
            .single();

    return response["id"] as int;
  }

  Future<void> addTripImages(int idViaggio, String imagePath) async {
    print("IDVIAGGIO: $idViaggio");
    try {
      await supabase.from('tripImages').insert({
        'idViaggio': idViaggio,
        'image_path': imagePath,
      });
      print('Inserimento riuscito.');
    } catch (e) {
      print('Eccezione durante l\'inserimento: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getImagesUrl(String title) async {
    var id = await fetchTripIdFromTitle(title); // id è un int
    return await supabase
        .from(DatabaseTable.tripImages)
        .select()
        .eq("idViaggio", id); // correggi il nome della colonna
  }

  Future<int> fetchTripIdFromTitle(String title) async {
    var response =
        await supabase
            .from(DatabaseTable.percorsi)
            .select("id")
            .eq("titolo", title)
            .single();
    return response["id"] as int; // ritorna direttamente un int
  }

  Future<void> deleteTrip(int tripId) async {
    await supabase.from(DatabaseTable.percorsi).delete().eq("id", tripId);
  }

  Future<List<Map<String, dynamic>>> getCoordByTripId(int tripId) async {
    return await supabase.from(DatabaseTable.coordinate).select().eq("idPercorso", tripId);
  }

  Future<void> addCoord(List<Position> posizioni, int idPercorso) async {
    final supabase = Supabase.instance.client;

    final coordinate =
        posizioni
            .map(
              (pos) => {
                'idPercorso': idPercorso, // foreign key al percorso
                'lat': pos.latitude,
                'lon': pos.longitude,
              },
            )
            .toList();

    try {
      await supabase.from(DatabaseTable.coordinate).insert(coordinate);
      print("Coordinate inserite con successo!");
    } catch (e) {
      print("Errore durante inserimento coordinate: $e");
    }
  }

  Future<List<Map<String, dynamic>>> getTrip(String userID) async {
    try {
      var trip = await supabase.from(DatabaseTable.percorsi).select().eq("userID", userID);
      return trip;
    } catch (e) {
      print("error: $e");
      return [];
    }
  }

  Future<double> getTotKm(String userId) async {
    double tot = 0;

    try {
      var response = await supabase
          .from(DatabaseTable.percorsi)
          .select()
          .eq("userID", userId);
      for (var row in response) {
        tot += row["distanza"];
      }

      return tot;
    } catch (e) {
      print("error: $e");
      return -1;
    }
  }

  Future<void> incrementVerifiedReport(int reportId) async {
    //recupero il valore
    try {
      var response =
          await supabase.from(DatabaseTable.reports).select().eq("id", reportId).single();
      int num = response["verified"];

      print("NUMERO OTTENUTO: $num");

      //incremento +1
      await supabase
          .from(DatabaseTable.reports)
          .update({"verified": num + 1})
          .eq("id", reportId);
    } catch (e) {
      print("error: $e");
    }
  }







  Future<String?> uploadPNGImage(File image, String bucket) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final String fullPath = await supabase.storage
          .from(bucket)
          .upload(
        '$fileName.png',
        image,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
      );
      return fullPath;
    } catch (e) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getQuestions() async {
    try {
      var response = await supabase.from(DatabaseTable.questionsQuiz).select();
      return response;
    }catch(e){
      print("error: $e");
      return [];
    }
  }
  
  Future<List<Map<String, dynamic>>> getAnswers(int questionId) async{
    try {
      var response = await supabase.from(DatabaseTable.answer).select().eq(
          "questionID", questionId);
      return response;
    }catch(e){
      print("errore: $e");
      return[];
    }
  }

  Future<void> saveQuizResult(int accuracy, int duration, int skipped, int incorrect, int score)async{
    try{
      await supabase.from(DatabaseTable.quizScore).insert({
        "accuracy" : accuracy,
        "duration" : duration,
        "skipped" : skipped,
        "incorrect":incorrect,
        "score":score,
        "userID":supabase.auth.currentUser!.id,
      });

    }catch(e){
      print("error: $e");
    }
  }
  
  Future<List<Map<String, dynamic>>> getPastQuiz()async{
    try{

        var response = await supabase.from(DatabaseTable.quizScore).select().eq(
            "userID", supabase.auth.currentUser!.id);
        return response;


    }catch(e){
      print("error: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getARModels()async{
    try {
      var response = await supabase.from(DatabaseTable.models).select();
      return response;
    }catch(e){
      print("error: $e");
      return [];
    }
  }

  /*only for populate database*/
  Future<void> insertQuestionQuiz(String question, List<Map<String, dynamic>>options) async{
    try{
      var responseQuestion = await supabase.from(DatabaseTable.questionsQuiz).insert({"question":question}).select().single();
      var questionID = responseQuestion["id"];
      for(var option in options){
        await supabase.from(DatabaseTable.answer).insert({
          "answer":option["answer"],
          "correct": option["correct"],
          "questionID":questionID
        });
      }



    }catch(e){
      print("errore: $e");
    }
  }


}
