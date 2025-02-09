import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:monumento/domain/entities/monument_entity.dart';
import 'package:monumento/utils/app_colors.dart';
import 'package:monumento/utils/custom_mobile_appBar.dart';

class MonumentModelViewDesktop extends StatefulWidget {
  final MonumentEntity monument;
  const MonumentModelViewDesktop({super.key, required this.monument});

  @override
  State<MonumentModelViewDesktop> createState() =>
      _MonumentModelViewDesktopState();
}

class _MonumentModelViewDesktopState extends State<MonumentModelViewDesktop> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomMobileAppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppColor.appBlack,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          Text(
            widget.monument.name,
            style: TextStyle(color: AppColor.appBlack),
          ),
        ],
      ),
      body: ModelViewer(
        backgroundColor: const Color.fromARGB(0xFF, 0xEE, 0xEE, 0xEE),
        src: widget.monument.modelLink!,
        ar: true,
        autoRotate: true,
        disableZoom: true,
      ),
    );
  }
}
