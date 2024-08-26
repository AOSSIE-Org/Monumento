import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:monumento/domain/entities/monument_entity.dart';

class MonumentModelViewMobile extends StatefulWidget {
  final MonumentEntity monument;
  const MonumentModelViewMobile({super.key, required this.monument});

  @override
  State<MonumentModelViewMobile> createState() =>
      _MonumentModelViewMobileState();
}

class _MonumentModelViewMobileState extends State<MonumentModelViewMobile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.monument.name),
      ),
      body: Center(
        child: ModelViewer(
          src: widget.monument.modelLink!,
          alt: 'A 3D model of an astronaut',
          autoPlay: true,
          autoRotate: false,
          ar: true,
          cameraControls: true,
          iosSrc: 'https://modelviewer.dev/shared-assets/models/Astronaut.usdz',
        ),
      ),
    );
  }
}



