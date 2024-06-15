import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:monumento/presentation/home/mobile/widgets/pick_image.dart';
import 'package:monumento/utils/app_colors.dart';
import 'package:monumento/utils/app_text_styles.dart';

class NewPostBottomSheet {
  newPostBottomSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (_) {
          return Container(
            padding: const EdgeInsets.all(16),
            height: 150,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "New Post",style: AppTextStyles.s18(
                          color: AppColor.appSecondary,
                          fontType: FontType.MEDIUM,
                        ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Column(
                      children: [
                        IconButton(
                            iconSize: 60,
                            icon: const Icon(Icons.camera),
                            onPressed: () {
                              Navigator.pop(context);
                              newPostPickImage(ImageSource.camera);
                            }),
                        const Text("Camera")
                      ],
                    ),
                    Column(
                      children: [
                        IconButton(
                            iconSize: 60,
                            icon: const Icon(Icons.image),
                            onPressed: () {
                              Navigator.pop(context);
                              newPostPickImage(ImageSource.gallery);
                            }),
                        const Text("Gallery")
                      ],
                    )
                  ],
                ),
              ],
            ),
          );
        });
  }
  Future newPostPickImage(ImageSource source) async {
    File image = await PickImage.takePicture(imageSource: source);
    File croppedImage =
        await PickImage.cropImage(image: image, ratioX: 1, ratioY: 1);
        //TODO: create a new post
    // Navigator.of(context).pushNamed(NewPostScreen.route,
    //     arguments: NewPostScreenArguments(pickedImage: croppedImage));
    print(croppedImage);
  }
}
