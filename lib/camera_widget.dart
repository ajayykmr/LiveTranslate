import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:live_translate/recognition_api.dart';
import 'package:live_translate/translation_api.dart';

class CameraWidget extends StatefulWidget {
  final CameraDescription camera;
  const CameraWidget({required this.camera, super.key});

  @override
  State<CameraWidget> createState() => _CameraWidgetState();
}

class _CameraWidgetState extends State<CameraWidget> {
  late CameraController cameraController;
  String? shownText;
  late Future<void> initCameraFn;

  @override
  void initState() {
    super.initState();
    cameraController = CameraController(
      widget.camera,
      ResolutionPreset.max,

    );

    initCameraFn = cameraController.initialize();
  }

  @override
  void dispose() {
    super.dispose();
    cameraController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(alignment: AlignmentDirectional.bottomCenter, children: [
      FutureBuilder(
        future: initCameraFn,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator.adaptive(),
            );
          }

          return Center(child: CameraPreview(cameraController));

        },
      ),
      Positioned(
        bottom: 50,
        child: FloatingActionButton(
          onPressed: () async {
            shownText=null;
            final image = await cameraController.takePicture();
            final recognizedText = await RecognitionApi.recognizeText(
                InputImage.fromFile(File(image.path)));

            if (recognizedText != null) {
              final translatedText =
                  await TranslationApi.translateText(recognizedText);
              setState(() {
                shownText = translatedText;
              });
            }
          },
          child: const Icon(Icons.translate),
        ),
      ),
      if (shownText != null)
        Align(
          alignment: Alignment.center,
          child: Container(
            color: Colors.black45,
            child: Text(
              shownText!,
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        )
    ]);
  }
}
