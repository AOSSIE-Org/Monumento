import 'dart:developer' as dev;
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:image_picker/image_picker.dart';
import 'package:monumento/application/popular_monuments/monument_3d_model/monument_3d_model_bloc.dart';
import 'package:monumento/gen/assets.gen.dart';
import 'package:monumento/presentation/popular_monuments/mobile/monument_model_view_mobile.dart';
import 'package:monumento/service_locator.dart';
import 'package:monumento/utils/app_colors.dart';
import 'package:monumento/utils/app_text_styles.dart';
import 'package:monumento/utils/custom_mobile_appBar.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class ScanMonumentsScreen extends StatefulWidget {
  const ScanMonumentsScreen({super.key});

  @override
  State<ScanMonumentsScreen> createState() => _ScanMonumentsScreenState();
}

class _ScanMonumentsScreenState extends State<ScanMonumentsScreen> {
  File? image;
  var monument = "";
  String dropDownValue = 'Asia';

  @override
  Widget build(BuildContext context) {
    return BlocListener<Monument3dModelBloc, MonumentModelState>(
        bloc: locator<Monument3dModelBloc>(),
        listener: (context, state) {
          if (state is LoadingMonumentModelSuccess) {
            if (state.monumentModel.has3DModel) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => MonumentModelViewMobile(
                    monument: state.monumentModel,
                  ),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("3D Model not available for this monument"),
                ),
              );
              return;
            }
          } else if (state is MonumentModelLoadFailed) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("3D Model not available for this monument")));
          }
        },
        child: BlocBuilder<Monument3dModelBloc, MonumentModelState>(
          bloc: locator<Monument3dModelBloc>(),
          builder: (context, state) {
            if (state is LoadingMonumentModel) {
              return const Center(
                child: CircularProgressIndicator(
                  backgroundColor: AppColor.appPrimary,
                ),
              );
            }
            return Scaffold(
              appBar: CustomMobileAppBar(
                leading: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.arrow_back,
                    color: AppColor.appBlack,
                  ),
                ),
                logoPath: Assets.mobile.logoProfile.path,
              ),
              body: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 30,
                    ),
                    image != null
                        ? Container(
                            height: 224,
                            width: 224,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              image: DecorationImage(
                                image: FileImage(image!),
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                        : Container(
                            height: 224,
                            width: 224,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color.fromARGB(255, 136, 197, 205),
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                "Monument Image Here",
                                style: AppTextStyles.textStyle(
                                    fontType: FontType.MEDIUM,
                                    size: 14,
                                    isBody: true),
                              ),
                            ),
                          ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.sp),
                          boxShadow: [
                            BoxShadow(
                                color: AppColor.appSecondary.withOpacity(0.2),
                                offset: const Offset(2, 1))
                          ],
                          color: AppColor.appPrimary),
                      child: Center(
                        child: DropdownButton<String>(
                          style: AppTextStyles.s16(
                            color: AppColor.appSecondary,
                            fontType: FontType.MEDIUM,
                          ),
                          focusColor: AppColor.appPrimary,
                          isDense: true,
                          dropdownColor: AppColor.appPrimary,
                          underline: Container(
                            height: 1,
                            color: AppColor.appPrimary,
                          ),
                          value: dropDownValue,
                          items: const [
                            DropdownMenuItem<String>(
                              value: 'Asia',
                              child: Text("Asia"),
                            ),
                            DropdownMenuItem<String>(
                              value: 'Europe',
                              child: Text("Europe"),
                            )
                          ],
                          onChanged: (newValue) {
                            setState(() {
                              dropDownValue = newValue!;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            var img = await ImagePicker()
                                .pickImage(source: ImageSource.gallery);
                            if (img != null) {
                              setState(() {
                                image = File(img.path);
                              });
                              imageRecognition(image);
                            }
                          },
                          child: Column(
                            children: [
                              const CircleAvatar(
                                child: Icon(Icons.add_photo_alternate_outlined),
                              ),
                              const SizedBox(
                                width: 4,
                              ),
                              Text(
                                "Media",
                                style: AppTextStyles.s14(
                                  color: AppColor.appSecondary,
                                  fontType: FontType.MEDIUM,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        GestureDetector(
                          onTap: () async {
                            var img = await ImagePicker()
                                .pickImage(source: ImageSource.camera);
                            if (img != null) {
                              setState(() {
                                image = File(img.path);
                              });
                              imageRecognition(image);
                            }
                          },
                          child: Column(
                            children: [
                              const CircleAvatar(
                                child: Icon(Icons.camera_alt_outlined),
                              ),
                              const SizedBox(
                                width: 4,
                              ),
                              Text(
                                "Camera",
                                style: AppTextStyles.s14(
                                  color: AppColor.appSecondary,
                                  fontType: FontType.MEDIUM,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      width: 150,
                      child: ElevatedButton(
                        onPressed: () {
                          locator<Monument3dModelBloc>().add(
                              ViewMonument3DModel(
                                  monumentName: monument == ""
                                      ? "Mount Rushmore National Memorial"
                                      : monument));
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          backgroundColor: AppColor.appPrimary,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Assets.icons.ic3d.svg(),
                            SizedBox(
                              width: 8.w,
                            ),
                            Text(
                              "View in 3D",
                              style: AppTextStyles.s16(
                                color: AppColor.appSecondary,
                                fontType: FontType.MEDIUM,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ));
  }

  imageRecognition(File? image) async {
    dev.log(dropDownValue);
    try {
      final inputImage = InputImage.fromFilePath(image!.path);
      final modelPath = await getModelPath(dropDownValue == 'Asia'
          ? 'assets/ml/asia.tflite'
          : 'assets/ml/europe.tflite');
      final options = LocalLabelerOptions(
        confidenceThreshold: 0.8,
        modelPath: modelPath,
      );
      final imageLabeler = ImageLabeler(options: options);
      final List<ImageLabel> labels =
          await imageLabeler.processImage(inputImage);
      var maximum = 0.0;
      for (ImageLabel label in labels) {
        final String text = label.label;
        final double confidence = label.confidence;
        if (maximum < max(maximum, confidence * 100)) {
          maximum = max(maximum, confidence * 100);
          monument = text;
        }
        dev.log('$text:$confidence');
      }
    } catch (e) {
      dev.log("error during image processing $e");
    }
  }

  Future<String> getModelPath(String asset) async {
    final path = '${(await getApplicationSupportDirectory()).path}/$asset';
    await Directory(dirname(path)).create(recursive: true);
    final file = File(path);
    if (!await file.exists()) {
      final byteData = await rootBundle.load(asset);
      await file.writeAsBytes(byteData.buffer
          .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    }
    return file.path;
  }
}
