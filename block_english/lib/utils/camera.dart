import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class Camera {
  static late List<CameraDescription> cameras;
  static initCamera() async {
    WidgetsFlutterBinding.ensureInitialized();

    cameras = await availableCameras();
  }
}
