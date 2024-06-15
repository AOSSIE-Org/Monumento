import 'dart:developer';
import 'dart:io';

import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class PickImage {
  static Future<File> takePicture({required ImageSource imageSource}) async {
    try {
      final imagePicker = ImagePicker();
      final imagePickerFile = await imagePicker.pickImage(
        source: imageSource,
      );
      File imageFile = File(imagePickerFile!.path);
      return imageFile;
    } catch (e) {
      log(e.toString());
      return File('');
    }
  }

  static Future<File> cropImage(
      {required File image,
      required double ratioX,
      required double ratioY}) async {
    CroppedFile? croppedImageFile = await ImageCropper().cropImage(
        sourcePath: image.path,
        aspectRatio: CropAspectRatio(ratioX: ratioX, ratioY: ratioY),
        compressQuality: 15);
    File croppedImage = File(croppedImageFile!.path);
    log("${croppedImageFile.path} file name");
    return croppedImage;
  }
}
