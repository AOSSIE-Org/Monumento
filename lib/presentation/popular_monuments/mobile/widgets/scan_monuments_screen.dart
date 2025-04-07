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
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        image != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12.r),
                                child: Image.file(
                                  image!,
                                  height: 250.w,
                                  width: 250.w,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Container(
                                height: 250.w,
                                width: 250.w,
                                decoration: BoxDecoration(
                                  color: AppColor.appPrimary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(
                                    color: AppColor.appPrimary,
                                    width: 1.5,
                                    style: BorderStyle.solid,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.image_search,
                                      size: 60.sp,
                                      color: AppColor.appPrimary,
                                    ),
                                    SizedBox(height: 10.h),
                                    Text(
                                      "Select Monument Image",
                                      style: AppTextStyles.s16(
                                          color: AppColor.appSecondary,
                                          fontType: FontType.MEDIUM),
                                    ),
                                  ],
                                ),
                              ),
                        const SizedBox(
                          height: 30,
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 5.h),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.r),
                              color: AppColor.appPrimary.withOpacity(0.9),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColor.appBlack.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                )
                              ]),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              style: AppTextStyles.s16(
                                color: AppColor.appSecondary,
                                fontType: FontType.MEDIUM,
                              ),
                              icon: Icon(Icons.arrow_drop_down, color: AppColor.appSecondary),
                              focusColor: Colors.transparent,
                              isDense: true,
                              dropdownColor: AppColor.appPrimary,
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
                          height: 30,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildImageSourceButton(
                              icon: Icons.photo_library_outlined,
                              label: "Gallery",
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
                            ),
                            _buildImageSourceButton(
                              icon: Icons.camera_alt_outlined,
                              label: "Camera",
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
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 40,
                        ),
                        _build3dButton(
                          text: "View in 3D",
                          onPressed: image == null
                              ? null
                              : () {
                                  locator<Monument3dModelBloc>().add(
                                      ViewMonument3DModel(
                                          monumentName: monument == ""
                                              ? "Mount Rushmore National Memorial"
                                              : monument));
                                },
                        ),
                        SizedBox(height: 15.h),
                        _build3dButton(
                          text: "See 3D Demo",
                          onPressed: () {
                            locator<Monument3dModelBloc>().add(
                                ViewMonument3DModel(
                                    monumentName: "Mount Rushmore National Memorial"));
                          },
                        ),
                      ],
                    ),
                  ),
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

  Widget _buildImageSourceButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 30.r,
            backgroundColor: AppColor.appPrimary.withOpacity(0.15),
            child: Icon(icon, size: 30.sp, color: AppColor.appPrimary),
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: AppTextStyles.s14(
              color: AppColor.appSecondary,
              fontType: FontType.MEDIUM,
            ),
          ),
        ],
      ),
    );
  }

  Widget _build3dButton({required String text, required VoidCallback? onPressed}) {
    return SizedBox(
      width: 200.w,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          backgroundColor: AppColor.appPrimary,
          foregroundColor: AppColor.appSecondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          elevation: 3,
        ),
        icon: Assets.icons.ic3d.svg(
          colorFilter: ColorFilter.mode(AppColor.appSecondary, BlendMode.srcIn),
        ),
        label: Text(
          text,
          style: AppTextStyles.s16(
            color: AppColor.appSecondary,
            fontType: FontType.MEDIUM,
          ),
        ),
      ),
    );
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
