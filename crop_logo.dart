import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  final path = 'assets/images/splash_screen/logo.png.png';
  final bytes = File(path).readAsBytesSync();
  final image = img.decodeImage(bytes);

  if (image == null) {
    print('Could not decode image');
    return;
  }

  int minX = image.width;
  int minY = image.height;
  int maxX = 0;
  int maxY = 0;
  bool found = false;

  for (int y = 0; y < image.height; y++) {
    for (int x = 0; x < image.width; x++) {
      final pixel = image.getPixel(x, y);
      if (pixel.a > 0) {
        if (x < minX) minX = x;
        if (y < minY) minY = y;
        if (x > maxX) maxX = x;
        if (y > maxY) maxY = y;
        found = true;
      }
    }
  }

  if (!found) return;

  final logoWidth = maxX - minX + 1;
  final logoHeight = maxY - minY + 1;
  final size = logoWidth > logoHeight ? logoWidth : logoHeight;
  
  // 3% margin to make it as big as possible without touching edges
  final margin = (size * 0.03).toInt(); 
  final totalSize = size + (margin * 2);

  final newImage = img.Image(width: totalSize, height: totalSize, numChannels: 4);
  
  final offsetX = (totalSize - logoWidth) ~/ 2;
  final offsetY = (totalSize - logoHeight) ~/ 2;

  for (int y = 0; y < logoHeight; y++) {
    for (int x = 0; x < logoWidth; x++) {
      final pixel = image.getPixel(minX + x, minY + y);
      newImage.setPixel(offsetX + x, offsetY + y, pixel);
    }
  }

  final outputPath = 'assets/images/splash_screen/logo_resized.png';
  File(outputPath).writeAsBytesSync(img.encodePng(newImage));
  print('Saved larger resized image (3% margin) to $outputPath');
}
