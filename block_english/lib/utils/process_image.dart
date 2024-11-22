import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;

class ProcessImage {
  static Future<Uint8List> cropImage(XFile xFile) async {
    final image = img.decodeImage(await xFile.readAsBytes());

    if (image == null) {
      throw Exception();
    }

    // int cropHeight = image.height * (155 ~/ 375);
    // int startHeight = image.height * (110 ~/ 375);

    // final processedImaged = img.copyCrop(
    //   image,
    //   x: 0,
    //   y: startHeight,
    //   width: image.width,
    //   height: cropHeight,
    // );

    final rotatedImage = img.copyRotate(image, angle: 180);
    final png = img.encodePng(rotatedImage);
    return png;
  }
}
