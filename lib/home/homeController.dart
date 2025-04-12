import 'package:weatherapi/weatherapi.dart';

import '../database/supabase.dart';

class HomeController{
  final WeatherRequest wr = WeatherRequest('9e7aac68e41b4e53877132202250804');
  final SupabaseDB db = SupabaseDB();



  Future<List<Map<String, dynamic>>>getMeteo() async {
    List<Map<String, dynamic>> meteoCondition = [];
    var meteo = await wr.getRealtimeWeatherByLocation(44.95, 12.41);

    meteoCondition.add({
      "temp": meteo.current.tempC,
      "humidity": meteo.current.humidity,
      "windSpeed": meteo.current.windMph,
      "rain": meteo.current.precipMm,
      "icona": meteo.current.condition.icon,
      "condition": meteo.current.condition.text,
      "windDirection": meteo.current.windDir,
    });

    return meteoCondition;
  }

  String getMainImageDescription() {
    return '''
Benvenuto nel Parco del Delta del Po dell’Emilia-Romagna, un territorio dove la natura incontra l’avventura! Preparati a esplorare paesaggi mozzafiato, costellati da lagune, canali e sentieri immersi nel silenzio.
Lasciati guidare tra antiche valli da pesca, boschi misteriosi e distese d’acqua popolate da fenicotteri e altre specie rare. Ad ogni passo, ogni avvistamento e ogni scoperta potrai collezionare ricordi... e magari anche qualche badge!
Che tu sia un esploratore curioso, un fotografo appassionato o un semplice amante delle passeggiate nella natura, qui troverai un’esperienza unica, tra avventure, biodiversità e la magia di un paesaggio in continua trasformazione.
Sei pronto a metterti in gioco? La natura ti aspetta! 🌿🦩📍
''';
  }


  Future<List<Map<String, dynamic>>> getCuriosity() async {
    var cur = await db.getData(table: "curiosity");
    return cur;
  }

  Future<List<Map<String, dynamic>>> getSpotted() async {

    var spotted = await db.getData(table: "spotted", limit: 3);
    spotted.shuffle();
    spotted= spotted.sublist(0,2);
    return spotted;

  }


}