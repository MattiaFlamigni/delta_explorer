import '../database/supabase.dart';

class TripController {
  final SupabaseDB _db = SupabaseDB();
  List<Map<String, dynamic>> _tripPassati =
      []; //lista dei viaggi passati ottenuti dal db

  Future<void> fetchTrip() async {
    var trip = await _db.getTrip(_db.supabase.auth.currentUser!.id);
    _tripPassati = trip;
  }

  Future<void> deleteTrip(int tripId) async {
    await _db.deleteTrip(tripId);
    await fetchTrip();
  }

  List<Map<String, dynamic>> getTripPassati() {
    return _tripPassati;
  }
}
