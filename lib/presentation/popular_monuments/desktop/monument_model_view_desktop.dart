import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:monumento/domain/entities/monument_entity.dart';

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
      appBar: AppBar(
        title: Text(widget.monument.name),
      ),
      body: ModelViewer(
        backgroundColor: Color.fromARGB(0xFF, 0xEE, 0xEE, 0xEE),
        src: widget.monument.modelLink!,
        ar: true,
        autoRotate: true,
        disableZoom: true,
      ),
      // body: Container(
      //   color: Colors.white,
      //   child: Stack(
      //     children: [
      //       ThreeJSViewer(
      //         scale: 4500,
      //         onError: ((message, code) {
      //           print("Error: $message, Code: $code");
      //         }),
      //         progressBuilder: (double? progress, String message) {
      //           return Column(
      //             mainAxisAlignment: MainAxisAlignment.center,
      //             children: [
      //               CircularProgressIndicator(
      //                 value: progress,
      //                 color: Colors.red,
      //                 backgroundColor: Colors.black,
      //               ),
      //               SizedBox(
      //                 height: 20,
      //                 width: double.infinity,
      //               ),
      //               Text(message),
      //             ],
      //           );
      //         },
      //         onWebViewCreated: (c) {
      //           controller = c;
      //         },
      //         debug: kDebugMode,
      //         models: [
      //           ThreeModel(
      //             src: widget.monument.modelLink!,
      //             playAnimation: false,
      //           ),
      //         ],
      //       ),
      //     ],
      //   ),
      // ),
    );
  }
}
