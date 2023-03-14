import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class PickImage {
  static Future<File> takePicture({ImageSource imageSource}) async {
    try {
      final _imagePicker = ImagePicker();
      final imagePickerFile = await _imagePicker.getImage(
        source: imageSource,
      );
      File imageFile = File(imagePickerFile.path);
      if (imageFile == null) {
        return null;
      }

      return imageFile;
    } catch (e) {
      print(e.toString());
    }
  }

  static Future<File> cropImage(
      {@required File image,
      @required double ratioX,
      @required double ratioY}) async {
    File croppedImageFile = await ImageCropper().cropImage(
        sourcePath: image.path,
        aspectRatio: CropAspectRatio(ratioX: ratioX, ratioY: ratioY),
        compressQuality: 15);
    if (croppedImageFile == null) {
      return null;
    }
    print(croppedImageFile.path + " file name");
    return croppedImageFile;
  }
}
