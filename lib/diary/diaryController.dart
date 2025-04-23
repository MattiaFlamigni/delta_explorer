import 'package:image_picker/image_picker.dart';

class DiaryController{
  bool _registrando = false;
  List<XFile> images = [];



  bool getStatus(){
    return _registrando;
  }

  void changeStatus(){
    _registrando = !_registrando;
  }

  Future<void> pickImagesFromGallery() async {
    final ImagePicker _picker = ImagePicker();
    final List<XFile> selectedImages = await _picker.pickMultiImage();

    if (selectedImages.isNotEmpty) {
      images.addAll(selectedImages);
    }
  }

  getImages(){
    return images;
  }


}