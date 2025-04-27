import '../database/supabase.dart';

class DetailsController{
  final SupabaseDB _db = SupabaseDB();
  List<Map<String, dynamic>> images = [];


  Future<void> fetchImagesPaths(String title)async{
    images = await _db.getImagesUrl(title);
    print("immagini: $images");
  }

  List<Map<String, dynamic>> getImages(){
    return images;
  }


}